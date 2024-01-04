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

  select from  ddls_ris_index as _Field
    inner join ZSCV_CdsView   as CdsView on CdsView.DdlSourceName = _Field.ddlsrc_name
{
  key   _Field.ddlsrc_name            as AbapViewName,
  key   _Field.used_artifact_fullname as FullFieldName,

        CdsView.AbapViewType

}
where
  //Only fields. Fields contain \TY:<CDS view>\TY:<Field name>
  INSTR(SUBSTRING(_Field.used_artifact_fullname,5, 100), '\\TY:') > 0
