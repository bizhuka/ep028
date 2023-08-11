CLASS zcl_ep028_iaf DEFINITION PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
*    INTERFACES:
*      .

    TYPES:
      BEGIN OF ts_request,
        guid            TYPE zi_ep0298_iaf-guid,
        atta_id         TYPE zi_ep0298_iaf_attachment-atta_id,
        file_name       TYPE string,

        " create new one
        employee_id     TYPE zi_ep0298_iaf-employee_id,
        vacancy_id      TYPE zi_ep0298_iaf-vacancy_id,
        comments        TYPE zi_ep0298_iaf-comments,
        " TODO pass to IAF
        jprf_id         TYPE zc_ep028_vacancy_head-jprf_id, "zi_ep0298_iaf

        " result field
        response_iaf_id TYPE zi_ep0298_iaf-iaf_id,
      END OF ts_request.

    METHODS:
      create_new_iaf IMPORTING ir_request      TYPE REF TO ts_request
                     RETURNING VALUE(rv_error) TYPE string,

      get_request_from_slug IMPORTING iv_slug           TYPE string
                            RETURNING VALUE(rs_request) TYPE ts_request,

      get_request_from_struct IMPORTING is_filter         TYPE any
                              RETURNING VALUE(rs_request) TYPE ts_request,

      get_request_from_keys IMPORTING it_key_tab        TYPE /iwbep/t_mgw_name_value_pair
                            RETURNING VALUE(rs_request) TYPE ts_request,

      gos_action IMPORTING iv_guid        TYPE zi_ep0298_iaf-guid
                           iv_req_file_id TYPE csequence     OPTIONAL
                           is_ins_file    TYPE gos_s_attcont OPTIONAL
                           iv_del_file_id TYPE csequence     OPTIONAL
                 EXPORTING ev_error       TYPE string
                           et_files       TYPE gos_t_atta
                           es_res_file    TYPE gos_s_attcont.

  PRIVATE SECTION.
    METHODS _is_first_time IMPORTING iv_guid         TYPE zi_ep0298_iaf-guid
                           RETURNING VALUE(rv_first) TYPE abap_bool.
    METHODS _check_jprf_is_created IMPORTING is_request      TYPE zcl_ep028_iaf=>ts_request
                                   RETURNING VALUE(rv_error) TYPE string.
ENDCLASS.



CLASS ZCL_EP028_IAF IMPLEMENTATION.


  METHOD create_new_iaf.
    " Create 1 time. If there are several attachments called multiple times
    CHECK _is_first_time( ir_request->guid ) = abap_true.

    rv_error = _check_jprf_is_created( ir_request->* ).
    CHECK rv_error IS INITIAL.

    TRY.
        DATA(lo_model) = NEW zcl_hr204_iaf_model( ir_request->guid ).
        " TODO pass jprf_id to IAF
        lo_model->set_header( CORRESPONDING #( ir_request->* ) ).

        lo_model->check_save( ).
        lo_model->save( ).

        " Send for approval
        lo_model->wf_start( abap_true ).

        ir_request->response_iaf_id = lo_model->get_header( )-iaf_id.
      CATCH cx_root INTO DATA(lo_error).
        rv_error = lo_error->get_text( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_request_from_keys.
    LOOP AT it_key_tab ASSIGNING FIELD-SYMBOL(<ls_key>).
      ASSIGN COMPONENT <ls_key>-name OF STRUCTURE rs_request TO FIELD-SYMBOL(<lv_value>).
      <lv_value> = <ls_key>-value.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_request_from_slug.
    SPLIT iv_slug AT `|` INTO TABLE DATA(lt_pair).
    LOOP AT lt_pair INTO DATA(lv_pair).
      SPLIT lv_pair AT `:` INTO DATA(lv_key)
                                DATA(lv_value).

      ASSIGN COMPONENT lv_key OF STRUCTURE rs_request TO FIELD-SYMBOL(<lv_field>).
      ASSERT sy-subrc = 0.

      <lv_field> = lv_value.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_request_from_struct.
    rs_request = CORRESPONDING #( is_filter ).
  ENDMETHOD.


  METHOD gos_action.
    CLEAR: ev_error,
           et_files,
           es_res_file.

    DATA(ls_gos_key) = VALUE gos_s_obj(
      instid = '01' && iv_guid
      typeid = 'PDOTYPE_O'
      catid  = 'BO' ).

    TRY.
        DATA(lo_gos_api) = cl_gos_api=>create_instance( ls_gos_key ).

        " Get all files info
        IF et_files IS REQUESTED OR iv_req_file_id IS NOT INITIAL OR iv_del_file_id IS NOT INITIAL.
          et_files = lo_gos_api->get_atta_list( ).
        ENDIF.

        " Get 1 file content
        DO 1 TIMES.
          CHECK iv_req_file_id IS NOT INITIAL.

          ASSIGN et_files[ atta_id = iv_req_file_id ] TO FIELD-SYMBOL(<ls_file_info>).
          IF sy-subrc <> 0.
            ev_error = |File { iv_req_file_id } is not found!|.
          ELSE.
            es_res_file = lo_gos_api->get_al_item( CORRESPONDING #(  <ls_file_info> ) ).
          ENDIF.
        ENDDO.

        " Insert 1 file
        IF is_ins_file IS NOT INITIAL.
          lo_gos_api->insert_al_item(
               is_attcont =  is_ins_file
               iv_roltype =  cl_gos_api=>c_attachment ).
        ENDIF.

        " Delete 1 file
        DO 1 TIMES.
          CHECK iv_del_file_id IS NOT INITIAL.

          ASSIGN et_files[ atta_id = iv_del_file_id ] TO <ls_file_info>.
          IF sy-subrc <> 0.
            ev_error = |File { iv_del_file_id } is not found!|.
          ELSE.
            lo_gos_api->delete_al_item( CORRESPONDING #(  <ls_file_info> ) ).
          ENDIF.
        ENDDO.

      CATCH cx_gos_api INTO DATA(lo_error).
        ev_error = lo_error->get_text( ).
    ENDTRY.
  ENDMETHOD.


  METHOD _check_jprf_is_created.
    SELECT SINGLE iaf_id INTO @DATA(lv_iaf_id)   "#EC CI_NOFIELD
    FROM zdhr204_iaf_h
    WHERE employee_id = @is_request-employee_id
      AND vacancy_id  = @is_request-vacancy_id
      " TODO check status ?
    .

    CHECK lv_iaf_id IS NOT INITIAL.
    MESSAGE e006(zep_028) WITH lv_iaf_id INTO rv_error. "DATA(lv_error_message).
    " zcx_eui_no_check=>raise_sys_error( iv_message = lv_error_message ).
  ENDMETHOD.


  METHOD _is_first_time.
    DATA lt_new_items TYPE SORTED TABLE OF zi_ep0298_iaf-guid WITH UNIQUE KEY table_line.

    DATA(lv_memory_id) = CONV text70( |ZEP_028_204{ sy-uname }| ).
    TRY.
        IMPORT lt_new_items = lt_new_items
            FROM SHARED MEMORY indx(z4) ID lv_memory_id .
      CATCH cx_dynamic_check.
        CLEAR lt_new_items.
    ENDTRY.

    READ TABLE lt_new_items TRANSPORTING NO FIELDS
     WITH KEY table_line = iv_guid.
    rv_first = xsdbool( sy-subrc <> 0 ).

    " TODO clear by date
    INSERT iv_guid INTO TABLE lt_new_items.

    EXPORT lt_new_items = lt_new_items
        TO SHARED MEMORY indx(z4) ID lv_memory_id.
  ENDMETHOD.
ENDCLASS.
