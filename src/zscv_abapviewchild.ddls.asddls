@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAP View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZSCV_AbapViewChild
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
where
     $parameters.p_DdicCdsBasedOnDllResourceInd        = ''
  or DdicViewParentChildRelation.ParentDllResourceName is null

union

select from ZSCV_CdsViewChildCdsView as CdsViewParentChildRelation
{
  key CdsViewParentChildRelation.ParentDllResourceName as ParentAbapViewName,
  key case
    when $parameters.p_DdicCdsBasedOnDllResourceInd    = 'X'
      then
        case CdsViewParentChildRelation.ChildAbapViewType
          when 'DDic'     then CdsViewParentChildRelation.ChildDdicViewName
          when 'DDic CDS' then CdsViewParentChildRelation.ChildDdlResourceName
          else  CdsViewParentChildRelation.ChildDdlResourceName
        end
      else
        case CdsViewParentChildRelation.ChildAbapViewType
          when 'DDic'       then CdsViewParentChildRelation.ChildDdicViewName
          when 'DDic CDS'   then CdsViewParentChildRelation.ChildDdicViewName
          else CdsViewParentChildRelation.ChildDdlResourceName
        end
    end                                                as ChildAbapViewName,

      CdsViewParentChildRelation.ParentAbapViewType    as ParentAbapViewType,
      CdsViewParentChildRelation.ChildAbapViewType     as ChildAbapViewType,

      CdsViewParentChildRelation.ParentDllResourceName as ParentDllResourceName,
      CdsViewParentChildRelation.ParentDdicViewName    as ParentDdicViewName,

      CdsViewParentChildRelation.ChildDdicViewName     as ChildDdicViewName,
      CdsViewParentChildRelation.ChildDdlResourceName  as ChildDdlResourceName

}
//Do not show the DDic
where
     $parameters.p_DdicCdsBasedOnDllResourceInd    = 'X'
  or CdsViewParentChildRelation.ParentDdicViewName is null
