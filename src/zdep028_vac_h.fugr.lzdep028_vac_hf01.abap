*----------------------------------------------------------------------*
***INCLUDE LZDEP028_VAC_HF01.
*----------------------------------------------------------------------*

form zep028_maint_on_cre.
  zdep028_vac_h-db_key = /bobf/cl_frw_factory=>get_new_key( ).
endform.
