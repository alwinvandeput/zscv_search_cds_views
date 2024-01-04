CLASS zscv_cds_relation_bo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF gts_key,
        parent_type TYPE zscv_cds_rel-parent_type,
        parent_name TYPE zscv_cds_rel-parent_name,
        child_type  TYPE zscv_cds_rel-child_type,
        child_name  TYPE zscv_cds_rel-child_name,
      END OF gts_key,

      gtt_parent_name_rng TYPE RANGE OF zscv_cds_rel-parent_name.

    CLASS-METHODS delete_all.

    CLASS-METHODS create_new
      IMPORTING is_cds_relation           TYPE zscv_cds_rel
      RETURNING VALUE(rr_cds_relation_bo) TYPE REF TO zscv_cds_relation_bo.

    CLASS-METHODS get_cds_relation_bo
      IMPORTING is_key                    TYPE gts_key
      RETURNING VALUE(rr_cds_relation_bo) TYPE REF TO zscv_cds_relation_bo
      RAISING   zx_scv_return.

    CLASS-METHODS fill_main_db_table_name
      IMPORTING it_parent_name_rng TYPE gtt_parent_name_rng.

    CLASS-METHODS fill_main_db_table_delta
      IMPORTING is_begin_date_time type zscv_run_bo=>ts_begin_date_time.

    CLASS-METHODS delete_parent
      IMPORTING
        parent_type TYPE zscv_cds_rel-parent_type
        parent_name TYPE zscv_cds_rel-parent_name.

    METHODS update_main_db_table_name
      IMPORTING
        iv_main_db_table_name TYPE zscv_cds_rel-main_db_table_name.
    METHODS delete.

  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA gs_cds_relation TYPE zscv_cds_rel.

    CLASS-METHODS cds_view_main_db_table
      IMPORTING
        is_cds_rel TYPE zscv_cds_rel.

ENDCLASS.

CLASS zscv_cds_relation_bo IMPLEMENTATION.

  METHOD delete_all.

    DELETE FROM zscv_cds_rel.                           "#EC CI_NOWHERE
    COMMIT WORK.

  ENDMETHOD.

  METHOD create_new.

    SELECT SINGLE
      FROM zscv_cds_rel
      FIELDS *
      WHERE
        parent_type    = @is_cds_relation-parent_type AND
        parent_name    = @is_cds_relation-parent_name AND
        child_type     = @is_cds_relation-child_type AND
        child_name     = @is_cds_relation-child_name
      INTO @DATA(ls_cds_relation).

    IF sy-subrc <> 0.

      INSERT zscv_cds_rel
        FROM is_cds_relation.

    ELSE.

      UPDATE zscv_cds_rel
        SET
          parent_ddl_type = is_cds_relation-parent_ddl_type
        WHERE
         parent_type      = is_cds_relation-parent_type AND
         parent_name      = is_cds_relation-parent_name AND
         child_type       = is_cds_relation-child_type AND
         child_name       = is_cds_relation-child_name.

    ENDIF.

    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

    rr_cds_relation_bo = NEW #( ).

    rr_cds_relation_bo->gs_cds_relation = is_cds_relation.

  ENDMETHOD.


  METHOD get_cds_relation_bo.

    rr_cds_relation_bo = NEW #( ).

    SELECT SINGLE *
      FROM zscv_cds_rel
      WHERE
        parent_type = @is_key-parent_type AND
        parent_name = @is_key-parent_name AND
        child_type  = @is_key-child_type AND
        child_name  = @is_key-child_name
      INTO @rr_cds_relation_bo->gs_cds_relation.

    IF sy-subrc <> 0.

      DATA(lx_return) = NEW zx_scv_return( ).
      lx_return->add_text(
        iv_message =
          |CDS relation does not exist. | &&
          || ).
      RAISE EXCEPTION lx_return.

    ENDIF.

  ENDMETHOD.

  METHOD update_main_db_table_name.

    UPDATE zscv_cds_rel
      SET main_db_table_name = iv_main_db_table_name
      WHERE
        parent_type  = gs_cds_relation-parent_type AND
        parent_name  = gs_cds_relation-parent_name AND
        child_type   = gs_cds_relation-child_type AND
        child_name   = gs_cds_relation-child_name.

    COMMIT WORK.

  ENDMETHOD.

  METHOD fill_main_db_table_name.

    DATA ls_cds_rel TYPE zscv_cds_rel.

    SELECT
      FROM zscv_cds_rel
      FIELDS
        *
      WHERE
        parent_name IN @it_parent_name_rng[]
      INTO TABLE @DATA(lt_cds_relations).

    LOOP AT lt_cds_relations
      ASSIGNING FIELD-SYMBOL(<ls_cds_relation>).

      IF sy-batch = abap_false.

        cl_progress_indicator=>progress_indicate(
          EXPORTING
            i_text               = |Update Root DB table: { sy-tabix } / { lines( lt_cds_relations ) } - { <ls_cds_relation>-parent_name }|
            i_processed          = sy-tabix
            i_total              = lines( lt_cds_relations )
            i_output_immediately = abap_false ).

      ENDIF.

      cds_view_main_db_table( <ls_cds_relation> ).

    ENDLOOP.

  ENDMETHOD.

  METHOD fill_main_db_table_delta.

    SELECT
      FROM zscv_cds_rel AS relation
      LEFT JOIN ddddlsrc AS ddl_source ON ddl_source~ddlname = relation~parent_name
      FIELDS
        relation~parent_type,
        relation~parent_name,
        relation~child_type,
        relation~child_name,
        relation~parent_ddl_type,
        relation~main_db_table_name,
        as4date,
        as4time
      WHERE
        (
          as4date > @is_begin_date_time-date
          OR
          ( as4date =  @is_begin_date_time-date AND
            as4time >= @is_begin_date_time-time )
          OR
          as4date IS NULL
        )
      ORDER BY ddlname
      INTO TABLE @DATA(lt_ddl_sources).

    LOOP AT lt_ddl_sources
      ASSIGNING FIELD-SYMBOL(<ls_cds_relation>).

      IF sy-batch = abap_false.

        cl_progress_indicator=>progress_indicate(
          EXPORTING
            i_text               = |Update Root DB table: { sy-tabix } / { lines( lt_ddl_sources ) } - { <ls_cds_relation>-parent_name }|
            i_processed          = sy-tabix
            i_total              = lines( lt_ddl_sources )
            i_output_immediately = abap_false ).

      ENDIF.

      DATA(ls_cds_relation) = CORRESPONDING zscv_cds_rel( <ls_cds_relation> ).

      cds_view_main_db_table( ls_cds_relation ).

    ENDLOOP.

  ENDMETHOD.

  METHOD cds_view_main_db_table.

    SELECT
      FROM zscv_cdsview_rootchild( p_abapviewname = @is_cds_rel-parent_name )
      FIELDS
        abapviewname,
        childabapviewname
      INTO TABLE @DATA(lt_rootchild).

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DATA(lv_lines) = lines( lt_rootchild ).

    TRY.

        DATA(lr_cds_relation_bo) = zscv_cds_relation_bo=>get_cds_relation_bo(
          VALUE #(
            parent_type  = is_cds_rel-parent_type
            parent_name  = is_cds_rel-parent_name
            child_type   = is_cds_rel-child_type
            child_name   = is_cds_rel-child_name ) ).

      CATCH cx_root INTO DATA(lx_root).

        "This will not happen

    ENDTRY.

    IF lv_lines > 1.

      lr_cds_relation_bo->update_main_db_table_name( CONV #( lv_lines ) ).

      RETURN.

    ENDIF.

    DATA(lv_child_abap_view_name) = lt_rootchild[ 1 ]-childabapviewname.
    DATA(lv_child_abap_view_name_length) = strlen( lv_child_abap_view_name ).

    DATA lv_main_db_table_name TYPE tabname16.
    CLEAR lv_main_db_table_name.

    CASE lv_child_abap_view_name.
      WHEN 'DD07V'.
        lv_main_db_table_name = 'DD07T'.
      WHEN 'V_MARC_MD'.
        lv_main_db_table_name = 'MARC'.
    ENDCASE.

    IF lv_main_db_table_name IS INITIAL AND lv_child_abap_view_name_length <= 16.

      "Check root child is DB table (and not a CDS Table Function)
      SELECT SINGLE
        FROM dd02l
        FIELDS
          tabname
        WHERE
          ( as4local = 'L' OR as4local = 'A' OR as4local = 'N' ) AND
          tabname = @lv_child_abap_view_name AND
          tabclass = 'TRANSP'
        INTO @DATA(ls_dd02l).

      IF sy-subrc = 0.

        lv_main_db_table_name = CONV tabname16( lv_child_abap_view_name ).

      ENDIF.

    ENDIF.

    IF lv_main_db_table_name IS INITIAL.

      SELECT SINGLE
        FROM tadir
        FIELDS object, obj_name
        WHERE
          pgmid     = 'R3TR' AND
          object    = 'DDLS' AND
          obj_name  = @lv_child_abap_view_name
        INTO @DATA(ls_tadir).

      IF sy-subrc = 0.
        lv_main_db_table_name = '<Non-view DDLS>'.
      ENDIF.

    ENDIF.

    IF lv_main_db_table_name IS INITIAL.
      lv_main_db_table_name = '<Unknow>'.
    ENDIF.

    IF is_cds_rel-main_db_table_name <> lv_main_db_table_name.

      lr_cds_relation_bo->update_main_db_table_name( lv_main_db_table_name ).

    ENDIF.

  ENDMETHOD.

  METHOD delete.

    DELETE FROM zscv_cds_rel
      WHERE
        parent_type  = gs_cds_relation-parent_type AND
        parent_name  = gs_cds_relation-parent_name AND
        child_type   = gs_cds_relation-child_type AND
        child_name   = gs_cds_relation-child_name.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    COMMIT WORK.

  ENDMETHOD.


  METHOD delete_parent.

    DELETE
      FROM zscv_cds_rel
      WHERE
        parent_type  = parent_type AND
        parent_name  = parent_name.

    IF sy-subrc = 0.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
