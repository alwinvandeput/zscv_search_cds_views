@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View Root View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZSCV_CdsView_RootChild 
  with parameters
    p_AbapViewName :vibastab
as 
  select from ZSCV_CdsView_RootChild_Hier( p_AbapViewName: $parameters.p_AbapViewName )
{
    key AbapViewName,
    key ChildAbapViewName
}
where TreeSize = 1
