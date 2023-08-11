CLASS zcl_ep028_iaf_attachment DEFINITION PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES:
      zif_sadl_read_runtime,
      zif_sadl_stream_runtime,
      zif_sadl_delete_runtime.

    METHODS:
      constructor.

  PRIVATE SECTION.
    DATA:
      mo_iaf_util TYPE REF TO zcl_ep028_iaf.

    METHODS:
      _get_request_from_body IMPORTING iv_body           TYPE xstring
                             RETURNING VALUE(rs_request) TYPE zcl_ep028_iaf=>ts_request.
ENDCLASS.


CLASS zcl_ep028_iaf_attachment IMPLEMENTATION.
  METHOD constructor.
    mo_iaf_util = NEW #( ).
  ENDMETHOD.

  METHOD zif_sadl_read_runtime~execute.
    DATA(ls_request) = mo_iaf_util->get_request_from_struct( is_filter ).
    ASSERT ls_request-guid IS NOT INITIAL.

    " Based on GOS
    CLEAR ct_data_rows[].

    mo_iaf_util->gos_action( EXPORTING iv_guid    = ls_request-guid
                             IMPORTING ev_error   = DATA(lv_error)
                                       et_files   = DATA(lt_files) ).
    IF lv_error IS NOT INITIAL.
      TRY.
          zcx_eui_exception=>raise_sys_error( iv_message = lv_error ).
        CATCH zcx_eui_exception INTO DATA(lo_eui_exception).
          RAISE EXCEPTION TYPE cx_sadl_static EXPORTING previous = lo_eui_exception.
      ENDTRY.
    ENDIF.

    SORT lt_files BY cr_date DESCENDING
                    cr_time DESCENDING.
    LOOP AT lt_files ASSIGNING FIELD-SYMBOL(<ls_flie>).
      APPEND INITIAL LINE TO ct_data_rows ASSIGNING FIELD-SYMBOL(<ls_item>).
      MOVE-CORRESPONDING: ls_request TO <ls_item>, " <--- Fill guid only
                          <ls_flie>  TO <ls_item>.
    ENDLOOP.

    "cv_number_all_hits = lines( ct_data_rows ).
  ENDMETHOD.

  METHOD zif_sadl_stream_runtime~get_stream.
    DATA(ls_request) = mo_iaf_util->get_request_from_keys( it_key_tab ).
    mo_iaf_util->gos_action( EXPORTING iv_guid        = ls_request-guid
                                       iv_req_file_id = ls_request-atta_id
                             IMPORTING ev_error       = DATA(lv_error)
                                       es_res_file    = DATA(ls_res_file) ).
    IF lv_error IS NOT INITIAL.
      TRY.
          zcx_eui_exception=>raise_sys_error( iv_message = lv_error ).
        CATCH zcx_eui_exception INTO DATA(lo_eui_exception).
          RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception EXPORTING previous = lo_eui_exception.
      ENDTRY.
    ENDIF.

    DATA(lv_mime_type) = |application/binary|.
    io_srv_runtime->set_header(
         VALUE #( name  = 'Content-Disposition'
                  value = |outline; filename="{ escape( val    = ls_res_file-descr
                                                        format = cl_abap_format=>e_url ) }"| ) ).
    " Any binary file
    er_stream = NEW /iwbep/cl_mgw_abs_data=>ty_s_media_resource(
      value     = ls_res_file-content_x
      mime_type = lv_mime_type ).
  ENDMETHOD.

  METHOD _get_request_from_body.
    /ui2/cl_json=>deserialize( EXPORTING jsonx = iv_body
                               CHANGING  data  = rs_request ).
  ENDMETHOD.

  METHOD zif_sadl_stream_runtime~create_stream.
    DATA(ls_request) = COND #( WHEN iv_slug IS NOT INITIAL
                               THEN mo_iaf_util->get_request_from_slug( iv_slug )

                               WHEN is_media_resource-mime_type = 'application/json' " <-- Without attachment
                               THEN _get_request_from_body( is_media_resource-value ) ).
    ASSERT ls_request IS NOT INITIAL.

    DATA(lv_error) = ||.
    IF ls_request-employee_id IS NOT INITIAL.
      lv_error = mo_iaf_util->create_new_iaf( REF #( ls_request ) ).
    ENDIF.

    IF lv_error IS NOT INITIAL.
      CLEAR ls_request-file_name.
    ENDIF.

    DO 1 TIMES.
      CHECK ls_request-file_name IS NOT INITIAL.

      DATA(ls_atta_content) = VALUE gos_s_attcont(
        filename  = ls_request-file_name
        descr     = ls_request-file_name
        atta_cat  = cl_gos_api=>c_msg

        content_x = is_media_resource-value
        filesize  = xstrlen( is_media_resource-value )
        tech_type = is_media_resource-mime_type

        cr_date   = sy-datum
        cr_time   = sy-uzeit
        cr_user   = sy-uname
        lang      = sy-langu ).

      " Add new file to existing
      mo_iaf_util->gos_action( EXPORTING iv_guid     = ls_request-guid
                                         is_ins_file = ls_atta_content
                               IMPORTING ev_error    = lv_error ).
    ENDDO.

    IF lv_error IS NOT INITIAL.
      er_entity = NEW zi_ep0298_iaf_attachment(
        guid     = ls_request-guid
        message  = lv_error
        is_error = abap_true ).
      RETURN.
*      TRY. zcx_eui_exception=>raise_sys_error( iv_message = lv_error ).
*        CATCH zcx_eui_exception INTO DATA(lo_eui_exception). RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception EXPORTING previous = lo_eui_exception.
*      ENDTRY.
    ENDIF.

    DATA(ls_cds_entity) = CORRESPONDING zi_ep0298_iaf_attachment( ls_atta_content ).
    ls_cds_entity-guid    = ls_request-guid.
    ls_cds_entity-message = COND #(
         WHEN ls_request-response_iaf_id IS NOT INITIAL THEN |The IAF request { ls_request-response_iaf_id } is successfully created|
         WHEN ls_request-file_name       IS NOT INITIAL THEN |File { ls_request-file_name } is successfully uploaded| ).

    IF ls_cds_entity-message IS INITIAL.
      ls_cds_entity-message  = |No action is executed|.
      ls_cds_entity-is_error = abap_true.
    ENDIF.

    er_entity = NEW zi_ep0298_iaf_attachment( ls_cds_entity ).

    COMMIT WORK AND WAIT.
  ENDMETHOD.

  METHOD zif_sadl_delete_runtime~execute.
    LOOP AT it_key_values ASSIGNING FIELD-SYMBOL(<ls_item>).
      DATA(ls_item) = CORRESPONDING zi_ep0298_iaf_attachment( <ls_item> ).

      mo_iaf_util->gos_action( EXPORTING iv_guid        = ls_item-guid
                                         iv_del_file_id = ls_item-atta_id
                               IMPORTING ev_error       = DATA(lv_error) ).

      IF lv_error IS NOT INITIAL.
        TRY.
            zcx_eui_exception=>raise_sys_error( iv_message = lv_error ).
          CATCH zcx_eui_exception INTO DATA(lo_eui_exception).
            RAISE EXCEPTION TYPE cx_sadl_static EXPORTING previous = lo_eui_exception.
        ENDTRY.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
