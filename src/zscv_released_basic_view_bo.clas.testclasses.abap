CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS fill_db_table_initially . "FOR TESTING RAISING cx_static_check.

    METHODS create ."FOR TESTING.
    METHODS delete ."FOR TESTING RAISING cx_static_check.

    METHODS add_db_table_initially FOR TESTING.

ENDCLASS.

CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD fill_db_table_initially.

    zscv_released_basic_view_bo=>fill_db_table_initially( ).

  ENDMETHOD.

  METHOD create.

    DATA(lr_relation_bo) =
      zscv_released_basic_view_bo=>create_relation(
        iv_db_table_name       = 'ZZTEST_DB'
        iv_cds_view_name       = 'ZZTEST_CDS999'
        iv_relation_level      = zscv_released_basic_view_bo=>gcs__relation_level-super
        iv_check_valid_cds_ind = abap_false
        iv_show_message_ind    = abap_false ).

  ENDMETHOD.

  METHOD delete.

    DATA(lr_relation_bo) =
      zscv_released_basic_view_bo=>get_instance_by_table_name(
        iv_db_table_name = 'ZZTEST_DB'
        iv_cds_view_name = 'ZZTEST_CDS999' ).

    lr_relation_bo->delete_relation( ).

  ENDMETHOD.

  METHOD add_db_table_initially.

    zscv_released_basic_view_bo=>add_db_table_initially( ).

  ENDMETHOD.

ENDCLASS.
