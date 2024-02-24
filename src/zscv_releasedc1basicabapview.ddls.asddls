@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Released C1 Basic ABAP View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZSCV_ReleasedC1BasicAbapView
  as

  select

  from              ZSCV_ReleasedC1Basic_Union2 as BasicView
    left outer join ZSCV_AbapView              as AbapView   on AbapView.AbapViewName = BasicView.CdsName

    left outer join zscv_basic_view            as _BasicView on  _BasicView.cds_view_name = BasicView.CdsName
                                                             and _BasicView.table_name    = BasicView.DbTableName

{
      @EndUserText.label: 'Basic CDS View'
  key BasicView.CdsName         as AbapViewName,
  
      @EndUserText.label: 'Main DB Table'
  key BasicView.DbTableName     as DbTableName,
        
      @EndUserText.label: 'Text'
      AbapView._CdsView.EndUserTextLabel,
        
      @EndUserText.label: 'Parent DDL Type'
      AbapView._CdsRelation.parent_ddl_type as ParentDdlType,
      
      @EndUserText.label: 'ABAP View Type'
      AbapView.AbapViewType,
      
      //VDM
      @EndUserText.label: 'View Type (VDM)'
      AbapView._CdsView.VdmViewType,
      
      @EndUserText.label: 'Contract Type (VDM)'
      AbapView._CdsView.VdmLifeCycleContractType,
      
      //Exists
      @EndUserText.label: 'Exists in this system'
      BasicView.ExistsInd,
      
      //API
      @EndUserText.label: 'C1 Release State'
      BasicView.C1_ReleaseState,

      @EndUserText.label: 'C1 Key User App'
      AbapView._CdsView._Status.C1_UseInKeyUserApps,

      @EndUserText.label: 'C1 ABAP Cloud'
      BasicView.C1_UseInCloudPlatform,

      @EndUserText.label: 'C2 Release State'
      AbapView._CdsView._Status.C2_ReleaseState,

      //Object Model
      @EndUserText.label: 'Data Category (Object Model)'
      AbapView._CdsView.ObjectModelDataCategory,
      
      @EndUserText.label: 'Data Class (Object Model)'
      AbapView._CdsView.ObjectModelUsageTypeDataClass,
      
      @EndUserText.label: 'Create Enabled (Object Model)'
      AbapView._CdsView.ObjectModelCreateEnabled,
      
      //Analytics
      @EndUserText.label: 'Query (Analytics)'
      AbapView._CdsView.AnalyticsQueryInd,
      
      @EndUserText.label: 'Data Category (Analytics)'
      AbapView._CdsView.AnalyticsDataCategory,
      
      //OData / RAP
      @EndUserText.label: 'View OData'
      AbapView._CdsView.ODataPublish,

      @EndUserText.label: 'Main RAP'
      AbapView._CdsView.RapPublish,
            
      @EndUserText.label: 'Secondairy RAP'
      AbapView._CdsView.ChildRapViewInd,
      
      //Maintenance
      @EndUserText.label: 'Create Date'
      AbapView._CdsView.CreateDate,
      
      @EndUserText.label: 'Create User'
      AbapView._CdsView.CreateUser,

      @EndUserText.label: 'Auth. Check'
      AbapView._CdsView.AccessControlAuthCheck,
      
      @EndUserText.label: 'Metadata Extensions Allowed'
      AbapView._CdsView.MetadataAllowExtensions,

      @EndUserText.label: 'DDic name'
      AbapView._CdsView.DdicViewName
}
where BasicView.CdsName is not initial
