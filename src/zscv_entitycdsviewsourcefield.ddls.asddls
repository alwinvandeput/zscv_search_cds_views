@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Entity CDS Source Field'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZSCV_EntityCdsViewSourceField
  as

  select from ZSCV_CdsViewSourceField
{
  key DdlSourceName,
  key ViewName,
  key Field
}
where AbapViewType = 'Entity CDS'
