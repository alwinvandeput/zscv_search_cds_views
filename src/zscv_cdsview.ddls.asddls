@EndUserText.label: 'CDS View'
@AbapCatalog.sqlViewName: 'ZSCV_CDSVW'

@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED

//Entity CDS view
define view ZSCV_CdsView
  as select from    tadir         as DdlSource

    left outer join ddldependency as DdlToDdicLink on  DdlToDdicLink.ddlname    = DdlSource.obj_name
                                                   and DdlToDdicLink.objecttype = 'VIEW'
                                                   and DdlToDdicLink.state      = 'A'

  association [0..1] to ZSCV_CdsViewReleaseStatus as _Status              on  _Status.ViewName = $projection.DdlSourceName

  association [0..1] to ddheadanno                as _Annotation          on  _Annotation.strucobjn = $projection.DdlSourceName
  //association [0..1] to ZSCV_CdsViewServiceDefCount as _ServiceDefCount on _ServiceDefCount.DdlSourceName = $projection.DdlSourceName
  association [0..1] to tadir                     as _RapBehaviorDef      on  _RapBehaviorDef.object   = 'BDEF'
                                                                          and _RapBehaviorDef.pgmid    = 'R3TR'
                                                                          and _RapBehaviorDef.obj_name = $projection.DdlSourceName
  association [0..1] to ZSCV_ChildRapCdsView      as _ChildRapBehaviorDef on  _ChildRapBehaviorDef.entity = $projection.DdlSourceName
  association [0..1] to zscv_cds_rel              as _CdsRelation         on  _CdsRelation.parent_name = $projection.DdlSourceName
{

  key DdlSource.obj_name                                             as DdlSourceName,


      DdlToDdicLink.ddlname                                          as LinkDddlName,
      DdlToDdicLink.objectname                                       as LinkDdlObjectName,
      DdlToDdicLink.state                                            as LinkDdlState,


      DdlToDdicLink.objectname                                       as DdicViewName,

      //Child: DDic, DDic CDS, Entity CDS
      case
        when DdlToDdicLink.ddlname is null then 'Entity CDS'
        else 'DDic CDS'
        end                                                          as AbapViewType,

      DdlSource.created_on                                           as CreateDate,
      DdlSource.author                                               as CreateUser,
      _Annotation[ name = 'ANALYTICS.QUERY' ].value                  as EmbeddedAnalyticsQueryInd,
      _Annotation[ name = 'ANALYTICS.DATACATEGORY' ].value           as DataCategory,

      _Annotation[ name = 'ENDUSERTEXT.LABEL' ].value                as EndUserTextLabel,
      _Annotation[ name = 'VDM.VIEWTYPE' ].value                     as VdmViewType,
      _Annotation[ name = 'ACCESSCONTROL.AUTHORIZATIONCHECK' ].value as AccessControlAuthCheck,
      _Annotation[ name = 'OBJECTMODEL.USAGETYPE.DATACLASS' ].value  as ObjectModelUsageTypeDataClass,
      _Annotation[ name = 'VDM.LIFECYCLE.CONTRACT.TYPE' ].value      as VdmLifeCycleContractType,
      _Annotation[ name = 'OBJECTMODEL.CREATEENABLED' ].value        as ObjectModelCreateEnabled,

      case _Annotation[ name = 'METADATA.ALLOWEXTENSIONS' ].value
        when  'true' then 'X'
        else ''
        end                                                          as MetadataAllowExtensions,
      case _Annotation[ name = 'SEARCH.SEARCHABLE' ].value
        when  'true' then 'X'
        else ''
        end                                                          as SearchSearchable,

      _Annotation[ name = 'VDM.USAGE.TYPE$1$' ].value                as VdmUsageType1,
      _Annotation[ name = 'OBJECTMODEL.SEMANTICKEY$1$' ].value       as ObjectModelSemanticKey1,
      _Annotation[ name = 'OBJECTMODEL.SEMANTICKEY$2$' ].value       as ObjectModelSemanticKey2,
      _Annotation[ name = 'OBJECTMODEL.SEMANTICKEY$3$' ].value       as ObjectModelSemanticKey3,


      case _Annotation[name = 'ODATA.PUBLISH' ].value
        when  'true' then 'X'
        else ''
        end                                                          as ODataPublish,

      case
        when _RapBehaviorDef.obj_name is not null
          then 'X'
        else ''
        end                                                          as RapPublish,

      case
        when _ChildRapBehaviorDef.entity is not null
          then 'X'
        else ''
        end                                                          as ChildRapViewInd,

      _Status,
      _CdsRelation
}

where
      DdlSource.pgmid   =  'R3TR'
  and DdlSource.object  =  'DDLS'
  and DdlSource.delflag <> 'X'
