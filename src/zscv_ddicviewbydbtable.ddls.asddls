@EndUserText.label: 'DDic View by DB Table'
@AbapCatalog.sqlViewName: 'ZSCV_DDVW_DBTAB'

@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED

define view ZSCV_DdicViewByDbTable
  with parameters
    p_DbTableName :vibastab

  as select from ZSCV_DdicViewHier(p_DbTableName: $parameters.p_DbTableName) as DdicViewHier
  association [0..1] to ZSCV_CdsView as _CdsView         on  _CdsView.DdicViewName = DdicViewHier.ParentViewName
  association [0..1] to dd25l        as _DevObjectHeader on  _DevObjectHeader.viewname  = DdicViewHier.ParentViewName
                                                         and _DevObjectHeader.as4local = 'A'
                                                         and _DevObjectHeader.as4vers  = '0000'
{
  ParentViewName as DdicViewName,
  ChildViewName  as ChildDdicViewName,

  HierarchyLevel,
  IsOrphan,
  TreeSize,
  IsCycle,
  NodeId,

  _CdsView,
  _DevObjectHeader
}
/* Unit test
  p_DbTableName = MARC

  FIELDS
    \_CdsView-DdlSourceName,
    \_CdsView-DataCategory,
    \_CdsView-EmbeddedAnalyticsQueryInd,

    \_CdsView\_Status-C1_ReleaseState,
    \_CdsView\_Status-C2_ReleaseState

  WHERE
    \_CdsView\_Status-C1_ReleaseState = 'RELEASED' and
    \_CdsView-datacategory <> '#CUBE' and
    \_CdsView-datacategory <> '#FACT'

  ORDER BY
    \_CdsView-DdlSourceName
*/
