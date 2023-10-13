@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View Field'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}

/*Design decisions
Db Table DDLS_RIS_INDEX contains relations on view and field level.
For example: field I_Product.Product is stored as: \TY:MARA\TY:MATNR

Db Table DD03ND contains the fields. "DD: Attributes of a Node of a Structured Object"

*/
define view entity ZSCV_EntityCdsViewAliasField
  as

  select from  dd03nd       as Field
    inner join ZSCV_CdsView as CdsView on  CdsView.DdlSourceName = Field.strucobjn
                                       //and CdsView.AbapViewType  = 'Entity CDS'
{
  key Field.strucobjn as DdlSourceName,
  key Field.fieldname as FieldName,  
  
      CdsView.AbapViewType,

      Field.position  as FieldPosition,

      Field.keyflag   as KeyFlag,
      Field.rollname  as DataElementName,
      //      checktable             as Checktable,
      //      adminfield             as Adminfield,
      //      inttype                as Inttype,
      //      intlen                 as Intlen,
      //      reftable               as Reftable,
      //      precfield              as Precfield,
      //      reffield               as Reffield,
      //      notnull                as Notnull,
      //      datatype               as Datatype,
      //      leng                   as Leng,
      //      decimals               as Decimals,
      Field.domname                as DomainName
      //      shlporigin             as Shlporigin,
      //      tabletype              as Tabletype,
      //      depth                  as Depth,
      //      comptype               as Comptype,
      //      reftype                as Reftype,
      //      languflag              as Languflag,
      //      anonymous              as Anonymous,
      //      outputstyle            as Outputstyle,
      //      enabled                as Enabled,
      //      transient              as Transient,
      //      fieldnamedbs           as Fieldnamedbs,
      //      lfieldname             as Lfieldname,
      //      fieldorigin            as Fieldorigin,
      //      appendstruname         as Appendstruname,
      //      fieldname_raw          as FieldnameRaw,
      //      sql_passvalue          as SqlPassvalue,
      //      outputlen              as Outputlen,
      //      is_virtual             as IsVirtual,
      //      is_calculated          as IsCalculated,
      //      extendname             as Extendname,
      //      convexit               as Convexit,
      //      is_calculated_quantity as IsCalculatedQuantity,
      //      simple_type            as SimpleType
}
where
      Field.nodename = '.NODE1'
  and Field.as4local = 'A'
