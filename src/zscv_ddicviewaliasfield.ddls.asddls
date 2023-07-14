@AbapCatalog.sqlViewName: 'ZSCV_DDVWALFLD'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DDic View Field'
define view ZSCV_DdicViewAliasField
  as

  select from  dd03l         as Field
    inner join ZSCV_DdicView as DDicView on DDicView.Dd25lViewName = Field.tabname
{
  key Field.tabname   as Tabname,
  key Field.fieldname as Fieldname,
  
  DDicView.AbapViewType,
  
      //key Field.as4local    as As4local,
      //key Field.as4vers     as As4vers,
      Field.position  as Position,
      //      field.keyflag     as keyflag,
      //      field.mandatory   as mandatory,
      Field.rollname  as DataElementName,
      //      field.checktable  as checktable,
      //      field.adminfield  as adminfield,
      //      field.inttype     as inttype,
      //      field.intlen      as intlen,
      //      field.reftable    as reftable,
      //      field.precfield   as precfield,
      //      field.reffield    as reffield,
      //      field.conrout     as conrout,
      //      field.notnull     as notnull,
      //      field.datatype    as datatype,
      //      field.leng        as leng,
      //      field.decimals    as decimals,
      Field.domname   as DomainName
      //      field.shlporigin  as shlporigin,
      //      field.tabletype   as tabletype,
      //      field.depth       as depth,
      //      field.comptype    as comptype,
      //      field.reftype     as reftype,
      //      field.languflag   as languflag,
      //      field.dbposition  as dbposition,
      //      field.anonymous   as anonymous,
      //      field.outputstyle as outputstyle,
      //      field.srs_id      as srsid
}
