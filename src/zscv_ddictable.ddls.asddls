@AbapCatalog.sqlViewName: 'ZSCV_DDICTB'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAP Table'
define view ZSCV_DdicTable
  as

  select from dd02l
{
  key tabname as TableName
}

where as4local = 'A'
  and as4vers  = '0000'
  and tabclass = 'TRANSP'
