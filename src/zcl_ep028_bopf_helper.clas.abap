class zcl_ep028_bopf_helper definition
  public
  final
  create public .

  public section.
    class-methods: get_iv_data_by_jprf importing i_jprf_id        type hrobjid

                                       returning value(rs_result) type zss_ep028_vacancy.

    class-methods: class_constructor.
    class-methods: save_vacancy importing i_key    type /bobf/conf_key optional
                                          i_commit type abap_bool default abap_false,
      get_message_container
        returning
          value(r_result) type ref to /bobf/if_frw_message .
    class-data mo_bopf type ref to /bobf/if_frw_service_layer read-only.

    class-methods: create_new_vacancy importing i_jprf          type hrobjid
                                                i_no_check_jprf type abap_bool default abap_false
                                      returning value(r_result) type /bobf/conf_key
                                      raising
                                                zcx_ep028_error.
    "
    class-methods: set_vacancy_data importing i_key   type /bobf/conf_key
                                              is_data type zss_ep028_vacancy.
    class-methods: call_internal_posting_dialog importing i_jprf type hrobjid,
      vacancy_exists
        importing
                  i_jprf          type hrobjid
        returning value(r_result) type abap_bool.
    class-methods: call_iaf_creation importing i_position type hrobjid i_uname type syuname default sy-uname.
    class-methods: get_all_vacancies exporting et_vacancies type ztt_ep028_vacancy.
  protected section.

    class-data: mo_trx type ref to /bobf/if_tra_transaction_mgr .
    class-data:  mo_message type ref to /bobf/if_frw_message  .

  private section.

ENDCLASS.



CLASS ZCL_EP028_BOPF_HELPER IMPLEMENTATION.


  method call_iaf_creation.
    data lv_absolute_url type string.
    data lv_url                type char255.
    data ls_parameter    type ihttpnvp.
    data lt_parameters   type tihttpnvp.

* Assemble the parameter name/value pairs as needed
    ls_parameter-name  = 'POSITION'.
    ls_parameter-value  = i_position.
    append ls_parameter to lt_parameters.

* construct the url with parameters
    cl_wd_utilities=>construct_wd_url(
        exporting
            application_name = 'ZWDA_HR204_IAF_EMPLOYEE'
            in_parameters      = lt_parameters
            importing
            out_absolute_url = lv_absolute_url
    ).

    lv_url = lv_absolute_url. " cast data type

    call function 'CALL_BROWSER'
      exporting
        url         = lv_url
        window_name = 'Internal Application'
        new_window  = abap_false
      exceptions
        others      = 0.

  endmethod.


  method call_internal_posting_dialog.
    data lv_absolute_url type string.
    data lv_url                type char255.
    data ls_parameter    type ihttpnvp.
    data lt_parameters   type tihttpnvp.

* Assemble the parameter name/value pairs as needed
    ls_parameter-name  = 'JPRF_ID'.
    ls_parameter-value  = i_jprf.
    append ls_parameter to lt_parameters.

    ls_parameter-name  = 'MODE'.
    ls_parameter-value  = 'C'.
    append ls_parameter to lt_parameters.

* construct the url with parameters
    cl_wd_utilities=>construct_wd_url(
        exporting
            application_name = 'ZWDA_EP028_VACANCY_CRE'
            in_parameters      = lt_parameters
            importing
            out_absolute_url = lv_absolute_url
    ).

    lv_url = lv_absolute_url. " cast data type

    call function 'CALL_BROWSER'
      exporting
        url         = lv_url
        window_name = 'Internal Posting'
        new_window  = abap_true
      exceptions
        others      = 0.
  endmethod.


  method class_constructor.
    try.
        mo_bopf = /bobf/cl_frw_factory=>get_bopf(
                    iv_bo_key   = zif_ep028_bopf_vacancy_c=>sc_bo_key ).
      catch /bobf/cx_frw.
        "handle exception
    endtry.
    "mo_slave_transaction_manager = /bobf/cl_tra_trans_mgr_factory=>get_slave_transaction_manager( ).
    mo_trx = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).
    mo_message = get_message_container( ).
  endmethod.


  method create_new_vacancy.
    mo_message = get_message_container( ).
    data ls_param type zss_ep028_ap_create_by_jprf.
    ls_param-jprf_id = i_jprf.

    if i_no_check_jprf = abap_false.
      if vacancy_exists( i_jprf ).
        message e001(zep_028) with i_jprf into data(dummy).

        mo_message->add_message(
          exporting
            is_msg       = corresponding #( sy )
            iv_node      = zif_ep028_bopf_vacancy_c=>sc_node-root
            iv_key       = ``
        ).
      endif.

      if mo_message->check( ).
        data(lx_error) = new zcx_ep028_error( io_message = mo_message ).
        raise exception lx_error.
        "raise exception type zcx_ep028_error message .
      endif.

    endif.

    data lt_created_objects type ztt_ep028_vacancy.
    mo_bopf->do_action(
      exporting
        is_action     = value #(
            act_key = zif_ep028_bopf_vacancy_c=>sc_action-root-create_by_jprf
            parameters = ref #( ls_param )
            )

      importing
        eo_message    = data(lo_messages)
        et_failed_key = data(lt_failed_keys)
        et_data = lt_created_objects

    )..
    read table lt_created_objects assigning field-symbol(<ls_created>) index 1.
    r_result = <ls_created>-key.

    if lo_messages is bound.
      get_message_container( )->add( lo_messages ).
    endif.

    if mo_message->check( ).
      lx_error = new zcx_ep028_error( io_message = mo_message ).
      raise exception lx_error.
      "raise exception type zcx_ep028_error message .
    endif.
  endmethod.


  method get_all_vacancies.
    select * from zdep028_vac_h into corresponding fields of table @et_vacancies. "#EC "#EC CI_NOWHERE
  endmethod.


  method get_iv_data_by_jprf.

    DATA(ls_new_vacancy) = VALUE zscep028_vacancy_head_d( jprf_id = i_jprf_id ).
    zcl_d_ep028_create_by_jprf=>fill_from_jprf( CHANGING cs_new_vacancy = ls_new_vacancy ).

    rs_result = CORRESPONDING #( ls_new_vacancy ).
  endmethod.


  method get_message_container.

    if mo_message is not bound.
      mo_message = /bobf/cl_frw_factory=>get_message( ).
    endif.
    r_result = mo_message.
  endmethod.


  method save_vacancy.
    mo_bopf->finalize( ).

    data lt_roots_for_save type /bobf/t_frw_key .
    if i_key is supplied and i_key is not initial.
      lt_roots_for_save = value #( ( key = i_key ) ).
    endif.
    mo_bopf->check_before_save(
      exporting
        it_root_key = lt_roots_for_save
      importing
        eo_message  = data(lo_message)
        ev_rejected = data(l_rej)                 " Action rejected
    ).
    get_message_container( )->add( lo_message ).

    if l_rej = abap_true.
      message e109(zep_train_booking) into data(dummy).
      try.
          zcx_sy=>raise( is_symsg = corresponding #( sy ) ).
        catch zcx_sy.
          "handle exception
      endtry.
    endif.
    check l_rej = abap_false.


    mo_bopf->adjust_numbers(
      exporting
        it_root_key = lt_roots_for_save
      importing
        eo_message  = lo_message
        eo_change = data(lo_num_change)
        et_adjusted_numbers = data(lt_adj_numbers)                 " Adjusted Numbers
    ).
    get_message_container( )->add( lo_message ).

    check mo_message->check( ) = abap_false.

    mo_bopf->on_numbers_adjusted(
      exporting
        it_root_key         = lt_roots_for_save
        it_adjusted_numbers = lt_adj_numbers
      importing
        eo_message          = lo_message
        eo_change           = lo_num_change
    ).
    get_message_container( )->add( lo_message ).

    check mo_message->check( ) = abap_false.

    mo_bopf->do_save(
    exporting
      it_root_key = lt_roots_for_save
    importing
      eo_message  = lo_message

      ev_rejected = l_rej                 " Save rejected
  ).

    get_message_container( )->add( lo_message ).

    check l_rej = abap_false and ( mo_message->check( ) = abap_false ).

    mo_bopf->after_successful_save(
      exporting
        it_root_key = lt_roots_for_save
      importing
        eo_message  = lo_message
        eo_change   = lo_num_change
    ).
    get_message_container( )->add( lo_message ).

    mo_trx->save(
    exporting
    iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
       importing ev_rejected =  data(l_was_rejected)
                 eo_message  =  lo_message
                 eo_change = data(lo_change_tx) ).
    get_message_container( )->add( lo_message ).

    if l_was_rejected = abap_false.
      message s004(ztv_021_dar).
    endif.

    mo_bopf->after_successful_save( lt_roots_for_save  ).

    if i_commit = abap_true.
      commit work and wait.
    endif.

    message s005(zep_train_booking).
    get_message_container( )->add_message( is_msg = corresponding #( sy ) ).

  endmethod.


  method set_vacancy_data.
    data:  lt_modification type /bobf/t_frw_modification.
    data(ls_data) = is_data.
    append initial line to lt_modification assigning field-symbol(<ls_mod>).
    <ls_mod>-key = i_key.
    <ls_mod>-change_mode = 'U'.
    <ls_mod>-data = ref #( ls_data ).
    <ls_mod>-node = zif_ep028_bopf_vacancy_c=>sc_node-root.
    mo_bopf->modify(
      exporting
        it_modification = lt_modification
  importing
*    eo_change       =                  " Change Object
        eo_message      = data(lo_message)                 " Message Object
    ).
  endmethod.


  method vacancy_exists.

    select single @abap_true from zdep028_vac_h into @r_result where jprf_id = @i_jprf. "#EC "#EC CI_NOFIELD


  endmethod.
ENDCLASS.
