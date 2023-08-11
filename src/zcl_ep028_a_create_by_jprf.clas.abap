class zcl_ep028_a_create_by_jprf definition
  public
  inheriting from /bobf/cl_lib_a_superclass
  final
  create public .

  public section.

    methods /bobf/if_frw_action~execute
        redefinition .

  protected section.

  private section.
endclass.



class zcl_ep028_a_create_by_jprf implementation.


  method /bobf/if_frw_action~execute.
    data(l_key) = /bobf/cl_frw_factory=>get_new_key( ).
    data lt_mod type /bobf/t_frw_modification.

    field-symbols: <ls_params> type zss_ep028_ap_create_by_jprf.
    assign is_parameters->* to <ls_params>.
    check sy-subrc = 0.

    data(ls_root_data) = zcl_ep028_bopf_helper=>get_iv_data_by_jprf( <ls_params>-jprf_id ).

    append initial line to lt_mod assigning field-symbol(<ls_mod>).
    <ls_mod>-key = l_key.
    <ls_mod>-change_mode = 'C'.
    <ls_mod>-root_key = l_key.
    <ls_mod>-node = zif_ep028_bopf_vacancy_c=>sc_node-root.
    <ls_mod>-data = ref #( ls_root_data ).
    zcl_ep028_bopf_helper=>mo_bopf->modify(
      exporting
        it_modification = lt_mod                 " Changes
      importing
        "eo_change       =                  " Interface of Change Object
        eo_message      = data(lo_message)
    ).
    zcl_ep028_bopf_helper=>get_message_container( )->add( lo_message ).
    "r_result = m_key.
    if lo_message is bound and lo_message->check( ).
      " Errors
      append value #( key = l_key ) to et_failed_key.
    else.
      data(lt_new_data) = value ztt_ep028_vacancy( ).
      zcl_ep028_bopf_helper=>mo_bopf->retrieve(
        exporting
          iv_node_key             = zif_ep028_bopf_vacancy_c=>sc_node-root                                   " Node
          it_key                  = value #( ( key = l_key ) )
        importing
          et_data                 = lt_new_data
      ).
      et_data = lt_new_data.
      "zcl_ep028_bopf_helper=>mo_trx->save
    endif.

  endmethod.


endclass.
