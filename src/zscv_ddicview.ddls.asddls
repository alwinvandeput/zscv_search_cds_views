@EndUserText.label: 'DDic View'
@AbapCatalog.sqlViewName: 'ZSCV_DDVW'

@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED

define view ZSCV_DdicView
  as select from    tadir      as DdicView
    left outer join dd25l                 on dd25l.viewname = DdicView.obj_name
    left outer join cdssqlview as CdsView on CdsView.sqlviewname = DdicView.obj_name
{
  DdicView.obj_name as ViewName,

  dd25l.viewname    as Dd25lViewName,

  case
    when CdsView.ddlsourcename is not null then 'X'
    else ''
    end             as CdsViewInd

}
where
      DdicView.pgmid  = 'R3TR'
  and DdicView.object = 'VIEW'
