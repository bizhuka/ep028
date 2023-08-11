CLASS zcl_ep028_opt DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE GLOBAL FRIENDS zcl_aqo_option.

  PUBLIC SECTION.
*    TYPES:

    CLASS-DATA:
      t_admin_roles TYPE RANGE OF agr_users-agr_name  READ-ONLY,
      r_super_users TYPE RANGE OF suid_st_bname-bname READ-ONLY,
      v_about_info  TYPE string                       READ-ONLY.

    CLASS-METHODS:
      class_constructor,

      is_super RETURNING VALUE(rv_super) TYPE abap_bool.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ep028_opt IMPLEMENTATION.
  METHOD class_constructor.
    zcl_aqo_option=>create( NEW zcl_ep028_opt( ) ).
  ENDMETHOD.

  METHOD is_super.
    CHECK r_super_users[] IS NOT INITIAL.

    DATA(lv_uname) = NEW zcl_ep028_current_user( )->ms_info-login. " sy-uname
    rv_super = xsdbool( lv_uname IN r_super_users[] ).
  ENDMETHOD.

ENDCLASS.
