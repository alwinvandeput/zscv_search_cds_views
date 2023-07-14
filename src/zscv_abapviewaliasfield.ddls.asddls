@AbapCatalog.sqlViewName: 'ZSCV_ABAPVWALFLD'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAP View Field'
define view ZSCV_AbapViewAliasField
  as

  select from ZSCV_DdicTableField
{
  key AbapViewType,
  key TableName as AbapViewName,
  key FieldName as FieldName,
  DataElementName,
  DomainName
}

union all

//DDic Views Alias Field and DDic CDS Views Alias Field
select from ZSCV_DdicViewAliasField
{
  key AbapViewType as AbapViewType,
  key Tabname as AbapViewName,
  key Fieldname as FieldName,
  DataElementName,
  DomainName
}

union all

//Entity CDS View Alias Field
select from ZSCV_EntityCdsViewAliasField
{
  key AbapViewType,
  key DdlSourceName as AbapViewName,
  key FieldName as FieldName,
  DataElementName,
  DomainName
}
