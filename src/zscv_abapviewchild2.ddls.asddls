@EndUserText.label: 'ABAP View Child'
@AbapCatalog.sqlViewName: 'ZSCV_ABAP_CHILD'

@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED

define view  ZSCV_AbapViewChild2
  with parameters
    p_DdicCdsBasedOnDllResourceInd :abap_boolean

  as

  select from ZSCV_DdicViewChildDdicView as DdicViewParentChildRelation
{
  key DdicViewParentChildRelation.ParentViewName                         as ParentAbapViewName,
  key DdicViewParentChildRelation.ChildViewName                          as ChildAbapViewName,

      cast( DdicViewParentChildRelation.ViewType as abap.char(10) )      as ParentAbapViewType,
      cast( DdicViewParentChildRelation.ChildViewType as abap.char(10) ) as ChildAbapViewType,

      DdicViewParentChildRelation.ParentDllResourceName                  as ParentDllResourceName,
      DdicViewParentChildRelation.ParentViewName                         as ParentDdicViewName,

      DdicViewParentChildRelation.ChildViewName                          as ChildDdicViewName,
      cast( '' as abap.char(30) )                                        as ChildDdlResourceName
}
//where
//     $parameters.p_DdicCdsBasedOnDllResourceInd        = ''
//  or DdicViewParentChildRelation.ParentDllResourceName is null

union

select from ZSCV_CdsViewChildCdsView as CdsViewParentChildRelation
{
  key CdsViewParentChildRelation.ParentDllResourceName as ParentAbapViewName,
  key 
    /*case
    when $parameters.p_DdicCdsBasedOnDllResourceInd    = 'X'
      then
        case CdsViewParentChildRelation.ChildAbapViewType
          when 'DDic'     then CdsViewParentChildRelation.ChildDdicViewName
          when 'DDic CDS' then CdsViewParentChildRelation.ChildDdlResourceName
          else  CdsViewParentChildRelation.ChildDdlResourceName
        end
      else */
        case CdsViewParentChildRelation.ChildAbapViewType
          when 'DDic View'       then CdsViewParentChildRelation.ChildDdicViewName
          when 'DDic CDS'   then CdsViewParentChildRelation.ChildDdicViewName
          else CdsViewParentChildRelation.ChildDdlResourceName
        end  as ChildAbapViewName,
    //end                                                

      CdsViewParentChildRelation.ParentAbapViewType    as ParentAbapViewType,
      CdsViewParentChildRelation.ChildAbapViewType     as ChildAbapViewType,

      CdsViewParentChildRelation.ParentDllResourceName as ParentDllResourceName,
      CdsViewParentChildRelation.ParentDdicViewName    as ParentDdicViewName,

      CdsViewParentChildRelation.ChildDdicViewName     as ChildDdicViewName,
      CdsViewParentChildRelation.ChildDdlResourceName  as ChildDdlResourceName

}

where
  //Do not show the DDic relation
  CdsViewParentChildRelation.ParentDdicViewName is null
