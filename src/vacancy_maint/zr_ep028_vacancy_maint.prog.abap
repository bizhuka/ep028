*&---------------------------------------------------------------------*
*& Report zr_ep028_vacancy_maint
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zr_ep028_vacancy_maint.


include zi_ep028_vacancy_maint_cls.

data zdep028_vac_h type zdep028_vac_h.
selection-screen begin of block bl1 with frame title text-t01.
SELECT-options: _OBJID FOR zdep028_vac_h-jprf_id. "Object ID
select-options: _PKPOS FOR zdep028_vac_h-pos_id. " *PermnKeptPos
select-options: _job FOR zdep028_vac_h-job_id. " Job
select-options: _dep FOR zdep028_vac_h-department. " Department ID
select-options: _dir FOR zdep028_vac_h-directorate. " Directorat ID
select-options: _loc FOR zdep028_vac_h-location. " Location
select-options: _status for zdep028_vac_h-status. " Status


selection-screen end of block bl1.

start-of-selection.

  data(lo_report) = new lcl_controller( ).

  lo_report->set_params( is_params =
    value #(
      status = _status[]
      objid = _objid[]
      perm_kept_pos = _pkpos[]
      job = _job[]
      dep = _dep[]
      dir = _dir[]
      location = _loc[]
    )
  ).

  lo_report->run( ).
