@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View Field'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}

//THIS VIEW IS NOT USED!!

define view entity ZSCV_CdsViewSourceField
  as

  select from  ddls_ris_index as Field
    inner join ZSCV_CdsView   as CdsView on CdsView.DdlSourceName = Field.ddlsrc_name
{
  key   CdsView.DdlSourceName        as DdlSourceName,

  key   case
          when CdsView.AbapViewType = 'Entity CDS'  then CdsView.DdlSourceName
          else  CdsView.DdicViewName
        end                          as AbapViewName,

        //  key   SUBSTRING(
        //          Field.used_artifact_fullname,
        //          5,
        //          INSTR(
        //            SUBSTRING(Field.used_artifact_fullname, 5, 100), '\\TY:') - 1
        //          )                          as ViewName,
  key   ''                           as ViewName,

        //  key   SUBSTRING(
        //            Field.used_artifact_fullname,
        //            INSTR(
        //              SUBSTRING(Field.used_artifact_fullname, 5, 100), '\\TY:') + 8 ,
        //            100)                     as Field,

  key   ''                           as Field,

        Field.used_artifact_fullname as FullFieldName,

        CdsView.AbapViewType

}
where
  //Only fields. Fields contain \TY:<CDS view>\TY:<Field name>
  INSTR(SUBSTRING(Field.used_artifact_fullname,5, 100), '\\TY:') > 0
