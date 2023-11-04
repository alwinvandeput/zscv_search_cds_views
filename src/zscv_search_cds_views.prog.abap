REPORT zscv_search_cds_views.

*--------------------------------------------------------------------
*Date        : 04.03.2023
*Last update : 17.06.2023
*Author      : Alwin van de Put
*
*Purpose:
*Search all related ABAP views hierarchically.
*
*ABAP views are:
*- ZSCV_DdicTable     = Database tables
*- ZSCV_DdicView      = DDic views
*- ZSCV_DdicView      = DDic CDS views -> must be changed
*- ZSCV_EntityCdsView = Entity CDS views

*- ZSCV_AbapView      = All the above views
*- ZSCV_CdsView       = DDic CDS views + Entity CDS views

*--------------------------------------------------------------------

TABLES: ars_w_api_state, dd26s, sscrfields.

SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME.

  "Source view name selection
  SELECTION-SCREEN BEGIN OF BLOCK dbtab WITH FRAME TITLE TEXT-101.

    "All tables
    SELECTION-SCREEN  PUSHBUTTON 1(10) TEXT-006 USER-COMMAND dball.
    "Get successor CDS view
    SELECTION-SCREEN  PUSHBUTTON 13(20) TEXT-007 USER-COMMAND dbsucc.
    "Compatibility tables
    SELECTION-SCREEN  PUSHBUTTON 41(20) TEXT-005 USER-COMMAND compdb.

    DATA db_view_name_type TYPE vibastab.
    SELECT-OPTIONS s_dbtab FOR db_view_name_type.

*    SELECTION-SCREEN SKIP.

*    DATA db_field_name_type TYPE fieldname.
*    SELECT-OPTIONS s_fldnm FOR db_view_name_type NO INTERVALS.
*
*    DATA db_data_element_name_type TYPE rollname.
*    SELECT-OPTIONS s_dtelnm FOR db_data_element_name_type NO INTERVALS.
*
*    DATA db_domain_name_type TYPE domname.
*    SELECT-OPTIONS s_domnm FOR db_domain_name_type NO INTERVALS.

  SELECTION-SCREEN END OF BLOCK dbtab.

  SELECTION-SCREEN BEGIN OF BLOCK vtype WITH FRAME TITLE TEXT-113.
    PARAMETERS vt_table AS CHECKBOX DEFAULT 'X'.
    PARAMETERS vt_ddvw  AS CHECKBOX DEFAULT 'X'.
    PARAMETERS vt_ddcds AS CHECKBOX DEFAULT 'X'.
    PARAMETERS vt_entcd AS CHECKBOX DEFAULT 'X'.
  SELECTION-SCREEN END OF BLOCK vtype.

  "Result view name selection
  SELECTION-SCREEN BEGIN OF BLOCK vname WITH FRAME TITLE TEXT-102.

    "Custom ABAP views
    SELECTION-SCREEN  PUSHBUTTON 2(17) TEXT-001 USER-COMMAND q_custom.
    "Custom DDic Views
    SELECTION-SCREEN  PUSHBUTTON 21(20) TEXT-002 USER-COMMAND q_cusddc.
    "Custom DDL source
    SELECTION-SCREEN  PUSHBUTTON 44(20) TEXT-003 USER-COMMAND q_cuscds.
    "All views
    SELECTION-SCREEN  PUSHBUTTON 66(10) TEXT-004 USER-COMMAND q_all.

    SELECT-OPTIONS s_abapvw FOR dd26s-viewname.
    SELECTION-SCREEN BEGIN OF LINE.
      SELECTION-SCREEN POSITION 1.
      SELECTION-SCREEN COMMENT 1(70) TEXT-104.
    SELECTION-SCREEN END OF LINE.

    SELECT-OPTIONS s_ddicvw FOR dd26s-viewname.

    DATA ddl_name_type TYPE ddldependency-ddlname.
    SELECT-OPTIONS s_ddlnm FOR ddl_name_type.

  SELECTION-SCREEN END OF BLOCK vname.

  "Status selection
  SELECTION-SCREEN BEGIN OF BLOCK stat WITH FRAME TITLE TEXT-103.

    "ABAP all
    SELECTION-SCREEN  PUSHBUTTON 1(15) TEXT-105 USER-COMMAND q_aball.
    "ABAP internal
    SELECTION-SCREEN  PUSHBUTTON 18(18) TEXT-106 USER-COMMAND q_abap.
    "API CDS views only
    SELECTION-SCREEN  PUSHBUTTON 38(20) TEXT-107 USER-COMMAND q_api.
    "All statuses
    SELECTION-SCREEN  PUSHBUTTON 60(15) TEXT-108 USER-COMMAND q_stall.

    SELECT-OPTIONS s_c1stat FOR ars_w_api_state-release_state.
    PARAMETERS p_c1kapp AS CHECKBOX.
    PARAMETERS p_c1abap AS CHECKBOX.
    SELECT-OPTIONS s_c2stat FOR ars_w_api_state-release_state.

  SELECTION-SCREEN END OF BLOCK stat.

  SELECTION-SCREEN BEGIN OF BLOCK odata WITH FRAME TITLE TEXT-112.
    DATA odata_publish_type TYPE xfeld.
    SELECT-OPTIONS s_odata FOR odata_publish_type.
    SELECT-OPTIONS s_rapodt FOR odata_publish_type.
  SELECTION-SCREEN END OF BLOCK odata.

  SELECTION-SCREEN BEGIN OF BLOCK viewtype WITH FRAME TITLE TEXT-109.
    "#BASIC
    SELECTION-SCREEN  PUSHBUTTON 1(18) TEXT-008 USER-COMMAND vt_basic.
*    "All
*    SELECTION-SCREEN  PUSHBUTTON 21(18) dc_all USER-COMMAND dc_all.
    DATA vdm_view_type_type TYPE ddannotation_val.
    SELECT-OPTIONS s_viewtp FOR vdm_view_type_type.
  SELECTION-SCREEN END OF BLOCK viewtype.


  SELECTION-SCREEN BEGIN OF BLOCK datcat WITH FRAME TITLE datcat.
    "#DIMENSION
    SELECTION-SCREEN  PUSHBUTTON 1(18) TEXT-009 USER-COMMAND dc_dim.
    "All
    SELECTION-SCREEN  PUSHBUTTON 21(18) TEXT-010 USER-COMMAND dc_all.
    DATA data_category_type TYPE ddannotation_val.
    SELECT-OPTIONS s_datcat FOR data_category_type.
  SELECTION-SCREEN END OF BLOCK datcat.

*  "Status selection
*  SELECTION-SCREEN BEGIN OF BLOCK ddiccds WITH FRAME TITLE TEXT-110.
*    PARAMETERS:
*      p_ddcddc RADIOBUTTON GROUP ddcc  DEFAULT 'X',
*      p_ddcddl RADIOBUTTON GROUP ddcc.
*    SELECTION-SCREEN BEGIN OF LINE.
*      SELECTION-SCREEN POSITION 1.
*      SELECTION-SCREEN COMMENT 1(70) TEXT-111.
*    SELECTION-SCREEN END OF LINE.
*  SELECTION-SCREEN END OF BLOCK ddiccds.

SELECTION-SCREEN END OF BLOCK sel.


AT SELECTION-SCREEN OUTPUT.

  DATA(ls_restriction) =
    VALUE sscr_restrict(

*      opt_list_tab = VALUE #(
*        (
*          name    = 'EQ_ONLY'         "Options list name (is not the SELECT-OPTION name)
*          options = VALUE #(
*            eq      = abap_true       "EQ option is activated
*            bt      = abap_false      "BT option is deactivated (there are more options)
*          )
*        )
*      )

      ass_tab      = VALUE #(
        (
          kind        = 'S'           "A(ll), B(lock), S(elect-Option)
          name        = 'S_FLDNM'    "SELECT-OPTION field name
          sg_main     = 'I'           "Main SiGn: I = only include, SPACE = both  / * Both Include and Exclude options
          sg_addy     = space         "Additional multiple selection screen - Sign ('I'/'')
          "op_main     = 'EQ_ONLY'     "Main selection screen - options list name (must match opt_list_tab[]-name
          op_main     = ''
          op_addy     = ''          "Additional multiple selection screen - options list name
        )
        (
          kind        = 'S'           "A(ll), B(lock), S(elect-Option)
          name        = 'S_DTELNM'    "SELECT-OPTION field name
          sg_main     = 'I'           "Main SiGn: I = only include, SPACE = both  / * Both Include and Exclude options
          sg_addy     = space         "Additional multiple selection screen - Sign ('I'/'')
          "op_main     = 'EQ_ONLY'     "Main selection screen - options list name (must match opt_list_tab[]-name
          op_addy     = ''            "Additional multiple selection screen - options list name
        )
        (
          kind        = 'S'           "A(ll), B(lock), S(elect-Option)
          name        = 'S_DOMNM'    "SELECT-OPTION field name
          sg_main     = 'I'           "Main SiGn: I = only include, SPACE = both  / * Both Include and Exclude options
          sg_addy     = space         "Additional multiple selection screen - Sign ('I'/'')
          "op_main     = 'EQ_ONLY'     "Main selection screen - options list name (must match opt_list_tab[]-name
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


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method zca_progress_bar->ADD_TEXT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TEXT                        TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD add_text.

    DATA(lv_percentage) = get_percentage( ).

    DATA(lv_text) = get_text( ).

    lv_text = |{ lv_text } { iv_text }|.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = lv_percentage
        text       = lv_text.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method zca_progress_bar->CLEAR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
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


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zca_progress_bar=>CREATE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_DATA                        TYPE        GTS_DATA
* | [<-()] RR_INSTANCE                    TYPE REF TO zca_progress_bar
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create.

    rr_instance = NEW #( ).
    rr_instance->gs_data = is_data.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method zca_progress_bar->GET_PERCENTAGE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RV_PERCENTAGE                  TYPE        GTV_PERCENTAGE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_percentage.

    rv_percentage = ( gv_value / gs_data-max_value ) * 100.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method zca_progress_bar->GET_REFRESH_NEEDED_IND
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RV_REFRESH_NEEDED_IND          TYPE        XFELD
* +--------------------------------------------------------------------------------------</SIGNATURE>
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


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method zca_progress_bar->GET_TEXT
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RV_TEXT                        TYPE        GTV_TEXT
* +--------------------------------------------------------------------------------------</SIGNATURE>
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


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method zca_progress_bar->SET_VALUE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_VALUE                       TYPE        GTV_VALUE
* +--------------------------------------------------------------------------------------</SIGNATURE>
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


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zca_progress_bar=>STATIC_CLEAR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD static_clear.

    ""Use this method only for clearing progress bar not created by this class
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = 0
        text       = space.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zca_progress_bar=>STATIC_SET_TEXT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TEXT                        TYPE        GTV_TEXT
* +--------------------------------------------------------------------------------------</SIGNATURE>
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
        AbapViewType                  TYPE c LENGTH 10,
        AbapViewName                  TYPE ZSCV_AbapViewByView-AbapViewName,
        DdlSourceName                 TYPE cds_sql_view-ddlsourcename,

        DataCategory                  TYPE ddannotation_val,
        EmbeddedAnalyticsQueryInd     TYPE abap_bool,

        DdicViewName                  TYPE dd26s-viewname,
        childddicviewname             TYPE dd26s-viewname,

        c1_releasestate               TYPE ars_w_api_state-release_state,
        c1_useinkeyuserapps           TYPE abap_bool,
        c1_useincloudplatform         TYPE abap_bool,

        c2_releasestate               TYPE ars_w_api_state-release_state,
        c2_useinkeyuserapps           TYPE abap_bool,
        c2_useincloudplatform         TYPE abap_bool,

        EndUserTextLabel              TYPE ddheadanno-value,
        VdmViewType                   TYPE ddheadanno-value,
        AccessCONTROLAuthCheck        TYPE ddheadanno-value,
        ObjectModelUsageTypeDataClass TYPE ddheadanno-value,
        VdmLifeCycleContractType      TYPE ddheadanno-value,
        ObjectModelCreateEnabled      TYPE ddheadanno-value,
        ODataPublish                  TYPE ddheadanno-value,
        RapPublish                    TYPE ddheadanno-value,

        MetadataAllowExtensions       TYPE ddheadanno-value,
        SearchSearchable              TYPE ddheadanno-value,
        VdmUsageType1                 TYPE ddheadanno-value,
        ObjectModelSemanticKey1       TYPE ddheadanno-value,

        Create_User_Name              TYPE dd02l-as4user,
        Create_Date                   TYPE dd02l-as4date,
        Create_Time                   TYPE dd02l-as4time,

        start_view_name               TYPE dd26s-viewname,

      END OF ts_ddic_view,
      tt_ddic_view_list TYPE STANDARD TABLE OF ts_ddic_view WITH EMPTY KEY. "TODO: rename

    TYPES t_view_range TYPE RANGE OF ts_ddic_view-abapviewname.

    METHODS get_views_by_source_names
      IMPORTING view_range       TYPE t_view_range OPTIONAL
      RETURNING VALUE(view_list) TYPE zscv_view_search_dp=>tt_ddic_view_list
      RAISING   zcx_generic_exc.

    TYPES t_view_rng TYPE RANGE OF ZSCV_AbapViewByView-AbapViewName.
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

*    METHODS _get_abap_views_by_ddl
*      IMPORTING db_table_name    TYPE vibastab
*      RETURNING VALUE(view_list) TYPE tt_ddic_view_list
*      RAISING   zcx_generic_exc.

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
      FROM ZSCV_AbapView
      FIELDS
        AbapViewName
      WHERE
        AbapViewName IN @view_range2[]
      ORDER BY
        AbapViewName
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
        iv_text  = |Count: { view_list_line_count }, root view: { <root_view>-AbapViewName } | ).

      DATA(temp_view_list) = _get_views_by_source_name(
        db_table_name = <root_view>-AbapViewName ).

      LOOP AT temp_view_list
        ASSIGNING FIELD-SYMBOL(<source_line>).

        <source_line>-start_view_name = <root_view>-AbapViewName.

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
       AbapView~AbapViewType,
       AbapView~AbapViewName,

       AbapView~ddlsourcename,
       \_cdsview-datacategory,
       \_cdsview-embeddedanalyticsqueryind,

       AbapView~DdicViewName,

        \_cdsview\_status-c1_releasestate,
        \_cdsview\_status-c1_useinkeyuserapps,
        \_cdsview\_status-c1_useincloudplatform,

        \_cdsview\_status-c2_releasestate,

        \_CdsView-EndUserTextLabel,
        \_CdsView-vdmviewtype,
        \_CdsView-accesscontrolauthcheck,
        \_CdsView-objectmodelusagetypedataclass,
        \_CdsView-vdmlifecyclecontracttype,
        \_CdsView-objectmodelcreateenabled,
        \_CdsView-odatapublish,
        \_CdsView-rappublish,

        \_CdsView-MetadataAllowExtensions,
        \_CdsView-SearchSearchable,
        \_CdsView-VdmUsageType1,
        \_CdsView-ObjectModelSemanticKey1,

        \_cdsview-CreateUser AS Create_User_Name,
        \_cdsview-CreateDate AS Create_Date

        FROM
          ZSCV_AbapView AS AbapView

        WHERE
          AbapView~AbapViewType    IN @view_type_rng[] AND
          AbapView~AbapViewName    IN @view_range[] AND
          AbapView~AbapViewName    IN @s_abapvw[] AND
          AbapView~DdicViewName    IN @s_ddicvw[] AND
          \_cdsview-ddlsourcename  IN @s_ddlnm
          AND
          (where_parameters-where_text)

          AND
          \_cdsview-VdmViewType     IN @s_viewtp[] AND
          \_cdsview-ODataPublish    IN @s_odata[] AND
          \_cdsview-RapPublish      IN @s_rapodt[] AND
          \_cdsview-datacategory    IN @s_datcat[]

          ORDER BY
            AbapView~ddlsourcename,
            AbapView~DdicViewName

      INTO CORRESPONDING FIELDS OF TABLE @view_list.

  ENDMETHOD.

  METHOD _get_views_by_field_names2.

*    IF s_fldnm[] IS NOT INITIAL.
*      SELECT
*        FROM ZSCV_AbapViewAliasField AS Field
*        FIELDS
*          Field~AbapViewName,
*          Field~FieldName,
*          Field~DataElementName,
*          Field~DomainName
*        WHERE
*          Field~AbapViewName IN @view_rng[] AND
*          FieldName          IN @s_fldnm[]
*        INTO TABLE @DATA(temp_filtered_views).
*    ENDIF.
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
*    DATA selected_view_list TYPE t_view_range.
*
*    LOOP AT temp_filtered_views
*      INTO DATA(view_field)
*      GROUP BY view_field-AbapViewName.
*
*      APPEND VALUE #(
*        sign = 'I'
*        option = 'EQ'
*        low = view_field-AbapViewName )
*        TO selected_view_list.
*
*    ENDLOOP.
*
*    LOOP AT selected_view_list
*      ASSIGNING FIELD-SYMBOL(<selected_view>).
*
*      DATA(ViewName) = <selected_view>-low.

*      DATA(all_fields_found_ind) = abap_true.
*
*      LOOP AT s_fldnm ASSIGNING FIELD-SYMBOL(<field>).
*
*        DATA field_one_field_rng LIKE s_fldnm[].
*
*        REFRESH field_one_field_rng.
*        APPEND <field> TO field_one_field_rng.
*
*        LOOP AT temp_filtered_views
*          ASSIGNING FIELD-SYMBOL(<dummy>)
*          WHERE
*            AbapViewName =  ViewName AND
*            FieldName    IN field_one_field_rng.
*        ENDLOOP.
*
*        IF sy-subrc <> 0.
*          all_fields_found_ind = abap_false.
*        ENDIF.
*
*      ENDLOOP.

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

*      IF all_fields_found_ind = abap_true.
*        APPEND <selected_view> TO view_range.
*      ENDIF.

*    ENDLOOP.

  ENDMETHOD.

  METHOD _get_views_by_source_name.

    view_list = _get_views_by_source_name2( db_table_name ).

*    IF s_fldnm[] IS NOT INITIAL OR
*       s_dtelnm[] IS NOT INITIAL OR
*       s_domnm[] IS NOT INITIAL.
*
*      view_list = _filter_views_by_fields( view_list ).
*
*    ENDIF.

  ENDMETHOD.

*  METHOD _get_abap_views_by_ddl.
*
*    TYPES:
*      BEGIN OF ty_temp_parent_view,
*        ParentAbapViewName  TYPE ZSCV_AbapViewParent-ParentAbapViewName,
*        ParentAbapViewType  TYPE ZSCV_AbapViewParent-ParentAbapViewType,
*        ParentDdlSourceName TYPE ZSCV_AbapViewParent-ParentDdlSourceName,
*        ParentDdicViewName  TYPE ZSCV_AbapViewParent-ParentDdicViewName,
*      END OF ty_temp_parent_view,
*      tt_temp_parent_views TYPE SORTED TABLE OF ty_temp_parent_view
*        WITH UNIQUE KEY ParentAbapViewName.
*
*    DATA child_view_rng TYPE RANGE OF ZSCV_AbapViewParent-ChildAbapViewName.
*
*    child_view_rng = VALUE #(
*      ( sign = 'I'
*        option = 'EQ'
*        low = db_table_name )
*    ).
*
*    DATA hierarchy_level TYPE i.
*
*    WHILE 1 = 1.
*
*      hierarchy_level = hierarchy_level + 1.
*
*      zca_progress_bar=>static_set_text( |Hierarchy level: {  hierarchy_level } - Childs: { lines( child_view_rng ) }| ).
*
*      SELECT
*        FROM ZSCV_AbapViewParent( p_DdicCdsBasedOnDllResourceInd = 'X' )
*        FIELDS
*          ParentAbapViewName,
*          ParentAbapViewType,
*          ParentDdlSourceName,
*          ParentDdicViewName
*        WHERE ChildAbapViewName IN @child_view_rng
*        GROUP BY
*          ParentAbapViewName,
*          ParentAbapViewType,
*          ParentDdlSourceName,
*          ParentDdicViewName
*        INTO TABLE @DATA(level_parent_view_list).
*
*      SORT level_parent_view_list BY ParentAbapViewName.
*
*      REFRESH child_view_rng[].
*
*      DATA parent_view_list TYPE tt_temp_parent_views.
*
*      LOOP AT level_parent_view_list
*        ASSIGNING FIELD-SYMBOL(<level_parent_view>).
*
*        READ TABLE parent_view_list
*          WITH KEY ParentAbapViewName = <level_parent_view>-ParentAbapViewName
*          TRANSPORTING NO FIELDS.
*
*        IF sy-subrc <> 0.
*          INSERT <level_parent_view> INTO TABLE parent_view_list.
*
*          APPEND VALUE #(
*            sign = 'I'
*            option = 'EQ'
*            low = <level_parent_view>-ParentAbapViewName )
*            TO child_view_rng.
*        ENDIF.
*
*      ENDLOOP.
*
*      REFRESH level_parent_view_list[].
*
*      IF child_view_rng[] IS INITIAL.
*        EXIT.
*      ENDIF.
*
*    ENDWHILE.
*
*    LOOP AT parent_view_list
*      ASSIGNING FIELD-SYMBOL(<view>).
*
*      APPEND INITIAL LINE TO view_list
*        ASSIGNING FIELD-SYMBOL(<result_view>).
*
*      <result_view>-abapviewtype  = <view>-ParentAbapViewType.
*      <result_view>-ddlsourcename = <view>-ParentDdlSourceName.
*      <result_view>-ddicviewname  = <view>-parentddicviewname.
*
*    ENDLOOP.
*
*    EXIT.
*
*  ENDMETHOD.

  METHOD _get_views_by_source_name2.

    DATA(where_parameters) = _get_where_parameters( ).

    DATA(view_type_rng) = _get_view_type_rng( ).

    "-----------------------------------------------------------------------------------
    "SELECT
    "-----------------------------------------------------------------------------------
    TRY.

        SELECT
           AbapView~AbapViewType,
           AbapView~AbapViewName,

           AbapView~ddlsourcename,
           \_cdsview-datacategory,
           \_cdsview-embeddedanalyticsqueryind,

           AbapView~DdicViewName,

            \_cdsview\_status-c1_releasestate,
            \_cdsview\_status-c1_useinkeyuserapps,
            \_cdsview\_status-c1_useincloudplatform,

            \_cdsview\_status-c2_releasestate,

            \_CdsView-EndUserTextLabel,
            \_CdsView-vdmviewtype,
            \_CdsView-accesscontrolauthcheck,
            \_CdsView-objectmodelusagetypedataclass,
            \_CdsView-vdmlifecyclecontracttype,
            \_CdsView-objectmodelcreateenabled,
            \_CdsView-odatapublish,
            \_CdsView-rappublish,

            \_CdsView-MetadataAllowExtensions,
            \_CdsView-SearchSearchable,
            \_CdsView-VdmUsageType1,
            \_CdsView-ObjectModelSemanticKey1,

            \_cdsview-CreateUser AS Create_User_Name,
            \_cdsview-CreateDate AS Create_Date

            FROM
              ZSCV_AbapViewByView(
                  p_AbapViewName                 = @db_table_name
                ) AS AbapView

            WHERE
              AbapView~AbapViewType    IN @view_type_rng[] AND
              AbapView~AbapViewName    IN @s_abapvw[] AND
              AbapView~DdicViewName    IN @s_ddicvw[] AND
              \_cdsview-ddlsourcename  IN @s_ddlnm
              AND
              (where_parameters-where_text)

              AND
              \_cdsview-VdmViewType     IN @s_viewtp[] AND
              \_cdsview-ODataPublish    IN @s_odata[] AND
              \_cdsview-RapPublish      IN @s_rapodt[] AND
              \_cdsview-datacategory    IN @s_datcat[]

          ORDER BY
            \_cdsview-ddlsourcename,
            AbapView~ddicviewname

          INTO CORRESPONDING FIELDS OF TABLE @view_list.

      CATCH cx_sy_open_sql_db INTO DATA(sy_open_sql_db_exc).

        RAISE EXCEPTION TYPE zcx_generic_exc
          EXPORTING
            text = sy_open_sql_db_exc->get_text( ).

    ENDTRY.

  ENDMETHOD.

  METHOD _get_where_parameters.

    IF p_c1kapp = 'X'.
      where_parameters-c1_useinkeyuserapps_rng = VALUE ty_useinkeyuserapps_rng(
        ( sign = 'I' option = 'EQ' low = 'X' )  ).
    ENDIF.

    IF p_c1abap  = 'X'.

      where_parameters-c1_useincloudplatforms_rng = VALUE ty_useincloudplatforms_rng(
        ( sign = 'I' option = 'EQ' low = 'X' )  ).
    ENDIF.

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

    SORT temp_filtered_views BY AbapViewName.

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

CLASS zscv_main_ctl DEFINITION.

  PUBLIC SECTION.

    "-----------------------------------------------------
    "Methods
    "-----------------------------------------------------
    METHODS initialization.

    METHODS at_selection_screen.

    METHODS start_of_selection.

  PRIVATE SECTION.

    DATA view_list TYPE zscv_view_search_dp=>tt_ddic_view_list.
    DATA field_catalog  TYPE slis_t_fieldcat_alv.

    METHODS _show_data.

    METHODS _add_field_to_catalogue
      IMPORTING column   TYPE c
                field    TYPE c
                table    TYPE c
                length   TYPE c
                text     TYPE c
                hot      TYPE c
                checkbox TYPE c.

    METHODS _create_field_catalogue.

ENDCLASS.


CLASS zscv_main_ctl IMPLEMENTATION.

  METHOD initialization.
  ENDMETHOD.

  METHOD at_selection_screen.

    CASE sy-ucomm.

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
        s_c1stat[] = VALUE #(
          ( sign = 'I' option = 'EQ' low = 'RELEASED' ) ).
        CLEAR p_c1kapp.
        p_c1abap = 'X'.
        s_c2stat[] = VALUE #(
          ( sign = 'I' option = 'EQ' low = 'RELEASED' ) ).

      WHEN 'Q_ABAP'.
        s_c1stat[] = VALUE #(
          ( sign = 'I' option = 'EQ' low = 'RELEASED' ) ).
        CLEAR p_c1kapp.
        p_c1abap = 'X'.
        REFRESH s_c2stat[].

      WHEN 'Q_API'.
        REFRESH s_c1stat.
        CLEAR p_c1kapp.
        CLEAR p_c1abap.
        s_c2stat[] = VALUE #(
          ( sign = 'I' option = 'EQ' low = 'RELEASED' ) ).

      WHEN 'Q_STALL'.
        REFRESH s_c1stat.
        CLEAR p_c1kapp.
        CLEAR p_c1abap.
        REFRESH s_c2stat.

      WHEN 'DBALL'.
        REFRESH s_dbtab[].

      WHEN 'DBSUCC'.

        IF s_dbtab[] IS INITIAL.
          "DB tables/views field is empty.
          MESSAGE TEXT-200 TYPE 'I'.
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

      WHEN 'DC_DIM'.
        s_datcat[] = VALUE #(
          ( sign = 'I' option = 'EQ' low = '#DIMENSION' ) ).

      WHEN 'DC_ALL'.
        REFRESH s_datcat[].

      WHEN OTHERS.

    ENDCASE.

  ENDMETHOD.

  METHOD start_of_selection.

    TRY.

        CASE sy-ucomm.

          WHEN 'COMPDB'.

          WHEN OTHERS.

            IF s_dbtab[] IS NOT INITIAL.

              DATA(view_search_dp) = NEW zscv_view_search_dp( ).
              view_list = view_search_dp->get_views_by_source_names(  ).


*            ELSEIF
*              s_fldnm[] IS NOT INITIAL OR
*              s_dtelnm[] IS NOT INITIAL OR
*              s_domnm[] IS NOT INITIAL.
*
*              view_search_dp = NEW zscv_view_search_dp( ).
*              view_list = view_search_dp->get_views_by_field_names(  ).

            ELSE.

              MESSAGE |Table/Views or Field has to be filled.| TYPE 'I' DISPLAY LIKE 'E' .
              RETURN.

            ENDIF.

            _show_data( ).

        ENDCASE.

      CATCH zcx_generic_exc INTO DATA(generic_exc).

        DATA(error_message_text) = generic_exc->get_text( ).

        MESSAGE error_message_text TYPE 'I' DISPLAY LIKE 'E' .

    ENDTRY.

  ENDMETHOD.


  METHOD _show_data.

    _create_field_catalogue( ).

    DATA layout      TYPE slis_layout_alv.

    MESSAGE |View count: { lines( view_list ) }| TYPE 'S'.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        "i_callback_user_command = 'USER_COMMAND'
        it_fieldcat        = field_catalog[]
        is_layout          = layout
      TABLES
        t_outtab           = view_list
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.

  ENDMETHOD.

  METHOD _add_field_to_catalogue.

    DATA: catalog_field TYPE slis_fieldcat_alv.

    CLEAR: catalog_field.

    catalog_field-col_pos       = column.
    catalog_field-fieldname     = field.
    catalog_field-tabname       = table.
    catalog_field-outputlen     = length.
    catalog_field-seltext_l     = text.
    catalog_field-emphasize     = hot.
    catalog_field-checkbox      = checkbox.

    APPEND catalog_field TO field_catalog.

  ENDMETHOD.


  METHOD _create_field_catalogue.

    _add_field_to_catalogue( column = '01' field = 'ABAPVIEWTYPE'           table = 'VIEW_LIST' length = '10' text = 'View Type'              hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '07' field = 'DDICVIEWNAME'           table = 'VIEW_LIST' length = '20' text = 'DDic Name'              hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '05' field = 'DDLSOURCENAME'          table = 'VIEW_LIST' length = '30' text = 'DDL Source Name'        hot = 'X' checkbox = ' ' ).

    _add_field_to_catalogue( column = '30' field = 'C1_RELEASESTATE'        table = 'VIEW_LIST' length = '10' text = 'C1 Release State'           hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '32' field = 'C1_UseInKeyUserApps'    table = 'VIEW_LIST' length = '10' text =  'C1 Use In Key User Apps'   hot = 'X' checkbox = 'X' ).
    _add_field_to_catalogue( column = '34' field = 'C1_USEINCLOUDPLATFORM'  table = 'VIEW_LIST' length = '12' text = 'C1 Use In Cloud platform'   hot = 'X' checkbox = 'X' ).
    _add_field_to_catalogue( column = '40' field = 'C2_RELEASESTATE'        table = 'VIEW_LIST' length = '10' text = 'C2 Release State'           hot = 'X' checkbox = ' ' ).

    _add_field_to_catalogue( column = '50' field = 'ENDUSERTEXTLABEL'               table = 'VIEW_LIST' length = '30' text = 'End User Text Label'  hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '50' field = 'DATACATEGORY'                   table = 'VIEW_LIST' length = '15' text = 'CDS Data Category'    hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '50' field = 'VDMVIEWTYPE'                    table = 'VIEW_LIST' length = '15' text = 'VDM View Type'        hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '50' field = 'ACCESSCONTROLAUTHCHECK'         table = 'VIEW_LIST' length = '10' text = 'Auth. check'          hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '50' field = 'OBJECTMODELUSAGETYPEDATACLASS'  table = 'VIEW_LIST' length = '15' text = 'Data Class'           hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '50' field = 'VDMLIFECYCLECONTRACTTYPE'       table = 'VIEW_LIST' length = '15' text = 'Contract Type'        hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '50' field = 'OBJECTMODELCREATEENABLED'       table = 'VIEW_LIST' length = '10' text = 'Object Model Create Enabled' hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '50' field = 'ODATAPUBLISH'                   table = 'VIEW_LIST' length = '10' text = 'OData Publish'        hot = 'X' checkbox = 'X' ).
    _add_field_to_catalogue( column = '50' field = 'RAPPUBLISH'                     table = 'VIEW_LIST' length = '10' text = 'RAP Serv.def.'        hot = 'X' checkbox = 'X' ).


    _add_field_to_catalogue( column = '50' field = 'MetadataAllowExtensions'        table = 'VIEW_LIST' length = '10' text = '@Metadata.allowExtensions'  hot = 'X' checkbox = 'X' ).
    _add_field_to_catalogue( column = '50' field = 'SearchSearchable'               table = 'VIEW_LIST' length = '10' text = '@Search.searchable.'        hot = 'X' checkbox = 'X' ).
    _add_field_to_catalogue( column = '50' field = 'VdmUsageType1'                  table = 'VIEW_LIST' length = '10' text = '@VDM.usage.type 1'          hot = 'X' checkbox = '' ).
    _add_field_to_catalogue( column = '50' field = 'ObjectModelSemanticKey1'        table = 'VIEW_LIST' length = '10' text = '@ObjectModel.semanticKey 1' hot = 'X' checkbox = '' ).


    _add_field_to_catalogue( column = '70' field = 'CREATE_USER_NAME'               table = 'VIEW_LIST' length = '12' text = 'Last Changed User'    hot = 'X' checkbox = ' ' ).
    _add_field_to_catalogue( column = '72' field = 'CREATE_DATE'                    table = 'VIEW_LIST' length = '12' text = 'Last Changed Date'    hot = 'X' checkbox = ' ' ).

  ENDMETHOD.

ENDCLASS.

"------------------------------------------------
"Application
"------------------------------------------------
DATA main_controller TYPE REF TO zscv_main_ctl.

LOAD-OF-PROGRAM.

  main_controller = NEW #( ).

INITIALIZATION.

  main_controller->initialization( ).

AT SELECTION-SCREEN.

  main_controller->at_selection_screen( ).

START-OF-SELECTION.

  main_controller->start_of_selection( ).
