CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS      create FOR TESTING.
    METHODS      delete FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD create.

    DATA(lr_relation_bo) =
      zscv_cds_relation_bo=>create_new(
        VALUE #(
          parent_type        = 'DDLS'
          parent_name        = '////TEST2'
          child_type         = 'DDLS'
          child_name         = '////TEST2'
          main_db_table_name = 'ZZTEST'
        )
       ).

  ENDMETHOD.

  METHOD delete.

    DATA(lr_relation_bo) =
      zscv_cds_relation_bo=>get_cds_relation_bo(
        VALUE #(
          parent_type     = 'DDLS'
          parent_name     = '////TEST2'
          child_type      = 'DDLS'
          child_name      = '////TEST2'
        )
       ).

       lr_relation_bo->delete( ).

  ENDMETHOD.

ENDCLASS.
