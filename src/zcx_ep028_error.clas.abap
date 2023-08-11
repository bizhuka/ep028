class zcx_ep028_error definition inheriting from cx_static_check
  public
  create public .

  public section.
    methods: constructor importing
                           textid     type sotr_conc optional
                           previous   type ref to cx_root optional

                           io_message type ref to /bobf/if_frw_message optional.
    data: mo_bopf_message type ref to /bobf/if_frw_message.
  protected section.
  private section.
endclass.



class zcx_ep028_error implementation.
  method constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor( textid = textid previous = previous ).
    mo_bopf_message = io_message.
  endmethod.

endclass.
