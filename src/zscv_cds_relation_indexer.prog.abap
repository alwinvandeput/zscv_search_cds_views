*&---------------------------------------------------------------------*
*& Report zscv_fill_cds_relations
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zscv_cds_relation_indexer.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Selection screen
DATA zscv_cds_rel TYPE zscv_cds_rel.

SELECT-OPTIONS s_cds FOR zscv_cds_rel-child_name.

PARAMETERS p_refrsh AS CHECKBOX DEFAULT 'X'.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Classes
CLASS lcl_cds_parent_child_indexer DEFINITION.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ts_parameters,
        cds_names   TYPE RANGE OF zscv_cds_rel-child_name,
        refresh_ind TYPE abap_bool,
      END OF ts_parameters.

    METHODS constructor
      IMPORTING is_parameters TYPE ts_parameters.

    METHODS execute.

  PRIVATE SECTION.

    DATA gv_parent_ddl_name TYPE zscv_cds_rel-parent_name.
    DATA gs_parameters TYPE ts_parameters.

    METHODS append_union_ast
      IMPORTING ir_union_query TYPE REF TO cl_qlast_union.

    METHODS append_datasource_ast
      IMPORTING ir_datasource_ast TYPE REF TO cl_qlast_datasource.

    METHODS append_child
      IMPORTING iv_child_name TYPE string.

    METHODS append_query_ast
      IMPORTING ir_query_ast TYPE REF TO cl_qlast_query.

    METHODS append_join_datasource
      IMPORTING ir_join_datasource TYPE REF TO cl_qlast_join_datasource.

    METHODS append_statement_ast
      IMPORTING ir_statement_ast TYPE REF TO cl_qlast_ddlstmt.

    CONSTANTS:
      BEGIN OF gcs_relation_types,
        view TYPE trobjtype VALUE 'VIEW',
      END OF gcs_relation_types.

    CONSTANTS:
      BEGIN OF gcs_index_run_status,
        running   TYPE char10 VALUE 'RUNNING',
        completed TYPE char10 VALUE 'COMPLETED',
      END OF gcs_index_run_status.

    METHODS update_run_index
      IMPORTING
        iv_relation_type TYPE trobjtype
        iv_status        TYPE char10.

ENDCLASS.

CLASS lcl_cds_parent_child_indexer IMPLEMENTATION.

  METHOD constructor.

    gs_parameters = is_parameters.

  ENDMETHOD.

  METHOD execute.

    zscv_basic_view_relation_bo=>fill_db_table_initially( ).

    IF p_refrsh = abap_true.

      DELETE FROM zscv_cds_rel.                         "#EC CI_NOWHERE

      COMMIT WORK.

    ENDIF.

    update_run_index(
      iv_relation_type = gcs_relation_types-view
      iv_status        = gcs_index_run_status-running ).

    SELECT ddlname
      FROM ddddlsrc
      INTO TABLE @DATA(lt_ddl_names)
      WHERE ddlname IN @s_cds[]
      ORDER BY ddlname.

    LOOP AT lt_ddl_names
      ASSIGNING FIELD-SYMBOL(<lv_ddl_name>).

      gv_parent_ddl_name = <lv_ddl_name>-ddlname.

      IF sy-batch = abap_false.

        cl_progress_indicator=>progress_indicate(
          EXPORTING
            i_text               = |{ sy-tabix } / { lines( lt_ddl_names ) } - { gv_parent_ddl_name }|
            i_processed          = sy-tabix
            i_total              = lines( lt_ddl_names )
            i_output_immediately = abap_false ).

      ENDIF.

      TRY.

          "Not available on S/4HANA 2020
          "DATA(lr_ddl_abstract_syntax_tree) = cl_qlast_utility=>get_ast_for_active_ddls( <lv_ddl_name>-ddlname ).

          "Now compatible with S/4HANA 2020
          DATA(lr_ddl_abstract_syntax_tree) = cl_qlast_utility=>get_ast_for_ddls(
            i_ddlsname = <lv_ddl_name>-ddlname
            i_version = if_dd_sobject_constants=>get_a ).

          append_statement_ast( lr_ddl_abstract_syntax_tree ).


        CATCH cx_root INTO DATA(lx_root).

          WRITE : / <lv_ddl_name>-ddlname, lx_root->get_text( ).

      ENDTRY.

    ENDLOOP.

    update_run_index(
      iv_relation_type = gcs_relation_types-view
      iv_status        = gcs_index_run_status-completed ).

  ENDMETHOD.

  METHOD update_run_index.

    IF s_cds[] IS INITIAL.

      SELECT SINGLE
        FROM zscv_cds_rel_run
        FIELDS *
        WHERE relation_type = @iv_relation_type
        INTO @DATA(ls_update_index_run).

      IF sy-subrc <> 0.

        ls_update_index_run =
          VALUE zscv_cds_rel_run(
            relation_type = iv_relation_type
            sap_release   = sy-saprl
            status        = iv_status
          ).

        INSERT zscv_cds_rel_run
          FROM ls_update_index_run.

      ELSE.

        ls_update_index_run-status = iv_status.

        UPDATE zscv_cds_rel_run
          FROM ls_update_index_run.

      ENDIF.

      COMMIT WORK.

    ENDIF.

  ENDMETHOD.

  METHOD append_statement_ast.

    CASE TYPE OF ir_statement_ast.

      WHEN TYPE cl_qlast_view_definition INTO DATA(lr_view_ast).

        DATA(lr_select)           = lr_view_ast->get_select( ).

        IF lr_select IS NOT INITIAL.

          append_datasource_ast( lr_select->get_from( ) ).

        ELSE.

          CASE TYPE OF lr_view_ast .

            WHEN TYPE cl_qlast_view_entity_def INTO DATA(lr_entity_view_ast).

              DATA(lr_query)           = lr_entity_view_ast->get_query( ).

              CASE TYPE OF lr_query .

                WHEN TYPE cl_qlast_union INTO DATA(lr_union_query).

                  append_union_ast( lr_union_query ).

                WHEN OTHERS.

                  RETURN.

              ENDCASE.

            WHEN OTHERS.

              RETURN.

          ENDCASE.

        ENDIF.

    ENDCASE.

  ENDMETHOD.

  METHOD append_union_ast.

    DATA(lr_union_left) = ir_union_query->get_left(  ).

    append_query_ast( lr_union_left ).

    DATA(lr_union_right) = ir_union_query->get_right(  ).

    append_query_ast( lr_union_right ).

  ENDMETHOD.

  METHOD append_query_ast.

    CASE TYPE OF ir_query_ast .

      WHEN TYPE cl_qlast_select INTO DATA(lr_select).

        append_datasource_ast( lr_select->get_from( ) ).

      WHEN TYPE cl_qlast_union INTO DATA(lr_union_ast).

        append_union_ast( lr_union_ast ).

    ENDCASE.

  ENDMETHOD.

  METHOD append_datasource_ast.

    CASE TYPE OF ir_datasource_ast.

      WHEN TYPE cl_qlast_table_datasource INTO DATA(lr_table_datasource).

        DATA(lv_child_name) = lr_table_datasource->get_name( ).
        append_child( lv_child_name ).

      WHEN TYPE cl_qlast_join_datasource INTO DATA(lr_join_datasource).

        append_join_datasource( lr_join_datasource ).

      WHEN TYPE cl_qlast_path_datasource INTO DATA(lr_path_datasource).

        "These are associations, so do not add. Example CDS view: demo_cds_assoc_from
        "... as select from demo_cds_assoc_spfli._sflight
        RETURN.

      WHEN OTHERS.

        RETURN.

    ENDCASE.

  ENDMETHOD.

  METHOD append_join_datasource.

    append_datasource_ast( ir_join_datasource->get_left( ) ).

    "Only the left is important for the index.
    "append_datasource_ast( ir_join_datasource->get_right( ) ).

  ENDMETHOD.

  METHOD append_child.

    DATA(lv_child_name) = iv_child_name.

    SELECT SINGLE ddlname
      FROM ddldependency
      WHERE objectname = @iv_child_name
    INTO @DATA(lv_ddl_name).                            "#EC CI_NOORDER

    IF sy-subrc = 0.
      lv_child_name = lv_ddl_name.
    ENDIF.

    SELECT SINGLE
      FROM tadir
      FIELDS pgmid, object, obj_name
      WHERE
        pgmid    = 'R3TR' AND
        ( object  = 'DDLS' OR
          object = 'TABL' ) AND
        obj_name = @lv_child_name
    INTO @DATA(ls_tadir).                                   "#EC WARNOK

    IF sy-subrc <> 0.
      CLEAR ls_tadir.
    ENDIF.

    DATA ls_cds_relation TYPE zscv_cds_rel.

    ls_cds_relation = VALUE #(
      parent_type  = 'DDLS'
      parent_name  = gv_parent_ddl_name
      child_type   = ls_tadir-object
      child_name   = lv_child_name ).

    INSERT zscv_cds_rel
      FROM ls_cds_relation.

    COMMIT WORK.

  ENDMETHOD.

ENDCLASS.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Report events

INITIALIZATION.
**  "TODO: delete code
*  s_cds[] = VALUE #(
*    ( sign   = 'I'
*      option = 'GE'
*      "low    = 'I_PRODUCT'
*      low    = 'I_INBDELIVPARTNERADDRESSTP '
*    ) ).

START-OF-SELECTION.

  DATA(lr_index) = NEW lcl_cds_parent_child_indexer(
    VALUE #(
      cds_names   = s_cds[]
      refresh_ind = p_refrsh ) ).

  lr_index->execute( ).
