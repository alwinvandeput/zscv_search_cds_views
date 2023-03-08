@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAP View Parent'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZSCV_AbapViewParent
  with parameters
    p_DdicCdsBasedOnDllResourceInd :abap_boolean

  as

  select from ZSCV_AbapViewChild2(p_DdicCdsBasedOnDllResourceInd : $parameters.p_DdicCdsBasedOnDllResourceInd)
  association [1..*] to ZSCV_AbapViewParent as _Parent on $projection.ChildAbapViewName = _Parent.ParentAbapViewName
{
  key ParentAbapViewName as ParentAbapViewName,
  key ChildAbapViewName as ChildAbapViewName,
  
     ParentAbapViewType,
     ParentDllResourceName as ParentDdlSourceName,
     ParentDdicViewName,  
  
      /* Associations */
      _Parent
}
//  where ParentViewName like '%ZZAP%MARC%'
