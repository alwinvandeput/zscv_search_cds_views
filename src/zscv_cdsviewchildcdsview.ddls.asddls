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

        //Parent
  key   case
      when ParentDdicView.ddlname is null then 'Entity CDS'
      else 'DDic CDS'
      end                               as ParentAbapViewType,

  key   CdsRelation.ParentDdlSourceName as ParentAbapViewName,

        //Child: DDic, DDic CDS, Entity CDS
  key
        case
          when ChildDdicCdsViewRelation.ddlname is not null then 'DDic CDS'
          when ChildDdicTable.tabname is not null then 'DDic'
          when ChildDDicView2.viewname is not null then 'DDic'
          else 'Entity CDS'
          end                           as ChildAbapViewType,

  key   CdsRelation.ChildAbapViewName   as ChildAbapViewName,

        //  key
        //      case
        //        when ChildDdicCdsViewRelation.ddlname is not null then ChildDdicCdsViewRelation.objectname
        //        when ChildDdicTable.tabname is not null then ChildDdicTable.tabname
        //        when ChildDDicView2.viewname is not null then ChildDDicView2.viewname
        //        else ''
        //        end                           as ChildAbapViewName,

        CdsRelation.ParentDdlSourceName as ParentDllResourceName,

        //CdsRelation.ChildAbapViewName   as SourceChildAbapViewName,

        case
          when ChildDdicCdsViewRelation.ddlname is not null then ChildDdicCdsViewRelation.objectname
          when ChildDdicTable.tabname is not null then ChildDdicTable.tabname
          when ChildDDicView2.viewname is not null then ChildDDicView2.viewname
          else ''
          end                           as ChildDdicViewName
          ,

        //Parent
        case
          when ParentDdicView.objectname is not null then ParentDdicView.objectname
          else CdsRelation.ParentDdlSourceName
          end                           as ParentDdicViewName


//        //Child
//        case
//          when ChildDdicCdsViewRelation.ddlname is not null then ChildDdicCdsViewRelation.ddlname
//          when ChildDdicTable.tabname is not null then ''
//          when ChildDDicView2.viewname is not null then ''
//          else CdsRelation.ChildAbapViewName
//          end                           as ChildDdlResourceName

}
