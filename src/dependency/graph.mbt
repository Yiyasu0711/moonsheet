// MoonSheet Dependency Graph
// Manages cell dependencies for incremental recalculation

/// Dependency graph for tracking cell relationships
pub struct DependencyGraph {
  pub dependents : Map[(Int, Int), Array[(Int, Int)]]
  pub dependees : Map[(Int, Int), Array[(Int, Int)]]
}

/// Create a new empty dependency graph
pub fn DependencyGraph::new() -> DependencyGraph {
  DependencyGraph { dependents: {}, dependees: {} }
}

/// Build a dependency graph from a sheet
pub fn DependencyGraph::from_sheet(sheet : @sheet.Sheet) -> DependencyGraph {
  let mut graph = DependencyGraph::new()
  let formula_cells = sheet.get_formula_cells()
  for cell in formula_cells {
    let deps = @evaluator.get_cell_dependencies(sheet, cell.row, cell.col)
    for dep in deps {
      graph = graph.add_dependency(cell.row, cell.col, dep.0, dep.1)
    }
  }
  graph
}

/// Add a dependency: cell (row, col) depends on (dep_row, dep_col)
pub fn DependencyGraph::add_dependency(self : DependencyGraph, row : Int, col : Int, dep_row : Int, dep_col : Int) -> DependencyGraph {
  let mut new_dependents = self.dependents
  match new_dependents.get((dep_row, dep_col)) {
    Some(list) => {
      let mut new_list = list
      new_list.push((row, col))
      new_dependents[(dep_row, dep_col)] = new_list
    }
    None => new_dependents[(dep_row, dep_col)] = [(row, col)]
  }
  let mut new_dependees = self.dependees
  match new_dependees.get((row, col)) {
    Some(list) => {
      let mut new_list = list
      new_list.push((dep_row, dep_col))
      new_dependees[(row, col)] = new_list
    }
    None => new_dependees[(row, col)] = [(dep_row, dep_col)]
  }
  DependencyGraph { dependents: new_dependents, dependees: new_dependees }
}

/// Remove a dependency
pub fn DependencyGraph::remove_dependency(self : DependencyGraph, row : Int, col : Int, dep_row : Int, dep_col : Int) -> DependencyGraph {
  let mut new_dependents = self.dependents
  match new_dependents.get((dep_row, dep_col)) {
    Some(list) => {
      let mut new_list = []
      for item in list {
        if item != (row, col) {
          new_list.push(item)
        }
      }
      if new_list.length() == 0 {
        new_dependents.remove((dep_row, dep_col))
      } else {
        new_dependents[(dep_row, dep_col)] = new_list
      }
    }
    None => ()
  }
  let mut new_dependees = self.dependees
  match new_dependees.get((row, col)) {
    Some(list) => {
      let mut new_list = []
      for item in list {
        if item != (dep_row, dep_col) {
          new_list.push(item)
        }
      }
      if new_list.length() == 0 {
        new_dependees.remove((row, col))
      } else {
        new_dependees[(row, col)] = new_list
      }
    }
    None => ()
  }
  DependencyGraph { dependents: new_dependents, dependees: new_dependees }
}

/// Get all cells that depend on the given cell
pub fn DependencyGraph::get_dependents(self : DependencyGraph, row : Int, col : Int) -> Array[(Int, Int)] {
  match self.dependents.get((row, col)) {
    Some(list) => list
    None => []
  }
}

/// Get all cells that the given cell depends on
pub fn DependencyGraph::get_dependees(self : DependencyGraph, row : Int, col : Int) -> Array[(Int, Int)] {
  match self.dependees.get((row, col)) {
    Some(list) => list
    None => []
  }
}

/// Find all cells affected by a change at (row, col)
pub fn DependencyGraph::find_affected(self : DependencyGraph, row : Int, col : Int) -> Array[(Int, Int)] {
  let mut visited = {}
  let mut result = []
  let mut queue = [(row, col)]
  while queue.length() > 0 {
    let cell = queue[0]
    queue = queue.substring(start=1).to_array()
    if visited.contains(cell) {
      continue
    }
    visited[cell] = true
    result.push(cell)
    let deps = self.get_dependents(cell.0, cell.1)
    for dep in deps {
      if not(visited.contains(dep)) {
        queue.push(dep)
      }
    }
  }
  // Remove the original cell from the result
  let mut filtered = []
  for cell in result {
    if cell != (row, col) {
      filtered.push(cell)
    }
  }
  filtered
}

/// Check for circular references
pub fn DependencyGraph::has_circular(self : DependencyGraph) -> Bool {
  let mut all_cells = []
  for item in self.dependees {
    let (key, _) = item
    if not(all_cells.contains(key)) { all_cells.push(key) }
  }
  for item in self.dependents {
    let (key, _) = item
    if not(all_cells.contains(key)) { all_cells.push(key) }
  }
  for cell in all_cells {
    let mut visited = {}
    match self.dfs_cycle_check(cell, visited) {
      true => return true
      false => ()
    }
  }
  false
}

/// DFS cycle check helper
fn DependencyGraph::dfs_cycle_check(self : DependencyGraph, cell : (Int, Int), visited : Map[(Int, Int), Bool]) -> Bool {
  match visited.get(cell) {
    Some(true) => return true
    _ => ()
  }
  let mut new_visited = visited
  new_visited[cell] = true
  let deps = self.get_dependees(cell.0, cell.1)
  for dep in deps {
    if self.dfs_cycle_check(dep, new_visited) {
      return true
    }
  }
  new_visited[cell] = false
  false
}

/// Get the topological order of all cells for calculation
pub fn DependencyGraph::topological_sort(self : DependencyGraph) -> Result[Array[(Int, Int)], String] {
  let mut result = []
  let mut visited = {}
  let mut in_stack = {}

  // Get all unique cells
  let mut all_cells = []
  for item in self.dependents {
    let (key, _) = item
    if not(all_cells.contains(key)) { all_cells.push(key) }
  }
  for item in self.dependees {
    let (key, _) = item
    if not(all_cells.contains(key)) { all_cells.push(key) }
  }

  // Sort for deterministic order
  all_cells.sort()

  for cell in all_cells {
    if not(visited.contains(cell)) {
      match self.dfs_visit(cell, visited, in_stack, result) {
        Ok(_) => ()
        Err(e) => return Err(e)
      }
    }
  }

  result.reverse()
  Ok(result)
}

/// DFS visit for topological sort
fn DependencyGraph::dfs_visit(self : DependencyGraph, cell : (Int, Int), visited : Map[(Int, Int), Bool], in_stack : Map[(Int, Int), Bool], result : Array[(Int, Int)]) -> Result[Unit, String] {
  if in_stack.contains(cell) {
    return Err("Circular reference detected at " + cell.0.to_string() + "," + cell.1.to_string())
  }
  if visited.contains(cell) {
    return Ok(())
  }
  let mut new_visited = visited
  new_visited[cell] = true
  let mut new_in_stack = in_stack
  new_in_stack[cell] = true
  let deps = self.get_dependees(cell.0, cell.1)
  for dep in deps {
    match self.dfs_visit(dep, new_visited, new_in_stack, result) {
      Ok(_) => ()
      Err(e) => return Err(e)
    }
  }
  new_in_stack.remove(cell)
  result.push(cell)
  Ok(())
}

/// Get all unique cells in the graph
pub fn DependencyGraph::get_all_cells(self : DependencyGraph) -> Array[(Int, Int)] {
  let mut all_cells = []
  for item in self.dependents {
    let (key, _) = item
    if not(all_cells.contains(key)) { all_cells.push(key) }
  }
  for item in self.dependees {
    let (key, _) = item
    if not(all_cells.contains(key)) { all_cells.push(key) }
  }
  all_cells
}

/// Count total edges
pub fn DependencyGraph::edge_count(self : DependencyGraph) -> Int {
  let mut count = 0
  for item in self.dependees {
    let (_, list) = item
    count = count + list.length()
  }
  count
}

/// Clear all dependencies for a cell
pub fn DependencyGraph::clear_cell(self : DependencyGraph, row : Int, col : Int) -> DependencyGraph {
  // Remove from dependees
  let mut new_dependees = self.dependees
  new_dependees.remove((row, col))
  // Remove from dependents
  let mut new_dependents = self.dependents
  for item in new_dependents {
    let (key, list) = item
    let mut new_list = []
    for cell in list {
      if cell != (row, col) {
        new_list.push(cell)
      }
    }
    if new_list.length() == 0 {
      new_dependents.remove(key)
    } else {
      new_dependents[key] = new_list
    }
  }
  DependencyGraph { dependents: new_dependents, dependees: new_dependees }
}
