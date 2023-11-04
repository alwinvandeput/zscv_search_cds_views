@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAP View by View Group By'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZSCV_AbapViewByViewGroupBy
  with parameters
    p_AbapViewName                 :vibastab

  as select from ZSCV_AbapViewHier(
                 p_AbapViewName                  : $parameters.p_AbapViewName )
{
  key AbapViewType  as AbapViewType,
  key AbapViewName  as AbapViewName
}
group by
  AbapViewType,
  AbapViewName
