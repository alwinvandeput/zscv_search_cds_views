@EndUserText.label: 'CDS View'
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}

define view entity ZSCV_CdsViewRelation
  as select from zscv_cds_rel as CdsRelation
{
  key parent_type as ParentType,
  key parent_name as ParentDdlSourceName,
  key child_type  as ChildType,
  key child_name  as ChildAbapViewName
}
