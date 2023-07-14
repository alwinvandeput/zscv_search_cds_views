@EndUserText.label: 'DDic view related child DDic view'
@AbapCatalog.sqlViewName: 'ZSCVCHILDDDVW'

@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED

define view ZSCV_DdicViewChildDdicView
  as select from    dd26s         as DdicViewRelation

    left outer join ddldependency as _ParentDdlDependency on  _ParentDdlDependency.objectname = DdicViewRelation.viewname
                                                          and _ParentDdlDependency.objecttype = 'VIEW'

    left outer join ddldependency as _ChildDdlDependency  on  _ChildDdlDependency.objectname = DdicViewRelation.tabname
                                                          and _ChildDdlDependency.objecttype = 'VIEW'
{
  key DdicViewRelation.viewname    as ParentViewName,
  key DdicViewRelation.tabname     as ChildViewName,
      DdicViewRelation.as4local,
      DdicViewRelation.as4vers,

      case
        when _ParentDdlDependency.ddlname is null then 'DDic View'
        else 'DDic CDS' end        as ViewType, //Parent

      _ParentDdlDependency.ddlname as ParentDllResourceName,

      case
        when _ChildDdlDependency.ddlname is null then 'DDic View'
        else 'DDic CDS' end        as ChildViewType
}
where
      DdicViewRelation.as4local =  'A'
  and DdicViewRelation.as4vers  is initial
  and DdicViewRelation.viewname <> DdicViewRelation.tabname
