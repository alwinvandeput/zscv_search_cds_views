@EndUserText.label: 'DDic view related child DDic view'
@AbapCatalog.sqlViewName: 'ZSCVCHILDDDVW'

@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED

define view ZSCV_DdicViewChildDdicView
  as select from    dd26s         as DdicViewRelation

    inner join tadir         as _ParentRepositoryObject on _ParentRepositoryObject.obj_name = DdicViewRelation.viewname                            
                                                            and
                                                            //Filter out:
                                                            //- enqueue objects (ENQU)
                                                            //- DDLS objects
                                                            (
                                                              _ParentRepositoryObject.object    = 'TABL'
                                                              or _ParentRepositoryObject.object = 'VIEW'
                                                              //or _ParentRepositoryObject.object = 'STOB'
                                                            )

    left outer join tadir         as _ChildRepositoryObject on _ChildRepositoryObject.obj_name = DdicViewRelation.tabname
                                                            and(
                                                              _ChildRepositoryObject.object    = 'TABL'
                                                              or _ChildRepositoryObject.object = 'VIEW'
                                                              or _ChildRepositoryObject.object = 'STOB'
                                                            )

    left outer join ddldependency as _ParentDdlDependency   on  _ParentDdlDependency.objectname = DdicViewRelation.viewname
                                                            and _ParentDdlDependency.objecttype = 'VIEW'

    left outer join ddldependency as _ChildDdlDependency    on  _ChildDdlDependency.objectname = DdicViewRelation.tabname
                                                            and _ChildDdlDependency.objecttype = 'VIEW'
{
  key      $session.client              as mandt,

  key      case
             when _ParentDdlDependency.ddlname is null then 'DDic'
             else 'DDic CDS' 
           end        as ParentViewType, //Parent
  key      DdicViewRelation.viewname    as ParentViewName,

  key      case
             when _ChildDdlDependency.ddlname is not null then 'DDic CDS'
             when _ChildRepositoryObject.object = 'TABL'  then 'DDic'
             when _ChildRepositoryObject.object = 'VIEW' then 'DDic'
             when _ChildRepositoryObject.object = 'STOB' then 'CDS DD'
             else 'Unknown'
           end                          as ChildViewType,
  key      DdicViewRelation.tabname     as ChildViewName,
           DdicViewRelation.as4local,
           DdicViewRelation.as4vers,

           _ParentDdlDependency.ddlname as ParentDllResourceName,
           _ChildRepositoryObject.object
}
where
      DdicViewRelation.as4local =  'A'
  and DdicViewRelation.as4vers  is initial
  and DdicViewRelation.viewname <> DdicViewRelation.tabname
