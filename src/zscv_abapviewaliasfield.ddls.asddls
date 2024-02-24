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
  key cast(TableName as ddlname) as AbapViewName,
  key cast(concat('\TY:', concat(TableName, concat('\TY:', FieldName))) as abap.sstring(400))  as FullFieldName
//      DataElementName,
//      DomainName
}

union all

//DDic and Entity CDS View Alias Field
select from ZSCV_CdsViewSourceField
{
  key AbapViewType,
  key AbapViewName as AbapViewName,
  key FullFieldName        as FullFieldName
}


//union all
//
////DDic Views Alias Field and DDic CDS Views Alias Field
//select from ZSCV_DdicViewAliasField
//{
//  key AbapViewType as AbapViewType,
//  key Tabname      as AbapViewName,
//  key Fieldname    as FieldName,
//      DataElementName,
//      DomainName
//}

//union all
//
////Entity CDS View Alias Field
//select from       ZSCV_CdsViewSourceField as Field
//  left outer join dd03l                   as DdicField on  DdicField.tabname = Field.AbapViewType
//                                                       and DdicField.tabname = Field.AbapViewName
//
//{
//  key Field.AbapViewType,
//  key Field.AbapViewName as AbapViewName,
//  key Field.Field        as FieldName,
//      DdicField.rollname as DataElementName,
//      DdicField.domname  as DomainName
//}
//where
//  Field.AbapViewType = 'DDic CDS'

//union all
//
////DDic and Entity CDS View Alias Field
//select from ZSCV_CdsViewSourceField
//{
//  key AbapViewType,
//  key AbapViewName as AbapViewName,
//  key Field        as FieldName,
//      ''           as DataElementName,
//      ''           as DomainName
//}
//where
//  AbapViewType = 'Entity CDS'

/*
//Entity CDS View Alias Field
select from ZSCV_EntityCdsViewAliasField
{
  key AbapViewType,
  key DdlSourceName as AbapViewName,
  key FieldName as FieldName,
  DataElementName,
  DomainName
}
*/
