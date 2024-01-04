@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Released C1 Basic views Union'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZSCV_ReleasedC1Basic_Union
  as

  select from       zscv_cds_rel as _CdsRelation
    left outer join ZSCV_CdsView as AbapView on AbapView.DdlSourceName = _CdsRelation.parent_name
{
  key AbapView._CdsRelation.main_db_table_name as DbTableName,
  key AbapView.DdlSourceName                   as CdsName,
      AbapView._Status.C1_ReleaseState         as C1_ReleaseState,
      AbapView._Status.C1_UseInCloudPlatform   as C1_UseInCloudPlatform,
      AbapView.VdmViewType                     as VdmViewType,
      'X'                                      as ExistsInd
}
where
     _CdsRelation.parent_ddl_type = 'View'
  or _CdsRelation.parent_ddl_type = 'Union View' 
  or _CdsRelation.parent_ddl_type = 'View Path Source'
//      AbapView._CdsView._Status.C1_ReleaseState       = 'RELEASED'
//  and AbapView._CdsView._Status.C1_UseInCloudPlatform = 'X'
//  and AbapView._CdsView.VdmViewType                   = '#BASIC'

//union all

////Not yet released basic views --> Deze moet weg
//select from  zscv_basic_view as BasicView
//  inner join ZSCV_AbapView   as AbapView on AbapView.AbapViewName = BasicView.cds_view_name
//{
//  key AbapView._CdsRelation.main_db_table_name as DbTableName,
//  key AbapView.AbapViewName                 as CdsName,
//      AbapView._CdsView._Status.C1_ReleaseState,
//      AbapView._CdsView._Status.C1_UseInCloudPlatform,
//      AbapView._CdsView.VdmViewType         as VdmViewType,
//      'X'                                   as ExistsInd,
//      ' '                                   as ReleasedInd
//}
//where
//  (
//       AbapView._CdsView._Status.C1_ReleaseState       <> 'RELEASED'
//    or AbapView._CdsView._Status.C1_UseInCloudPlatform <> 'X'
//  )
//  and  AbapView._CdsView.VdmViewType                   =  '#BASIC'

union all

select from       zscv_basic_view as BasicView
  left outer join ZSCV_AbapView   as AbapView on AbapView.AbapViewName = BasicView.cds_view_name
{
  key BasicView.table_name    as DbTableName,
  key BasicView.cds_view_name as CdsName,
      'X'                     as C1_ReleaseState,
      'X'                     as C1_UseInCloudPlatform,
      '#BASIC'                as VdmViewType,
      ' '                     as ExistsInd
}
where
  AbapView.AbapViewName is null
