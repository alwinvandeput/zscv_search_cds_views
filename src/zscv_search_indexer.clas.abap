CLASS zscv_search_indexer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF gts_full_update,
        basic_view_delete_ind      TYPE abap_bool,
        basic_view_fill_ind        TYPE abap_bool,
        basic_view_add_missing_ind TYPE abap_bool,

        cds_rel_cds_view_rng       TYPE  zscv_cds_relation_bo=>gtt_parent_name_rng,
        cds_rel_fill_ind           TYPE abap_bool,
        cds_rel_delete_ind         TYPE abap_bool,

        main_db_cds_view_rng       TYPE  zscv_cds_relation_bo=>gtt_parent_name_rng,
        main_db_update_ind         TYPE abap_bool,
      END OF gts_full_update.

    METHODS full_update
      IMPORTING is_full_update TYPE gts_full_update.

    METHODS delta_update
      IMPORTING is_begin_date_time TYPE zscv_run_bo=>ts_begin_date_time OPTIONAL.

    METHODS reset_running_runs.

    METHODS set_runs
      IMPORTING is_begin_date_time TYPE zscv_run_bo=>ts_begin_date_time.

ENDCLASS.

CLASS zscv_search_indexer IMPLEMENTATION.

  METHOD full_update.

    "Fill ZSCV_BASIC_VIEW
    IF is_full_update-basic_view_delete_ind = abap_true.

      zscv_released_basic_view_bo=>delete_all( ).

    ENDIF.

    IF is_full_update-basic_view_fill_ind = abap_true.

      DATA(lr_run) = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-released_basic_view ).
      lr_run->update( zscv_run_bo=>gcs_index_run_status-running ).

      zscv_released_basic_view_bo=>fill_db_table_initially( ).

      lr_run->update( zscv_run_bo=>gcs_index_run_status-completed ).

    ENDIF.

    "CDS view relations - fill Initially (ZSCV_CDS_REL)
    IF is_full_update-cds_rel_delete_ind = abap_true.

      zscv_cds_relation_bo=>delete_all( ).

    ENDIF.

    "CDS view relations
    IF is_full_update-cds_rel_fill_ind = abap_true.

      IF is_full_update-cds_rel_cds_view_rng[] IS INITIAL.
        lr_run = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-cds_relation ).
        lr_run->update( zscv_run_bo=>gcs_index_run_status-running ).
      ENDIF.

      DATA(lr_cds_relation_index) = NEW zscv_cds_relation_index_prc( ).
      lr_cds_relation_index->execute_full_update(
        it_cds_view_rng = is_full_update-cds_rel_cds_view_rng[]  ).

      IF is_full_update-cds_rel_cds_view_rng[] IS  INITIAL.
        lr_run->update( zscv_run_bo=>gcs_index_run_status-completed ).
      ENDIF.

    ENDIF.

    "Fill ZSCV_CDS_REL field Main DB Table name
    IF is_full_update-main_db_update_ind = abap_true.

      IF is_full_update-main_db_cds_view_rng[] IS INITIAL.
        lr_run = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-cds_main_db_table_name ).
        lr_run->update( zscv_run_bo=>gcs_index_run_status-running ).
      ENDIF.

      zscv_cds_relation_bo=>fill_main_db_table_name( is_full_update-main_db_cds_view_rng ).

      IF is_full_update-main_db_cds_view_rng[] IS INITIAL.
        lr_run->update( zscv_run_bo=>gcs_index_run_status-completed ).
      ENDIF.

    ENDIF.

    "Add missing released basic views
    IF is_full_update-basic_view_add_missing_ind = abap_true.

      zscv_released_basic_view_bo=>add_db_table_initially( ).

    ENDIF.

  ENDMETHOD.

  METHOD delta_update.

    DATA(lr_cds_relation_run) = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-cds_relation ).
    DATA(ls_cds_relation_run) = lr_cds_relation_run->check_run_is_completed( ).

    DATA(lr_main_db_table_nm_run) = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-cds_main_db_table_name ).
    DATA(ls_main_db_table_nm_run) = lr_main_db_table_nm_run->check_run_is_completed( ).

    "CDS relations
    IF ls_cds_relation_run-completed_ind = abap_false OR
       ls_main_db_table_nm_run-completed_ind = abap_false.

      IF ls_cds_relation_run-completed_ind = abap_false.
        DATA(lv_text) = ls_cds_relation_run-text.
      ELSE.
        lv_text = ls_main_db_table_nm_run-text.
      ENDIF.

      MESSAGE lv_text TYPE 'I' DISPLAY LIKE 'E'.

      RETURN.

    ENDIF.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "Delta update CDS relation
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    IF is_begin_date_time IS INITIAL.
      DATA(ls_begin_date_time) = lr_cds_relation_run->get_begin_date_time( ).
    ELSE.
      ls_begin_date_time = is_begin_date_time.
    ENDIF.

    lr_cds_relation_run->update( zscv_run_bo=>gcs_index_run_status-running ).

    DATA(lr_cds_relation_index) = NEW zscv_cds_relation_index_prc( ).
    lr_cds_relation_index->execute_delta_update( ls_begin_date_time ).

    lr_cds_relation_run->update( zscv_run_bo=>gcs_index_run_status-completed ).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "Delta update Main DB Table Name
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    lr_main_db_table_nm_run->update( zscv_run_bo=>gcs_index_run_status-running ).

    zscv_cds_relation_bo=>fill_main_db_table_delta( ls_begin_date_time ).

    lr_main_db_table_nm_run->update( zscv_run_bo=>gcs_index_run_status-completed ).

  ENDMETHOD.

  METHOD reset_running_runs.

    DATA(lr_run)  = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-cds_relation ).
    lr_run->reset( ).

    lr_run  = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-cds_main_db_table_name ).
    lr_run->reset( ).

    lr_run  = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-released_basic_view ).
    lr_run->reset( ).

  ENDMETHOD.

  METHOD set_runs.

    DATA(lr_run)  = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-cds_relation ).
    lr_run->set( is_begin_date_time ).

    lr_run  = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-cds_main_db_table_name ).
    lr_run->set( is_begin_date_time ).

    lr_run  = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-released_basic_view ).
    lr_run->set( is_begin_date_time ).

  ENDMETHOD.

ENDCLASS.

