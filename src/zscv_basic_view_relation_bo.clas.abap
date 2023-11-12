CLASS zscv_basic_view_relation_bo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF gcs__relation_level,
        super TYPE zscv_relation_level VALUE 'SUPER',
        sub   TYPE zscv_relation_level VALUE 'SUB',
      END OF gcs__relation_level.

    CLASS-METHODS fill_db_table_initially.

    CLASS-METHODS create_relation
      IMPORTING iv_db_table_name    TYPE zscv_basic_view-table_name
                iv_cds_view_name    TYPE zscv_basic_view-cds_view_name
                iv_relation_level   TYPE zscv_relation_level
                iv_show_message_ind TYPE abap_bool
      RETURNING VALUE(rr_relation)  TYPE REF TO zscv_basic_view_relation_bo.

    CLASS-METHODS get_instance_by_table_name
      IMPORTING iv_db_table_name   TYPE zscv_basic_view-table_name
                iv_cds_view_name   TYPE zscv_basic_view-cds_view_name
      RETURNING VALUE(rr_relation) TYPE REF TO zscv_basic_view_relation_bo.

    METHODS update_sap_release.

    METHODS update_relation_level
      IMPORTING iv_relation_level TYPE zscv_relation_level.

    METHODS delete_relation.

  PROTECTED SECTION.

  PRIVATE SECTION.

    TYPES gtt_basic_view TYPE STANDARD TABLE OF zscv_basic_view WITH EMPTY KEY.

    DATA gs_basic_data TYPE zscv_basic_view.

    CLASS-METHODS get_default_basic_views
      RETURNING VALUE(rt_basic_view) TYPE gtt_basic_view.

ENDCLASS.

CLASS zscv_basic_view_relation_bo IMPLEMENTATION.

  METHOD get_default_basic_views.

    rt_basic_view =
        VALUE #(
            ( client = '401' table_name = 'REGUV' cds_view_name = 'I_PAYMENTPROGRAMCONTROL' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'IKPF' cds_view_name = 'I_PHYSINVTRYDOCHEADER' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'ISEG' cds_view_name = 'I_PHYSINVTRYDOCITEM' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'T001L' cds_view_name = 'I_STORAGELOCATION' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'MARA' cds_view_name = 'I_PRODUCT' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'LIKP' cds_view_name = 'I_DELIVERYDOCUMENT' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'LIKP' cds_view_name = 'I_INBOUNDDELIVERY' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'LIKP' cds_view_name = 'I_OUTBOUNDDELIVERY' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'LIKP' cds_view_name = 'I_CUSTOMERRETURNDELIVERY' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'LIPS' cds_view_name = 'I_DELIVERYDOCUMENTITEM' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'LIPS' cds_view_name = 'I_CUSTOMERRETURNDELIVERYITEM' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'LIPS' cds_view_name = 'I_INBOUNDDELIVERYITEM' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'LIPS' cds_view_name = 'I_OUTBOUNDDELIVERYITEM' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'KNA1' cds_view_name = 'I_CUSTOMER' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'KNB1' cds_view_name = 'I_CUSTOMERCOMPANY' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'KNVK' cds_view_name = 'I_CONTACTPERSON' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'KNVP' cds_view_name = 'I_CUSTSALESPARTNERFUNC' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'KNVV' cds_view_name = 'I_CUSTOMERSALESAREA' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'LFA1' cds_view_name = 'I_SUPPLIER' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'LFB1' cds_view_name = 'I_SUPPLIERCOMPANY' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'LFM1' cds_view_name = 'I_SUPPLIERPURCHASINGORG' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'TVST' cds_view_name = 'I_SHIPPINGPOINT' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'BKPF' cds_view_name = 'I_JOURNALENTRY' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'BSEG' cds_view_name = 'I_OPERATIONALACCTGDOCITEM' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'ACDOCA' cds_view_name = 'I_JOURNALENTRYITEM' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'ACDOCA' cds_view_name = 'I_GLACCOUNTLINEITEM' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'ACDOCA' cds_view_name = 'I_GLACCOUNTLINEITEMRAWDATA' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'SKA1' cds_view_name = 'I_GLACCOUNT' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'SKB1' cds_view_name = 'I_GLACCOUNTINCOMPANYCODE' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'SKA1' cds_view_name = 'I_GLACCOUNTINCHARTOFACCOUNTS' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'T001' cds_view_name = 'I_COMPANYCODE' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'T003' cds_view_name = 'I_ACCOUNTINGDOCUMENTTYPE' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'CEPC' cds_view_name = 'I_PROFITCENTER' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'MARA' cds_view_name = 'I_PRODUCTQM' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'MARA' cds_view_name = 'I_PRODUCTSALES' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'MARD' cds_view_name = 'I_PRODUCTSTORAGELOCATIONBASIC' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'MARM' cds_view_name = 'I_PRODUCTUNITSOFMEASURE' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'AFPO' cds_view_name = 'I_MANUFACTURINGORDERITEM' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'AFPO' cds_view_name = 'I_RPTVMFGPRODCOSTCTRLGORDITEM' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'AFRU' cds_view_name = 'I_MFGORDERCONFIRMATION' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'AFVC' cds_view_name = 'I_MANUFACTURINGORDEROPERATION' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'MKAL' cds_view_name = 'I_PRODUCTIONVERSION' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'PLKO' cds_view_name = 'I_BILLOFOPERATIONSGROUP' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'PLPO' cds_view_name = 'I_MFGBILLOFOPERATIONSOPERATION' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'T001W' cds_view_name = 'I_PLANT' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'VBAK' cds_view_name = 'I_SALESORDER' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBAK' cds_view_name = 'I_SALESCONTRACT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBAK' cds_view_name = 'I_SALESDOCUMENT' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'VBAK' cds_view_name = 'I_CREDITMEMOREQUEST' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBAK' cds_view_name = 'I_CUSTOMERRETURN' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBAK' cds_view_name = 'I_DEBITMEMOREQUEST' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBAK' cds_view_name = 'I_SALESINQUIRY' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBAK' cds_view_name = 'I_SALESORDERWITHOUTCHARGE' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBAK' cds_view_name = 'I_SALESQUOTATION' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBAK' cds_view_name = 'I_SALESSCHEDGAGRMT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBAP' cds_view_name = 'I_SALESDOCUMENTITEM' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'VBAP' cds_view_name = 'I_SALESORDERITEM' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBAP' cds_view_name = 'I_SALESINQUIRYITEM' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBAP' cds_view_name = 'I_CREDITMEMOREQUESTITEM' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBAP' cds_view_name = 'I_CUSTOMERRETURNITEM' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBAP' cds_view_name = 'I_DEBITMEMOREQUESTITEM' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBAP' cds_view_name = 'I_SALESCONTRACTITEM' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBAP' cds_view_name = 'I_SALESORDERWITHOUTCHARGEITEM' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBAP' cds_view_name = 'I_SALESQUOTATIONITEM' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBAP' cds_view_name = 'I_SALESSCHEDGAGRMTITEM' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBEP' cds_view_name = 'I_SALESDOCUMENTSCHEDULELINE' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'VBEP' cds_view_name = 'I_SALESSCHEDGAGRMTSCHEDLINE' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBEP' cds_view_name = 'I_SLSORDWTHOUTCHRGSCHEDLINE' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBFA' cds_view_name = 'I_SDDOCUMENTMULTILEVELPROCFLOW' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'VBRK' cds_view_name = 'I_BILLINGDOCUMENTBASIC' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'VBRK' cds_view_name = 'I_BILLINGDOCUMENT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBRK' cds_view_name = 'I_BILLINGDOCUMENTREQUEST' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBRK' cds_view_name = 'I_PRELIMBILLINGDOCUMENT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBRP' cds_view_name = 'I_BILLINGDOCUMENTITEMBASIC' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'VBRP' cds_view_name = 'I_BILLINGDOCUMENTITEM' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBRP' cds_view_name = 'I_BILLINGDOCUMENTREQUESTITEM' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'VBRP' cds_view_name = 'I_PRELIMBILLINGDOCUMENTITEM' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'TVGRT' cds_view_name = 'I_SALESGROUPTEXT' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'TVKBT' cds_view_name = 'I_SALESOFFICETEXT' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'TVKBZ' cds_view_name = 'I_SALESAREASALESOFFICE' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'TVKGR' cds_view_name = 'I_SALESGROUP' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'TVKO' cds_view_name = 'I_SALESORGANIZATION' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'TVTA' cds_view_name = 'I_SALESAREA' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'TVTW' cds_view_name = 'I_DISTRIBUTIONCHANNEL' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'MARC' cds_view_name = 'I_PRODUCTPLANTBASIC' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'AUSP' cds_view_name = 'I_CLFNOBJECTCHARCVALFORKEYDATE' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'BUT000' cds_view_name = 'I_BUSINESSPARTNER' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'KONH' cds_view_name = 'I_SLSPRCGCONDITIONRECORD' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'KONH' cds_view_name = 'I_PURGPRCGCONDITIONRECORD' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'KONH' cds_view_name = 'I_SLSPRCGCNDNRECDSUPLMNT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'KONH' cds_view_name = 'I_PURGPRCGCNDNRECDSUPLMNT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'KONM' cds_view_name = 'I_SLSPRCGCNDNRECORDSCALE' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'KONM' cds_view_name = 'I_PURGPRCGCNDNRECORDSCALE' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_BILLINGDOCITEMPRCGELMNTBASIC' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_BILLINGDOCPRCGELMNTBASIC' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_BILLINGDOCREQITEMPRCGELMNT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_BILLINGDOCREQPRCGELMNT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_BILLINGDOCUMENTITEMPRCGELMNT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_BILLINGDOCUMENTPRCGELMNT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_CREDITMEMOREQITEMPRCGELMNT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_CREDITMEMOREQPRCGELMNT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_DEBITMEMOREQITEMPRCGELMNT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_DEBITMEMOREQPRCGELMNT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_PRELIMBILLGDOCITEMPRCGELMNT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_PRELIMBILLINGDOCPRCGELMNT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_SALESDOCITEMPRICINGELEMENT' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_SALESDOCUMENTPRICINGELEMENT' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_SALESORDERITEMPRICINGELEMENT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_SALESORDERPRICINGELEMENT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_SALESQUOTATIONITEMPRCGELMNT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_SALESQUOTATIONPRCGELMNT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'PRCD_ELEMENTS' cds_view_name = 'I_SLSCONTRITEMPRICINGELEMENT' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'T685' cds_view_name = 'I_CONDITIONTYPE' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'T685' cds_view_name = 'I_PRICINGCONDITIONTYPE' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'T685' cds_view_name = 'I_SLSPRICINGCONDITIONTYPE' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'EKKO' cds_view_name = 'I_PURCHASECONTRACTAPI01' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'EKKO' cds_view_name = 'I_CENTRALREQUESTFORQUOTATION' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'EKKO' cds_view_name = 'I_CENTRALSUPPLIERQUOTATION' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'EKKO' cds_view_name = 'I_REQUESTFORQUOTATION_API01' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'EKKO' cds_view_name = 'I_SCHEDGAGRMTHDRAPI01' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'EKKO' cds_view_name = 'I_SUPPLIERQUOTATION_API01' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'EKKO' cds_view_name = 'I_PURORDPRICINGELEMENTAPI01' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'EKKO' cds_view_name = 'I_PURCHASEORDERAPI01' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'EKKO' cds_view_name = 'I_CNTRLSUPPLIERQTANITEMPRICING' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'EKKO' cds_view_name = 'I_PURORDITMPRICINGELEMENTAPI01' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'EKPO' cds_view_name = 'I_PURCHASEORDERITEMAPI01' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'RBKP' cds_view_name = 'I_SUPPLIERINVOICEAPI01' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'RBKP' cds_view_name = 'I_SUPPLIERINVOICETAXAPI01' relation_level = 'SUB' sap_release = '757'  )
            ( client = '401' table_name = 'RSEG' cds_view_name = 'I_SUPLRINVCITEMPURORDREFAPI01' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'EINA' cds_view_name = 'I_PURCHASINGINFORECORDAPI01' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'EINE' cds_view_name = 'I_PURGINFORECDORGPLNTDATAAPI01' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'TFACD' cds_view_name = 'I_FACTORYCALENDAR' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'TFACS' cds_view_name = 'I_FACTORYCALWORKINGDAYSPERYR' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'THOC' cds_view_name = 'I_PUBLHOLIDAYCALHOLIDAYDATE' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'THOCD' cds_view_name = 'I_PUBLICHOLIDAYCALENDARHOLIDAY' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'CDPOS' cds_view_name = 'I_SUPLRINVCCHGDOCITMAPI01' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'TCURR' cds_view_name = 'I_EXCHANGERATERAWDATA' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'T006' cds_view_name = 'I_UNITOFMEASURE' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'T006A' cds_view_name = 'I_UNITOFMEASURETEXT' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'T006B' cds_view_name = 'I_UNITOFMEASURECOMMERCIALNAME' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'T006C' cds_view_name = 'I_UNITOFMEASURETECHNICALNAME' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'T006D' cds_view_name = 'I_UNITOFMEASUREDIMENSION' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'T006I' cds_view_name = 'I_UNITOFMEASUREISOCODE' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'T006J' cds_view_name = 'I_UNITOFMEASUREISOCODETEXT' relation_level = 'SUPER' sap_release = '757'  )
            ( client = '401' table_name = 'T006T' cds_view_name = 'I_UNITOFMEASUREDIMENSIONTEXT' relation_level = 'SUPER' sap_release = '757'  )
        ).

  ENDMETHOD.

  METHOD fill_db_table_initially.

    DATA(lt_basic_views) = get_default_basic_views( ).

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

      zscv_basic_view_relation_bo=>create_relation(
        iv_db_table_name    = <ls_basic_view>-table_name
        iv_cds_view_name    = <ls_basic_view>-cds_view_name
        iv_relation_level   = <ls_basic_view>-relation_level
        iv_show_message_ind = abap_false ).

    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_by_table_name.

    SELECT SINGLE *
      FROM zscv_basic_view
      WHERE table_name    = @iv_db_table_name AND
            cds_view_name = @iv_cds_view_name
      INTO @DATA(ls_basic_table_cds_view).

    IF sy-subrc <> 0.

      RETURN.

    ENDIF.

    rr_relation = NEW #( ).

    rr_relation->gs_basic_data = ls_basic_table_cds_view.

  ENDMETHOD.

  METHOD create_relation.

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

    DATA(lr_relation) = get_instance_by_table_name(
      iv_db_table_name = iv_db_table_name
      iv_cds_view_name = iv_cds_view_name ).

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

    rr_relation->gs_basic_data =
      VALUE zscv_basic_view(
        table_name     = iv_db_table_name
        cds_view_name  = iv_cds_view_name
        relation_level = iv_relation_level
        sap_release    = sy-saprl ).

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

    COMMIT WORK.

  ENDMETHOD.

ENDCLASS.
