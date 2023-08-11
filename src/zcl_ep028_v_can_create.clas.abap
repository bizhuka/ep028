class zcl_ep028_v_can_create definition
  public
  inheriting from /bobf/cl_lib_v_supercl_simple
  final
  create public .

  public section.

    methods /bobf/if_frw_validation~execute
        redefinition .
  protected section.
  private section.
endclass.



class zcl_ep028_v_can_create implementation.


  method /bobf/if_frw_validation~execute.
    eo_message = /bobf/cl_frw_factory=>get_message( ).

    data lt_data type ztt_ep028_vacancy.
    io_read->retrieve(
      exporting
        iv_node                 = zif_ep028_bopf_vacancy_c=>sc_node-root
        it_key                  = it_key
*      iv_before_image         = abap_false       " Data Element for Domain BOOLE: TRUE (="X") and FALSE (=" ")
*      iv_fill_data            = abap_true        " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
        it_requested_attributes = value #( ( `JPRF_ID` ) ( `STATUS` ) )                 " List of Names (e.g. Fieldnames)
      importing
        eo_message              = data(lo_message)                 " Message Object
        et_data                 = lt_data                 " Data Return Structure
*      et_failed_key           =                  " Key Table
*      et_node_cat             =                  " Node Category Assignment
    ).
    if lo_message is bound.
      eo_message->add( lo_message ).
    endif.
    loop at lt_data assigning field-symbol(<ls_checked_object>).
      select single @abap_true from zdep028_vac_h into @data(l_exists) where jprf_id = @<ls_checked_object>-jprf_id and
      db_key ne @<ls_checked_object>-key. "#EC "#EC CI_NOFIELD
      if l_exists = abap_true.
        message e001(zep_028) with <ls_checked_object>-jprf_id into data(dummy).

        append value #( key = <ls_checked_object>-key ) to et_failed_key.
        eo_message->add_message(
          exporting
            is_msg       = corresponding #( sy )
            iv_node      = zif_ep028_bopf_vacancy_c=>sc_node-root
            iv_key       = <ls_checked_object>-key
        ).
      endif.
    endloop.

  endmethod.
endclass.
