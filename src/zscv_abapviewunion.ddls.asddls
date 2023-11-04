@AbapCatalog.sqlViewName: 'ZSCV_ABAPVWUN2'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAP View Union'
define view ZSCV_AbapViewUnion
  as

  select from ZSCV_DdicTable
{
  key TableName                   as AbapViewName,
      'DDic Table'                as AbapViewType,

      TableName                   as DdicViewName,
      cast( '' as abap.char(40) ) as DdlSourceName,

      'X'                         as DdicTableInd,
      ''                          as DdicViewInd,
      ''                          as DdicCdsViewInd,
      ''                          as EntityCdsViewInd
}

union all

//DDic Views and DDic CDS Views
select from ZSCV_DdicView
{
  key Dd25lViewName as AbapViewName,
      case CdsViewInd
        when 'X'
          then 'DDic CDS'
        else  'DDic View'
      end           as AbapViewType,

      Dd25lViewName as DdicViewName,
      DdlSourceName as DdlSourceName,

      ''            as DdicTableInd,
      case
        when CdsViewInd = 'X' then ''
        else 'X'
        end         as DdicViewInd,
      CdsViewInd    as DdicCdsViewInd,
      ''            as EntityCdsViewInd
}
where
  CdsViewInd = ''

union all

select from ZSCV_CdsView
{
  key DdlSourceName as AbapViewName,
      AbapViewType,

      DdicViewName  as DdicViewName,
      DdlSourceName as DdlSourceName,

      ''            as DdicTableInd,
      ''            as DdicViewInd,
      case
        when AbapViewType = 'DDic CDS' then 'X'
        else ''
        end         as DdicCdsViewInd,
      case
        when AbapViewType = 'Entity CDS' then 'X'
        else ''
        end         as EntityCdsViewInd
}
//where AbapViewType = 'Entity CDS'
