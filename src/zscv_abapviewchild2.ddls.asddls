@EndUserText.label: 'ABAP View Child'
@AbapCatalog.sqlViewName: 'ZSCV_ABAP_CHILD'

@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED

define view ZSCV_AbapViewChild2

  as

  select from ZSCV_DdicViewChildDdicView as DdicViewParentChildRelation
{
  key    $session.client                                                     as mandt,
  key    cast( DdicViewParentChildRelation.ParentViewType as abap.char(10) ) as ParentAbapViewType,
  key    DdicViewParentChildRelation.ParentViewName                          as ParentAbapViewName,
  key    cast( DdicViewParentChildRelation.ChildViewType as abap.char(10) )  as ChildAbapViewType,
  key    DdicViewParentChildRelation.ChildViewName                           as ChildAbapViewName,

         DdicViewParentChildRelation.ParentDllResourceName                   as ParentDllResourceName,
         DdicViewParentChildRelation.ParentViewName                          as ParentDdicViewName

         //DdicViewParentChildRelation.ChildViewName                           as ChildDdicViewName
         //cast( '' as abap.char(30) )                                        as ChildDdlResourceName
}
where
  DdicViewParentChildRelation.ParentViewType = 'DDic'

union all

select from ZSCV_CdsViewChildCdsView as CdsViewParentChildRelation
{
  key $session.client       as mandt,
  key ParentAbapViewType    as ParentAbapViewType,
  key ParentAbapViewName    as ParentAbapViewName,
  key ChildAbapViewType     as ChildAbapViewType,
  key ChildAbapViewName     as ChildAbapViewName,

      ParentDllResourceName as ParentDllResourceName,
      ParentDdicViewName    as ParentDdicViewName

      //ChildDdicViewName     as ChildDdicViewName
      //CdsViewParentChildRelation.ChildDdlResourceName  as ChildDdlResourceName

}
