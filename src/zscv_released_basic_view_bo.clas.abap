CLASS zscv_released_basic_view_bo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF gcs__relation_level,
        unknown     TYPE zscv_relation_level VALUE '',
        super       TYPE zscv_relation_level VALUE 'SUPER',
        sub         TYPE zscv_relation_level VALUE 'SUB',
        domain      TYPE zscv_relation_level VALUE 'DOMAIN',
        domain_text TYPE zscv_relation_level VALUE 'DOMAIN_TEXT',
      END OF gcs__relation_level.

    CLASS-METHODS fill_db_table_initially.

    CLASS-METHODS add_db_table_initially.

    CLASS-METHODS create_relation
      IMPORTING iv_db_table_name       TYPE zscv_basic_view-table_name
                iv_cds_view_name       TYPE zscv_basic_view-cds_view_name
                iv_relation_level      TYPE zscv_relation_level
                iv_sap_release         TYPE zscv_basic_view-sap_release OPTIONAL
                iv_not_in_sap_release  TYPE zscv_basic_view-not_in_sap_release OPTIONAL
                iv_check_valid_cds_ind TYPE abap_bool DEFAULT abap_true
                iv_show_message_ind    TYPE abap_bool
      RETURNING VALUE(rr_relation)     TYPE REF TO zscv_released_basic_view_bo.

    CLASS-METHODS get_instance_by_table_name
      IMPORTING iv_db_table_name       TYPE zscv_basic_view-table_name
                iv_cds_view_name       TYPE zscv_basic_view-cds_view_name
                iv_not_found_error_ind TYPE abap_bool DEFAULT abap_true
      RETURNING VALUE(rr_relation)     TYPE REF TO zscv_released_basic_view_bo
      RAISING   zx_scv_return.

    CLASS-METHODS delete_all.

    METHODS update_sap_release.

    METHODS update_relation_level
      IMPORTING iv_relation_level TYPE zscv_relation_level.

    METHODS delete_relation
      RAISING zx_scv_return.

  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA gs_basic_data TYPE zscv_basic_view.

ENDCLASS.

CLASS zscv_released_basic_view_bo IMPLEMENTATION.

  METHOD fill_db_table_initially.

    DATA(lt_basic_views) = zscv_relsd_basic_view_set_dp=>get_content( ).

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

      zscv_released_basic_view_bo=>create_relation(
        iv_db_table_name       = <ls_basic_view>-table_name
        iv_cds_view_name       = <ls_basic_view>-cds_view_name
        iv_relation_level      = <ls_basic_view>-relation_level
        iv_sap_release         = <ls_basic_view>-sap_release
        iv_not_in_sap_release  = <ls_basic_view>-not_in_sap_release
        iv_check_valid_cds_ind = abap_false
        iv_show_message_ind    = abap_false ).

    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_by_table_name.

    SELECT SINGLE *
      FROM zscv_basic_view
      WHERE table_name    = @iv_db_table_name AND
            cds_view_name = @iv_cds_view_name
      INTO @DATA(ls_basic_table_cds_view).

    IF sy-subrc <> 0.

      IF iv_not_found_error_ind = abap_false.
        RETURN.
      ENDIF.

      DATA(lx_return) = NEW zx_scv_return( ).
      lx_return->add_text(
        iv_message = |Released Basic View not found. Db table: { iv_db_table_name }, CDS view: { iv_cds_view_name }.| ).
      RAISE EXCEPTION lx_return.

    ENDIF.

    rr_relation = NEW #( ).

    rr_relation->gs_basic_data = ls_basic_table_cds_view.

  ENDMETHOD.

  METHOD create_relation.

    IF iv_check_valid_cds_ind = abap_true.

      SELECT SINGLE
          abapviewname,
          abapviewtype,
          \_cdsview\_status-c1_releasestate,
          \_cdsview\_status-c1_useincloudplatform,
          \_cdsview\_status-c2_releasestate
        FROM zscv_abapview
        WHERE abapviewname = @iv_cds_view_name
        INTO @DATA(ls_abap_view).

      IF sy-subrc <> 0.
        IF iv_show_message_ind = abap_true.
          MESSAGE |CDS view { iv_cds_view_name } not found.| TYPE 'I' DISPLAY LIKE 'E'.
        ENDIF.
        RETURN.
      ENDIF.

      IF ls_abap_view-abapviewtype  <> 'DDic CDS' AND
         ls_abap_view-abapviewtype  <> 'Entity CDS'.
        IF iv_show_message_ind = abap_true.
          MESSAGE |View type must be CDS and not { ls_abap_view-abapviewtype }.| TYPE 'I' DISPLAY LIKE 'E'.
        ENDIF.
        RETURN.
      ENDIF.

      IF ls_abap_view-c1_releasestate = 'RELEASED'.

        IF ls_abap_view-c1_useincloudplatform <> 'X'.
          IF iv_show_message_ind = abap_true.
            MESSAGE |CDS view has release state C1 but not Use in Cloud Development.| TYPE 'I' DISPLAY LIKE 'E'.
          ENDIF.
          RETURN.
        ENDIF.

      ELSEIF ls_abap_view-c2_releasestate = 'RELEASED'.

      ELSE.
        IF iv_show_message_ind = abap_true.
          MESSAGE |CDS view has not release state C1 or C2.| TYPE 'I' DISPLAY LIKE 'E'.
        ENDIF.
        RETURN.

      ENDIF.

    ENDIF.

    DATA(lr_relation) = get_instance_by_table_name(
      iv_db_table_name       = iv_db_table_name
      iv_cds_view_name       = iv_cds_view_name
      iv_not_found_error_ind = abap_false ).

    IF lr_relation IS NOT INITIAL.

      IF iv_show_message_ind = abap_true.

        IF iv_show_message_ind = abap_true.
          MESSAGE
            |Tabel { iv_db_table_name } is already linked to | &&
            |CDS view { iv_cds_view_name }.|
            TYPE 'I'.
        ENDIF.

      ENDIF.

      lr_relation->update_sap_release( ).

      lr_relation->update_relation_level( iv_relation_level ).

      RETURN.

    ENDIF.

    rr_relation = NEW #( ).

    IF iv_sap_release IS NOT INITIAL.
      DATA(lv_sap_release) = iv_sap_release.
    ELSE.
      lv_sap_release = sy-saprl.
    ENDIF.

    rr_relation->gs_basic_data =
      VALUE zscv_basic_view(
        table_name         = iv_db_table_name
        cds_view_name      = iv_cds_view_name
        relation_level     = iv_relation_level
        sap_release        = lv_sap_release
        not_in_sap_release = iv_not_in_sap_release ).

    INSERT INTO zscv_basic_view
      VALUES @rr_relation->gs_basic_data.

    IF sy-subrc <> 0.
      IF iv_show_message_ind = abap_true.
        MESSAGE
          |Not created: link with tabel { iv_db_table_name },  | &&
          |CDS view { iv_cds_view_name }.|
          TYPE 'E'.
      ENDIF.
      RETURN.
    ENDIF.

    COMMIT WORK.

    rr_relation->update_sap_release( ).

    IF iv_show_message_ind = abap_true.
      MESSAGE
        |Table { rr_relation->gs_basic_data-table_name } is now linked to | &&
        |CDS view { rr_relation->gs_basic_data-cds_view_name  }.|
        TYPE 'S'.
    ENDIF.

  ENDMETHOD.

  METHOD update_sap_release.

    SELECT SINGLE
        ddlsourcename,
        \_status-c1_releasestate,
        \_status-c1_useincloudplatform
      FROM zscv_cdsview
      WHERE ddlsourcename = @me->gs_basic_data-cds_view_name
      INTO @DATA(ls_cds_view).

    IF ls_cds_view-c1_releasestate = 'RELEASED' AND
       ls_cds_view-c1_useincloudplatform = abap_true.

      IF me->gs_basic_data-sap_release <= sy-saprl.
        RETURN.
      ENDIF.

      me->gs_basic_data-sap_release = sy-saprl.

    ELSE.

      IF me->gs_basic_data-not_in_sap_release IS INITIAL OR
         me->gs_basic_data-not_in_sap_release < sy-saprl.
        me->gs_basic_data-not_in_sap_release = sy-saprl.
      ELSE.
        RETURN.
      ENDIF.

    ENDIF.

    UPDATE  zscv_basic_view
      FROM @gs_basic_data.

    COMMIT WORK.

  ENDMETHOD.

  METHOD update_relation_level.

    IF me->gs_basic_data-relation_level = iv_relation_level.
      RETURN.
    ENDIF.

    me->gs_basic_data-relation_level = iv_relation_level.

    UPDATE  zscv_basic_view
      FROM @gs_basic_data.

    COMMIT WORK.

  ENDMETHOD.

  METHOD delete_relation.

    DELETE  zscv_basic_view
      FROM @gs_basic_data.

    IF sy-subrc <> 0.

      DATA(lx_return) = NEW zx_scv_return( ).
      lx_return->add_text(
        iv_message = |Released Basic View { gs_basic_data-table_name } { gs_basic_data-cds_view_name } not found.| ).
      RAISE EXCEPTION lx_return.

    ENDIF.

    COMMIT WORK.

  ENDMETHOD.

  METHOD delete_all.

    DELETE FROM zscv_basic_view.
    COMMIT WORK.

  ENDMETHOD.

  METHOD add_db_table_initially.

    SELECT
        abapviewname, dbtablename
      FROM zscv_releasedc1basicabapview
      INTO TABLE @DATA(lt_basic_views).

    LOOP AT lt_basic_views
      ASSIGNING FIELD-SYMBOL(<ls_basic_view>).

      IF sy-batch = abap_false.

        cl_progress_indicator=>progress_indicate(
          EXPORTING
            i_text               = |CDS { sy-tabix } / { lines( lt_basic_views ) } - { <ls_basic_view>-abapviewname }|
            i_processed          = sy-tabix
            i_total              = lines( lt_basic_views )
            i_output_immediately = abap_false ).

      ENDIF.

      DATA(lr_relation) = zscv_released_basic_view_bo=>get_instance_by_table_name(
        iv_db_table_name = CONV #( <ls_basic_view>-dbtablename )
        iv_cds_view_name = CONV #( <ls_basic_view>-abapviewname )
        iv_not_found_error_ind = abap_false ).

      IF lr_relation IS NOT INITIAL.

        CONTINUE.

      ENDIF.

      IF <ls_basic_view>-dbtablename = 'DD07L'.

        lr_relation =
            zscv_released_basic_view_bo=>create_relation(
              EXPORTING
                iv_db_table_name       = CONV #( <ls_basic_view>-dbtablename )
                iv_cds_view_name       = CONV #( <ls_basic_view>-abapviewname )
                iv_relation_level      = zscv_released_basic_view_bo=>gcs__relation_level-domain
                iv_show_message_ind    = abap_false ).

        CONTINUE.

      ENDIF.

      IF <ls_basic_view>-dbtablename = 'DD07T'.

        lr_relation =
            zscv_released_basic_view_bo=>create_relation(
              EXPORTING
                iv_db_table_name       = CONV #( <ls_basic_view>-dbtablename )
                iv_cds_view_name       = CONV #( <ls_basic_view>-abapviewname )
                iv_relation_level      = zscv_released_basic_view_bo=>gcs__relation_level-domain_text
                iv_show_message_ind    = abap_false ).

        CONTINUE.

      ENDIF.

      SELECT COUNT( * )
        FROM zscv_releasedc1basicabapview
        WHERE
         dbtablename = @<ls_basic_view>-dbtablename
        INTO @DATA(lv_count).

      IF lv_count > 1.

        lr_relation =
            zscv_released_basic_view_bo=>create_relation(
              EXPORTING
                iv_db_table_name       = CONV #( <ls_basic_view>-dbtablename )
                iv_cds_view_name       = CONV #( <ls_basic_view>-abapviewname )
                iv_relation_level      = zscv_released_basic_view_bo=>gcs__relation_level-unknown
                iv_show_message_ind    = abap_false ).

        CONTINUE.

      ENDIF.

      IF lv_count = 1.

        lr_relation =
            zscv_released_basic_view_bo=>create_relation(
              EXPORTING
                iv_db_table_name       = CONV #( <ls_basic_view>-dbtablename )
                iv_cds_view_name       = CONV #( <ls_basic_view>-abapviewname )
                iv_relation_level      = zscv_released_basic_view_bo=>gcs__relation_level-super
                iv_show_message_ind    = abap_false ).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
