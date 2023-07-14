@AbapCatalog.sqlViewName: 'ZSCV_ABAPVW2'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAP View'
define view ZSCV_AbapView
  as

  select from ZSCV_AbapViewUnion as AbapView
  association [0..1] to ZSCV_CdsView as _CdsView         on  _CdsView.DdlSourceName = AbapView.AbapViewName

  association [0..1] to dd25l        as _DevObjectHeader on  _DevObjectHeader.viewname = AbapView.AbapViewName
                                                         and _DevObjectHeader.as4local = 'A'
                                                         and _DevObjectHeader.as4vers  = '0000'
{
  key AbapViewName,
      AbapViewType,
      
      DdicViewName, //Todo: rename to DdicName
      DdlSourceName,
     

      /* Associations */
      _CdsView,
      _DevObjectHeader
}
