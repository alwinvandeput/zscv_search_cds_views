@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAP View by View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZSCV_AbapViewByView
  with parameters
    p_AbapViewName                 :vibastab,
    p_DdicCdsBasedOnDllResourceInd :abap_boolean

  as select from ZSCV_AbapViewByViewGroupBy(
                 p_AbapViewName                  : $parameters.p_AbapViewName,
                 p_DdicCdsBasedOnDllResourceInd  : $parameters.p_DdicCdsBasedOnDllResourceInd
                 ) as AbapViewHier

  association [0..1] to ZSCV_CdsView as _CdsView         on  _CdsView.DdlSourceName = AbapViewHier.DdlSourceName

  association [0..1] to dd25l        as _DevObjectHeader on  _DevObjectHeader.viewname = AbapViewHier.AbapViewName
                                                         and _DevObjectHeader.as4local = 'A'
                                                         and _DevObjectHeader.as4vers  = '0000'
{
  key AbapViewName  as AbapViewName,
      AbapViewType  as AbapViewType,
      DdlSourceName as DdlSourceName,
      DdicViewName  as DdicViewName,

      /* Associations */
      _CdsView,
      _DevObjectHeader
}
