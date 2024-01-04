CLASS zscv_run_bo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF gcs_run_types,
        "Fill ZSCV_CDS_REL based on CDS view syntax FROM source
        cds_relation           TYPE zscv_run-run_type VALUE 'CDS_RELATION',

        "Initially fill of ZSCV_BASIC_VIEW
        released_basic_view    TYPE zscv_run-run_type VALUE 'RELEASED_BASIC_VIEW',

        "ZSCV_CDS_REL field root_child
        cds_main_db_table_name TYPE zscv_run-run_type VALUE 'CDS_MAIN_DB_TABLE_NAME',

      END OF gcs_run_types.

    CONSTANTS:
      BEGIN OF gcs_index_run_status,
        running   TYPE char10 VALUE 'RUNNING',
        completed TYPE char10 VALUE 'COMPLETED',
      END OF gcs_index_run_status.
    CLASS-METHODS delete_all.

    METHODS constructor
      IMPORTING iv_run_type TYPE zscv_run-run_type.

    METHODS get_start_timestamp
      RETURNING VALUE(rv_start_timestamp) TYPE zscv_run-end_timestamp.

    TYPES:
      BEGIN OF ts_begin_date_time,
        date TYPE syst-datum,
        time TYPE syst-uzeit,
      END OF ts_begin_date_time.

    METHODS get_begin_date_time
      RETURNING VALUE(ls_begin_date_time) TYPE ts_begin_date_time.

    METHODS get_selection_date_time
      RETURNING VALUE(ls_begin_date_time) TYPE ts_begin_date_time.

    METHODS update
      IMPORTING iv_status TYPE zscv_run-status.

    TYPES:
      BEGIN OF gts_run_check,
        completed_ind TYPE abap_bool,
        text          TYPE char80,
      END OF gts_run_check.

    METHODS check_run_is_completed
      RETURNING VALUE(rs_run_check) TYPE gts_run_check.

    METHODS reset.

    METHODS set
      IMPORTING is_begin_date_time TYPE ts_begin_date_time.

  PROTECTED SECTION.

  PRIVATE SECTION.

    CONSTANTS gcv_indexer_program_name TYPE syst-repid VALUE 'ZSCV_CDS_RELATION_INDEXER'.
    CONSTANTS gcv_index_table TYPE tabname16 VALUE 'ZSCV_CDS_REL'.

    DATA gv_run_type TYPE zscv_run-run_type.

    METHODS _update
      IMPORTING
        iv_status          TYPE zscv_run-status
        iv_start_timestamp TYPE timestamp OPTIONAL.

ENDCLASS.

CLASS zscv_run_bo IMPLEMENTATION.

  METHOD constructor.

    gv_run_type = iv_run_type.

  ENDMETHOD.

  METHOD update.

    _update(
      iv_status = iv_status ).

  ENDMETHOD.

  METHOD _update.

    SELECT SINGLE
      FROM zscv_run
      FIELDS *
      WHERE run_type = @gv_run_type
      INTO @DATA(ls_update_index_run).

    IF sy-subrc = 0.
      DATA(lv_exits_ind) = abap_true.
    ENDIF.

    CASE iv_status.

      WHEN gcs_index_run_status-running.

        ls_update_index_run-selection_timestamp = ls_update_index_run-start_timestamp.

        IF iv_start_timestamp IS INITIAL.
          GET TIME STAMP FIELD ls_update_index_run-start_timestamp.
        ELSE.
          ls_update_index_run-start_timestamp = iv_start_timestamp.
        ENDIF.

        CLEAR ls_update_index_run-end_timestamp.

      WHEN gcs_index_run_status-completed.

        IF iv_start_timestamp IS INITIAL.
          GET TIME STAMP FIELD ls_update_index_run-end_timestamp.
        ELSE.
          ls_update_index_run-start_timestamp = iv_start_timestamp.
          ls_update_index_run-end_timestamp   = iv_start_timestamp.
        ENDIF.

    ENDCASE.

    IF lv_exits_ind = abap_false.

      DATA ls_run TYPE zscv_run.

      ls_run = CORRESPONDING #( ls_update_index_run ).
      ls_run-run_type        = gv_run_type.
      ls_run-sap_release     = sy-saprl.
      ls_run-status          = iv_status.
      ls_run-start_timestamp = ls_update_index_run-start_timestamp.
      ls_run-end_timestamp   = ls_update_index_run-end_timestamp.

      INSERT zscv_run
        FROM @ls_run.

    ELSE.

      ls_update_index_run-status = iv_status.

      UPDATE zscv_run
        FROM ls_update_index_run.

    ENDIF.

    COMMIT WORK.

  ENDMETHOD.

  METHOD check_run_is_completed.

    SELECT SINGLE
      FROM zscv_run
      FIELDS *
      WHERE run_type = @gv_run_type
      INTO @DATA(ls_update_index_run).

    "Check run is started
    IF sy-subrc <> 0.

      rs_run_check-text = |Run { gv_run_type } is not executed. Start program { gcv_indexer_program_name }.|.
      RETURN.

    ENDIF.

    "Check run status
    IF ls_update_index_run-status = gcs_index_run_status-running.

      rs_run_check-text = |Batch { gv_run_type } is running. Wait...|.
      RETURN.

    ELSEIF ls_update_index_run-status <> gcs_index_run_status-completed.

      rs_run_check-text = |Batch { gv_run_type } has unknown status { ls_update_index_run-status }.|.
      RETURN.

    ENDIF.

    "Check SAP release
    IF ls_update_index_run-sap_release < sy-saprl.

      rs_run_check-text = |SAP is upgraded. Start delta update. ({ ls_update_index_run-sap_release } vs { sy-saprl })|.
      RETURN.

    ENDIF.

    rs_run_check-completed_ind = abap_true.
    rs_run_check-text = |Last update: { ls_update_index_run-end_timestamp  TIMESTAMP = USER TIMEZONE = sy-zonlo }|.

  ENDMETHOD.

  METHOD delete_all.

    DELETE FROM zscv_run.                               "#EC CI_NOWHERE
    COMMIT WORK.

  ENDMETHOD.

  METHOD get_start_timestamp.

    SELECT SINGLE
      FROM zscv_run
      FIELDS start_timestamp
      WHERE run_type = @gv_run_type
      INTO @rv_start_timestamp.

  ENDMETHOD.

  METHOD get_begin_date_time.

    SELECT SINGLE
      FROM zscv_run
      FIELDS start_timestamp
      WHERE run_type = @gv_run_type
      INTO @DATA(lv_start_timestamp).

    CONVERT TIME STAMP lv_start_timestamp TIME ZONE sy-zonlo
      INTO
        DATE ls_begin_date_time-date
        TIME ls_begin_date_time-time.

  ENDMETHOD.

  METHOD get_selection_date_time.

    SELECT SINGLE
      FROM zscv_run
      FIELDS selection_timestamp
      WHERE run_type = @gv_run_type
      INTO @DATA(lv_selection_timestamp).

    CONVERT TIME STAMP lv_selection_timestamp TIME ZONE sy-zonlo
      INTO
        DATE ls_begin_date_time-date
        TIME ls_begin_date_time-time.

  ENDMETHOD.

  METHOD reset.

    SELECT SINGLE
      FROM zscv_run
      FIELDS selection_timestamp
      WHERE run_type = @gv_run_type
      INTO @DATA(lv_selection_timestamp).

    IF sy-subrc = 0.

      _update(
        iv_status          = gcs_index_run_status-completed
        iv_start_timestamp = lv_selection_timestamp ).

    ENDIF.

  ENDMETHOD.

  METHOD set.

    DATA lv_start_timestamp TYPE timestamp.

    CONVERT
      DATE is_begin_date_time-date
      TIME is_begin_date_time-time
      INTO TIME STAMP lv_start_timestamp TIME ZONE  sy-zonlo.

    _update(
      iv_status          = gcs_index_run_status-completed
      iv_start_timestamp = lv_start_timestamp ).

  ENDMETHOD.

ENDCLASS.
