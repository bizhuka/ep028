CLASS zcl_ep028_current_user DEFINITION PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES:
      zif_sadl_read_runtime.

    DATA:
      ms_info  TYPE zi_ep0298_current_user READ-ONLY.

    METHODS:
      constructor IMPORTING iv_datum TYPE d DEFAULT sy-datum.

  PRIVATE SECTION.
    DATA:
      mv_datum TYPE d.
ENDCLASS.



CLASS zcl_ep028_current_user IMPLEMENTATION.


  METHOD constructor.
    mv_datum = iv_datum.

    ms_info-login = sy-uname.
    TRY.
        ms_info-pernr = zcl_hcm_wf=>get_pernr_by_uname( ms_info-login ).
      CATCH zcx_sy INTO DATA(lo_cx_sy).
        zcx_eui_no_check=>raise_sys_error( io_error = lo_cx_sy ).
    ENDTRY.

    ms_info-ename = CAST p0001( zcl_hr_read=>infty_row(
      iv_infty   = '0001'
      iv_pernr   = ms_info-pernr
      iv_begda   = mv_datum
      iv_endda   = mv_datum
      iv_no_auth = 'X'
      is_default = VALUE p0001( )
    ) )->ename.

    ms_info-v_about_info = zcl_ep028_opt=>v_about_info.

    SELECT SINGLE @abap_true INTO @ms_info-is_admin     "#EC CI_GENBUFF
    FROM agr_users
    WHERE agr_name IN @zcl_ep028_opt=>t_admin_roles[]
      AND uname    EQ @ms_info-login
      AND from_dat LE @mv_datum
      AND to_dat   GE @mv_datum.
  ENDMETHOD.


  METHOD zif_sadl_read_runtime~execute.
    " Always 1 line
    cv_number_all_hits = 1.
    CLEAR ct_data_rows[].

    APPEND INITIAL LINE TO ct_data_rows ASSIGNING FIELD-SYMBOL(<ls_result>).
    MOVE-CORRESPONDING ms_info TO <ls_result>.
  ENDMETHOD.
ENDCLASS.
