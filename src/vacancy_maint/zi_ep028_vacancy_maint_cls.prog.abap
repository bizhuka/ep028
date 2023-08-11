*&---------------------------------------------------------------------*
*&  Include  zi_ep028_vacancy_maint_cls
*&---------------------------------------------------------------------*

class lcl_controller definition.
  public section.
    types: begin of ts_salv.
             include type zss_ep028_vacancy.
           types:
                  end of ts_salv.
    "types: tt_rng_stage type range of zde_ep029_appr_stage.
    types: tt_salv type standard table of ts_salv with empty key.
    types: begin of ts_selection,
             status        type range of zde_ep028_vacancy_status,
             objid         type range of zdep028_vac_h-jprf_id,
             perm_kept_pos type range of zdep028_vac_h-pos_id,
             job           type range of zdep028_vac_h-job_id,
             dep           type range of zdep028_vac_h-department,
             dir           type range of zdep028_vac_h-directorate,
             location      type range of zdep028_vac_h-location,
           end of ts_selection.
    types: tt_range_string type range of string.
    methods: set_params importing is_params type ts_selection.
    methods: run.
    methods: display_result.
    methods: get_salv returning value(ro_result) type ref to cl_salv_table.
    methods: retrieve_data.
    methods: refresh.

  protected section.
    data: mo_salv type ref to cl_salv_table.
    data: ms_selcrit type ts_selection.
    data: mt_data type tt_salv. " ztt_ep029_advance_req_head.

    methods: on_toolbar for event added_function of cl_salv_events_table importing e_salv_function.
    methods: on_hotspot for event link_click of cl_salv_events_table importing column row.
    methods: create_record.
    methods: get_selected_records returning value(rt_result) type tt_salv,
      edit_record
        importing
          is_record        type lcl_controller=>ts_salv
        returning
          value(rs_result) type  lcl_controller=>ts_salv.
  private section.
    methods get_bopf_selcrit
      importing
        it_range         type tt_range_string
        i_parname        type string
      returning
        value(rt_result) type /bobf/t_frw_query_selparam.
    methods hide_function
      importing
        i_function type string.


endclass.

class lcl_controller implementation.

  method display_result.
    me->get_salv( )->display( ).
  endmethod.

  method run.
    me->retrieve_data( ).
    me->display_result( ).

  endmethod.

  method set_params.
    ms_selcrit = is_params.
    if ms_selcrit-status[] is initial.
      ms_selcrit-status[] = value #( ( sign = 'I' option = 'CP' low = '*' ) ).
    endif.
    "
    "
  endmethod.

  method get_salv.
    if mo_salv is not bound.
      try.
          cl_salv_table=>factory(
            importing
              r_salv_table   = mo_salv
            changing
              t_table        = mt_data
          ).

          mo_salv->get_layout( )->set_key( value = value #( report = sy-repid handle = 0001 ) ).
          mo_salv->get_layout( )->set_save_restriction( if_salv_c_layout=>restrict_none ).
          mo_salv->get_layout( )->set_default( abap_true ).
          mo_salv->get_columns( )->set_optimize( ).
          mo_salv->get_functions( )->set_all( ).
          mo_salv->set_screen_status(
            exporting
              report        = 'ZR_EP028_VACANCY_MAINT'
              pfstatus      = 'STATUS_MAIN'
              set_functions = cl_salv_table=>c_functions_all
          ).

*          " Set hotspots
*          try.
*              data(lo_col_hotspot) = cast cl_salv_column_table( mo_salv->get_columns( )->get_column( 'HR_PAYROLL_COMMENT' ) ).
*              lo_col_hotspot->set_cell_type( if_salv_c_cell_type=>hotspot ).
*            catch cx_root.
*          endtry.
*          try.
*              lo_col_hotspot = cast cl_salv_column_table( mo_salv->get_columns( )->get_column( 'HR_ADMIN_COMMENT' ) ).
*              lo_col_hotspot->set_cell_type( if_salv_c_cell_type=>hotspot ).
*            catch cx_root.
*          endtry.
*          try.
*              lo_col_hotspot = cast cl_salv_column_table( mo_salv->get_columns( )->get_column( 'HR_REL_COMMENT' ) ).
*              lo_col_hotspot->set_cell_type( if_salv_c_cell_type=>hotspot ).
*            catch cx_root.
*          endtry.

          set handler on_toolbar for mo_salv->get_event( ).
          set handler on_hotspot for mo_salv->get_event( ).


        catch cx_salv_msg.
          "handle exception
      endtry.
*    catch cx_salv_msg. " ALV: General Error Class with Message
    endif.

    ro_result = mo_salv.

  endmethod.

  method retrieve_data.
    data  lt_selection_parameters type /bobf/t_frw_query_selparam.
    append lines of me->get_bopf_selcrit(
        it_range  = corresponding #( ms_selcrit-status )
        i_parname = zif_ep028_bopf_vacancy_c=>sc_query_attribute-root-select_by_elements-status ) to lt_selection_parameters.
    append lines of me->get_bopf_selcrit(
        it_range  = corresponding #( ms_selcrit-objid )
        i_parname = zif_ep028_bopf_vacancy_c=>sc_query_attribute-root-select_by_elements-jprf_id ) to lt_selection_parameters.
    append lines of me->get_bopf_selcrit(
        it_range  = corresponding #( ms_selcrit-dir )
        i_parname = zif_ep028_bopf_vacancy_c=>sc_query_attribute-root-select_by_elements-directorate ) to lt_selection_parameters.
    append lines of me->get_bopf_selcrit(
        it_range  = corresponding #( ms_selcrit-dep )
        i_parname = zif_ep028_bopf_vacancy_c=>sc_query_attribute-root-select_by_elements-department ) to lt_selection_parameters.
    append lines of me->get_bopf_selcrit(
        it_range  = corresponding #( ms_selcrit-perm_kept_pos )
        i_parname = zif_ep028_bopf_vacancy_c=>sc_query_attribute-root-select_by_elements-pos_id ) to lt_selection_parameters.
    append lines of me->get_bopf_selcrit(
        it_range  = corresponding #( ms_selcrit-location )
        i_parname = zif_ep028_bopf_vacancy_c=>sc_query_attribute-root-select_by_elements-location ) to lt_selection_parameters.

    zcl_ep028_bopf_helper=>mo_bopf->query(
      exporting
        iv_query_key            = zif_ep028_bopf_vacancy_c=>sc_query-root-select_by_elements
        it_selection_parameters = lt_selection_parameters                 " Query Selection Parameters
    iv_fill_data            = abap_true
  importing
    et_key                  = data(lt_keys)
    et_data                 = mt_data
    ).

    data lt_headers type ztt_ep028_vacancy.
    zcl_ep028_bopf_helper=>mo_bopf->retrieve(
      exporting
        iv_node_key             = zif_ep028_bopf_vacancy_c=>sc_node-root
        it_key                  = lt_keys
        iv_edit_mode            = /bobf/if_conf_c=>sc_edit_read_only
        iv_fill_data            = abap_true
      importing
        et_data                 = lt_headers
    ).

    mt_data = corresponding #( lt_headers ).

  endmethod.


  method get_bopf_selcrit.

    clear rt_result.

    loop at it_range assigning field-symbol(<ls_range>).
      append corresponding #( <ls_range>  ) to rt_result assigning field-symbol(<ls_result>).
      <ls_result>-attribute_name = i_parname.
    endloop.
  endmethod.

  method on_toolbar.
    case e_salv_function.
      when 'NEW'.
        me->create_record( ).
        me->refresh( ).
      when 'EDIT'.
        data(lt_selected) = me->get_selected_records( ).
        read table lt_selected assigning field-symbol(<ls_record>) index 1.

        data(ls_changed_record) = me->edit_record( <ls_record> ).

        if ls_changed_record ne <ls_record>.
          zcl_ep028_bopf_helper=>set_vacancy_data(
            exporting
              i_key   = ls_changed_record-key
              is_data = corresponding zss_ep028_vacancy( ls_changed_record )
          ).
          zcl_ep028_bopf_helper=>save_vacancy(
            exporting
              i_key    = <ls_record>-key
              i_commit = abap_true
          ).
          message s002(zep_028).
        endif.

        commit work and wait.
        me->refresh( ).

      when others.
    endcase.
  endmethod.

  method refresh.
    me->retrieve_data( ).
    me->get_salv( )->refresh( s_stable = value #( col = abap_true row = abap_true ) ).
  endmethod.

  method get_selected_records.
    data(lt_selrows) = me->get_salv( )->get_selections( )->get_selected_rows( ).
    loop at lt_selrows assigning field-symbol(<ls_selrow>).
      read table mt_data assigning field-symbol(<ls_header>) index <ls_selrow>.
      check sy-subrc = 0.
      append <ls_header> to rt_result.
    endloop.

  endmethod.

  method on_hotspot.
*    read table mt_data index row assigning field-symbol(<ls_header>).
*    check sy-subrc = 0.
*
*    case column.
*      when 'HR_PAYROLL_COMMENT'.
*        data l_note type string.
*        l_note = <ls_header>-hr_payroll_comment.
*        data(lo_note) = new zcl_eui_memo(
*          ir_text     = ref #( l_note )
**      iv_editable = abap_true
*        ).
*
*        data(l_ucomm) = lo_note->popup( )->show( ).
*        if l_ucomm = 'OK'.
*          <ls_header>-hr_payroll_comment = l_note.
*          zcl_ep029_bopf_helper=>set_request_data(
*            exporting
*              i_key     = <ls_header>-key
*              is_header = corresponding #( <ls_header> )
*          ).
*          zcl_ep029_bopf_helper=>save_request(
*              i_key    = <ls_header>-key
*              i_commit = abap_true
*          ).
*        endif.
*      when 'HR_ADMIN_COMMENT'.
*        l_note = <ls_header>-hr_admin_comment.
*
*        lo_note = new zcl_eui_memo(
*          ir_text     = ref #( l_note )
**      iv_editable = abap_true
*        ).
*        l_ucomm = lo_note->popup( )->show( ).
*        if l_ucomm = 'OK'.
*          <ls_header>-hr_admin_comment = l_note.
*          zcl_ep029_bopf_helper=>set_request_data(
*            exporting
*              i_key     = <ls_header>-key
*              is_header = corresponding #( <ls_header> )
*          ).
*          zcl_ep029_bopf_helper=>save_request(
*              i_key    = <ls_header>-key
*              i_commit = abap_true
*          ).
*        endif.
*
*      when 'HR_REL_COMMENT'.
*        l_note = <ls_header>-hr_rel_comment.
*
*        lo_note = new zcl_eui_memo(
*          ir_text     = ref #( l_note )
*
*        ).
*        l_ucomm = lo_note->popup( )->show( ).
*        if l_ucomm = 'OK'.
*          <ls_header>-hr_rel_comment = l_note.
*          zcl_ep029_bopf_helper=>set_request_data(
*            exporting
*              i_key     = <ls_header>-key
*              is_header = corresponding #( <ls_header> )
*          ).
*          zcl_ep029_bopf_helper=>save_request(
*              i_key    = <ls_header>-key
*              i_commit = abap_true
*          ).
*        endif.
*
*    endcase.
*
*    me->refresh( ).
  endmethod.


  method hide_function.
    check mo_salv is bound.
    data(lt_functions) = mo_salv->get_functions( )->get_functions( ).
    loop at lt_functions assigning field-symbol(<ls_function>).
      if <ls_function>-r_function->get_name( ) = i_function.
        <ls_function>-r_function->set_visible( abap_false ).
      endif.
    endloop.
  endmethod.



  method edit_record.
    data l_rc type char1.
    data lt_fields type standard table of sval.
    rs_result = is_record.

    data(lo_descr) = cast cl_abap_structdescr( cl_abap_structdescr=>describe_by_name( 'ZSS_EP028_VACANCY_P' ) ).
    loop at lo_descr->get_components( ) assigning field-symbol(<ls_component>).
      check <ls_component>-name ne 'JPRF_ID' and
        <ls_component>-name ne 'POS_ID' and
        <ls_component>-name ne 'JOB_ID' and
        <ls_component>-name ne 'DEPARTMENT' and
        <ls_component>-name ne 'DIRECTORATE'.
      assign component <ls_component>-name of structure is_record to field-symbol(<l_value>).
      check sy-subrc = 0.
      append value #( tabname = 'ZDEP028_VAC_H' fieldname = <ls_component>-name value = <l_value> ) to lt_fields.
    endloop.


    call function 'POPUP_GET_VALUES'
      exporting
*       no_value_check  = space            " Deactivates data type check
        popup_title     = 'Change record'                 " Text of title line
        start_column    = '5'              " Start column of the dialog box
        start_row       = '5'              " Start line of the dialog box
      importing
        returncode      = l_rc                 " User response
      tables
        fields          = lt_fields                 " Table fields, values and attributes
      exceptions
        error_in_fields = 1                " FIELDS were transferred incorrectly
        others          = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
        with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
    check l_rc is initial.

    loop at lt_fields assigning field-symbol(<ls_field>).
      assign component <ls_field>-fieldname of structure rs_result to <l_value>.
      check sy-subrc = 0.
      <l_value> = <ls_field>-value.
    endloop.

  endmethod.

  method create_record.
    "ZDEP028_VAC_H

    data(ls_new_record) = value zss_ep028_vacancy_p( ).

    try.
        data(l_key) = zcl_ep028_bopf_helper=>create_new_vacancy( i_jprf = '00000000' i_no_check_jprf = abap_true ).
      catch zcx_ep028_error.
        "handle exception
    endtry.

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    data l_rc type char1.
    data lt_fields type standard table of sval.

    data(lo_descr) = cast cl_abap_structdescr( cl_abap_structdescr=>describe_by_name( 'ZSS_EP028_VACANCY_P' ) ).
    loop at lo_descr->get_components( ) assigning field-symbol(<ls_component>).
      assign component <ls_component>-name of structure ls_new_record to field-symbol(<l_value>).
      check sy-subrc = 0.
      append value #( tabname = 'ZDEP028_VAC_H' fieldname = <ls_component>-name value = <l_value> ) to lt_fields.
    endloop.


    call function 'POPUP_GET_VALUES'
      exporting
*       no_value_check  = space            " Deactivates data type check
        popup_title     = 'Change record'                 " Text of title line
        start_column    = '5'              " Start column of the dialog box
        start_row       = '5'              " Start line of the dialog box
      importing
        returncode      = l_rc                 " User response
      tables
        fields          = lt_fields                 " Table fields, values and attributes
      exceptions
        error_in_fields = 1                " FIELDS were transferred incorrectly
        others          = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
        with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
    check l_rc is initial.

    loop at lt_fields assigning field-symbol(<ls_field>).
      assign component <ls_field>-fieldname of structure ls_new_record to <l_value>.
      check sy-subrc = 0.
      <l_value> = <ls_field>-value.
    endloop.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    zcl_ep028_bopf_helper=>set_vacancy_data(
      exporting
        i_key   = l_key
        is_data = corresponding zss_ep028_vacancy( ls_new_record )
    ).
    zcl_ep028_bopf_helper=>save_vacancy(
      exporting
        i_key    = l_key
        i_commit = abap_true
    ).
    message s002(zep_028).

    commit work and wait.

  endmethod.

endclass.
