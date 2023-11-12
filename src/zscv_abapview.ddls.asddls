@AbapCatalog.sqlViewName: 'ZSCV_ABAPVW2'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAP View'
define view ZSCV_AbapView
  as

  select from ZSCV_AbapViewUnion as AbapView
  association [0..1] to zscv_basic_view as _BasicView    on _BasicView.cds_view_name =   AbapView.AbapViewName
  association [0..1] to ZSCV_CdsView as _CdsView         on  _CdsView.DdlSourceName = AbapView.DdlSourceName

  association [0..1] to dd25l        as _DevObjectHeader on  _DevObjectHeader.viewname = AbapView.AbapViewName
                                                         and _DevObjectHeader.as4local = 'A'
                                                         and _DevObjectHeader.as4vers  = '0000'
{
  key AbapViewName,
      
      _BasicView.table_name as BasicTableName,
      _BasicView.relation_level as RelationLevel,
      case
        when _BasicView.table_name is not null then 'X'
        else ''
        end as BasicTableCdsViewInd,
   
      AbapViewType,
      
      DdicViewName, //Todo: rename to DdicName
      DdlSourceName,
     

      /* Associations */
      _CdsView,
      _DevObjectHeader
}
