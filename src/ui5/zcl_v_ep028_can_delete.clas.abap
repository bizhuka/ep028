CLASS zcl_v_ep028_can_delete DEFINITION PUBLIC
  INHERITING FROM /bobf/cl_lib_v_supercl_simple
  FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS /bobf/if_frw_validation~execute REDEFINITION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_v_ep028_can_delete IMPLEMENTATION.
  METHOD /bobf/if_frw_validation~execute.
    " Obsolete
    CHECK is_ctx-val_time = 'CHECK'.
    IF eo_message IS INITIAL.
      eo_message = /bobf/cl_frw_factory=>get_message( ).
    ENDIF.

    DATA(lt_head) = VALUE ztcep028_vacancy_head( ).
    io_read->retrieve(
      EXPORTING iv_node       = is_ctx-node_key
                it_key        = it_key
                iv_fill_data  = abap_true
      IMPORTING et_data       = lt_head ).

    LOOP AT lt_head ASSIGNING FIELD-SYMBOL(<ls_head>) WHERE status <> zcl_ep028_head=>ms_status-draft.
      MESSAGE e004(zep_028) WITH <ls_head>-jprf_id <ls_head>-status INTO sy-msgli.

      eo_message->add_message(
        iv_attribute = 'STATUS'
        is_msg       = CORRESPONDING #( sy )
        iv_node      = is_ctx-node_key
        iv_key       = <ls_head>-key ).
      APPEND VALUE #( key = <ls_head>-key ) TO et_failed_key.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
