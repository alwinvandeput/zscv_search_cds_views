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
        
      @EndUserText.label: 'DDL Type'
      AbapView._CdsRelation.parent_ddl_type as ParentDdlType,
      
      @EndUserText.label: 'ABAP View Type'
      AbapView.AbapViewType,
      
      @EndUserText.label: 'VDM View Type'
      AbapView._CdsView.VdmViewType,
      
      @EndUserText.label: 'Data Category'
      AbapView._CdsView.DataCategory,

      @EndUserText.label: 'Exists in this system'
      BasicView.ExistsInd,

      @EndUserText.label: 'C1 Release State'
      BasicView.C1_ReleaseState,

      @EndUserText.label: 'C1 Key User App'
      AbapView._CdsView._Status.C1_UseInKeyUserApps,

      @EndUserText.label: 'C1 ABAP Cloud'
      BasicView.C1_UseInCloudPlatform,

      @EndUserText.label: 'C2 Release State'
      AbapView._CdsView._Status.C2_ReleaseState,

      @EndUserText.label: 'View OData'
      AbapView._CdsView.ODataPublish,

      @EndUserText.label: 'Main RAP'
      AbapView._CdsView.RapPublish,

      @EndUserText.label: 'Secondairy RAP'
      AbapView._CdsView.ChildRapViewInd,

      @EndUserText.label: 'Analyticds Query'
      AbapView._CdsView.EmbeddedAnalyticsQueryInd,
      
      AbapView._CdsView.CreateDate,
      AbapView._CdsView.CreateUser,

      @EndUserText.label: 'Auth. Check'
      AbapView._CdsView.AccessControlAuthCheck,

      @EndUserText.label: 'Data Class'
      AbapView._CdsView.ObjectModelUsageTypeDataClass,

      @EndUserText.label: 'Contract Type'
      AbapView._CdsView.VdmLifeCycleContractType,
      
      @EndUserText.label: 'Relation Level'
      _BasicView.relation_level as RelationLevel

}
where BasicView.CdsName is not initial
