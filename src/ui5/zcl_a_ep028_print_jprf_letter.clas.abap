CLASS zcl_a_ep028_print_jprf_letter DEFINITION PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES:
      zif_sadl_stream_runtime.

  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_a_ep028_print_jprf_letter IMPLEMENTATION.
  METHOD zif_sadl_stream_runtime~get_stream.
    TYPES: BEGIN OF ts_key,
             jprf_id TYPE zi_ep0298_a_print_jprf_letter-jprf_id,
           END OF ts_key.

    DATA(ls_key) = VALUE ts_key( ).
    LOOP AT it_key_tab ASSIGNING FIELD-SYMBOL(<ls_key>).
      ASSIGN COMPONENT <ls_key>-name OF STRUCTURE ls_key TO FIELD-SYMBOL(<lv_value>).
      <lv_value> = <ls_key>-value.
    ENDLOOP.
    ASSERT ls_key-jprf_id IS NOT INITIAL.


    DATA(lo_form) = NEW zcl_hr013_jprf( im_objid = ls_key-jprf_id
                                        im_mode  = zcl_hr013_jprf=>c_mode-display ).
    DATA(ls_print_form) = lo_form->get_print_form_data( ).

    DATA(lv_mime_type) = |application/vnd.openxmlformats-officedocument.wordprocessingml.document|.
    io_srv_runtime->set_header(
         VALUE #( name  = 'Content-Disposition'
                  value = |outline; filename="ZR_HR013_JPRF_LET.DOCX"| ) ).

    " Send word
    er_stream = NEW /iwbep/cl_mgw_abs_data=>ty_s_media_resource(
      value     = lo_form->print_letter( ls_print_form )->get_raw( )
      mime_type = lv_mime_type ).
  ENDMETHOD.

  METHOD zif_sadl_stream_runtime~create_stream.

  ENDMETHOD.
ENDCLASS.
