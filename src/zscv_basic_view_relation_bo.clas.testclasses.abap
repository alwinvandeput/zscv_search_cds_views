CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      fill_db_table_initially FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD fill_db_table_initially.

    zscv_basic_view_relation_bo=>fill_db_table_initially( ).

  ENDMETHOD.

ENDCLASS.
