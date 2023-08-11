CLASS zcl_v_ep028_structure_check DEFINITION PUBLIC
  INHERITING FROM /bobf/cl_lib_v_supercl_simple
  FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS:
      constructor,
      /bobf/if_frw_validation~execute REDEFINITION.

  PRIVATE SECTION.
    TYPES:
       tt_fieldname TYPE SORTED TABLE OF ddfieldname_l WITH UNIQUE KEY table_line.

    DATA:
      mv_datum            TYPE d,
      mt_obligatory_field TYPE tt_fieldname,
      mo_message          TYPE REF TO /bobf/if_frw_message,
      mr_failed_key       TYPE REF TO /bobf/t_frw_key.

    METHODS:
      _get_obligatory IMPORTING iv_cds               TYPE /bobf/obm_name
                                it_fieldname         TYPE tt_fieldname OPTIONAL
                      RETURNING VALUE(rt_obligatory) TYPE tt_fieldname,

      _check_obligatory    IMPORTING is_head         TYPE zscep028_vacancy_head,
      _check_org_structure IMPORTING is_head         TYPE zscep028_vacancy_head,
      _check_grade         IMPORTING is_head         TYPE zscep028_vacancy_head,

      _add_message        IMPORTING iv_key       TYPE /bobf/conf_key
                                    is_msg       TYPE symsg
                                    iv_attribute TYPE string OPTIONAL,

      _is_num IMPORTING iv_grade         TYPE zc_ep028_vacancy_head-grade
              RETURNING VALUE(rv_is_num) TYPE abap_bool.
ENDCLASS.



CLASS zcl_v_ep028_structure_check IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    mv_datum            = sy-datum.
    mt_obligatory_field = _get_obligatory( iv_cds = 'ZC_EP028_VACANCY_HEAD' ).
  ENDMETHOD.

  METHOD /bobf/if_frw_validation~execute.
    " Called 2 times. Skip 1 of them
    CHECK is_ctx-val_time = 'CHECK_BEFORE_SAVE'
*      AND sy-uname <> 'MOLDAB'
    .

    IF eo_message IS INITIAL.
      eo_message = /bobf/cl_frw_factory=>get_message( ).
    ENDIF.
    mo_message    = eo_message.
    mr_failed_key = REF #( et_failed_key ).

    DATA(lt_head) = VALUE ztcep028_vacancy_head( ).
    io_read->retrieve(
      EXPORTING iv_node       = is_ctx-node_key
                it_key        = it_key
                iv_fill_data  = abap_true
      IMPORTING et_data       = lt_head ).

    LOOP AT lt_head ASSIGNING FIELD-SYMBOL(<ls_head>).
      " Create blank button?
      CHECK <ls_head>-node_data IS NOT INITIAL.

      " Create by JPRF ?
      CHECK zcl_d_ep028_create_by_jprf=>is_based_on_jprf( <ls_head>-node_data ) <> abap_true.

      _check_obligatory( <ls_head> ).
      _check_org_structure( <ls_head> ).
      _check_grade( <ls_head> ).
      " TODO add checks from ZCL_HR013_JPRF=>SAVE( )
    ENDLOOP.
  ENDMETHOD.

  METHOD _check_grade.
    CHECK _is_num( is_head-grade ) = abap_true
      AND _is_num( is_head-grad2 ) = abap_true.

    CHECK is_head-grade > is_head-grad2.
    MESSAGE e009(zep_028) WITH is_head-grade is_head-grad2 INTO sy-msgli.
    _add_message( iv_key       = is_head-key
                  is_msg       = CORRESPONDING #( sy )
                  iv_attribute = 'GRAD2' ).
  ENDMETHOD.

  METHOD _is_num.
    DATA(lv_number) = |{ iv_grade }|.
    REPLACE ALL OCCURRENCES OF REGEX '[^(0-9.,)]' IN lv_number WITH ''.
    rv_is_num = xsdbool( iv_grade IS NOT INITIAL AND lv_number = iv_grade ).
  ENDMETHOD.

  METHOD _get_obligatory.
    rt_obligatory = it_fieldname[].

    SELECT attribute_name APPENDING TABLE @rt_obligatory
    FROM /bobf/obm_propty
    WHERE name           EQ @iv_cds
      AND property_name  EQ 'M' AND property_value EQ 'X' " Mandatory
      AND extension      EQ ''
      AND version        EQ 00000.
    IF sy-subrc <> 0.
      " Read annotations
      SELECT lfieldname APPENDING TABLE @rt_obligatory
      FROM ddfieldanno
      WHERE strucobjn EQ @iv_cds
        AND name      EQ 'OBJECTMODEL.MANDATORY'
        AND value     EQ 'true'.
    ENDIF.
  ENDMETHOD.

  METHOD _check_obligatory.
    LOOP AT mt_obligatory_field ASSIGNING FIELD-SYMBOL(<lv_field>).
      ASSIGN COMPONENT <lv_field> OF STRUCTURE is_head TO FIELD-SYMBOL(<lv_value>).
      CHECK <lv_value> IS INITIAL.

      MESSAGE e007(zep_028) WITH <lv_field> INTO sy-msgli.
      _add_message( iv_key       = is_head-key
                    is_msg       = CORRESPONDING #( sy )
                    iv_attribute = CONV #( <lv_field> ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD _check_org_structure.
    CHECK is_head-pos_id IS NOT INITIAL.

    DATA(lv_department) = zcl_hr_om_utilities=>find_hlevel(
      im_otype  = 'S'
      im_objid  = is_head-pos_id
      im_datum  = mv_datum
      im_wegid  = 'ZS-O-O'
      im_hlevel = 'DEPARTMENT' ).
    DATA(lv_directorate) = zcl_hr_om_utilities=>find_hlevel(
      im_otype  = 'S'
      im_objid  = is_head-pos_id
      im_datum  = mv_datum
      im_wegid  = 'ZS-O-O'
      im_hlevel = 'DIRECTORATE' ).

    IF is_head-department <> lv_department.
      MESSAGE e008(zep_028) WITH 'Department' is_head-pos_id INTO sy-msgli.
      _add_message( iv_key       = is_head-key
                    is_msg       = CORRESPONDING #( sy )
                    iv_attribute = 'DEPARTMENT' ).
    ENDIF.

    IF is_head-directorate <> lv_directorate.
      MESSAGE e008(zep_028) WITH 'Directorate' is_head-pos_id INTO sy-msgli.
      _add_message( iv_key       = is_head-key
                    is_msg       = CORRESPONDING #( sy )
                    iv_attribute = 'DIRECTORATE' ).
    ENDIF.

    CHECK is_head-job_id IS NOT INITIAL.

    SELECT SINGLE @abap_true INTO @DATA(lv_found)
    FROM hrp1001
    WHERE otype   EQ 'S'
      AND objid   EQ @is_head-pos_id
      AND plvar   EQ '01'
      AND rsign   EQ 'B'
      AND relat   EQ '007'
*      AND istat   EQ '1'
      AND begda   LE @mv_datum
      AND endda   GE @mv_datum
      AND sclas   EQ 'C'
      AND sobid   EQ @is_head-job_id.
    CHECK lv_found <> abap_true.

    MESSAGE e008(zep_028) WITH 'Job' is_head-pos_id INTO sy-msgli.
    _add_message( iv_key       = is_head-key
                  is_msg       = CORRESPONDING #( sy )
                  iv_attribute = 'job_id' ).
  ENDMETHOD.

  METHOD _add_message.
    mo_message->add_message(
      iv_attribute = iv_attribute
      is_msg       = is_msg
      iv_node      = zif_c_ep028_vacancy_head_c=>sc_node-zc_ep028_vacancy_head " is_ctx-node_key
      "iv_lifetime  = /bobf/cm_frw=>co_lifetime_state
      iv_key       = iv_key ).

    APPEND VALUE #( key = iv_key ) TO mr_failed_key->*.
    SORT mr_failed_key->* BY key.
    DELETE ADJACENT DUPLICATES FROM mr_failed_key->* COMPARING key.
  ENDMETHOD.
ENDCLASS.
