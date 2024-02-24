@EndUserText.label: 'CDS View Release Status'
@AbapCatalog.sqlViewName: 'ZSCV_CDSVW_STAT'

@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED

define view ZSCV_CdsViewReleaseStatus
  as select from    tadir

    left outer join ars_w_api_state as state_c0 on  state_c0.object_id              = tadir.obj_name
                                                and state_c0.object_type            = 'DDLS'
                                                and state_c0.sub_object_type        = 'CDS_STOB'
                                                and state_c0.sub_object_name        = tadir.obj_name
                                                and state_c0.compatibility_contract = 'C0'

    left outer join ars_w_api_state as state_c1 on  state_c1.object_id              = tadir.obj_name
                                                and state_c1.object_type            = 'DDLS'
                                                and state_c1.sub_object_type        = 'CDS_STOB'
                                                and state_c1.sub_object_name        = tadir.obj_name
                                                and state_c1.compatibility_contract = 'C1'

    left outer join ars_w_api_state as state_c2 on  state_c2.object_id              = tadir.obj_name
                                                and state_c2.object_type            = 'DDLS'
                                                and state_c2.sub_object_type        = 'CDS_STOB'
                                                and state_c2.sub_object_name        = tadir.obj_name
                                                and state_c2.compatibility_contract = 'C2'
{
  tadir.obj_name as ViewName,
  //tadir.srcsystem,
  //tadir.author,
  //tadir.devclass,
  //tadir.cproject,
  //tadir.masterlang,
  tadir.created_on as CreationDate,
  //tadir.check_date,

  case
  when state_c0.object_id is not null then 'X'
  else ''
  end                                as C0_Exists,
  state_c0.release_state             as C0_ReleaseState,
  state_c0.use_in_key_user_apps      as C0_UseInKeyIUserApps,
  state_c0.use_in_sap_cloud_platform as C0_UseInCloudPlatform,

  case
    when state_c1.object_id is not null then 'X'
    else ''
    end                              as C1_Exists,
  state_c1.release_state             as C1_ReleaseState,
  state_c1.use_in_key_user_apps      as C1_UseInKeyUserApps,
  state_c1.use_in_sap_cloud_platform as C1_UseInCloudPlatform,

  case
    when state_c2.object_id is not null then 'X'
    else ''
    end                              as C2_Exists,
  state_c2.release_state             as C2_ReleaseState
//  state_c2.use_in_key_user_apps      as C2_UseInKeyUserApps,
//  state_c2.use_in_sap_cloud_platform as C2_UseInCloudPlatform
}
where
      tadir.pgmid  = 'R3TR'
  and tadir.object = 'DDLS'
//  and tadir.obj_name = 'I_PRODUCTSUPPLYPLANNING'
