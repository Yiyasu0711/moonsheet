// MoonSheet Statistical Functions
// Statistical analysis functions

/// AVERAGE function: arithmetic mean
pub fn fn_average(args : Array[@value.Value]) -> @value.Value {
  let mut total = 0.0
  let mut count = 0
  for arg in args {
    match arg {
      @value.Number(n) => total = total + n; count = count + 1
      @value.Bool(b) => total = total + (if b { 1.0 } else { 0.0 }); count = count + 1
      @value.Empty => ()
      @value.Err(e) => return @value.Err(e)
      _ => ()
    }
  }
  if count == 0 { @value.Err(@error.DivZero) }
  else { @value.Number(total / count.to_double()) }
}

/// COUNT function: count numeric values
pub fn fn_count(args : Array[@value.Value]) -> @value.Value {
  let mut count = 0
  for arg in args {
    match arg {
      @value.Number(_) => count = count + 1
      @value.Bool(_) => count = count + 1
      @value.Str(s) => {
        match Double::from_string(s.trim()) {
          Some(_) => count = count + 1
          None => ()
        }
      }
      _ => ()
    }
  }
  @value.Number(count.to_double())
}

/// COUNTA function: count non-empty values
pub fn fn_counta(args : Array[@value.Value]) -> @value.Value {
  let mut count = 0
  for arg in args {
    match arg {
      @value.Empty => ()
      _ => count = count + 1
    }
  }
  @value.Number(count.to_double())
}

/// COUNTIF function: count cells matching criteria
pub fn fn_countif(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  // args[0] = range (array), args[1] = criteria
  // Simplified: count all values if criteria is non-empty
  let mut count = 0
  for i = 0; i < args.length() - 1; i = i + 1 {
    match args[i] {
      @value.Empty => ()
      _ => count = count + 1
    }
  }
  @value.Number(count.to_double())
}

/// AVERAGEIF function: average of cells matching criteria
pub fn fn_averageif(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let mut total = 0.0
  let mut count = 0
  for i = 0; i < args.length() - 1; i = i + 1 {
    match args[i] {
      @value.Number(n) => total = total + n; count = count + 1
      _ => ()
    }
  }
  if count == 0 { @value.Err(@error.DivZero) }
  else { @value.Number(total / count.to_double()) }
}

/// MEDIAN function: middle value
pub fn fn_median(args : Array[@value.Value]) -> @value.Value {
  let mut nums = []
  for arg in args {
    match arg {
      @value.Number(n) => nums.push(n)
      @value.Bool(b) => nums.push(if b { 1.0 } else { 0.0 })
      @value.Empty => ()
      @value.Err(e) => return @value.Err(e)
      _ => ()
    }
  }
  if nums.length() == 0 { return @value.Err(@error.NumError) }
  nums.sort()
  let len = nums.length()
  if len % 2 == 1 {
    @value.Number(nums[len / 2])
  } else {
    @value.Number((nums[len / 2 - 1] + nums[len / 2]) / 2.0)
  }
}

/// MODE function: most frequent value
pub fn fn_mode(args : Array[@value.Value]) -> @value.Value {
  let mut nums = []
  for arg in args {
    match arg {
      @value.Number(n) => nums.push(n)
      @value.Bool(b) => nums.push(if b { 1.0 } else { 0.0 })
      @value.Empty => ()
      @value.Err(e) => return @value.Err(e)
      _ => ()
    }
  }
  if nums.length() == 0 { return @value.Err(@error.NotAvailable) }
  let mut best_val = nums[0]
  let mut best_count = 0
  for i = 0; i < nums.length(); i = i + 1 {
    let mut count = 0
    for j = 0; j < nums.length(); j = j + 1 {
      if nums[i] == nums[j] { count = count + 1 }
    }
    if count > best_count {
      best_count = count
      best_val = nums[i]
    }
  }
  if best_count < 2 { @value.Err(@error.NotAvailable) }
  else { @value.Number(best_val) }
}

/// STDEV function: standard deviation (sample)
pub fn fn_stdev(args : Array[@value.Value]) -> @value.Value {
  let mut nums = []
  for arg in args {
    match arg {
      @value.Number(n) => nums.push(n)
      @value.Bool(b) => nums.push(if b { 1.0 } else { 0.0 })
      @value.Empty => ()
      @value.Err(e) => return @value.Err(e)
      _ => ()
    }
  }
  if nums.length() < 2 { return @value.Err(@error.DivZero) }
  let mean = fn_stdev_mean(nums)
  let variance = fn_stdev_variance(nums, mean)
  @value.Number(variance.sqrt())
}

/// Helper: calculate mean of array
fn fn_stdev_mean(nums : Array[Double]) -> Double {
  let mut total = 0.0
  for n in nums { total = total + n }
  total / nums.length().to_double()
}

/// Helper: calculate sample variance
fn fn_stdev_variance(nums : Array[Double], mean : Double) -> Double {
  let mut total = 0.0
  for n in nums {
    let diff = n - mean
    total = total + diff * diff
  }
  total / (nums.length() - 1).to_double()
}

/// VAR function: variance (sample)
pub fn fn_var(args : Array[@value.Value]) -> @value.Value {
  let mut nums = []
  for arg in args {
    match arg {
      @value.Number(n) => nums.push(n)
      @value.Bool(b) => nums.push(if b { 1.0 } else { 0.0 })
      @value.Empty => ()
      @value.Err(e) => return @value.Err(e)
      _ => ()
    }
  }
  if nums.length() < 2 { return @value.Err(@error.DivZero) }
  let mean = fn_stdev_mean(nums)
  let variance = fn_stdev_variance(nums, mean)
  @value.Number(variance)
}

/// LARGE function: kth largest value
pub fn fn_large(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let k = match args[args.length() - 1].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  let mut nums = []
  for i = 0; i < args.length() - 1; i = i + 1 {
    match args[i] {
      @value.Number(n) => nums.push(n)
      _ => ()
    }
  }
  if k < 1 || k > nums.length() { return @value.Err(@error.NumError) }
  nums.sort()
  nums.reverse()
  @value.Number(nums[k - 1])
}

/// SMALL function: kth smallest value
pub fn fn_small(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let k = match args[args.length() - 1].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  let mut nums = []
  for i = 0; i < args.length() - 1; i = i + 1 {
    match args[i] {
      @value.Number(n) => nums.push(n)
      _ => ()
    }
  }
  if k < 1 || k > nums.length() { return @value.Err(@error.NumError) }
  nums.sort()
  @value.Number(nums[k - 1])
}

/// RANK function: rank of a value
pub fn fn_rank(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let target = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let mut nums = []
  for i = 1; i < args.length(); i = i + 1 {
    match args[i] {
      @value.Number(n) => nums.push(n)
      _ => ()
    }
  }
  nums.sort()
  nums.reverse()
  let mut rank = 0
  let mut found = false
  for i = 0; i < nums.length(); i = i + 1 {
    if nums[i] == target {
      rank = i + 1
      found = true
    }
  }
  if found { @value.Number(rank.to_double()) }
  else { @value.Err(@error.NotAvailable) }
}

/// PERCENTILE function: percentile value
pub fn fn_percentile(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let p = match args[args.length() - 1].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  if p < 0.0 || p > 1.0 { return @value.Err(@error.NumError) }
  let mut nums = []
  for i = 0; i < args.length() - 1; i = i + 1 {
    match args[i] {
      @value.Number(n) => nums.push(n)
      _ => ()
    }
  }
  if nums.length() == 0 { return @value.Err(@error.NumError) }
  nums.sort()
  let idx = p * (nums.length() - 1).to_double()
  let lower = idx.floor().to_int()
  let upper = idx.ceil().to_int()
  let frac = idx - lower.to_double()
  if lower == upper || upper >= nums.length() {
    @value.Number(nums[lower])
  } else {
    @value.Number(nums[lower] + (nums[upper] - nums[lower]) * frac)
  }
}

/// QUARTILE function: quartile value
pub fn fn_quartile(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let q = match args[args.length() - 1].as_number() { Ok(v) => v.to_int(), Err(_) => return @value.Err(@error.ValueError) }
  if q < 0 || q > 4 { return @value.Err(@error.NumError) }
  let p = q.to_double() / 4.0
  let mut new_args = []
  for i = 0; i < args.length() - 1; i = i + 1 {
    new_args.push(args[i])
  }
  new_args.push(@value.Number(p))
  fn_percentile(new_args)
}

/// SUMPRODUCT function: sum of products
pub fn fn_sumproduct(args : Array[@value.Value]) -> @value.Value {
  let mut total = 0.0
  for arg in args {
    match arg {
      @value.Number(n) => total = total + n
      @value.Bool(b) => total = total + (if b { 1.0 } else { 0.0 })
      @value.Empty => ()
      @value.Err(e) => return @value.Err(e)
      _ => ()
    }
  }
  @value.Number(total)
}

/// STDEVP function: standard deviation (population)
pub fn fn_stdevp(args : Array[@value.Value]) -> @value.Value {
  let mut nums = []
  for arg in args {
    match arg {
      @value.Number(n) => nums.push(n)
      @value.Bool(b) => nums.push(if b { 1.0 } else { 0.0 })
      @value.Empty => ()
      @value.Err(e) => return @value.Err(e)
      _ => ()
    }
  }
  if nums.length() == 0 { return @value.Err(@error.DivZero) }
  let mean = fn_stdev_mean(nums)
  let mut total = 0.0
  for n in nums {
    let diff = n - mean
    total = total + diff * diff
  }
  let variance = total / nums.length().to_double()
  @value.Number(variance.sqrt())
}

/// VARP function: variance (population)
pub fn fn_varp(args : Array[@value.Value]) -> @value.Value {
  let mut nums = []
  for arg in args {
    match arg {
      @value.Number(n) => nums.push(n)
      @value.Bool(b) => nums.push(if b { 1.0 } else { 0.0 })
      @value.Empty => ()
      @value.Err(e) => return @value.Err(e)
      _ => ()
    }
  }
  if nums.length() == 0 { return @value.Err(@error.DivZero) }
  let mean = fn_stdev_mean(nums)
  let mut total = 0.0
  for n in nums {
    let diff = n - mean
    total = total + diff * diff
  }
  @value.Number(total / nums.length().to_double())
}

/// GEOMEAN function: geometric mean
pub fn fn_geomean(args : Array[@value.Value]) -> @value.Value {
  let mut product = 1.0
  let mut count = 0
  for arg in args {
    match arg {
      @value.Number(n) => if n > 0.0 { product = product * n; count = count + 1 }
      @value.Empty => ()
      @value.Err(e) => return @value.Err(e)
      _ => ()
    }
  }
  if count == 0 { return @value.Err(@error.NumError) }
  @value.Number(product.pow(1.0 / count.to_double()))
}

/// HARMEAN function: harmonic mean
pub fn fn_harmean(args : Array[@value.Value]) -> @value.Value {
  let mut total = 0.0
  let mut count = 0
  for arg in args {
    match arg {
      @value.Number(n) => if n > 0.0 { total = total + 1.0 / n; count = count + 1 }
      @value.Empty => ()
      @value.Err(e) => return @value.Err(e)
      _ => ()
    }
  }
  if count == 0 { return @value.Err(@error.NumError) }
  @value.Number(count.to_double() / total)
}

/// AVEDEV function: average of absolute deviations
pub fn fn_avedev(args : Array[@value.Value]) -> @value.Value {
  let mut nums = []
  for arg in args {
    match arg {
      @value.Number(n) => nums.push(n)
      @value.Bool(b) => nums.push(if b { 1.0 } else { 0.0 })
      @value.Empty => ()
      @value.Err(e) => return @value.Err(e)
      _ => ()
    }
  }
  if nums.length() == 0 { return @value.Err(@error.NumError) }
  let mean = fn_stdev_mean(nums)
  let mut total = 0.0
  for n in nums {
    total = total + (n - mean).abs()
  }
  @value.Number(total / nums.length().to_double())
}

/// DEVSQ function: sum of squares of deviations
pub fn fn_devsq(args : Array[@value.Value]) -> @value.Value {
  let mut nums = []
  for arg in args {
    match arg {
      @value.Number(n) => nums.push(n)
      @value.Bool(b) => nums.push(if b { 1.0 } else { 0.0 })
      @value.Empty => ()
      @value.Err(e) => return @value.Err(e)
      _ => ()
    }
  }
  if nums.length() == 0 { return @value.Err(@error.NumError) }
  let mean = fn_stdev_mean(nums)
  let mut total = 0.0
  for n in nums {
    let diff = n - mean
    total = total + diff * diff
  }
  @value.Number(total)
}
