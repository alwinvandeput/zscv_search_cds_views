@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View Field'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZSCV_CdsViewSourceField
  as

  select from  ddls_ris_index as Field
    inner join ZSCV_CdsView   as CdsView on CdsView.DdlSourceName = Field.ddlsrc_name
{
  key   Field.ddlsrc_name            as DdlSourceName,

  key
        SUBSTRING(
          Field.used_artifact_fullname,
          5,
          INSTR(
            SUBSTRING(Field.used_artifact_fullname, 5, 100), '\\TY:') - 1
          )                          as ViewName,

  key   SUBSTRING(
    Field.used_artifact_fullname,
    INSTR(
      SUBSTRING(Field.used_artifact_fullname, 5, 100), '\\TY:') + 8 ,
    100)                             as Field,

        Field.used_artifact_fullname as FullFieldName,

        CdsView.AbapViewType

}
where
  //Only fields. Fields contain \TY:<CDS view>\TY:<Field name>
  INSTR(SUBSTRING(Field.used_artifact_fullname,5, 100), '\\TY:') > 0
