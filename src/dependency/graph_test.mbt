test "DependencyGraph::new" {
  let g = DependencyGraph::new()
  assert_eq(g.edge_count(), 0)
}

test "DependencyGraph::add_dependency" {
  let g = DependencyGraph::new().add_dependency(0, 0, 1, 0)
  assert_eq(g.edge_count(), 1)
  let deps = g.get_dependees(0, 0)
  assert_eq(deps.length(), 1)
  assert_eq(deps[0], (1, 0))
}

test "DependencyGraph::get_dependents" {
  let g = DependencyGraph::new().add_dependency(0, 0, 1, 0)
  let deps = g.get_dependents(1, 0)
  assert_eq(deps.length(), 1)
  assert_eq(deps[0], (0, 0))
}

test "DependencyGraph::remove_dependency" {
  let g = DependencyGraph::new().add_dependency(0, 0, 1, 0).remove_dependency(0, 0, 1, 0)
  assert_eq(g.edge_count(), 0)
}

test "DependencyGraph::find_affected" {
  let g = DependencyGraph::new()
    .add_dependency(0, 1, 0, 0)
    .add_dependency(0, 2, 0, 1)
  let affected = g.find_affected(0, 0)
  assert_eq(affected.length(), 2)
}

test "DependencyGraph::from_sheet" {
  let sheet = @sheet.Sheet::with_default()
    .set_value(0, 0, @value.Number(1.0))
    .set_value(0, 1, @value.Number(2.0))
    .set_formula(0, 2, "=A1+B1")
  let g = DependencyGraph::from_sheet(sheet)
  let deps = g.get_dependees(0, 2)
  assert_eq(deps.length(), 2)
}

test "DependencyGraph::clear_cell" {
  let g = DependencyGraph::new().add_dependency(0, 0, 1, 0).clear_cell(0, 0)
  assert_eq(g.edge_count(), 0)
}

test "DependencyGraph::get_all_cells" {
  let g = DependencyGraph::new()
    .add_dependency(0, 0, 1, 0)
    .add_dependency(0, 1, 1, 1)
  let cells = g.get_all_cells()
  assert_eq(cells.length(), 4)
}
