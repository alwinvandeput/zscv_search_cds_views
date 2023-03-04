@EndUserText.label: 'CDS View'
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}

define view entity ZSCV_CdsViewRelation
  as select from ddls_ris_index as CdsRelation
{
  key cast(ddlsrc_name as abap.char(30))         as ParentDdlSourceName,
  key used_artifact_fullname as UsedArtifactFullname,
      
      cast( SUBSTRING( CdsRelation.used_artifact_fullname, 5, 100) as abap.char(30) ) as ChildAbapViewName
          
}
where
  //Only CDS views, no fields. Fields contain \TY:<CDS view>\TY:<Field name>
  INSTR(SUBSTRING(used_artifact_fullname,5, 100), '\\TY:') = 0
  and
  
  //No relation to itself 
  ddlsrc_name  <> cast( SUBSTRING( used_artifact_fullname,5, 100) as abap.char(30) )
