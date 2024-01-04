REPORT zscv_search_index_tools LINE-SIZE 240.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Selection screen
DATA zscv_cds_rel TYPE zscv_cds_rel.

SELECTION-SCREEN BEGIN OF BLOCK b_updm WITH FRAME TITLE t_updm.
  PARAMETERS: r_rfrsh  RADIOBUTTON GROUP updm USER-COMMAND updmt DEFAULT 'X',
              r_full   RADIOBUTTON GROUP updm,
              r_delta  RADIOBUTTON GROUP updm,
              r_deltdt RADIOBUTTON GROUP updm,
              r_spec   RADIOBUTTON GROUP updm,
              r_resrun RADIOBUTTON GROUP updm,
              r_setrun RADIOBUTTON GROUP updm.
SELECTION-SCREEN END OF BLOCK b_updm.

"Registered Released Basic CDS Views
SELECTION-SCREEN BEGIN OF BLOCK b_bscvw WITH FRAME TITLE t_bscvw.
  PARAMETERS p_bscdel AS CHECKBOX DEFAULT '' MODIF ID ful.
  PARAMETERS p_bscvw AS CHECKBOX DEFAULT 'X' MODIF ID ful.
  PARAMETERS p_mbscvw AS CHECKBOX DEFAULT 'X' MODIF ID ful.
SELECTION-SCREEN END OF BLOCK b_bscvw.

"CDS Relation Index Table
SELECTION-SCREEN BEGIN OF BLOCK b_cds WITH FRAME TITLE t_cds.
  SELECT-OPTIONS s_cds FOR zscv_cds_rel-child_name MODIF ID ful.
  PARAMETERS p_cdsvw AS CHECKBOX DEFAULT 'X' MODIF ID ful.
  PARAMETERS p_cdsdel AS CHECKBOX DEFAULT '' MODIF ID ful.
SELECTION-SCREEN END OF BLOCK b_cds.

"Main DB Table Name
SELECTION-SCREEN BEGIN OF BLOCK b_dbtbvw WITH FRAME TITLE t_dbtbvw.
  SELECT-OPTIONS s_cds2 FOR zscv_cds_rel-child_name MODIF ID ful.
  PARAMETERS p_dbtbvw AS CHECKBOX DEFAULT 'X' MODIF ID ful.
  SELECTION-SCREEN COMMENT /1(30) dbtabcom MODIF ID ful.
SELECTION-SCREEN END OF BLOCK b_dbtbvw.

"Delta from date
SELECTION-SCREEN BEGIN OF BLOCK b_deltdt WITH FRAME TITLE t_deltdt.
  PARAMETERS p_dldate TYPE syst-datum MODIF ID dlt.
  PARAMETERS p_dltime TYPE syst-uzeit MODIF ID dlt.
SELECTION-SCREEN END OF BLOCK b_deltdt.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Classes

CLASS lcl_main_ctl DEFINITION.

  PUBLIC SECTION.

    METHODS start_of_selection.

ENDCLASS.

CLASS lcl_main_ctl IMPLEMENTATION.

  METHOD start_of_selection.

    IF r_full = abap_true.

      DATA(lr_indexer) = NEW zscv_search_indexer( ).

      lr_indexer->full_update(
        VALUE #(
          basic_view_delete_ind       = abap_true
          basic_view_fill_ind         = abap_true
          basic_view_add_missing_ind  = abap_true

          cds_rel_fill_ind            = abap_true
          cds_rel_delete_ind          = abap_true

          main_db_update_ind          = abap_true ) ).

    ELSEIF r_rfrsh = abap_true.

      lr_indexer = NEW zscv_search_indexer( ).

      lr_indexer->full_update(
        VALUE #(
          basic_view_delete_ind       = abap_false
          basic_view_fill_ind         = abap_true
          basic_view_add_missing_ind  = abap_true

          cds_rel_fill_ind            = abap_true
          cds_rel_delete_ind          = abap_false

          main_db_update_ind          = abap_true ) ).

    ELSEIF r_spec = abap_true.

      lr_indexer = NEW zscv_search_indexer( ).

      lr_indexer->full_update(
        VALUE #(
          basic_view_delete_ind       = p_bscdel
          basic_view_fill_ind         = p_bscvw
          basic_view_add_missing_ind  = p_mbscvw

          cds_rel_cds_view_rng         = s_cds[]
          cds_rel_fill_ind             = p_cdsvw
          cds_rel_delete_ind           = p_cdsdel

          main_db_cds_view_rng   = s_cds2[]
          main_db_update_ind     = p_dbtbvw ) ).

    ELSEIF r_delta = 'X'.

      lr_indexer = NEW zscv_search_indexer( ).

      lr_indexer->delta_update( ).

      MESSAGE |Delta update completed.| TYPE 'S'.

    ELSEIF r_deltdt = 'X'.

      IF p_dldate IS INITIAL OR
         p_dltime IS INITIAL.

        MESSAGE |From date and time have to be filled.| TYPE 'I' DISPLAY LIKE 'E'.

        RETURN.

      ENDIF.

      lr_indexer = NEW zscv_search_indexer( ).

      lr_indexer->delta_update(
        VALUE #(
          date = p_dldate
          time = p_dltime
        ) ).

      MESSAGE |Delta update completed.| TYPE 'S'.

    ELSEIF r_resrun = 'X'.

      lr_indexer = NEW zscv_search_indexer( ).

      lr_indexer->reset_running_runs( ).

      MESSAGE |Runs are reset.| TYPE 'S'.


    ELSEIF r_setrun = 'X'.

      IF p_dldate IS INITIAL OR
         p_dltime IS INITIAL.

        MESSAGE |From date and time have to be filled.| TYPE 'I' DISPLAY LIKE 'E'.

        RETURN.

      ENDIF.

      lr_indexer = NEW zscv_search_indexer( ).

      lr_indexer->set_runs(
        VALUE #(
          date = p_dldate
          time = p_dltime
        ) ).

      MESSAGE |Runs are set.| TYPE 'S'.

    ENDIF.

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

  t_updm = 'Update method'.
  %_r_rfrsh_%_app_%-text  = 'Refresh full update'.
  %_r_full_%_app_%-text   = 'Clean full update'.
  %_r_delta_%_app_%-text  = 'Delta update'.
  %_r_deltdt_%_app_%-text  = 'Delta from date'.
  %_r_spec_%_app_%-text   = 'Specific'.
  %_r_resrun_%_app_%-text = 'Reset running runs'.
  %_r_setrun_%_app_%-text = 'Set run statuses'.

  t_cds = 'CDS View Relations (ZSCV_CDS_REL)'.
  %_p_cdsvw_%_app_%-text = 'Fill CDS View Relations'.
  %_p_cdsdel_%_app_%-text = 'First Delete All'.

  t_dbtbvw = 'Main DB Table Name (ZSCV_CDS_REL-MAIN_DB_TABLE_NAME)'.
  %_p_dbtbvw_%_app_%-text = 'Update Main DB Table Name'.
  "This process must be processed after all CDS relations are known.
  dbtabcom = 'Started after CDS relations.'.

  t_bscvw = 'DB table to Basic View Relations (ZSCV_BASIC_VIEW)'.
  %_p_bscvw_%_app_%-text = 'Fill Basic View Relations'.
  %_p_mbscvw_%_app_%-text = 'Add Missing Basic View Rel.'.
  %_p_bscdel_%_app_%-text = 'First Delete All'.

  %_s_cds2_%_app_%-text = 'CDS Views'.

  t_deltdt = 'Run from date / time'.
  %_p_dldate_%_app_%-text = 'From Date'.
  %_p_dltime_%_app_%-text = 'From Time'.


  DATA(lr_run) = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-cds_relation ).
  DATA(ls_date_time) = lr_run->get_selection_date_time( ).
  IF ls_date_time IS INITIAL.
    p_dldate = sy-datum.
    p_dltime = syst-uzeit.
  ELSE.
    p_dldate = ls_date_time-date.
    p_dltime = ls_date_time-time.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.

    CASE screen-group1.

      WHEN 'FUL'.

        IF r_spec = 'X'.
          screen-invisible = 0.
          screen-active = 1.
          screen-input = 1.
        ELSE.
          screen-invisible = 1.
          screen-active = 0.
          screen-input = 0.
        ENDIF.

        MODIFY SCREEN.

      WHEN 'DLT'.

        IF r_deltdt = 'X' OR r_setrun = 'X'.
          screen-invisible = 0.
          screen-active = 1.
          screen-input = 1.
        ELSE.
          screen-invisible = 1.
          screen-active = 0.
          screen-input = 0.
        ENDIF.

        MODIFY SCREEN.

    ENDCASE.

  ENDLOOP.

START-OF-SELECTION.

  DATA(lr_index) = NEW lcl_main_ctl( ).

  lr_index->start_of_selection( ).
