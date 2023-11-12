*&---------------------------------------------------------------------*
*& Report zsccv_basic_cds_view_updater
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsccv_sap_release_updater.

START-OF-SELECTION.

  SELECT *
    FROM zscv_basic_view
    INTO TABLE @DATA(lt_basic_views).

  LOOP AT lt_basic_views
    ASSIGNING FIELD-SYMBOL(<ls_basic_view>).

    IF sy-batch = abap_false.

      cl_progress_indicator=>progress_indicate(
        EXPORTING
          i_text               = |{ sy-tabix } / { lines( lt_basic_views ) } - { <ls_basic_view>-table_name } - { <ls_basic_view>-cds_view_name }|
          i_processed          = sy-tabix
          i_total              = lines( lt_basic_views )
          i_output_immediately = abap_true ).

    ENDIF.

    DATA(lr_basic_view_relation) =
      zscv_basic_view_relation_bo=>get_instance_by_table_name(
        iv_db_table_name = <ls_basic_view>-table_name
        iv_cds_view_name = <ls_basic_view>-cds_view_name ).

    IF lr_basic_view_relation IS INITIAL.
      CONTINUE.
    ENDIF.

    lr_basic_view_relation->update_sap_release( ).

  ENDLOOP.
