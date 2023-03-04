@EndUserText.label: 'DDic View Parent'
@AbapCatalog.sqlViewName: 'ZSCV_DDVW_PARENT'

@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED

define view ZSCV_DdicViewParent 
as
select 
  from    ZSCV_DdicViewChildDdicView as DdicView
  association [1..*] to ZSCV_DdicViewParent as _Parent on $projection.ChildViewName = _Parent.ParentViewName
{
  key DdicView.ParentViewName,
  key DdicView.ChildViewName,
  
      _Parent
}
