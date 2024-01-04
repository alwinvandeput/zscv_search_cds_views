@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAP View Parent'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZSCV_CdsView_RootChild_Recur

  as

  select from zscv_cds_rel
  association [1..*] to ZSCV_CdsView_RootChild_Recur as _Child on $projection.ParentAbapViewName = _Child.ChildAbapViewName
{
  key parent_name as ParentAbapViewName,
  key child_name  as ChildAbapViewName,

      /* Associations */
      _Child
}
//  where ParentViewName like '%ZZAP%MARC%'
