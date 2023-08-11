CLASS zcl_d_ep028_create_by_jprf DEFINITION PUBLIC
  INHERITING FROM /bobf/cl_lib_d_supercl_simple
  FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS /bobf/if_frw_determination~execute REDEFINITION.

    CLASS-METHODS:
      fill_from_jprf   CHANGING cs_new_vacancy TYPE zscep028_vacancy_head_d,

      is_based_on_jprf IMPORTING is_vacancy    TYPE zscep028_vacancy_head_d
                       RETURNING VALUE(rv_yes) TYPE abap_bool.

  PRIVATE SECTION.
    METHODS _get_new_jprf_id
      RETURNING
        VALUE(rv_jprf_id) TYPE zscep028_vacancy_head-jprf_id.

ENDCLASS.



CLASS zcl_d_ep028_create_by_jprf IMPLEMENTATION.
  METHOD /bobf/if_frw_determination~execute.
    IF eo_message IS INITIAL.
      eo_message = /bobf/cl_frw_factory=>get_message( ).
    ENDIF.

    DATA(lt_head) = VALUE ztcep028_vacancy_head( ).
    io_read->retrieve(
      EXPORTING iv_node       = is_ctx-node_key
                it_key        = it_key
                iv_fill_data  = abap_true
      IMPORTING et_data       = lt_head ).

    LOOP AT lt_head ASSIGNING FIELD-SYMBOL(<ls_head>).
      DATA(lt_fileds) = VALUE /bobf/t_frw_name( ).

      IF <ls_head>-node_data IS INITIAL.
        <ls_head>-jprf_id       = _get_new_jprf_id( ).
        <ls_head>-vacancy_descr = |New vacancy { <ls_head>-jprf_id }|.
        lt_fileds = VALUE #( ( |JPRF_ID| )     ( |VACANCY_DESCR| )
                             ( |UPDATE_USER| ) ( |UPDATE_DATE_TIME| ) ).

      ELSEIF is_based_on_jprf( <ls_head>-node_data ) = abap_true.
        fill_from_jprf( CHANGING cs_new_vacancy = <ls_head>-node_data ).

      ELSE.
        lt_fileds = VALUE #( ( |UPDATE_USER| ) ( |UPDATE_DATE_TIME| ) ).
      ENDIF.

      " Tech. info
      <ls_head>-update_user = sy-uname.
      GET TIME STAMP FIELD <ls_head>-update_date_time.

*      IF <ls_head>-create_user IS INITIAL
*        <ls_head>-create_user = sy-uname.
*        GET TIME STAMP FIELD <ls_head>-create_date_time.
*      ENDIF.

      " Send to BOPF
      io_modify->update( iv_node           = is_ctx-node_key
                         iv_key            = <ls_head>-key
                         is_data           = REF #( <ls_head> )
                         it_changed_fields = lt_fileds ).
    ENDLOOP.
  ENDMETHOD.

  METHOD _get_new_jprf_id.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = 'IN'
        object      = 'RP_PLAN'
        subobject   = '$$$$'
      IMPORTING
        number      = rv_jprf_id
      EXCEPTIONS
        OTHERS      = 0.
  ENDMETHOD.

  METHOD is_based_on_jprf.
    " Only 4 fields are visible
    DATA(ls_popup_item) = is_vacancy.
    CLEAR: ls_popup_item-jprf_id,
           ls_popup_item-hr_repr,
           ls_popup_item-comments,
           ls_popup_item-status.

    " Yes new item based on JPRF
    rv_yes = xsdbool( ls_popup_item IS INITIAL ).
  ENDMETHOD.

  METHOD fill_from_jprf.
    DATA(lv_datum) = sy-datum.

    SELECT SINGLE posid AS pos_id, jobid AS job_id INTO CORRESPONDING FIELDS OF @cs_new_vacancy
    FROM zi_ep028_vacancy_hr_data
    WHERE jprfid    = @cs_new_vacancy-jprf_id
      AND posbegda <= @lv_datum
      AND posendda >= @lv_datum
      AND jobbegda <= @lv_datum
      AND jobendda >= @lv_datum.

    DATA(lo_jprf) = NEW zcl_hr013_jprf(
      im_mode  = '3'
      im_objid = cs_new_vacancy-jprf_id ).

    DATA(ls_jprf_data) = lo_jprf->get_view_data( ).
    ASSIGN ls_jprf_data-position_table[ 1 ] TO FIELD-SYMBOL(<ls_pos>).
    IF sy-subrc = 0.
      cs_new_vacancy-pos_id = <ls_pos>-plans.
      cs_new_vacancy-job_id = zcl_hr_om_utilities=>get_job_for_position( im_objid = cs_new_vacancy-pos_id ).
    ENDIF.

    cs_new_vacancy-vacancy_descr   = ls_jprf_data-posit.
    cs_new_vacancy-department      = ls_jprf_data-department.
    cs_new_vacancy-department_name = ls_jprf_data-department_txt.

    cs_new_vacancy-directorate = zcl_hr_om_utilities=>find_hlevel(
        iv_orgeh       = ls_jprf_data-department
        "im_objid       = cs_new_vacancy-pos_id
        "im_otype       = 'S'              " Object Type
        im_datum       = lv_datum                 " Start Date
        im_hlevel      = 'DIRECTORATE'
    ).
    cs_new_vacancy-directorate_name = zcl_hr_om_utilities=>get_object_full_name(
       im_otype = 'O'
       im_objid = cs_new_vacancy-directorate
    ).

    "cs_new_vacancy-link_job_descr = lo_jprf->mv_job_descr.
    SELECT SINGLE job_description INTO @cs_new_vacancy-link_job_descr
    FROM hrp9001
    WHERE otype  = 'C'
      AND plvar  = '01'
      AND objid  = @cs_new_vacancy-job_id
      AND begda <= @lv_datum
      AND endda >= @lv_datum
      AND istat  = '1'.

    CASE abap_true.
      WHEN ls_jprf_data-pnew OR ls_jprf_data-prepl.
        cs_new_vacancy-vacancy_type = 'PERM'.
      WHEN ls_jprf_data-trepl.
        cs_new_vacancy-vacancy_type = 'TEMP'.
      WHEN ls_jprf_data-prnew OR ls_jprf_data-prrep.
        cs_new_vacancy-vacancy_type = 'PROJ'.
    ENDCASE.

    cs_new_vacancy-comp_slot  = ls_jprf_data-cmpn.
    cs_new_vacancy-work_sched = ls_jprf_data-wkptr.

    " From to
    cs_new_vacancy-grade      = ls_jprf_data-grade.
    cs_new_vacancy-grad2      = ls_jprf_data-grad2.

    zcl_hr013_jprf=>get_data(
      EXPORTING im_plvar = '01'
                im_otype = 'ZJ'
                im_objid = cs_new_vacancy-jprf_id
                im_datum = lv_datum
      IMPORTING ex_p9005 = DATA(ls_9005) ).

    cs_new_vacancy-location   = `#` && ls_9005-persa.
    " № 1 - From text to id
    SELECT SINGLE persa INTO @cs_new_vacancy-location
    FROM zc_py000_personnelarea
    WHERE name1 = @ls_9005-persa.

    cs_new_vacancy-subarea = `#` && ls_9005-btrtl.
    " № 2 - From text to id
    SELECT SINGLE btrtl INTO @cs_new_vacancy-subarea
    FROM zc_py000_personnelsubarea
    WHERE btext = @ls_9005-btrtl
      AND persa = @cs_new_vacancy-location.
  ENDMETHOD.
ENDCLASS.
