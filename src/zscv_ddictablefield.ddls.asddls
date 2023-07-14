@AbapCatalog.sqlViewName: 'ZSCV_DDTBFD2'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAP Table Field'
define view ZSCV_DdicTableField as 

select from dd03l as Field 
  inner join  ZSCV_DdicTable as DdicTable on DdicTable.TableName = Field.tabname  
{
  key Field.tabname     as TableName,
  key Field.fieldname   as FieldName,
  
  'DDic Table' as AbapViewType,
  
  Field.rollname as DataElementName,
  Field.domname  as DomainName
  //key Field.as4local    as As4local,
  //key Field.as4vers     as As4vers,
  //key Field.position    as Position
  
}
where Field.fieldname <> '.INCLUDE'
