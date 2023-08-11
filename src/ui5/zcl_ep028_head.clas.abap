CLASS zcl_ep028_head DEFINITION PUBLIC FINAL CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF ms_status,
        draft   TYPE zc_ep028_vacancy_head-status VALUE '',
        visible TYPE zc_ep028_vacancy_head-status VALUE 'VISIBLE',
        hidden  TYPE zc_ep028_vacancy_head-status VALUE 'HIDDEN',
        closed  TYPE zc_ep028_vacancy_head-status VALUE 'CLOSED',
      END OF ms_status.

    INTERFACES:
      zif_sadl_read_runtime,
      zif_sadl_mpc,
      zif_sadl_prepare_batch.

    METHODS constructor RAISING /bobf/cx_frw.

  PRIVATE SECTION.
    DATA mo_manager TYPE REF TO zcl_bopf_manager.
ENDCLASS.



CLASS zcl_ep028_head IMPLEMENTATION.
  METHOD constructor.
    mo_manager = zcl_bopf_manager=>create( 'ZC_EP028_VACANCY_HEAD' ).
  ENDMETHOD.

  METHOD zif_sadl_mpc~define.
    DATA(lo_entity) = io_model->get_entity_type( 'ZI_EP0298_IAFType' ).
    lo_entity->set_is_media( abap_true ).
    lo_entity->get_property( 'guid' )->set_as_content_type( ).

    lo_entity = io_model->get_entity_type( 'ZI_EP0298_IAF_AttachmentType' ).
    lo_entity->set_is_media( abap_true ).
    lo_entity->get_property( 'guid' )->set_as_content_type( ).

    lo_entity = io_model->get_entity_type( 'ZI_EP0298_A_PRINT_JPRF_LETTERType' ).
    lo_entity->set_is_media( abap_true ).
    lo_entity->get_property( 'jprf_id' )->set_as_content_type( ).

    " Change SH to dropboxes
    DATA(lc_fixed_values) = /iwbep/if_mgw_odata_property=>gcs_value_list_type_property-fixed_values.
    io_model->get_entity_type( 'zc_ep028_vacancy_headType' )->get_property( 'status' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZSH_EP028_VacancyStatusType' )->get_property( 'vac_status' )->set_value_list( lc_fixed_values ).

    io_model->get_entity_type( 'zc_ep028_vacancy_headType' )->get_property( 'vacancy_type' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZSH_EP028_VacancyTypeType' )->get_property( 'vac_type' )->set_value_list( lc_fixed_values ).

    io_model->get_entity_type( 'zc_ep028_vacancy_headType' )->get_property( 'grade' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'zc_ep028_vacancy_headType' )->get_property( 'grad2' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZSH_EP028_GradeType' )->get_property( 'grade_id' )->set_value_list( lc_fixed_values ).

    io_model->get_entity_type( 'zc_ep028_vacancy_headType' )->get_property( 'comp_slot' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZSH_EP028_SlotType' )->get_property( 'slot_id' )->set_value_list( lc_fixed_values ).

    io_model->get_entity_type( 'zc_ep028_vacancy_headType' )->get_property( 'work_sched' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZSH_EP028_WorkPatternType' )->get_property( 'id_work_pattern' )->set_value_list( lc_fixed_values ).

    io_model->get_entity_type( 'zc_ep028_vacancy_headType' )->get_property( 'location' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_PY000_PersonnelAreaType' )->get_property( 'persa' )->set_value_list( lc_fixed_values ).

    io_model->get_entity_type( 'zc_ep028_vacancy_headType' )->get_property( 'subarea' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_PY000_PersonnelSubAreaType' )->get_property( 'btrtl' )->set_value_list( lc_fixed_values ).


*    lo_entity = io_model->get_entity_type( 'zc_ep028_vacancy_headType' )->/iwbep/if_mgw_odata_annotatabl~create_annotation( 'sap' )->add
    DATA(lo_entity_set) = io_model->get_entity_set( 'zc_ep028_vacancy_head' ).

    DATA(lo_annotation) = lo_entity_set->create_annotation( 'sap' ).
    lo_annotation->add( iv_key   = 'deletable-path' iv_value = 'is_deletable' ).
    lo_annotation->add( iv_key   = 'updatable-path' iv_value = 'is_updatable' ).
  ENDMETHOD.

  METHOD zif_sadl_read_runtime~execute.
    " Can edit everything
    DATA(lv_is_super) = zcl_ep028_opt=>is_super( ).
    DATA(lv_is_admin) = NEW zcl_ep028_current_user( )->ms_info-is_admin.

    LOOP AT ct_data_rows ASSIGNING FIELD-SYMBOL(<ls_row>).
      DATA(ls_row) = CORRESPONDING zc_ep028_vacancy_head( <ls_row> ).

      ls_row-is_deletable = xsdbool( ls_row-status = ms_status-draft ). " OR lv_is_super = abap_true
      ls_row-is_updatable = xsdbool( ls_row-status <> ms_status-closed OR lv_is_super = abap_true ).

      IF lv_is_admin <> abap_true.
        CLEAR: ls_row-is_deletable,
               ls_row-is_updatable.
      ENDIF.

      MOVE-CORRESPONDING ls_row TO <ls_row>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_sadl_prepare_batch~prepare.
    TRY.
        " No administrator rights to change data
        IF lines( ct_create ) + lines( ct_update ) + lines( ct_delete ) > 0
          AND NEW zcl_ep028_current_user( )->ms_info-is_admin <> abap_true.

          MESSAGE e005(zep_028) INTO DATA(lv_error_message).
          zcx_eui_exception=>raise_sys_error( iv_message = lv_error_message ).
        ENDIF.

        LOOP AT ct_delete ASSIGNING FIELD-SYMBOL(<ls_delete>).
          ASSIGN <ls_delete>-rs_key_values->* TO FIELD-SYMBOL(<ls_item>).
          CHECK sy-subrc = 0.

          DATA(ls_item) = CORRESPONDING zc_ep028_vacancy_head( <ls_item> ).
          DATA(lr_item) = CAST zscep028_vacancy_head( mo_manager->retrieve_row( ls_item-db_key ) ).

          " JPRF &1 with status &2 cannot be deleted (only drafts can be deleted)
          CHECK lr_item->status <> ms_status-draft. " <--- Obsolete
          MESSAGE e004(zep_028) WITH lr_item->jprf_id lr_item->status INTO lv_error_message.
          zcx_eui_exception=>raise_sys_error( iv_message = lv_error_message ).
        ENDLOOP.
      CATCH cx_static_check INTO DATA(lo_error).
        RAISE EXCEPTION TYPE cx_sadl_static EXPORTING previous = lo_error.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
