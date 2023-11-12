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
    p_AbapViewName :vibastab

  as select from ZSCV_AbapViewByViewGroupBy(
                 p_AbapViewName                  : $parameters.p_AbapViewName ) as AbapViewHier

  association [1..1] to ZSCV_AbapView as _AbapView        on  _AbapView.AbapViewName = $projection.AbapViewName

  association [0..1] to ZSCV_CdsView  as _CdsView         on  _CdsView.DdlSourceName = $projection.AbapViewName

  association [0..1] to dd25l         as _DevObjectHeader on  _DevObjectHeader.viewname = AbapViewHier.AbapViewName
                                                          and _DevObjectHeader.as4local = 'A'
                                                          and _DevObjectHeader.as4vers  = '0000'
{
  key AbapViewHier.AbapViewType as AbapViewType,
  key AbapViewHier.AbapViewName as AbapViewName,

      _AbapView.BasicTableCdsViewInd,
      _AbapView.RelationLevel,

      _AbapView.AbapViewName    as AbapViewName_Test,
      _AbapView.DdlSourceName   as DdlSourceName,
      _AbapView.DdicViewName    as DdicViewName,

      /* Associations */
      _AbapView,
      _CdsView,
      _DevObjectHeader
}
