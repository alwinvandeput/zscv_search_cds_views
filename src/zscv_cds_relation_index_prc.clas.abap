CLASS zscv_cds_relation_index_prc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES gtt_cds_view_rng TYPE RANGE OF ddddlsrc-ddlname.

    METHODS execute_full_update
      IMPORTING it_cds_view_rng TYPE gtt_cds_view_rng.

    METHODS execute_delta_update
      IMPORTING is_begin_date_time TYPE zscv_run_bo=>ts_begin_date_time.

  PRIVATE SECTION.

    TYPES gtv_ddl_type TYPE c LENGTH 20.

    CONSTANTS:
      BEGIN OF gcs_ddl_type,
        view                  TYPE gtv_ddl_type VALUE 'View',
        view_with_path_source TYPE gtv_ddl_type VALUE 'View Path Source',
        union_view            TYPE gtv_ddl_type VALUE 'Union View',
        abstract_entity       TYPE gtv_ddl_type VALUE 'Abstract Entity',
      END OF gcs_ddl_type.

    TYPES gtt_cds_rel_update TYPE STANDARD TABLE OF zscv_cds_rel.

    DATA gt_cds_rel_update TYPE gtt_cds_rel_update.

    METHODS process_cds_view
      IMPORTING
        iv_ddl_name TYPE ddddlsrc-ddlname.

    METHODS update
      IMPORTING
        iv_ddl_name       TYPE ddddlsrc-ddlname
        it_cds_rel_update TYPE gtt_cds_rel_update.

    METHODS delete_incorrect_relations
      IMPORTING
        iv_ddl_name       TYPE ddddlsrc-ddlname
        it_cds_rel_update TYPE gtt_cds_rel_update.

    METHODS upsert_relations
      IMPORTING
        it_cds_rel_update TYPE gtt_cds_rel_update.

    METHODS append_union_ast
      IMPORTING
        iv_parent_ddl_name TYPE zscv_cds_rel-parent_name
        iv_parent_ddl_type TYPE gtv_ddl_type
        ir_union_query     TYPE REF TO cl_qlast_union.

    METHODS append_datasource_ast
      IMPORTING
        iv_parent_ddl_name TYPE zscv_cds_rel-parent_name
        iv_parent_ddl_type TYPE gtv_ddl_type
        ir_datasource_ast  TYPE REF TO cl_qlast_datasource.

    METHODS append_child
      IMPORTING iv_parent_ddl_name TYPE zscv_cds_rel-parent_name
                iv_parent_ddl_type TYPE gtv_ddl_type
                iv_child_name      TYPE string OPTIONAL.

    METHODS append_query_ast
      IMPORTING
        iv_parent_ddl_name TYPE zscv_cds_rel-parent_name
        iv_parent_ddl_type TYPE gtv_ddl_type
        ir_query_ast       TYPE REF TO cl_qlast_query.

    METHODS append_join_datasource
      IMPORTING
        iv_parent_ddl_name TYPE zscv_cds_rel-parent_name
        iv_parent_ddl_type TYPE gtv_ddl_type
        ir_join_datasource TYPE REF TO cl_qlast_join_datasource.

    METHODS append_statement_ast
      IMPORTING
        iv_parent_ddl_name TYPE zscv_cds_rel-parent_name
        ir_statement_ast   TYPE REF TO cl_qlast_ddlstmt.

    METHODS remove_deleted_views.

ENDCLASS.

CLASS zscv_cds_relation_index_prc IMPLEMENTATION.

  METHOD append_statement_ast.

    CASE TYPE OF ir_statement_ast.

      WHEN TYPE cl_qlast_view_definition INTO DATA(lr_view_ast).

        DATA(lr_select)           = lr_view_ast->get_select( ).

        IF lr_select IS NOT INITIAL.

          append_datasource_ast(
            iv_parent_ddl_name = iv_parent_ddl_name
            iv_parent_ddl_type = gcs_ddl_type-view
            ir_datasource_ast  = lr_select->get_from( ) ).

        ELSE.

          CASE TYPE OF lr_view_ast .

            WHEN TYPE cl_qlast_view_entity_def INTO DATA(lr_entity_view_ast).

              DATA(lr_query)           = lr_entity_view_ast->get_query( ).

              CASE TYPE OF lr_query .

                WHEN TYPE cl_qlast_union INTO DATA(lr_union_query).

                  append_union_ast(
                    iv_parent_ddl_name = iv_parent_ddl_name
                    iv_parent_ddl_type = gcs_ddl_type-union_view
                    ir_union_query     = lr_union_query ).

                WHEN OTHERS.

                  RETURN.

              ENDCASE.

            WHEN OTHERS.

              RETURN.

          ENDCASE.

        ENDIF.

      WHEN TYPE cl_qlast_abstract_entity.

        append_child(
          iv_parent_ddl_name = iv_parent_ddl_name
          iv_parent_ddl_type = gcs_ddl_type-abstract_entity ).

    ENDCASE.

  ENDMETHOD.

  METHOD append_union_ast.

    DATA(lr_union_left) = ir_union_query->get_left(  ).

    append_query_ast(
      iv_parent_ddl_name = iv_parent_ddl_name
      iv_parent_ddl_type = iv_parent_ddl_type
      ir_query_ast       = lr_union_left ).

    DATA(lr_union_right) = ir_union_query->get_right(  ).

    append_query_ast(
      iv_parent_ddl_name = iv_parent_ddl_name
      iv_parent_ddl_type = iv_parent_ddl_type
      ir_query_ast       = lr_union_right ).

  ENDMETHOD.

  METHOD append_query_ast.

    CASE TYPE OF ir_query_ast .

      WHEN TYPE cl_qlast_select INTO DATA(lr_select).

        append_datasource_ast(
          iv_parent_ddl_name = iv_parent_ddl_name
          iv_parent_ddl_type = iv_parent_ddl_type
          ir_datasource_ast  = lr_select->get_from( ) ).

      WHEN TYPE cl_qlast_union INTO DATA(lr_union_ast).

        append_union_ast(
          iv_parent_ddl_name = iv_parent_ddl_name
          iv_parent_ddl_type = iv_parent_ddl_type
          ir_union_query     = lr_union_ast ).

    ENDCASE.

  ENDMETHOD.

  METHOD append_datasource_ast.

    CASE TYPE OF ir_datasource_ast.

      WHEN TYPE cl_qlast_table_datasource INTO DATA(lr_table_datasource).

        DATA(lv_child_name) = lr_table_datasource->get_name( ).
        append_child(
          iv_parent_ddl_name = iv_parent_ddl_name
          iv_parent_ddl_type = iv_parent_ddl_type
          iv_child_name      = lv_child_name ).

      WHEN TYPE cl_qlast_join_datasource INTO DATA(lr_join_datasource).

        append_join_datasource(
          iv_parent_ddl_name = iv_parent_ddl_name
          iv_parent_ddl_type = iv_parent_ddl_type
          ir_join_datasource = lr_join_datasource ).

      WHEN TYPE cl_qlast_path_datasource INTO DATA(lr_path_datasource).

        "These are associations, so do not add. Example CDS view: demo_cds_assoc_from
        "... as select from demo_cds_assoc_spfli._sflight
        append_child(
          iv_parent_ddl_name = iv_parent_ddl_name
          iv_parent_ddl_type = gcs_ddl_type-view_with_path_source
          iv_child_name      = '' ).

      WHEN OTHERS.

        RETURN.

    ENDCASE.

  ENDMETHOD.

  METHOD append_join_datasource.

    append_datasource_ast(
      iv_parent_ddl_name = iv_parent_ddl_name
      iv_parent_ddl_type = iv_parent_ddl_type
      ir_datasource_ast  = ir_join_datasource->get_left( ) ).

    "Only the left is important for the index.
    "append_datasource_ast( ir_join_datasource->get_right( ) ).

  ENDMETHOD.

  METHOD append_child.

    CASE iv_parent_ddl_type.

      WHEN gcs_ddl_type-view OR gcs_ddl_type-union_view.

        DATA(lv_child_name) = iv_child_name.

        SELECT SINGLE ddlname
          FROM ddldependency
          WHERE objectname = @iv_child_name
        INTO @DATA(lv_ddl_name).                        "#EC CI_NOORDER

        IF sy-subrc = 0.
          lv_child_name = lv_ddl_name.
        ENDIF.

        SELECT SINGLE
          FROM tadir
          FIELDS pgmid, object, obj_name
          WHERE
            pgmid    = 'R3TR' AND
            ( object = 'DDLS' OR
              object = 'TABL' OR
              object = 'VIEW' ) AND
            obj_name = @lv_child_name
        INTO @DATA(ls_tadir).                               "#EC WARNOK

        IF sy-subrc <> 0.
          CLEAR ls_tadir.
        ENDIF.

      WHEN gcs_ddl_type-abstract_entity.

    ENDCASE.

    APPEND
      VALUE #(
        parent_type     = 'DDLS'
        parent_name     = iv_parent_ddl_name
        parent_ddl_type = iv_parent_ddl_type
        child_type      = ls_tadir-object
        child_name      = lv_child_name
      )
      TO gt_cds_rel_update.

  ENDMETHOD.

  METHOD execute_full_update.

    SELECT ddlsourcename
      FROM zscv_cdsview
      INTO TABLE @DATA(lt_cdsview)
      WHERE ddlsourcename IN @it_cds_view_rng "s_cds[]
      ORDER BY ddlsourcename.

    DATA(lv_source_count) = lines( lt_cdsview ).

    LOOP AT lt_cdsview
      ASSIGNING FIELD-SYMBOL(<ls_ddl_source>).

      IF sy-batch = abap_false.

        cl_progress_indicator=>progress_indicate(
          EXPORTING
            i_text               = |CDS rel. { sy-tabix } / { lv_source_count } - { <ls_ddl_source>-ddlsourcename }|
            i_processed          = sy-tabix
            i_total              = lv_source_count
            i_output_immediately = abap_false ).

      ENDIF.

      process_cds_view( <ls_ddl_source>-ddlsourcename ).

    ENDLOOP.

    remove_deleted_views( ).

  ENDMETHOD.

  METHOD execute_delta_update.

    SELECT ddlname, as4date, as4time
      FROM ddddlsrc
      INTO TABLE @DATA(lt_ddl_sources)
      WHERE
        (
          as4date > @is_begin_date_time-date
          OR
          ( as4date =  @is_begin_date_time-date AND
            as4time >= @is_begin_date_time-time )
        )
      ORDER BY ddlname.

    DATA(lv_source_count) = lines( lt_ddl_sources ).

    LOOP AT lt_ddl_sources
      ASSIGNING FIELD-SYMBOL(<ls_ddl_source>).

      IF sy-batch = abap_false.

        cl_progress_indicator=>progress_indicate(
          EXPORTING
            i_text               = |CDS rel. { sy-tabix } / { lv_source_count } - { <ls_ddl_source>-ddlname }|
            i_processed          = sy-tabix
            i_total              = lv_source_count
            i_output_immediately = abap_false ).

      ENDIF.

      process_cds_view( <ls_ddl_source>-ddlname ).

    ENDLOOP.

    remove_deleted_views( ).

  ENDMETHOD.

  METHOD process_cds_view.

    TRY.

        REFRESH gt_cds_rel_update.

        "Not available on S/4HANA 2020
        "DATA(lr_ddl_abstract_syntax_tree) = cl_qlast_utility=>get_ast_for_active_ddls( <lv_ddl_name>-ddlname ).

        "Now compatible with S/4HANA 2020
        DATA(lr_ddl_abstract_syntax_tree) = cl_qlast_utility=>get_ast_for_ddls(
          i_ddlsname = iv_ddl_name
          i_version  = if_dd_sobject_constants=>get_a ).

        append_statement_ast(
          iv_parent_ddl_name = iv_ddl_name
          ir_statement_ast   = lr_ddl_abstract_syntax_tree ).

        "TODO
        update(
          iv_ddl_name       = iv_ddl_name
          it_cds_rel_update = gt_cds_rel_update ).

        REFRESH gt_cds_rel_update.

      CATCH cx_root INTO DATA(lx_root).

        DATA(lv_text) = lx_root->get_text( ).

        DATA(lv_class_name) = cl_abap_classdescr=>get_class_name( lx_root ).

        WRITE : / iv_ddl_name, lv_class_name(50), lv_text.

    ENDTRY.

  ENDMETHOD.

  METHOD update.

    "Delete incorrect relations.
    delete_incorrect_relations(
      iv_ddl_name       = iv_ddl_name
      it_cds_rel_update = it_cds_rel_update ).

    "Insert new and updated records.
    upsert_relations(
      it_cds_rel_update = it_cds_rel_update ).

  ENDMETHOD.

  METHOD delete_incorrect_relations.

    SELECT
    FROM zscv_cds_rel
    FIELDS *
    WHERE
      parent_type  = 'DDLS' AND
      parent_name  = @iv_ddl_name
    INTO TABLE @DATA(lt_current_records).

    LOOP AT lt_current_records
      ASSIGNING FIELD-SYMBOL(<ls_current_record>).

      READ TABLE it_cds_rel_update
        WITH KEY
          parent_type     = <ls_current_record>-parent_type
          parent_name     = <ls_current_record>-parent_name
          child_type      = <ls_current_record>-child_type
          child_name      = <ls_current_record>-child_name
        TRANSPORTING NO FIELDS.

      IF sy-subrc <> 0.

        DELETE FROM zscv_cds_rel
          WHERE
          parent_type     = <ls_current_record>-parent_type AND
          parent_name     = <ls_current_record>-parent_name AND
          child_type      = <ls_current_record>-child_type AND
          child_name      = <ls_current_record>-child_name.

        COMMIT WORK.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD upsert_relations.

    LOOP AT it_cds_rel_update
      ASSIGNING FIELD-SYMBOL(<ls_cds_rel_update>).

      zscv_cds_relation_bo=>create_new(
        VALUE #(
          parent_type     = <ls_cds_rel_update>-parent_type
          parent_name     = <ls_cds_rel_update>-parent_name
          parent_ddl_type = <ls_cds_rel_update>-parent_ddl_type
          child_type      = <ls_cds_rel_update>-child_type
          child_name      = <ls_cds_rel_update>-child_name ) ).

    ENDLOOP.

  ENDMETHOD.

  METHOD remove_deleted_views.

    SELECT
      FROM zscv_deletedrelationcdsviews
      FIELDS *
      INTO TABLE @DATA(deleted_cds_views).

    LOOP AT deleted_cds_views
      ASSIGNING FIELD-SYMBOL(<deleted_cds_view>).

      DELETE
        FROM zscv_cds_rel
        WHERE
          parent_type = <deleted_cds_view>-parenttype AND
          parent_name = <deleted_cds_view>-parentname AND
          child_type  = <deleted_cds_view>-childtype AND
          child_name  = <deleted_cds_view>-childname.

      COMMIT WORK.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

