REPORT zscv_search_cds_views.

"--------------------------------------------------------------------
"Date        : 04.03.2023
"Last update : 11.11.2023
"Author      : Alwin van de Put
"
"Purpose:
"Search all related ABAP views hierarchically.
"
"ABAP views are:
"- ZSCV_DdicTable     = Database tables
"- ZSCV_DdicView      = DDic views
"- ZSCV_DdicView      = DDic CDS views -> must be changed
"- ZSCV_EntityCdsView = Entity CDS views

"- ZSCV_AbapView      = All the above views
"- ZSCV_CdsView       = DDic CDS views + Entity CDS views

"--------------------------------------------------------------------

TABLES: ars_w_api_state, dd26s, sscrfields.
DATA db_view_name_type TYPE vibastab.

SELECTION-SCREEN BEGIN OF BLOCK view_index WITH FRAME TITLE tt_index.

  SELECTION-SCREEN COMMENT /1(70) rel_ts.
  SELECTION-SCREEN PUSHBUTTON /2(30) delta USER-COMMAND delta.

SELECTION-SCREEN END OF BLOCK view_index.

SELECTION-SCREEN BEGIN OF BLOCK srch_mth WITH FRAME TITLE tt_srch.

  PARAMETERS r_shhier  RADIOBUTTON GROUP srch USER-COMMAND srch DEFAULT 'X'.
  PARAMETERS r_shdbtb RADIOBUTTON GROUP srch.

SELECTION-SCREEN END OF BLOCK srch_mth.

SELECTION-SCREEN BEGIN OF BLOCK basicvw WITH FRAME TITLE tbasic.

  SELECT-OPTIONS s_bstab FOR db_view_name_type MODIF ID dbt.
  SELECTION-SCREEN COMMENT /1(70) dbtab_ts MODIF ID dbt.

SELECTION-SCREEN END OF BLOCK basicvw.

SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME.

  "Source view name selection
  SELECTION-SCREEN BEGIN OF BLOCK dbtab WITH FRAME TITLE tt_view .

    "All tables
    SELECTION-SCREEN  PUSHBUTTON 1(10) pb_alltb USER-COMMAND dball MODIF ID hrs.
    "Get successor CDS view
    SELECTION-SCREEN  PUSHBUTTON 13(20) pb_succr USER-COMMAND dbsucc MODIF ID hrs.
    "Compatibility tables
    SELECTION-SCREEN  PUSHBUTTON 41(20) pb_comp USER-COMMAND compdb MODIF ID hrs.

    SELECT-OPTIONS s_dbtab FOR db_view_name_type NO INTERVALS NO-EXTENSION MODIF ID hrs.

    SELECTION-SCREEN SKIP.

    DATA db_field_name_type TYPE fieldname.
    SELECT-OPTIONS s_fldnm FOR db_view_name_type NO INTERVALS MODIF ID hrs.
*
*    DATA db_data_element_name_type TYPE rollname.
*    SELECT-OPTIONS s_dtelnm FOR db_data_element_name_type NO INTERVALS.
*
*    DATA db_domain_name_type TYPE domname.
*    SELECT-OPTIONS s_domnm FOR db_domain_name_type NO INTERVALS.

  SELECTION-SCREEN END OF BLOCK dbtab.

  SELECTION-SCREEN BEGIN OF BLOCK vtype WITH FRAME TITLE tt_vtype.
    PARAMETERS vt_table AS CHECKBOX DEFAULT '' MODIF ID hrs.
    PARAMETERS vt_ddvw  AS CHECKBOX DEFAULT '' MODIF ID hrs.
    PARAMETERS vt_ddcds AS CHECKBOX DEFAULT 'X' MODIF ID hrs.
    PARAMETERS vt_entcd AS CHECKBOX DEFAULT 'X' MODIF ID hrs.
  SELECTION-SCREEN END OF BLOCK vtype.

  "Result view name selection
  SELECTION-SCREEN BEGIN OF BLOCK vname WITH FRAME TITLE tt_vname.

    "Custom ABAP views
    SELECTION-SCREEN  PUSHBUTTON 2(17) pbcustvw USER-COMMAND q_custom.
    "Custom DDic Views
    SELECTION-SCREEN  PUSHBUTTON 21(20) pbddicvw USER-COMMAND q_cusddc MODIF ID hrs.
    "Custom DDL source
    SELECTION-SCREEN  PUSHBUTTON 44(20) pbcstddl USER-COMMAND q_cuscds MODIF ID hrs.
    "All views
    SELECTION-SCREEN  PUSHBUTTON 66(10) tq_all USER-COMMAND q_all.

    SELECT-OPTIONS s_abapvw FOR dd26s-viewname.
    SELECTION-SCREEN BEGIN OF LINE.
      SELECTION-SCREEN POSITION 1.
      SELECTION-SCREEN COMMENT 1(70) tabapvw MODIF ID hrs.
    SELECTION-SCREEN END OF LINE.

    SELECT-OPTIONS s_ddicvw FOR dd26s-viewname MODIF ID hrs.

    DATA ddl_name_type TYPE ddldependency-ddlname.
    SELECT-OPTIONS s_ddlnm FOR ddl_name_type MODIF ID hrs.

  SELECTION-SCREEN END OF BLOCK vname.

  "View type
  SELECTION-SCREEN BEGIN OF BLOCK viewtype WITH FRAME TITLE tviewtp.
    "#BASIC
    SELECTION-SCREEN  PUSHBUTTON 1(8) tvtbasic USER-COMMAND vt_basic.

    "#COMPOSITE
    SELECTION-SCREEN  PUSHBUTTON 10(12) tvtcomp USER-COMMAND vt_comp.

    "#CONSUMPTION
    SELECTION-SCREEN  PUSHBUTTON 23(14) tvtcons USER-COMMAND vt_cons.

    "#EXTENSION
    SELECTION-SCREEN  PUSHBUTTON 38(12) tvtext USER-COMMAND vt_ext.

    "#TRANSACTIONAL
    SELECTION-SCREEN  PUSHBUTTON 51(12) tvtran USER-COMMAND vt_tran.

    "All
    SELECTION-SCREEN  PUSHBUTTON 69(18) tvw_all USER-COMMAND vw_all.

    DATA vdm_view_type_type TYPE ddannotation_val.
    SELECT-OPTIONS s_viewtp FOR vdm_view_type_type.

  SELECTION-SCREEN END OF BLOCK viewtype.

  "Data Category
  SELECTION-SCREEN BEGIN OF BLOCK datcat WITH FRAME TITLE datcat.

    "#DIMENSION
    SELECTION-SCREEN  PUSHBUTTON 1(18) tdc_dim USER-COMMAND dc_dim.

    "#CUBE
    "#FACT
    "#TEXT
    "#HIERARCHY
    "#AGGREGATIONLEVEL

    "All
    SELECTION-SCREEN  PUSHBUTTON 21(18) tdc_all USER-COMMAND dc_all.

    "Data Category
    DATA data_category_type TYPE ddannotation_val.
    SELECT-OPTIONS s_datcat FOR data_category_type.

  SELECTION-SCREEN END OF BLOCK datcat.

  "API State
  SELECTION-SCREEN BEGIN OF BLOCK stat WITH FRAME TITLE tstat.

    "C1 ABAP internal
    SELECTION-SCREEN  PUSHBUTTON 1(18) tq_abap USER-COMMAND q_abap.
    "C2 API CDS views only
    SELECTION-SCREEN  PUSHBUTTON 21(20) tq_api USER-COMMAND q_api.
    "All statuses
    SELECTION-SCREEN  PUSHBUTTON 43(15) tq_stall USER-COMMAND q_stall.

    SELECT-OPTIONS s_c1stat FOR ars_w_api_state-release_state.
    DATA lv_boolean TYPE t001-xfdis.
    SELECT-OPTIONS s_c1kapp FOR lv_boolean.
    SELECT-OPTIONS s_c1abap FOR lv_boolean.
    SELECT-OPTIONS s_c2stat FOR ars_w_api_state-release_state.

  SELECTION-SCREEN END OF BLOCK stat.

  "OData and RAP
  SELECTION-SCREEN BEGIN OF BLOCK odata WITH FRAME TITLE todata.
    DATA odata_publish_type TYPE xfeld.
    SELECT-OPTIONS s_odata FOR odata_publish_type.
    SELECT-OPTIONS s_rapodt FOR odata_publish_type.
    SELECT-OPTIONS s_chdrap FOR odata_publish_type.
  SELECTION-SCREEN END OF BLOCK odata.

SELECTION-SCREEN END OF BLOCK sel.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Classes
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

CLASS zca_progress_bar DEFINITION
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF gts_data,
        text                TYPE c LENGTH 100,
        max_value           TYPE i,
        show_value_ind      TYPE abap_bool,
        show_max_value_ind  TYPE abap_bool,
        show_percentage_ind TYPE abap_bool,
      END OF gts_data .
    TYPES:
      gtv_text TYPE c LENGTH 200 .
    TYPES:
      gtv_value TYPE i.

    CLASS-METHODS create
      IMPORTING
        !is_data           TYPE gts_data
      RETURNING
        VALUE(rr_instance) TYPE REF TO zca_progress_bar .
    METHODS set_value
      IMPORTING
        !iv_value TYPE gtv_value
        iv_text   TYPE gts_data-text OPTIONAL.
    METHODS clear .
    CLASS-METHODS static_clear .
    CLASS-METHODS static_set_text
      IMPORTING
        !iv_text TYPE gtv_text .
    METHODS add_text
      IMPORTING
        !iv_text TYPE string .
  PROTECTED SECTION.

    TYPES:
      gtv_percentage TYPE p LENGTH 6 DECIMALS 0 .

    DATA gs_data TYPE gts_data .
    DATA gv_prev_percentage TYPE gtv_percentage VALUE -1 ##NO_TEXT.
    DATA gv_message_shown_ind TYPE abap_bool .
    DATA gv_previous_time TYPE i .
    DATA gv_value TYPE gtv_value .

    METHODS get_percentage
      RETURNING
        VALUE(rv_percentage) TYPE gtv_percentage .
    METHODS get_refresh_needed_ind
      RETURNING
        VALUE(rv_refresh_needed_ind) TYPE xfeld .
    METHODS get_text
      RETURNING
        VALUE(rv_text) TYPE gtv_text .
  PRIVATE SECTION.
ENDCLASS.

CLASS zca_progress_bar IMPLEMENTATION.

  METHOD add_text.

    DATA(lv_percentage) = get_percentage( ).

    DATA(lv_text) = get_text( ).

    lv_text = |{ lv_text } { iv_text }|.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = lv_percentage
        text       = lv_text.

  ENDMETHOD.

  METHOD clear.

    ""If no message shown, than clear is not needed.
    IF gv_message_shown_ind = abap_false.
      RETURN.
    ENDIF.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = 0
        text       = space.

  ENDMETHOD.

  METHOD create.

    rr_instance = NEW #( ).
    rr_instance->gs_data = is_data.

  ENDMETHOD.

  METHOD get_percentage.

    rv_percentage = ( gv_value / gs_data-max_value ) * 100.

  ENDMETHOD.

  METHOD get_refresh_needed_ind.

    DATA(lv_percentage) = get_percentage( ).

    ""Get time diff
    DATA lv_time_diff TYPE i.
    GET RUN TIME FIELD DATA(lv_time).

    IF gv_previous_time = 0.
      lv_time_diff = -1.
    ELSE.
      lv_time_diff = lv_time - gv_previous_time.
    ENDIF.

    ""Only update status bar if...
    ""- First time
    ""- More than one second between
    ""- Percentage changed
    IF lv_time_diff = -1 OR
       lv_time_diff >= 1000000."" OR
      ""lv_percentage <> gv_prev_percentage.

      gv_previous_time = lv_time.

      gv_prev_percentage = lv_percentage.
      gv_message_shown_ind = abap_true.

      rv_refresh_needed_ind  = abap_true.

    ENDIF.

  ENDMETHOD.

  METHOD get_text.

    DATA:
      lv_percent_char(3).

    DATA(lv_percentage) = get_percentage( ).

    ""Set text
    lv_percent_char  = lv_percentage.
    SHIFT lv_percent_char LEFT DELETING LEADING space.

    rv_text = gs_data-text.

    IF gs_data-show_value_ind = abap_true.

      rv_text = rv_text && | | && gv_value.

      IF gs_data-show_max_value_ind = abap_true.
        rv_text = rv_text && |/| && gs_data-max_value.
      ENDIF.

    ENDIF.

    IF gs_data-show_percentage_ind = abap_true.
      rv_text = rv_text && | | && ' (' && lv_percent_char && |%)|.
    ENDIF.

  ENDMETHOD.

  METHOD set_value.

    IF iv_text IS NOT INITIAL.
      gs_data-text = iv_text.
    ENDIF.

    gv_value = iv_value.

    IF sy-batch = 'X'.

      RETURN.

    ENDIF.

    DATA(lv_text) = get_text( ).

    DATA(lv_percentage) = get_percentage( ).

    DATA(lv_refresh_ind) = get_refresh_needed_ind( ).

    IF lv_refresh_ind = abap_true.

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = lv_percentage
          text       = lv_text.

    ENDIF.

  ENDMETHOD.

  METHOD static_clear.

    ""Use this method only for clearing progress bar not created by this class
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = 0
        text       = space.

  ENDMETHOD.

  METHOD static_set_text.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = 0
        text       = iv_text.

  ENDMETHOD.
ENDCLASS."

CLASS zcx_generic_exc DEFINITION INHERITING FROM cx_static_check.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING text TYPE string.

    METHODS get_text REDEFINITION.

  PRIVATE SECTION.
    DATA text TYPE string.

ENDCLASS.

CLASS zcx_generic_exc IMPLEMENTATION.

  METHOD constructor.

    super->constructor( ).

    me->text = text.

  ENDMETHOD.

  METHOD get_text.

    result = me->text.

  ENDMETHOD.

ENDCLASS.

CLASS zscv_view_search_dp DEFINITION.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ts_ddic_view,
        abapviewname                  TYPE zscv_abapviewbyview-abapviewname,
        endusertextlabel              TYPE ddheadanno-value,

        relationlevel                 TYPE zscv_abapviewbyview-relationlevel,
        abapviewtype                  TYPE c LENGTH 10,
        vdmviewtype                   TYPE ddheadanno-value,
        datacategory                  TYPE ddannotation_val,

        c1_releasestate               TYPE ars_w_api_state-release_state,
        c1_useinkeyuserapps           TYPE abap_bool,
        c1_useincloudplatform         TYPE abap_bool,

        c2_releasestate               TYPE ars_w_api_state-release_state,
        c2_useinkeyuserapps           TYPE abap_bool,
        c2_useincloudplatform         TYPE abap_bool,

        accesscontrolauthcheck        TYPE ddheadanno-value,
        objectmodelusagetypedataclass TYPE ddheadanno-value,
        vdmlifecyclecontracttype      TYPE ddheadanno-value,
        objectmodelcreateenabled      TYPE ddheadanno-value,
        odatapublish                  TYPE ddheadanno-value,
        rappublish                    TYPE ddheadanno-value,
        childrapviewind               TYPE ddheadanno-value,
        embeddedanalyticsqueryind     TYPE abap_bool,


        metadataallowextensions       TYPE ddheadanno-value,
        searchsearchable              TYPE ddheadanno-value,
        vdmusagetype1                 TYPE ddheadanno-value,
        objectmodelsemantickey1       TYPE ddheadanno-value,

        create_user_name              TYPE dd02l-as4user,
        create_date                   TYPE dd02l-as4date,
        create_time                   TYPE dd02l-as4time,

        start_view_name               TYPE dd26s-viewname,

        ddlsourcename                 TYPE cds_sql_view-ddlsourcename,
        basictablecdsviewind          TYPE zscv_abapviewbyview-basictablecdsviewind,

        ddicviewname                  TYPE dd26s-viewname,
        childddicviewname             TYPE dd26s-viewname,

      END OF ts_ddic_view,
      tt_ddic_view_list TYPE STANDARD TABLE OF ts_ddic_view WITH EMPTY KEY. "TODO: rename

    TYPES t_view_range TYPE RANGE OF ts_ddic_view-abapviewname.

    METHODS get_views_by_source_names
      IMPORTING view_range       TYPE t_view_range OPTIONAL
      RETURNING VALUE(view_list) TYPE zscv_view_search_dp=>tt_ddic_view_list
      RAISING   zcx_generic_exc.

    TYPES t_view_rng TYPE RANGE OF zscv_abapviewbyview-abapviewname.
    METHODS get_views_by_field_names
      IMPORTING view_rng         TYPE t_view_rng OPTIONAL
      RETURNING VALUE(view_list) TYPE zscv_view_search_dp=>tt_ddic_view_list
      RAISING   zcx_generic_exc.

  PRIVATE SECTION.

    TYPES ty_useinkeyuserapps_rng TYPE RANGE OF ts_ddic_view-c1_useinkeyuserapps.
    TYPES ty_useincloudplatforms_rng TYPE RANGE OF ts_ddic_view-c1_useincloudplatform.
    TYPES:
      BEGIN OF ty_where_parameters,
        c1_useinkeyuserapps_rng    TYPE ty_useinkeyuserapps_rng,
        c1_useincloudplatforms_rng TYPE ty_useincloudplatforms_rng,
        where_text                 TYPE string,
      END OF ty_where_parameters.

    TYPES t_view_type_rng TYPE RANGE OF char10.

    METHODS _get_views_by_source_name
      IMPORTING db_table_name    TYPE vibastab
      RETURNING VALUE(view_list) TYPE tt_ddic_view_list
      RAISING   zcx_generic_exc.

    METHODS _get_views_by_source_name2
      IMPORTING db_table_name    TYPE vibastab
      RETURNING VALUE(view_list) TYPE tt_ddic_view_list
      RAISING   zcx_generic_exc.

    METHODS _get_views_by_field_names2
      IMPORTING view_rng          TYPE t_view_rng OPTIONAL
      RETURNING VALUE(view_range) TYPE t_view_range.

    METHODS _get_where_parameters
      IMPORTING parameter_name          TYPE char30 DEFAULT 'WHERE_PARAMETERS'
      RETURNING VALUE(where_parameters) TYPE ty_where_parameters.

    METHODS _filter_views_by_fields
      IMPORTING view_list                 TYPE tt_ddic_view_list
      RETURNING VALUE(filtered_view_list) TYPE tt_ddic_view_list
      RAISING   zcx_generic_exc.

    METHODS _get_view_type_rng
      RETURNING VALUE(view_type_rng) TYPE t_view_type_rng.

ENDCLASS.

CLASS zscv_view_search_dp IMPLEMENTATION.

  METHOD get_views_by_source_names.

    DATA view_range2 TYPE t_view_range.

    IF s_dbtab[] IS NOT INITIAL.
      view_range2[] = s_dbtab[].
    ENDIF.

    IF view_range[] IS NOT INITIAL.
      IF view_range2[] IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_generic_exc
          EXPORTING
            text = |Double selection not allowed.|.
      ENDIF.
      view_range2[] = view_range[].
    ENDIF.

    DATA db_table_view_list TYPE zscv_view_search_dp=>tt_ddic_view_list.

    SELECT
      FROM zscv_abapview
      FIELDS
        abapviewname
      WHERE
        abapviewname IN @view_range2[]
      ORDER BY
        abapviewname
      INTO TABLE @DATA(root_views).

    "3. Vullen van de output table ==> <fs_output_line>
    DATA(lr_progress_bar) =
      zca_progress_bar=>create(
        VALUE #(
          text = 'Root views'
          max_value = lines( root_views[] )
          show_value_ind = abap_true
          show_max_value_ind = abap_true
          show_percentage_ind = abap_true ) ).

    LOOP AT root_views
      ASSIGNING FIELD-SYMBOL(<root_view>).

      DATA(view_list_line_count) = lines( view_list ).

      lr_progress_bar->set_value(
        iv_value = sy-tabix
        iv_text  = |Count: { view_list_line_count }, root view: { <root_view>-abapviewname } | ).

      DATA(temp_view_list) = _get_views_by_source_name(
        db_table_name = <root_view>-abapviewname ).

      LOOP AT temp_view_list
        ASSIGNING FIELD-SYMBOL(<source_line>).

        <source_line>-start_view_name = <root_view>-abapviewname.

        APPEND <source_line> TO view_list.

      ENDLOOP.

    ENDLOOP.

    lr_progress_bar->clear( ).

  ENDMETHOD.

  METHOD get_views_by_field_names.

    DATA(view_range) = _get_views_by_field_names2( view_rng ).

    IF view_range[] IS INITIAL.

      RAISE EXCEPTION TYPE zcx_generic_exc
        EXPORTING
          text = |No views found.|.

    ENDIF.

    DATA(where_parameters) = _get_where_parameters( ).

    DATA(view_type_rng) = _get_view_type_rng( ).

    SELECT
       abapview~abapviewtype,
       abapview~abapviewname,

       abapview~ddlsourcename,
       \_cdsview-datacategory,
       \_cdsview-embeddedanalyticsqueryind,

       abapview~ddicviewname,

        \_cdsview\_status-c1_releasestate,
        \_cdsview\_status-c1_useinkeyuserapps,
        \_cdsview\_status-c1_useincloudplatform,

        \_cdsview\_status-c2_releasestate,

        \_cdsview-endusertextlabel,
        \_cdsview-vdmviewtype,
        \_cdsview-accesscontrolauthcheck,
        \_cdsview-objectmodelusagetypedataclass,
        \_cdsview-vdmlifecyclecontracttype,
        \_cdsview-objectmodelcreateenabled,
        \_cdsview-odatapublish,
        \_cdsview-rappublish,
        \_cdsview-childrapviewind,

        \_cdsview-metadataallowextensions,
        \_cdsview-searchsearchable,
        \_cdsview-vdmusagetype1,
        \_cdsview-objectmodelsemantickey1,

        \_cdsview-createuser AS create_user_name,
        \_cdsview-createdate AS create_date

        FROM
          zscv_abapview AS abapview

        WHERE
          abapview~abapviewtype    IN @view_type_rng[] AND
          abapview~abapviewname    IN @view_range[] AND
          abapview~abapviewname    IN @s_abapvw[] AND
          abapview~ddicviewname    IN @s_ddicvw[] AND
          \_cdsview-ddlsourcename  IN @s_ddlnm
          AND
          (where_parameters-where_text)

          AND
          \_cdsview-vdmviewtype     IN @s_viewtp[] AND
          \_cdsview-odatapublish    IN @s_odata[] AND
          \_cdsview-rappublish      IN @s_rapodt[] AND
          \_cdsview-childrapviewind IN @s_chdrap[] AND
          \_cdsview-datacategory    IN @s_datcat[]

          ORDER BY
            abapview~ddlsourcename,
            abapview~ddicviewname

      INTO CORRESPONDING FIELDS OF TABLE @view_list.

  ENDMETHOD.

  METHOD _get_views_by_field_names2.

    IF s_fldnm[] IS NOT INITIAL.

      DATA lt_fullfieldname_rng TYPE RANGE OF i_product-product.

      LOOP AT s_fldnm
        ASSIGNING FIELD-SYMBOL(<ls_fldnm>).

        APPEND
          VALUE #(
            sign = 'I'
            option = if_fsbp_const_range=>option_contains_pattern
            low    = |\\TY:*\\TY:{ <ls_fldnm>-low }|
          )
          TO lt_fullfieldname_rng.

      ENDLOOP.

      SELECT
        FROM zscv_abapviewaliasfield AS field
        FIELDS
          field~abapviewname,
          field~fullfieldname
*          Field~DataElementName,
*          Field~DomainName
        WHERE
          field~abapviewname IN @view_rng[] AND
          fullfieldname      IN @lt_fullfieldname_rng
        INTO TABLE @DATA(temp_filtered_views).
    ENDIF.
*
*    IF s_dtelnm[] IS NOT INITIAL.
*      SELECT
*        FROM ZSCV_AbapViewAliasField AS Field
*        FIELDS
*          Field~AbapViewName,
*          Field~FieldName,
*          Field~DataElementName,
*          Field~DomainName
*        WHERE
*          Field~AbapViewName IN @view_rng[] AND
*          DataElementName IN @s_dtelnm[]
*        APPENDING TABLE @temp_filtered_views.
*    ENDIF.
*
*    IF s_domnm[] IS NOT INITIAL.
*      SELECT
*        FROM ZSCV_AbapViewAliasField AS Field
*        FIELDS
*          Field~AbapViewName,
*          Field~FieldName,
*          Field~DataElementName,
*          Field~DomainName
*        WHERE
*          Field~AbapViewName IN @view_rng[] AND
*          DomainName      IN @s_domnm[]
*          APPENDING TABLE @temp_filtered_views.
*    ENDIF.
*
    DATA selected_view_list TYPE t_view_range.

    LOOP AT temp_filtered_views
      INTO DATA(view_field)
      GROUP BY view_field-abapviewname.

      APPEND VALUE #(
        sign = 'I'
        option = 'EQ'
        low = view_field-abapviewname )
        TO selected_view_list.

    ENDLOOP.

    LOOP AT selected_view_list
      ASSIGNING FIELD-SYMBOL(<selected_view>).

      DATA(viewname) = <selected_view>-low.

      DATA(all_fields_found_ind) = abap_true.

      LOOP AT lt_fullfieldname_rng ASSIGNING FIELD-SYMBOL(<field>).

        DATA field_one_field_rng LIKE s_fldnm[].

        REFRESH field_one_field_rng.
        APPEND <field> TO field_one_field_rng.

        LOOP AT temp_filtered_views
          ASSIGNING FIELD-SYMBOL(<dummy>)
          WHERE
            abapviewname =  viewname AND
            fullfieldname    IN field_one_field_rng.
          EXIT.
        ENDLOOP.

        IF sy-subrc <> 0.
          all_fields_found_ind = abap_false.
        ENDIF.

      ENDLOOP.

*      LOOP AT s_dtelnm ASSIGNING FIELD-SYMBOL(<DataElementName>).
*
*        DATA DataElementName_rng LIKE s_dtelnm[].
*
*        REFRESH DataElementName_rng.
*        APPEND <DataElementName> TO DataElementName_rng.
*
*        LOOP AT temp_filtered_views
*          ASSIGNING FIELD-SYMBOL(<dummy2>)
*          WHERE
*            AbapViewName     =  ViewName AND
*            DataElementName  IN DataElementName_rng.
*        ENDLOOP.
*
*        IF sy-subrc <> 0.
*          all_fields_found_ind = abap_false.
*        ENDIF.
*
*      ENDLOOP.

*      LOOP AT s_domnm ASSIGNING FIELD-SYMBOL(<DomainName>).
*
*        DATA DomainName_rng LIKE s_domnm[].
*
*        REFRESH DomainName_rng.
*        APPEND <DomainName> TO DomainName_rng.
*
*        LOOP AT temp_filtered_views
*          ASSIGNING FIELD-SYMBOL(<dummy3>)
*          WHERE
*            AbapViewName  =  ViewName AND
*            DomainName    IN DomainName_rng.
*        ENDLOOP.
*
*        IF sy-subrc <> 0.
*          all_fields_found_ind = abap_false.
*        ENDIF.
*
*      ENDLOOP.

      IF all_fields_found_ind = abap_true.
        APPEND <selected_view> TO view_range.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD _get_views_by_source_name.

    view_list = _get_views_by_source_name2( db_table_name ).

    IF s_fldnm[] IS NOT INITIAL. "OR
*       s_dtelnm[] IS NOT INITIAL OR
*       s_domnm[] IS NOT INITIAL.
*
      view_list = _filter_views_by_fields( view_list ).

    ENDIF.

  ENDMETHOD.

  METHOD _get_views_by_source_name2.

    DATA(where_parameters) = _get_where_parameters( ).

    DATA(view_type_rng) = _get_view_type_rng( ).

    "-----------------------------------------------------------------------------------
    "SELECT
    "-----------------------------------------------------------------------------------
    TRY.

        SELECT
           abapview~basictablecdsviewind,
           abapview~relationlevel,
           abapview~abapviewtype,
           abapview~abapviewname,

           abapview~ddlsourcename,
           \_cdsview-datacategory,
           \_cdsview-embeddedanalyticsqueryind,

           abapview~ddicviewname,

            \_cdsview\_status-c1_releasestate,
            \_cdsview\_status-c1_useinkeyuserapps,
            \_cdsview\_status-c1_useincloudplatform,

            \_cdsview\_status-c2_releasestate,

            \_cdsview-endusertextlabel,
            \_cdsview-vdmviewtype,
            \_cdsview-accesscontrolauthcheck,
            \_cdsview-objectmodelusagetypedataclass,
            \_cdsview-vdmlifecyclecontracttype,
            \_cdsview-objectmodelcreateenabled,
            \_cdsview-odatapublish,
            \_cdsview-rappublish,
            \_cdsview-childrapviewind,

            \_cdsview-metadataallowextensions,
            \_cdsview-searchsearchable,
            \_cdsview-vdmusagetype1,
            \_cdsview-objectmodelsemantickey1,

            \_cdsview-createuser AS create_user_name,
            \_cdsview-createdate AS create_date

            FROM
              zscv_abapviewbyview(
                  p_abapviewname                 = @db_table_name
                ) AS abapview

            WHERE
              abapview~abapviewtype    IN @view_type_rng[] AND
              abapview~abapviewname    IN @s_abapvw[] AND
              abapview~ddicviewname    IN @s_ddicvw[] AND
              \_cdsview-ddlsourcename  IN @s_ddlnm
              AND
              (where_parameters-where_text)

              AND
              \_cdsview-vdmviewtype     IN @s_viewtp[] AND
              \_cdsview-odatapublish    IN @s_odata[] AND
              \_cdsview-rappublish      IN @s_rapodt[] AND
              \_cdsview-childrapviewind IN @s_chdrap[] AND
              \_cdsview-datacategory    IN @s_datcat[]

          ORDER BY
            \_cdsview-ddlsourcename,
            abapview~ddicviewname

          INTO CORRESPONDING FIELDS OF TABLE @view_list.

      CATCH cx_sy_open_sql_db INTO DATA(sy_open_sql_db_exc).

        DATA(lv_text) = sy_open_sql_db_exc->get_text( ).

        RAISE EXCEPTION TYPE zcx_generic_exc
          EXPORTING
            text = |{ sy_open_sql_db_exc->sqlcode } - { lv_text }|.

    ENDTRY.

  ENDMETHOD.

  METHOD _get_where_parameters.

    where_parameters-c1_useinkeyuserapps_rng = s_c1kapp[].

    where_parameters-c1_useincloudplatforms_rng = s_c1abap[].

    "-----------------------------------------------------------------------------------
    "Where clause
    "-----------------------------------------------------------------------------------

    IF s_c1stat[] IS NOT INITIAL OR
       where_parameters-c1_useinkeyuserapps_rng[] IS NOT INITIAL OR
       where_parameters-c1_useincloudplatforms_rng IS NOT INITIAL OR
       s_c2stat[] IS NOT INITIAL.

      IF s_c1stat[] IS NOT INITIAL OR
         where_parameters-c1_useinkeyuserapps_rng[] IS NOT INITIAL OR
         where_parameters-c1_useincloudplatforms_rng IS NOT INITIAL.

        DATA c1_where_text TYPE string.

        c1_where_text = c1_where_text && |(|.

        IF s_c1stat[] IS NOT INITIAL.
          c1_where_text = c1_where_text && | \\_cdsview\\_status-c1_releasestate IN @s_c1stat[]|  ##NO_TEXT.
        ENDIF.

        IF where_parameters-c1_useinkeyuserapps_rng[] IS NOT INITIAL.
          IF s_c1stat[] IS NOT INITIAL.
            c1_where_text = c1_where_text && | AND|.
          ENDIF.
          c1_where_text = c1_where_text && | \\_cdsview\\_status-c1_useinkeyuserapps IN @{ parameter_name }-c1_useinkeyuserapps_rng[]|  ##NO_TEXT.
        ENDIF.

        IF where_parameters-c1_useincloudplatforms_rng[] IS NOT INITIAL.
          IF s_c1stat[] IS NOT INITIAL OR where_parameters-c1_useinkeyuserapps_rng[] IS NOT INITIAL.
            c1_where_text = c1_where_text && | AND|.
          ENDIF.
          c1_where_text = c1_where_text && | \\_cdsview\\_status-c1_useincloudplatform IN @{ parameter_name }-c1_useincloudplatforms_rng[]|  ##NO_TEXT.
        ENDIF.

        c1_where_text = c1_where_text && | )|.

      ENDIF.

      DATA(status_where_text) = c1_where_text.

      IF s_c2stat[] IS NOT INITIAL.

        IF c1_where_text IS NOT INITIAL.
          status_where_text = | ( | && status_where_text.
          status_where_text = status_where_text && | OR|.
        ENDIF.

        status_where_text = status_where_text && | \\_cdsview\\_status-c2_releasestate IN @s_c2stat[]| ##NO_TEXT.

        IF c1_where_text IS NOT INITIAL.
          status_where_text = status_where_text && | ) |.
        ENDIF.

      ENDIF.

    ENDIF.

    where_parameters-where_text  = status_where_text.

  ENDMETHOD.


  METHOD _filter_views_by_fields.

    DATA view_rng TYPE t_view_rng.
    view_rng = VALUE #(
      FOR view IN view_list
       ( sign = 'I' option = 'EQ' low = view-abapviewname ) ).

    DATA(temp_filtered_views) = me->get_views_by_field_names( view_rng ).

    SORT temp_filtered_views BY abapviewname.

    LOOP AT view_list
     ASSIGNING FIELD-SYMBOL(<view>).

      READ TABLE temp_filtered_views
        WITH KEY abapviewname = <view>-abapviewname
        TRANSPORTING NO FIELDS.

      IF sy-subrc = 0.
        APPEND <view> TO filtered_view_list.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD _get_view_type_rng.

    IF vt_table = 'X' AND
       vt_ddvw  = 'X' AND
       vt_ddcds = 'X' AND
       vt_entcd = 'X'.
      RETURN.
    ENDIF.

    IF vt_table = 'X'.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = 'DDic Table' )
        TO view_type_rng[].
    ENDIF.

    IF vt_ddvw  = 'X'.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = 'DDic View' )
        TO view_type_rng[].
    ENDIF.

    IF vt_ddcds = 'X'.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = 'DDic CDS' )
        TO view_type_rng[].
    ENDIF.

    IF vt_entcd = 'X'.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = 'Entity CDS' )
        TO view_type_rng[].
    ENDIF.

  ENDMETHOD.

ENDCLASS.


CLASS zscv_cds_view_list_vw DEFINITION
  CREATE PRIVATE.

  PUBLIC SECTION.

    TYPES tt_cds_views TYPE zscv_view_search_dp=>tt_ddic_view_list.

    CLASS-METHODS create_by_ref_data
      IMPORTING ir_cds_views_data TYPE REF TO tt_cds_views
      RETURNING VALUE(rr_view)    TYPE REF TO zscv_cds_view_list_vw.

    METHODS display.

    METHODS refresh
      RAISING cx_salv_no_new_data_allowed.

    EVENTS on_function
      EXPORTING VALUE(ev_function_name) TYPE salv_de_function
                VALUE(et_selected_rows) TYPE salv_t_row.

  PRIVATE SECTION.

    DATA gr_cds_views_data TYPE REF TO tt_cds_views.
    DATA gr_container TYPE REF TO cl_gui_custom_container.
    DATA go_gr_alv TYPE REF TO cl_salv_table.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "Create
    METHODS _create_header
      IMPORTING
        io_gr_alv TYPE REF TO cl_salv_table.

    METHODS _add_field_to_catalogue
      IMPORTING column   TYPE c
                field    TYPE c
                table    TYPE c
                length   TYPE c
                text     TYPE c
                hot      TYPE c
                checkbox TYPE c.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "Events
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_before_salv_function FOR EVENT before_salv_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_after_salv_function FOR EVENT after_salv_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column,

      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "Setters
    METHODS _set_table_settings
      IMPORTING
        io_gr_alv TYPE REF TO cl_salv_table.

    METHODS _set_columns
      IMPORTING io_gr_alv TYPE REF TO cl_salv_table
      RAISING   cx_salv_not_found.

    METHODS _set_functions
      IMPORTING
        io_gr_alv TYPE REF TO cl_salv_table.

    METHODS _set_events
      IMPORTING
        io_gr_alv TYPE REF TO cl_salv_table.

ENDCLASS.

CLASS zscv_db_table_based_search_prc DEFINITION.

  PUBLIC SECTION.

    METHODS show_all_basic_views.

  PRIVATE SECTION.

    DATA gr_ida_table TYPE REF TO if_salv_gui_table_ida.

    METHODS update_relation
      IMPORTING ev_fcode TYPE ui_func.

    METHODS toolbar_function_selected
      FOR EVENT function_selected OF if_salv_gui_toolbar_ida
      IMPORTING ev_fcode.

ENDCLASS.

CLASS zscv_db_table_based_search_prc IMPLEMENTATION.

  METHOD show_all_basic_views.

    "ZSCV_ReleasedC1BasicAbapView
    gr_ida_table = cl_salv_gui_table_ida=>create_for_cds_view(
      iv_cds_view_name = 'ZSCV_RELEASEDC1BASICABAPVIEW' ).

    DATA(lr_default_layout) = gr_ida_table->default_layout( ).
    lr_default_layout->set_sort_order(
      it_sort_order = VALUE #(
        (
          field_name = 'ABAPVIEWNAME'
        )
      )
    ).

    "Set Selection
    DATA(lr_selection) = NEW cl_salv_range_tab_collector( ).

    lr_selection->add_ranges_for_name(
      iv_name = 'DBTABLENAME'
      it_ranges = s_bstab[] ).

    lr_selection->add_ranges_for_name(
      iv_name = 'ABAPVIEWNAME'
      it_ranges = s_abapvw[] ).

    lr_selection->add_ranges_for_name(
      iv_name = 'C1_RELEASESTATE'
      it_ranges = s_c1stat[] ).

    lr_selection->add_ranges_for_name(
      iv_name = 'C1_USEINKEYUSERAPPS'
      it_ranges = s_c1kapp[] ).

    lr_selection->add_ranges_for_name(
      iv_name = 'C1_USEINCLOUDPLATFORM'
      it_ranges = s_c1abap[] ).

    lr_selection->add_ranges_for_name(
      iv_name = 'C2_RELEASESTATE'
      it_ranges = s_c2stat[] ).

    lr_selection->add_ranges_for_name(
      iv_name = 'VDMVIEWTYPE'
      it_ranges = s_viewtp[] ).

    lr_selection->add_ranges_for_name(
      iv_name = 'DATACATEGORY'
      it_ranges = s_datcat[] ).

    lr_selection->add_ranges_for_name(
      iv_name = 'ODATAPUBLISH'
      it_ranges = s_odata[] ).

    lr_selection->add_ranges_for_name(
      iv_name = 'RAPPUBLISH'
      it_ranges = s_rapodt[] ).

    lr_selection->add_ranges_for_name(
      iv_name = 'CHILDRAPVIEWIND'
      it_ranges = s_chdrap[] ).

    lr_selection->get_collected_ranges(
      IMPORTING et_named_ranges = DATA(lt_named_ranges) ).

    gr_ida_table->set_select_options(
      it_ranges = lt_named_ranges ).

*    "Set tool bar
*    DATA(lr_toolbar) = gr_ida_table->toolbar( ).
*
*    lr_toolbar->add_separator( ).
*
*    lr_toolbar->add_button(
*      iv_fcode     = 'LINK_SINGLE_BASIC_VW'
*      iv_icon      = icon_bom
*      iv_text      = 'Set single basic views as Super' ).
*
*    lr_toolbar->add_separator( ).
*
*    lr_toolbar->add_button(
*      iv_fcode     = 'SUPER_ENTITY'
*      iv_icon      = icon_bom
*      iv_text      = 'Super entity' ).
*
*    lr_toolbar->add_button(
*      iv_fcode     = 'SUB_ENTITY'
*      iv_icon      = icon_bom_sub_item
*      iv_text      = 'Sub entity' ).
*
*    lr_toolbar->add_button(
*      iv_fcode     = 'DELETE_ENTITY'
*      iv_icon      = icon_delete
*      iv_text      = 'Delete entity' ).

*    SET HANDLER toolbar_function_selected FOR lr_toolbar.

    gr_ida_table->selection( )->set_selection_mode(
        iv_mode = if_salv_gui_selection_ida=>cs_selection_mode-multi ).

    gr_ida_table->fullscreen( )->display( ).

  ENDMETHOD.

  METHOD toolbar_function_selected.

    CASE ev_fcode.

      WHEN OTHERS.

        update_relation( ev_fcode ).

    ENDCASE.

  ENDMETHOD.

  METHOD update_relation.

    DATA(lr_selection) = gr_ida_table->selection( ).
    IF lr_selection->is_row_selected( ) = abap_false.
      MESSAGE |No row selected| TYPE 'I' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    DATA lt_row TYPE STANDARD TABLE OF zscv_releasedc1basicabapview.
    gr_ida_table->selection( )->get_selected_range(
      IMPORTING
        et_selected_rows     = lt_row ).

    DATA lv_refresh_ind TYPE abap_bool.

    LOOP AT lt_row
      ASSIGNING FIELD-SYMBOL(<ls_row>).

      IF sy-batch = abap_false.

        cl_progress_indicator=>progress_indicate(
          EXPORTING
            i_text               = |CDS { sy-tabix } / { lines( lt_row ) } - { <ls_row>-abapviewname }|
            i_processed          = sy-tabix
            i_total              = lines( lt_row )
            i_output_immediately = abap_false ).

      ENDIF.

      DATA(lr_relation) = zscv_released_basic_view_bo=>get_instance_by_table_name(
        iv_db_table_name = CONV #( <ls_row>-dbtablename )
        iv_cds_view_name = CONV #( <ls_row>-abapviewname ) ).

      CASE ev_fcode.

        WHEN 'LINK_SINGLE_BASIC_VW'.

          IF lr_relation IS INITIAL.

            IF <ls_row>-dbtablename = 'DD07L'.

              lr_relation =
                  zscv_released_basic_view_bo=>create_relation(
                    EXPORTING
                      iv_db_table_name       = CONV #( <ls_row>-dbtablename )
                      iv_cds_view_name       = CONV #( <ls_row>-abapviewname )
                      iv_relation_level      = zscv_released_basic_view_bo=>gcs__relation_level-domain
                      iv_show_message_ind    = abap_false ).
              lv_refresh_ind = abap_true.

              CONTINUE.

            ENDIF.

            IF <ls_row>-dbtablename = 'DD07T'.

              lr_relation =
                  zscv_released_basic_view_bo=>create_relation(
                    EXPORTING
                      iv_db_table_name       = CONV #( <ls_row>-dbtablename )
                      iv_cds_view_name       = CONV #( <ls_row>-abapviewname )
                      iv_relation_level      = zscv_released_basic_view_bo=>gcs__relation_level-domain_text
                      iv_show_message_ind    = abap_false ).
              lv_refresh_ind = abap_true.

              CONTINUE.

            ENDIF.


            SELECT COUNT( * )
              FROM zscv_releasedc1basicabapview
              WHERE
               dbtablename = @<ls_row>-dbtablename
              INTO @DATA(lv_count).

            IF lv_count = 1.
              lr_relation =
                  zscv_released_basic_view_bo=>create_relation(
                    EXPORTING
                      iv_db_table_name       = CONV #( <ls_row>-dbtablename )
                      iv_cds_view_name       = CONV #( <ls_row>-abapviewname )
                      iv_relation_level      = zscv_released_basic_view_bo=>gcs__relation_level-super
                      iv_show_message_ind    = abap_false ).
              lv_refresh_ind = abap_true.
            ENDIF.

          ENDIF.

        WHEN 'SUPER_ENTITY'.

          IF lr_relation IS NOT INITIAL.

            lr_relation->update_relation_level( zscv_released_basic_view_bo=>gcs__relation_level-super ).
            lv_refresh_ind = abap_true.

          ELSE.

            lr_relation =
                zscv_released_basic_view_bo=>create_relation(
                  EXPORTING
                    iv_db_table_name       = CONV #( <ls_row>-dbtablename )
                    iv_cds_view_name       = CONV #( <ls_row>-abapviewname )
                    iv_relation_level      = zscv_released_basic_view_bo=>gcs__relation_level-super
                    iv_show_message_ind    = abap_false ).
            lv_refresh_ind = abap_true.

          ENDIF.

        WHEN 'SUB_ENTITY'.

          IF lr_relation IS NOT INITIAL.

            lr_relation->update_relation_level( zscv_released_basic_view_bo=>gcs__relation_level-sub ).
            lv_refresh_ind = abap_true.

          ELSE.

            lr_relation =
                zscv_released_basic_view_bo=>create_relation(
                  EXPORTING
                    iv_db_table_name       = CONV #( <ls_row>-dbtablename )
                    iv_cds_view_name       = CONV #( <ls_row>-abapviewname )
                    iv_relation_level      = zscv_released_basic_view_bo=>gcs__relation_level-sub
                    iv_show_message_ind    = abap_false ).
            lv_refresh_ind = abap_true.

          ENDIF.

        WHEN 'DELETE_ENTITY'.

          IF lr_relation IS NOT INITIAL.
            lr_relation->delete_relation( ).
            lv_refresh_ind = abap_true.
          ELSE.
            MESSAGE |Entity { <ls_row>-abapviewname } has no relation.| TYPE 'I' DISPLAY LIKE 'E'.
            RETURN.
          ENDIF.

      ENDCASE.

    ENDLOOP.

    gr_ida_table->refresh( ).

  ENDMETHOD.

ENDCLASS.


CLASS zscv_cds_view_list_vw IMPLEMENTATION.

  METHOD create_by_ref_data.

    rr_view = NEW #( ).

    rr_view->gr_cds_views_data = ir_cds_views_data.

  ENDMETHOD.

  METHOD display.

    TRY.

        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = go_gr_alv
          CHANGING
            t_table      = gr_cds_views_data->* ).

        go_gr_alv->set_screen_status(
          pfstatus      = 'SALV_STANDARD'
          report        = sy-repid
          set_functions = go_gr_alv->c_functions_all ).

        "Set functions
        _set_functions( go_gr_alv ).

        "Create header
        _create_header( go_gr_alv ).

        "Set table settings
        _set_table_settings( go_gr_alv ).

        "Set events
        _set_events( go_gr_alv ).

        "Enable cell selection mode
        DATA(lo_selections) = go_gr_alv->get_selections( ).
        lo_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).

        "Set columns
        _set_columns( go_gr_alv ).


        "Display
        go_gr_alv->display( ).

      CATCH cx_root INTO DATA(lx_root).

        MESSAGE lx_root->get_text( ) TYPE 'W'.

    ENDTRY.

  ENDMETHOD.

  METHOD refresh.

    go_gr_alv->refresh( ).

  ENDMETHOD.

  METHOD on_double_click.

  ENDMETHOD.

  METHOD _create_header.

    "Create header
    DATA lv_rows  TYPE string.
    DESCRIBE TABLE gr_cds_views_data->* LINES lv_rows.
    DATA lv_title TYPE string.
    lv_title = |Row count: { lv_rows }|.
    DATA(lo_layout_grid) = NEW cl_salv_form_layout_grid( ).
    DATA(lo_layout_logo) = NEW cl_salv_form_layout_logo( ).
    lo_layout_grid->create_label(
      row     = 1
      column  = 1
      text    = lv_title
      tooltip = lv_title ).
    lo_layout_logo->set_left_content( lo_layout_grid ).
    DATA lo_content TYPE REF TO cl_salv_form_element.
    lo_content = lo_layout_logo.
    io_gr_alv->set_top_of_list( lo_content ).

  ENDMETHOD.

  METHOD _add_field_to_catalogue.

    DATA(gr_columns) = go_gr_alv->get_columns( ).

    TRY.
        DATA(gr_column)  = gr_columns->get_column( to_upper( field ) ).

        gr_column->set_short_text( CONV #( text ) ).
        gr_column->set_medium_text( CONV #(  text ) ).
        gr_column->set_long_text( CONV #( text ) ).
        gr_column->set_fixed_header_text( CONV #( text ) ).

      CATCH cx_root INTO DATA(lr_root).

        MESSAGE lr_root->get_text( ) TYPE 'W'.

    ENDTRY.

  ENDMETHOD.

  METHOD _set_columns.

    DATA(lo_column_list)  = io_gr_alv->get_columns( ).
    lo_column_list->set_optimize( 'X' ).

    _add_field_to_catalogue( column = '07' field = 'DDICVIEWNAME'                   table = 'VIEW_LIST' length = '20' text = 'DDic Name'              hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '09' field = 'ENDUSERTEXTLABEL'               table = 'VIEW_LIST' length = '30' text = 'End User Text Label'  hot = 'X' checkbox = ' ' ).

    _add_field_to_catalogue( column = '10' field = 'ABAPVIEWTYPE'                   table = 'VIEW_LIST' length = '10' text = 'View Type'              hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '12' field = 'DATACATEGORY'                   table = 'VIEW_LIST' length = '15' text = 'CDS Data Category'    hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '14' field = 'VDMVIEWTYPE'                    table = 'VIEW_LIST' length = '15' text = 'VDM View Type'        hot = 'X' checkbox = ' ' ).

    _add_field_to_catalogue( column = '30' field = 'C1_RELEASESTATE'                table = 'VIEW_LIST' length = '10' text = 'C1 Release State'           hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '32' field = 'C1_UseInKeyUserApps'            table = 'VIEW_LIST' length = '10' text =  'C1 Use In Key User Apps'   hot = 'X' checkbox = 'X' ).
    _add_field_to_catalogue( column = '34' field = 'C1_USEINCLOUDPLATFORM'          table = 'VIEW_LIST' length = '12' text = 'C1 Use In Cloud platform'   hot = 'X' checkbox = 'X' ).
    _add_field_to_catalogue( column = '40' field = 'C2_RELEASESTATE'                table = 'VIEW_LIST' length = '10' text = 'C2 Release State'           hot = 'X' checkbox = ' ' ).

    _add_field_to_catalogue( column = '50' field = 'ACCESSCONTROLAUTHCHECK'         table = 'VIEW_LIST' length = '10' text = 'Auth. check'          hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '52' field = 'OBJECTMODELUSAGETYPEDATACLASS'  table = 'VIEW_LIST' length = '15' text = 'Data Class'           hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '54' field = 'VDMLIFECYCLECONTRACTTYPE'       table = 'VIEW_LIST' length = '15' text = 'Contract Type'        hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '56' field = 'OBJECTMODELCREATEENABLED'       table = 'VIEW_LIST' length = '10' text = 'Object Model Create Enabled' hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '58' field = 'ODATAPUBLISH'                   table = 'VIEW_LIST' length = '10' text = 'OData Publish'        hot = 'X' checkbox = 'X' ).
    _add_field_to_catalogue( column = '60' field = 'RAPPUBLISH'                     table = 'VIEW_LIST' length = '10' text = 'RAP Serv.def.'        hot = 'X' checkbox = 'X' ).

    _add_field_to_catalogue( column = '62' field = 'METADATAALLOWEXTENSIONS'        table = 'VIEW_LIST' length = '10' text = '@Metadata.allowExtensions'  hot = 'X' checkbox = 'X' ).
    _add_field_to_catalogue( column = '64' field = 'SEARCHSEARCHABLE'               table = 'VIEW_LIST' length = '10' text = '@Search.searchable.'        hot = 'X' checkbox = 'X' ).
    _add_field_to_catalogue( column = '66' field = 'VDMUSAGETYPE1'                  table = 'VIEW_LIST' length = '10' text = '@VDM.usage.type 1'          hot = 'X' checkbox = '' ).
    _add_field_to_catalogue( column = '68' field = 'OBJECTMODELSEMANTICKEY1'        table = 'VIEW_LIST' length = '10' text = '@ObjectModel.semanticKey 1' hot = 'X' checkbox = '' ).

    _add_field_to_catalogue( column = '70' field = 'CREATE_USER_NAME'               table = 'VIEW_LIST' length = '12' text = 'Last Changed User'    hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '72' field = 'CREATE_DATE'                    table = 'VIEW_LIST' length = '12' text = 'Last Changed Date'    hot = 'X' checkbox = ' ' ).

    _add_field_to_catalogue( column = '80' field = 'BASICTABLECDSVIEWIND'           table = 'VIEW_LIST' length = '1' text = 'DB Table Basic CDS View'              hot = 'X' checkbox = 'X' ).
    _add_field_to_catalogue( column = '05' field = 'DDLSOURCENAME'                  table = 'VIEW_LIST' length = '30' text = 'DDL Source Name'        hot = 'X' checkbox = ' ' ).


  ENDMETHOD.

  METHOD _set_table_settings.

    "Apply zebra style to lv_rows
    DATA(lo_display_settings) = io_gr_alv->get_display_settings( ).
    lo_display_settings->set_striped_pattern( cl_salv_display_settings=>true ).

    "Enable the save layout buttons
    DATA lv_key TYPE salv_s_layout_key.
    lv_key-report = sy-repid.
    DATA(lo_layout) = io_gr_alv->get_layout( ).
    lo_layout->set_key( lv_key ).
    lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
    lo_layout->set_default( abap_true ).

  ENDMETHOD.

  METHOD _set_functions.

    TRY.

        DATA(lo_gr_function_list) = io_gr_alv->get_functions( ).

        "Show all default buttons of ALV
        lo_gr_function_list->set_all( abap_true ).

      CATCH cx_root INTO DATA(lx_root).

        MESSAGE lx_root->get_text( ) TYPE 'W'.

    ENDTRY.

  ENDMETHOD.


  METHOD _set_events.

    "Register events
    DATA(lo_events) = io_gr_alv->get_event( ).

    SET HANDLER me->on_double_click FOR lo_events.

    SET HANDLER me->on_user_command FOR lo_events.

    SET HANDLER me->on_before_salv_function FOR lo_events.

    SET HANDLER me->on_after_salv_function FOR lo_events.

    SET HANDLER me->on_double_click FOR lo_events.

    SET HANDLER me->on_link_click FOR lo_events.

  ENDMETHOD.

  METHOD on_after_salv_function.

  ENDMETHOD.

  METHOD on_before_salv_function.

  ENDMETHOD.

  METHOD on_user_command.

    DATA(lr_selections) = me->go_gr_alv->get_selections( ).
    DATA(et_selected_rows) = lr_selections->get_selected_rows( ).

    RAISE EVENT on_function
      EXPORTING ev_function_name = e_salv_function
                et_selected_rows = et_selected_rows.

  ENDMETHOD.

  METHOD on_link_click.

  ENDMETHOD.

ENDCLASS.

CLASS zscv_search_cds_views_ctl DEFINITION.

  PUBLIC SECTION.

    "-----------------------------------------------------
    "Methods
    "-----------------------------------------------------
    METHODS initialization.

    METHODS at_selection_screen_pbo.

    METHODS at_selection_screen_pai.

    METHODS start_of_selection.

    METHODS end_of_selection.

  PRIVATE SECTION.

    DATA view_list      TYPE zscv_view_search_dp=>tt_ddic_view_list.
    DATA gr_view TYPE REF TO zscv_cds_view_list_vw.
    DATA field_catalog  TYPE slis_t_fieldcat_alv.
    DATA gr_alv_table   TYPE REF TO cl_salv_table.

    METHODS _show_data.

    METHODS _on_view_function FOR EVENT on_function OF zscv_cds_view_list_vw
      IMPORTING ev_function_name
                et_selected_rows.

    METHODS set_sel_screen_field_prop.

    METHODS set_field_restrictions.

ENDCLASS.

CLASS zscv_search_cds_views_ctl IMPLEMENTATION.

  METHOD initialization.

    TRY.

        "set_sel_screen_field_prop( ).

      CATCH cx_root INTO DATA(lx_root).

        MESSAGE lx_root->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.

    ENDTRY.

  ENDMETHOD.

  METHOD _on_view_function.

    TRY.

        CASE ev_function_name.

          WHEN 'LINK_SUPER' OR 'LINK_SUB' OR 'LINK_DELE'.

            DATA(lv_selected_rows_count) = lines( et_selected_rows ).

            IF lv_selected_rows_count <> 1.
              MESSAGE |One CDS view must be selected.| TYPE 'I' DISPLAY LIKE 'E'.
              RETURN.
            ENDIF.

            DATA(row_index) = et_selected_rows[ 1 ].

            READ TABLE me->view_list
              ASSIGNING FIELD-SYMBOL(<ls_view>)
              INDEX row_index.

            CASE ev_function_name.

              WHEN 'LINK_SUPER' OR 'LINK_SUB'.

                DATA(lv_relation_level) = COND zscv_relation_level(
                    WHEN ev_function_name = 'LINK_SUPER' THEN zscv_released_basic_view_bo=>gcs__relation_level-super
                    WHEN ev_function_name = 'LINK_SUB'   THEN zscv_released_basic_view_bo=>gcs__relation_level-sub ).

                zscv_released_basic_view_bo=>create_relation(
                  iv_db_table_name    = CONV #( <ls_view>-start_view_name )
                  iv_cds_view_name    = CONV #( <ls_view>-abapviewname )
                  iv_relation_level   = lv_relation_level
                  iv_sap_release      = sy-saprl
                  iv_show_message_ind = abap_true ).

                <ls_view>-basictablecdsviewind = 'X'.
                <ls_view>-relationlevel = lv_relation_level.

              WHEN 'LINK_DELE'.

                DATA(lr_relation) = zscv_released_basic_view_bo=>get_instance_by_table_name(
                  iv_db_table_name = CONV #( <ls_view>-start_view_name )
                  iv_cds_view_name  = CONV #( <ls_view>-abapviewname ) ).

                lr_relation->delete_relation( ).

                <ls_view>-basictablecdsviewind = ''.
                <ls_view>-relationlevel = ''.

            ENDCASE.

            me->gr_view->refresh( ).

          WHEN 'LINK_DELE'.


        ENDCASE.

      CATCH cx_root INTO DATA(lx_root).

        MESSAGE lx_root->get_text( ) TYPE 'E'.

    ENDTRY.

  ENDMETHOD.

  METHOD set_sel_screen_field_prop.

    LOOP AT SCREEN.

      CASE screen-group1.

        WHEN 'HRS'.

          IF r_shdbtb = 'X'.
            screen-invisible = 1.
            screen-active = 0.
            screen-input = 0.
          ELSE.
            screen-invisible = 0.
            screen-active = 1.
            screen-input = 1.
          ENDIF.

          MODIFY SCREEN.

        WHEN 'DBT'.

          IF r_shdbtb = 'X'.
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

  ENDMETHOD.

  METHOD set_field_restrictions.

    DATA(ls_restriction) =
      VALUE sscr_restrict(

        opt_list_tab = VALUE #(
          (
            name       = 'EQ_CP'
            options = VALUE #(
              eq = 'X'
              cp = 'X'
            )
          )
        )

        ass_tab      = VALUE #(
          (
            kind        = 'S'           "A(ll), B(lock), S(elect-Option)
            name        = 'S_FLDNM'    "SELECT-OPTION field name
            sg_main     = 'I'           "Main SiGn: I = only include, SPACE = both  / * Both Include and Exclude options
            sg_addy     = space        "Additional multiple selection screen - Sign ('I'/'')
            op_main     = 'EQ_CP'     "Main selection screen - options list name (must match opt_list_tab[]-name
            op_addy     = 'EQ_CP'          "Additional multiple selection screen - options list name
          )
          (
            kind        = 'S'           "A(ll), B(lock), S(elect-Option)
            name        = 'S_DTELNM'    "SELECT-OPTION field name
            sg_main     = 'I'           "Main SiGn: I = only include
            sg_addy     = space         "Additional multiple selection screen - Sign ('I'/'')
            "op_main     = 'EQ_CP'     "Main selection screen - options list name (must match opt_list_tab[]-name
            op_addy     = ''            "Additional multiple selection screen - options list name
          )
          (
            kind        = 'S'           "A(ll), B(lock), S(elect-Option)
            name        = 'S_DOMNM'    "SELECT-OPTION field name
            sg_main     = 'I'           "Main SiGn: I = only include
            sg_addy     = space         "Additional multiple selection screen - Sign ('I'/'')
            "op_main     = 'EQ_CP'     "Main selection screen - options list name (must match opt_list_tab[]-name
            op_addy     = ''            "Additional multiple selection screen - options list name
          )

        )
      ).

    CALL FUNCTION 'SELECT_OPTIONS_RESTRICT'
      EXPORTING
        restriction            = ls_restriction
      EXCEPTIONS
        too_late               = 1
        repeated               = 2
        selopt_without_options = 3
        selopt_without_signs   = 4
        invalid_sign           = 5
        empty_option_list      = 6
        invalid_kind           = 7
        repeated_kind_a        = 8
        OTHERS                 = 9.

  ENDMETHOD.

  METHOD at_selection_screen_pbo.

    TRY.

        set_field_restrictions( ).

        set_sel_screen_field_prop( ).

        DATA(lr_cds_rel_run) = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-cds_relation ).
        DATA(ls_cds_rel_run_check) = lr_cds_rel_run->check_run_is_completed( ).
        rel_ts = |{ ls_cds_rel_run_check-text }|.

        DATA(lr_main_db_table_run) = NEW zscv_run_bo( zscv_run_bo=>gcs_run_types-cds_main_db_table_name ).
        DATA(ls_db_table_run_check) = lr_main_db_table_run->check_run_is_completed( ).
        dbtab_ts = |{ ls_db_table_run_check-text }|.

      CATCH zx_scv_return INTO DATA(lx_return).

        MESSAGE lx_return->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.

    ENDTRY.

  ENDMETHOD.

  METHOD at_selection_screen_pai.

    CASE sy-ucomm.

      WHEN 'SRCH'.

        "Action will be executed in PBO.
        IF r_shhier = 'X'.

          IF lines( s_bstab ) =  1.

            DATA(ls_db_name_rng) = s_bstab[ 1 ].

            IF ls_db_name_rng-sign = 'I' AND ls_db_name_rng-option = 'EQ'.
              s_dbtab[] = s_bstab[].
            ENDIF.

          ENDIF.

        ELSE.

          IF s_dbtab[] IS NOT INITIAL AND
             ( s_bstab[] IS INITIAL OR
               lines( s_bstab ) <= 1 ).

            s_bstab[] = s_dbtab[].

          ENDIF.

        ENDIF.

      WHEN 'DELTA'.

        DATA(lr_indexer) = NEW zscv_search_indexer( ).
        lr_indexer->delta_update( ).

        MESSAGE |Delta update executed.| TYPE 'S'.

      WHEN 'Q_ALL'.

        REFRESH s_abapvw[].
        REFRESH s_ddicvw[].
        REFRESH s_ddlnm[].

      WHEN 'Q_CUSTOM'.

        s_abapvw[] =
          VALUE #(
            ( sign   = 'I'
              option = 'CP'
              low    = 'Z*' )
            ( sign   = 'I'
              option = 'CP'
              low    = 'Y*' )
          ).
        REFRESH s_ddlnm[].

      WHEN 'Q_CUSDDC'.
        REFRESH s_abapvw.
        s_ddicvw[] =
          VALUE #(
            ( sign   = 'I'
              option = 'CP'
              low    = 'Z*' )
            ( sign   = 'I'
              option = 'CP'
              low    = 'Y*' )
          ).
        REFRESH s_ddlnm[].

      WHEN 'Q_CUSCDS'.

        REFRESH s_abapvw.
        REFRESH s_ddicvw[].
        s_ddlnm[] =
          VALUE #(
            ( sign   = 'I'
              option = 'CP'
              low    = 'Z*' )
            ( sign   = 'I'
              option = 'CP'
              low    = 'Y*' )
          ).

      WHEN 'Q_ABALL'.
        s_c1stat[] = VALUE #( ( sign = 'I' option = 'EQ' low = 'RELEASED' ) ).
        s_c1abap[] = VALUE #( ( sign = 'I' option = 'EQ' low = 'X' ) ).
        s_c2stat[] = VALUE #( ( sign = 'I' option = 'EQ' low = 'RELEASED' ) ).

      WHEN 'Q_ABAP'.
        s_c1stat[] = VALUE #( ( sign = 'I' option = 'EQ' low = 'RELEASED' ) ).
        s_c1abap[] = VALUE #( ( sign = 'I' option = 'EQ' low = 'X' ) ).
        REFRESH s_c2stat[].

      WHEN 'Q_API'.
        REFRESH s_c1stat.
        REFRESH s_c1kapp.
        REFRESH s_c1abap.
        s_c2stat[] = VALUE #(
          ( sign = 'I' option = 'EQ' low = 'RELEASED' ) ).

      WHEN 'Q_STALL'.
        REFRESH s_c1stat.
        REFRESH s_c1kapp.
        REFRESH s_c1abap.
        REFRESH s_c2stat.

      WHEN 'DBALL'.
        REFRESH s_dbtab[].

      WHEN 'DBSUCC'.

        IF s_dbtab[] IS INITIAL.
          "DB tables/views field is empty.
          MESSAGE |DB tables/views field is empty.| TYPE 'I'.
          RETURN.
        ENDIF.

        SELECT
          FROM dd02l
          FIELDS
            CAST( tabname AS CHAR( 36 ) )  AS table_name
          WHERE
            tabname IN @s_dbtab[] AND
            as4local = 'A' AND
            as4vers = ''
          ORDER BY
            dd02l~tabname
          INTO TABLE @DATA(db_views).

        IF sy-subrc <> 0.
          MESSAGE |No tables/views found.| TYPE 'I'.
          RETURN.
        ENDIF.

        SELECT
          FROM ars_w_api_state AS state
          INNER JOIN ddldependency
            ON ddldependency~ddlname = state~successor_object_name AND
               ddldependency~objecttype = 'VIEW'
          FIELDS
            object_name,
            successor_object_name AS successor_cds_view_name,
            ddldependency~objectname AS successor_ddic_view_name
          FOR ALL ENTRIES IN @db_views
          WHERE
            state~object_id = @db_views-table_name
          INTO TABLE @DATA(successor_views).

        IF sy-subrc <> 0.
          MESSAGE |No successor CDS views found. (Table: ARS_W_API_STATE)| TYPE 'I'.
          RETURN.
        ENDIF.

        REFRESH s_dbtab[].

        LOOP AT db_views
          ASSIGNING FIELD-SYMBOL(<db_table>).

          READ TABLE successor_views
            WITH KEY object_name = <db_table>-table_name
            ASSIGNING FIELD-SYMBOL(<successor_view>).
          IF sy-subrc <> 0.
            DATA(view_name) = <db_table>-table_name.
          ELSE.
            "IF p_ddcddc = 'X'.
            view_name = <successor_view>-successor_ddic_view_name.
            "ELSE.
            "view_name = <successor_view>-successor_cds_view_name.
            "ENDIF.
          ENDIF.

          APPEND VALUE #( sign = 'I' option = 'EQ' low = view_name )
            TO s_dbtab[].

        ENDLOOP.

        SORT s_dbtab BY low.

        MESSAGE |DB tables/views found: { lines( db_views[] ) }. Successor CDS views found { lines( successor_views ) }. (Table: ARS_W_API_STATE)| TYPE 'S'.

      WHEN 'DBAUFK'.
        s_dbtab[] = VALUE #(
          ( sign = 'I' option = 'EQ' low = 'AUFK' ) ).

      WHEN 'DBPROD'.
        s_dbtab[] = VALUE #(
          ( sign = 'I' option = 'EQ' low = 'IPRODUCT' ) ).

      WHEN 'COMPDB'.

        SELECT
          FROM dd02l
          FIELDS
            'I' AS sign,
            'EQ' AS option,
            dd02l~tabname AS low
          WHERE viewref <> ''
          ORDER BY
            dd02l~tabname
          INTO CORRESPONDING FIELDS OF TABLE @s_dbtab[].

        MESSAGE |Comp. table count: { lines( s_dbtab ) }| TYPE 'S'.

      WHEN 'VT_BASIC'.
        s_viewtp[] = VALUE #(
          ( sign = 'I' option = 'EQ' low = '#BASIC' ) ).

      WHEN 'VT_COMP'.
        s_viewtp[] = VALUE #(
          ( sign = 'I' option = 'EQ' low = '#COMPOSITE' ) ).

      WHEN 'VT_CONS'.
        s_viewtp[] = VALUE #(
          ( sign = 'I' option = 'EQ' low = '#CONSUMPTION' ) ).

      WHEN 'VT_EXT'.
        s_viewtp[] = VALUE #(
          ( sign = 'I' option = 'EQ' low = '#EXTENSION' ) ).

      WHEN 'VT_TRAN'.
        s_viewtp[] = VALUE #(
          ( sign = 'I' option = 'EQ' low = '#TRANSACTIONAL' ) ).

      WHEN 'VW_ALL'.
        REFRESH s_viewtp[].

      WHEN 'DC_DIM'.
        s_datcat[] = VALUE #(
          ( sign = 'I' option = 'EQ' low = '#DIMENSION' ) ).

      WHEN 'DC_ALL'.
        REFRESH s_datcat[].

      WHEN OTHERS.

    ENDCASE.

  ENDMETHOD.

  METHOD start_of_selection.

  ENDMETHOD.

  METHOD end_of_selection.

    TRY.

        CASE sy-ucomm.

          WHEN 'COMPDB'.

          WHEN OTHERS.

            IF r_shdbtb = abap_true.

              DATA(lr_db_table_based_search) = NEW zscv_db_table_based_search_prc( ).

              lr_db_table_based_search->show_all_basic_views( ).

            ELSEIF r_shhier = abap_true.

              IF s_dbtab[] IS NOT INITIAL.

                DATA(view_search_dp) = NEW zscv_view_search_dp( ).
                view_list = view_search_dp->get_views_by_source_names(  ).


              ELSEIF
                s_fldnm[] IS NOT INITIAL.

                view_search_dp = NEW zscv_view_search_dp( ).
                view_list = view_search_dp->get_views_by_field_names(  ).

              ELSE.

                MESSAGE |Table/Views or Field has to be filled.| TYPE 'I' DISPLAY LIKE 'E' .
                RETURN.

              ENDIF.

              _show_data( ).

            ENDIF.

        ENDCASE.

      CATCH zcx_generic_exc INTO DATA(generic_exc).

        DATA(error_message_text) = generic_exc->get_text( ).

        MESSAGE error_message_text TYPE 'I' DISPLAY LIKE 'E' .

    ENDTRY.

  ENDMETHOD.

  METHOD _show_data.

    DATA layout      TYPE slis_layout_alv.

    MESSAGE |View count: { lines( view_list ) }| TYPE 'S'.

    gr_view = zscv_cds_view_list_vw=>create_by_ref_data( REF #( view_list ) ).
    SET HANDLER _on_view_function FOR me->gr_view.

    gr_view->display( ).

  ENDMETHOD.

ENDCLASS.

"------------------------------------------------
"Application
"------------------------------------------------
DATA main_controller TYPE REF TO zscv_search_cds_views_ctl.

LOAD-OF-PROGRAM.

  main_controller = NEW #( ).

INITIALIZATION.

  s_c1stat[] = VALUE #(
    (
      sign = 'I'
      option = 'EQ'
      low = 'RELEASED'
    )
  ).

  s_c1abap[] = VALUE #( ( sign = 'I' option = 'EQ' low = 'X') ).

  s_viewtp[] = VALUE #(
    (
      sign = 'I'
      option = 'EQ'
      low = '#BASIC'
    )
  ).

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  tt_index = 'Index Table Status'.
  delta = 'Delta update CDS Index Table'.

  tt_srch   = 'CDS Search Method'.
  %_r_shhier_%_app_%-text  = 'Hierarchy search'.
  %_r_shdbtb_%_app_%-text  = 'List search'.

  tbasic = 'Main DB Table Source Selection'.
  %_s_bstab_%_app_%-text = 'DB Table'.
*  %_s_bscds_%_app_%-text = 'Basic CDS View'.
*  %_s_rellvl_%_app_%-text = 'Relation Level'.
*  %_s_exist_%_app_%-text = 'Exists indicator'.
*  %_s_clddev_%_app_%-text = 'Use in Cloud dev.'.

  tt_view = 'Hierarchy Source Selection'. "TEXT-101
  pb_alltb = 'All tables'.         "text-006
  pb_succr = 'Successor CDS view'. "text-007
  pb_comp  = 'Compatibility tables'. "text-007
  %_s_dbtab_%_app_%-text = 'DB Table / View'.

  %_s_fldnm_%_app_%-text = 'Field Name (AND-filter)'.

  tt_vtype = 'View types'. "TEXT-113.
  %_vt_table_%_app_%-text = 'DDic Table'.
  %_vt_ddvw_%_app_%-text  = 'DDic View'.
  %_vt_ddcds_%_app_%-text = 'DDic CDS View'.
  %_vt_entcd_%_app_%-text = 'Entity CDS View'.

  tt_vname = 'View names'. "TEXT-102
  pbcustvw = 'Custom ABAP views'. "TEXT-001
  pbddicvw = 'Custom DDic Views'.  "TEXT-002
  pbcstddl = 'Custom DDL source'.
  tq_all = 'All views'. "TEXT-004

  %_s_abapvw_%_app_%-text = 'ABAP View'.
  tabapvw = 'ABAP View: For DDic CDS name use DDic name'.      "TEXT-104

  %_s_ddicvw_%_app_%-text = 'DDic View Name'.
  %_s_ddlnm_%_app_%-text = 'DDL Resource Name'.

  tstat = 'API State'. "TEXT-103
*  tq_aball = 'ABAP C1 + C2'. "TEXT-105
  tq_abap = 'Internal API (C1)'. "TEXT-106
  tq_api = 'Public API (C2)'. "TEXT-107
  tq_stall = 'All statuses'. "TEXT-108

  %_s_c1stat_%_app_%-text = 'C1 Release state'.
  %_s_c1kapp_%_app_%-text = 'C1 In Key user app allowed'.
  %_s_c1abap_%_app_%-text = 'C1 In ABAP allowed'.
  %_s_c2stat_%_app_%-text = 'C2 Release state'.

  todata = 'OData and RAP'. "TEXT-112
  %_s_odata_%_app_%-text = 'View OData (@OData.publish)'.
  %_s_rapodt_%_app_%-text = 'Main RAP Entity'.
  %_s_chdrap_%_app_%-text = 'Secondairy RAP Entity'.

  tviewtp = 'View Type'. "TEXT-109
  tvtbasic = '#BASIC'.  "TEXT-008
  tvtcomp = '#COMPOSITE'.
  tvtcons = '#CONSUMPTION'.
  tvtext = '#EXTENSION'.
  tvtran = '#TRANSACTIONAL'.
  tvw_all = 'All'.
  %_s_viewtp_%_app_%-text = 'VDM View Type'.

  datcat = 'Data Category'.
  tdc_dim = '#DIMENSION'. "TEXT-009
  tdc_all = 'All'. " TEXT-010

  %_s_datcat_%_app_%-text = 'Data Category'.

  main_controller->initialization( ).

AT SELECTION-SCREEN OUTPUT.

  main_controller->at_selection_screen_pbo( ).

AT SELECTION-SCREEN.

  main_controller->at_selection_screen_pai( ).

START-OF-SELECTION.

  main_controller->start_of_selection( ).

END-OF-SELECTION.
  main_controller->end_of_selection( ).
