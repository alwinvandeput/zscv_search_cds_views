@EndUserText.label: 'CDS View'
@AbapCatalog.sqlViewName: 'ZSCV_CDSVW'

@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED

define view ZSCV_CdsView
  as select from tadir as DdlSource
  association [0..1] to ZSCV_CdsViewReleaseStatus as _Status     on _Status.ViewName = $projection.DdlSourceName

  association [0..1] to ddheadanno                as _Annotation on _Annotation.strucobjn = $projection.DdlSourceName

{

  key DdlSource.obj_name                                            as DdlSourceName,
      ''                                                            as DdicViewName,
      
      DdlSource.created_on as CreateDate,
      DdlSource.author as CreateUser,
      _Annotation[name = 'ANALYTICS.QUERY' ].value                  as EmbeddedAnalyticsQueryInd,
      _Annotation[name = 'ANALYTICS.DATACATEGORY' ].value           as DataCategory,

      _Annotation[name = 'ENDUSERTEXT.LABEL' ].value                as EndUserTextLabel,
      _Annotation[name = 'VDM.VIEWTYPE' ].value                     as VdmViewType,
      _Annotation[name = 'ACCESSCONTROL.AUTHORIZATIONCHECK' ].value as AccessControlAuthCheck,
      _Annotation[name = 'OBJECTMODEL.USAGETYPE.DATACLASS' ].value  as ObjectModelUsageTypeDataClass,
      _Annotation[name = 'VDM.LIFECYCLE.CONTRACT.TYPE' ].value      as VdmLifeCycleContractType,
      _Annotation[name = 'OBJECTMODEL.CREATEENABLED' ].value        as ObjectModelCreateEnabled,

      /*
                       ( NAME      = 'ANALYTICS.QUERY' OR
                       */

      _Status
}
where
      DdlSource.pgmid  = 'R3TR'
  and DdlSource.object = 'DDLS'
