@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View Child CDS View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}

/* This view contains only Entity CDS Views, no DDic CDS Views. */

define view entity ZSCV_CdsViewChildCdsView
  as select from    ZSCV_CdsViewRelation as CdsRelation

    //Parent view 
    inner join      ddddlsrc             as ParentCdsView            on ParentCdsView.ddlname = CdsRelation.ParentDdlSourceName

    left outer join ddldependency        as ParentDdicView           on  ParentDdicView.ddlname    = CdsRelation.ParentDdlSourceName
                                                                     and ParentDdicView.objecttype = 'VIEW'

    //Child view 
    left outer join ddldependency        as ChildDdicCdsViewRelation on  ChildDdicCdsViewRelation.ddlname    = CdsRelation.ChildAbapViewName
                                                                     and ChildDdicCdsViewRelation.objecttype = 'VIEW'

    left outer join dd02l                as ChildDdicTable           on ChildDdicTable.tabname = CdsRelation.ChildAbapViewName

    left outer join dd25l                as ChildDDicView2           on ChildDDicView2.viewname = CdsRelation.ChildAbapViewName

{
  key CdsRelation.ParentDdlSourceName as ParentDllResourceName,
  key CdsRelation.ChildAbapViewName  as ChildDdlRelationViewName,

      //Parent
      case
        when ParentDdicView.ddlname is null then 'Entity CDS'
        else 'DDic CDS'
        end                                               as ParentAbapViewType,

      //Child: DDic, DDic CDS, Entity CDS
      case
        when ChildDdicCdsViewRelation.ddlname is not null then 'DDic CDS'
        when ChildDdicTable.tabname is not null then 'DDic'
        when ChildDDicView2.viewname is not null then 'DDic'
        else 'Entity CDS'
        end                                               as ChildAbapViewType,

      //Parent
      ParentDdicView.objectname                           as ParentDdicViewName,

      //Child
      case
        when ChildDdicCdsViewRelation.ddlname is not null then ChildDdicCdsViewRelation.ddlname
        when ChildDdicTable.tabname is not null then ''
        when ChildDDicView2.viewname is not null then ''
        else CdsRelation.ChildAbapViewName
        end                                               as ChildDdlResourceName,
        
      case
        when ChildDdicCdsViewRelation.ddlname is not null then ChildDdicCdsViewRelation.objectname
        when ChildDdicTable.tabname is not null then ChildDdicTable.tabname
        when ChildDDicView2.viewname is not null then ChildDDicView2.viewname
        else ''
        end                                               as ChildDdicViewName       

}
