@AbapCatalog.sqlViewName: 'ZSCVCHILDRAPVW'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Child RAP CDS View'
define view ZSCV_ChildRapCdsView
  as

  select from       d010behv
    left outer join tadir as _MainRapBehaviorDef on  _MainRapBehaviorDef.object   = 'BDEF'
                                                 and _MainRapBehaviorDef.pgmid    = 'R3TR'
                                                 and _MainRapBehaviorDef.obj_name = d010behv.entity
{
  key entity
}
where _MainRapBehaviorDef.obj_name is null
group by
  entity
