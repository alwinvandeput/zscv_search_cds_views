CLASS ltcl_ DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS set_all_to_completed     ."FOR TESTING RAISING cx_static_check.

    METHODS delete_all               ."FOR TESTING.

    METHODS cds_relation_running     FOR TESTING.
    METHODS cds_relation_complete    ."FOR TESTING.
    METHODS cds_relation_completed   ."FOR TESTING.

    METHODS main_table_running       ."FOR TESTING.
    METHODS main_table_completed     ."FOR TESTING.

ENDCLASS.


CLASS ltcl_ IMPLEMENTATION.

  METHOD delete_all.
    zscv_run_bo=>delete_all( ).
  ENDMETHOD.

  METHOD set_all_to_completed.

    DATA(lr_run) = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-released_basic_view ).
    lr_run->update( zscv_run_bo=>gcs_index_run_status-running ).
    lr_run->update( zscv_run_bo=>gcs_index_run_status-completed ).

    lr_run = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-cds_relation ).
    lr_run->update( zscv_run_bo=>gcs_index_run_status-running ).
    lr_run->update( zscv_run_bo=>gcs_index_run_status-completed ).

    lr_run = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-cds_main_db_table_name ).
    lr_run->update( zscv_run_bo=>gcs_index_run_status-running ).
    lr_run->update( zscv_run_bo=>gcs_index_run_status-completed ).

  ENDMETHOD.

  METHOD cds_relation_running.
    DATA(lr_run)  = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-cds_relation ).
    lr_run->update( zscv_run_bo=>gcs_index_run_status-running ).
  ENDMETHOD.

  METHOD cds_relation_complete.
    DATA(lr_run)  = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-cds_relation ).
    lr_run->update( zscv_run_bo=>gcs_index_run_status-completed ).
  ENDMETHOD.

  METHOD cds_relation_completed.
    DATA(lr_run)  = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-cds_relation ).
    lr_run->update( zscv_run_bo=>gcs_index_run_status-running ).
    WAIT UP TO 2 SECONDS.
    lr_run->update( zscv_run_bo=>gcs_index_run_status-completed ).
  ENDMETHOD.

  METHOD main_table_running.
    DATA(lr_run)  = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-cds_main_db_table_name ).
    lr_run->update( zscv_run_bo=>gcs_index_run_status-running ).
  ENDMETHOD.

  METHOD main_table_completed.
    DATA(lr_run)  = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-cds_main_db_table_name ).
    lr_run->update( zscv_run_bo=>gcs_index_run_status-running ).
    WAIT UP TO 5 SECONDS.
    lr_run->update( zscv_run_bo=>gcs_index_run_status-completed ).
  ENDMETHOD.

ENDCLASS.
