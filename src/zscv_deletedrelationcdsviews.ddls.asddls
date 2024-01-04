@AbapCatalog.sqlViewName: 'ZSCVDELCDSVW'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DeleteRelationCdsViews'
define view ZSCV_DeletedRelationCdsViews as 

select from zscv_cds_rel as _Relation
  left outer join ZSCV_CdsView as _CdsView on _CdsView.DdlSourceName = _Relation.parent_name
{
  key _Relation.parent_type as ParentType,
  key _Relation.parent_name as ParentName,
  key _Relation.child_type as ChildType,
  key _Relation.child_name as ChildName,
  _CdsView.DdlSourceName
}
where  _CdsView.DdlSourceName is null
