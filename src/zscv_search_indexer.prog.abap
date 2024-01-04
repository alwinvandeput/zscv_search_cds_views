REPORT zscv_search_indexer LINE-SIZE 240.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Selection screen
DATA zscv_cds_rel TYPE zscv_cds_rel.

SELECTION-SCREEN BEGIN OF BLOCK b_updm WITH FRAME TITLE t_updm.
  PARAMETERS: r_rfrsh RADIOBUTTON GROUP updm USER-COMMAND updmt DEFAULT 'X',
              r_delta RADIOBUTTON GROUP updm.
SELECTION-SCREEN END OF BLOCK b_updm.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Classes

CLASS lcl_main_ctl DEFINITION.

  PUBLIC SECTION.

    METHODS start_of_selection.

ENDCLASS.

CLASS lcl_main_ctl IMPLEMENTATION.

  METHOD start_of_selection.

    IF r_rfrsh = abap_true.

      DATA(lr_indexer) = NEW zscv_search_indexer( ).

      lr_indexer->full_update(
        VALUE #(
          basic_view_delete_ind       = abap_false
          basic_view_fill_ind         = abap_true
          basic_view_add_missing_ind  = abap_true

          cds_rel_fill_ind            = abap_true
          cds_rel_delete_ind          = abap_false

          main_db_update_ind          = abap_true ) ).

    ELSEIF r_delta = 'X'.

      lr_indexer = NEW zscv_search_indexer( ).

      lr_indexer->delta_update( ).

      MESSAGE |Delta update completed.| TYPE 'S'.


    ENDIF.

  ENDMETHOD.

ENDCLASS.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Report events

INITIALIZATION.

  t_updm = 'Update method'.
  %_r_rfrsh_%_app_%-text  = 'Refresh full update'.
  %_r_delta_%_app_%-text  = 'Delta update'.

START-OF-SELECTION.

  DATA(lr_index) = NEW lcl_main_ctl( ).

  lr_index->start_of_selection( ).
