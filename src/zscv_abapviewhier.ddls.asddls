define hierarchy ZSCV_AbapViewHier
  with parameters
    p_AbapViewName :vibastab,
    p_DdicCdsBasedOnDllResourceInd :abap_boolean
  as parent child hierarchy(
    source ZSCV_AbapViewParent( p_DdicCdsBasedOnDllResourceInd : $parameters.p_DdicCdsBasedOnDllResourceInd )
    child to parent association _Parent
    start where
      ZSCV_AbapViewParent.ChildAbapViewName = $parameters.p_AbapViewName
    siblings order by
      ParentAbapViewName
    multiple parents allowed //1 view kan meerdere bovenliggende views hebben
    cycles breakup
  )
{
  ParentAbapViewName        as AbapViewName,
  ParentAbapViewType        as AbapViewType,
  ParentDdlSourceName       as DdlSourceName,
  ParentDdicViewName        as DdicViewName,

  ChildAbapViewName         as ChildAbapViewName,

  $node.hierarchy_level     as HierarchyLevel,
  $node.hierarchy_is_orphan as IsOrphan,
  $node.hierarchy_tree_size as TreeSize,
  $node.hierarchy_is_cycle  as IsCycle,
  $node.node_id             as NodeId,

  _Parent
}
