define hierarchy ZSCV_DdicViewHier
with parameters p_DbTableName:vibastab
  as parent child hierarchy (
    source ZSCV_DdicViewParent
    child to parent association _Parent //Parent is bovenliggende view
    start where
      ZSCV_DdicViewParent.ChildViewName = $parameters.p_DbTableName
    siblings order by ParentViewName
    multiple parents allowed //1 view kan meerdere bovenliggende views hebben
  )
{
    ParentViewName,
    ChildViewName,
    
    $node.hierarchy_level as HierarchyLevel,
    $node.hierarchy_is_orphan as IsOrphan,
    $node.hierarchy_tree_size as TreeSize,
    $node.hierarchy_is_cycle as IsCycle,
    $node.node_id as NodeId,
    
    _Parent
}
