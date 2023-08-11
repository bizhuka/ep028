CLASS zcl_v_ep028_create_by_jprf DEFINITION
  PUBLIC
  INHERITING FROM /bobf/cl_lib_v_supercl_simple
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS /bobf/if_frw_validation~execute REDEFINITION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_V_EP028_CREATE_BY_JPRF IMPLEMENTATION.


  METHOD /bobf/if_frw_validation~execute.
    " Called 2 times. Skip 1 of them
    CHECK is_ctx-val_time = 'CHECK_BEFORE_SAVE'.

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
      IF <ls_head>-node_data IS INITIAL.
        " create blank! @see zcl_d_ep028_create_by_jprf->_get_new_jprf_id
        CONTINUE.
      ENDIF.

      CHECK zcl_d_ep028_create_by_jprf=>is_based_on_jprf( <ls_head>-node_data ) = abap_true.

      DATA(lv_error_message) = ||.
      IF <ls_head>-jprf_id IS INITIAL.
        MESSAGE e003(zep_028) INTO lv_error_message.
      ELSEIF zcl_ep028_bopf_helper=>vacancy_exists( <ls_head>-jprf_id ).
        MESSAGE e001(zep_028) WITH <ls_head>-jprf_id INTO lv_error_message.
      ENDIF.

      CHECK lv_error_message IS NOT INITIAL.
      eo_message->add_message(
        iv_attribute = 'JPRF_ID'
        is_msg       = CORRESPONDING #( sy )
        iv_node      = is_ctx-node_key
        "iv_lifetime  = /bobf/cm_frw=>co_lifetime_state
        iv_key       = <ls_head>-key ).
      APPEND VALUE #( key = <ls_head>-key ) TO et_failed_key.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
