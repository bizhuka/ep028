class zcl_ep028_wd_view_opti definition
  public
  final
  create public
  global friends zcl_aqo_option .
  public section.
    class-methods class_constructor .

    types: begin of ts_contact,
             employee_name type string,
             phone         type string,
           end of ts_contact.
    types: tt_contacts type standard table of ts_contact with empty key.

    types: begin of ts_general_settings,
             enabled_in_jprf type abap_bool,
           end of ts_general_settings.

    types: begin of ts_required_docs,
             seqnr         type string,
             document_name type string,
           end of ts_required_docs.
    types: tt_required_docs type standard table of ts_required_docs with empty key.
    class-data: m_enabled_in_jprf type string read-only.
    class-data: iaf_contacts type tt_contacts read-only.
    class-data: mailto type string read-only.
    class-data: iaf_guideline_link type string read-only.
    class-data: html_island type string read-only.
    class-data: required_docs type tt_required_docs read-only.
    "CLASS-data: column_with type zss_ep028_wd_column_width read-only.
  protected section.
  private section.
ENDCLASS.



CLASS ZCL_EP028_WD_VIEW_OPTI IMPLEMENTATION.


  method class_constructor.

    " Read option " @see -> https://github.com/bizhuka/aqo/wiki
    try.
        zcl_aqo_option=>create(
          iv_package_id = 'ZEP_028'  " Package    "#EC NOTEXT
          iv_option_id  = 'WD_OPTIONS'   " For report "#EC NOTEXT
          io_data       = new zcl_ep028_wd_view_opti( )
*          iv_repair     = abap_true
        ).
      catch zcx_aqo_exception into data(lo_error).
        message lo_error type 'S' display like 'E'.
        return.
    endtry.

  endmethod.
ENDCLASS.
