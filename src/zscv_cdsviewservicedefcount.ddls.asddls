@AbapCatalog.sqlViewName: 'ZSCVSERVDEFCNT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View Service Definition Count'
define view ZSCV_CdsViewServiceDefCount as 

select 
from srvd_rt_entities
{
key exposed_artifact as DdlSourceName,
  count(*) as ServiceDefCount  
}
group by exposed_artifact
