// MoonSheet Financial Functions
// Financial calculation functions

/// PV function: present value
pub fn fn_pv(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 3 { return @value.Err(@error.ValueError) }
  let rate = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let nper = match args[1].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let pmt = match args[2].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let fv = if args.length() >= 4 {
    match args[3].as_number() { Ok(v) => v, Err(_) => 0.0 }
  } else { 0.0 }
  let pmt_type = if args.length() >= 5 {
    match args[4].as_number() { Ok(v) => v, Err(_) => 0.0 }
  } else { 0.0 }

  if rate == 0.0 {
    let pv = -(pmt * nper + fv)
    return @value.Number(pv)
  }

  let pvif = 1.0 / (1.0 + rate).pow(nper)
  let pva = if rate == 0.0 {
    nper
  } else {
    (1.0 - pvif) / rate
  }
  let pmt_adj = if pmt_type == 1.0 { pmt * (1.0 + rate) } else { pmt }
  let pv = -(pmt_adj * pva + fv * pvif)
  @value.Number(pv)
}

/// FV function: future value
pub fn fn_fv(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 3 { return @value.Err(@error.ValueError) }
  let rate = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let nper = match args[1].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let pmt = match args[2].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let pv = if args.length() >= 4 {
    match args[3].as_number() { Ok(v) => v, Err(_) => 0.0 }
  } else { 0.0 }
  let pmt_type = if args.length() >= 5 {
    match args[4].as_number() { Ok(v) => v, Err(_) => 0.0 }
  } else { 0.0 }

  if rate == 0.0 {
    let fv = -(pv + pmt * nper)
    return @value.Number(fv)
  }

  let pvif = (1.0 + rate).pow(nper)
  let pva = (1.0 - 1.0 / pvif) / rate
  let pmt_adj = if pmt_type == 1.0 { pmt * (1.0 + rate) } else { pmt }
  let fv = -(pv * pvif + pmt_adj * pva * (1.0 + rate) / (1.0 + rate) * (1.0 + rate))
  // Simplified calculation
  let fv2 = -(pv * pvif + pmt * ((pvif - 1.0) / rate))
  @value.Number(fv2)
}

/// PMT function: periodic payment
pub fn fn_pmt(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 3 { return @value.Err(@error.ValueError) }
  let rate = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let nper = match args[1].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let pv = match args[2].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let fv = if args.length() >= 4 {
    match args[3].as_number() { Ok(v) => v, Err(_) => 0.0 }
  } else { 0.0 }
  let pmt_type = if args.length() >= 5 {
    match args[4].as_number() { Ok(v) => v, Err(_) => 0.0 }
  } else { 0.0 }

  if rate == 0.0 {
    let pmt = -(pv + fv) / nper
    return @value.Number(pmt)
  }

  let pvif = 1.0 / (1.0 + rate).pow(nper)
  let pva = (1.0 - pvif) / rate
  let pmt = -(pv + fv * pvif) / pva
  if pmt_type == 1.0 {
    @value.Number(pmt / (1.0 + rate))
  } else {
    @value.Number(pmt)
  }
}

/// NPER function: number of periods
pub fn fn_nper(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 3 { return @value.Err(@error.ValueError) }
  let rate = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let pmt = match args[1].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let pv = match args[2].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let fv = if args.length() >= 4 {
    match args[3].as_number() { Ok(v) => v, Err(_) => 0.0 }
  } else { 0.0 }
  let pmt_type = if args.length() >= 5 {
    match args[4].as_number() { Ok(v) => v, Err(_) => 0.0 }
  } else { 0.0 }

  if rate == 0.0 {
    let nper = -(pv + fv) / pmt
    return @value.Number(nper)
  }

  let pmt_adj = if pmt_type == 1.0 { pmt * (1.0 + rate) } else { pmt }
  let numerator = pmt_adj / rate - fv
  let denominator = pv + pmt_adj / rate
  if numerator <= 0.0 || denominator <= 0.0 {
    return @value.Err(@error.NumError)
  }
  let nper = (numerator / denominator).log() / (1.0 + rate).log()
  @value.Number(nper)
}

/// RATE function: interest rate per period
pub fn fn_rate(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 3 { return @value.Err(@error.ValueError) }
  let nper = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let pmt = match args[1].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let pv = match args[2].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let fv = if args.length() >= 4 {
    match args[3].as_number() { Ok(v) => v, Err(_) => 0.0 }
  } else { 0.0 }
  let pmt_type = if args.length() >= 5 {
    match args[4].as_number() { Ok(v) => v, Err(_) => 0.0 }
  } else { 0.0 }
  let guess = if args.length() >= 6 {
    match args[5].as_number() { Ok(v) => v, Err(_) => 0.1 }
  } else { 0.1 }

  // Newton-Raphson method to approximate rate
  let mut rate = guess
  let mut iteration = 0
  let max_iter = 100
  let tolerance = 1e-7
  let mut found = false

  while iteration < max_iter && not(found) {
    // Calculate f(rate) = pv + pmt*(1+rate*type)/rate * (1 - 1/(1+rate)^nper) + fv/(1+rate)^nper
    if rate == 0.0 {
      rate = 1e-10
    }
    let pvif = 1.0 / (1.0 + rate).pow(nper)
    let pva = (1.0 - pvif) / rate
    let pmt_adj = if pmt_type == 1.0 { pmt * (1.0 + rate) } else { pmt }
    let f = pv + pmt_adj * pva + fv * pvif

    // Calculate derivative f'(rate)
    let dpva = (nper * pvif / (1.0 + rate) - pva) / rate
    let dfv = -nper * fv * pvif / (1.0 + rate)
    let df = if pmt_type == 1.0 {
      pmt * pva + pmt_adj * dpva + dfv
    } else {
      pmt * dpva + dfv
    }

    if df == 0.0 {
      found = true
    } else {
      let new_rate = rate - f / df
      if (new_rate - rate).abs() < tolerance {
        rate = new_rate
        found = true
      } else {
        rate = new_rate
      }
    }
    iteration = iteration + 1
  }

  if found {
    @value.Number(rate)
  } else {
    @value.Err(@error.NumError)
  }
}

/// NPV function: net present value
pub fn fn_npv(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let rate = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let mut npv = 0.0
  for i = 1; i < args.length(); i = i + 1 {
    match args[i].as_number() {
      Ok(cf) => {
        npv = npv + cf / (1.0 + rate).pow(i.to_double())
      }
      Err(_) => return @value.Err(@error.ValueError)
    }
  }
  @value.Number(npv)
}

/// IRR function: internal rate of return
pub fn fn_irr(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }

  // Newton-Raphson method
  let mut rate = 0.1
  let mut iteration = 0
  let max_iter = 100
  let tolerance = 1e-7
  let mut found = false

  while iteration < max_iter && not(found) {
    // Calculate NPV at current rate
    let mut npv = 0.0
    let mut dnpv = 0.0
    for i = 0; i < args.length(); i = i + 1 {
      match args[i].as_number() {
        Ok(cf) => {
          let factor = (1.0 + rate).pow((i + 1).to_double())
          npv = npv + cf / factor
          dnpv = dnpv - (i + 1).to_double() * cf / (factor * (1.0 + rate))
        }
        Err(_) => return @value.Err(@error.ValueError)
      }
    }

    if dnpv == 0.0 {
      found = true
    } else {
      let new_rate = rate - npv / dnpv
      if (new_rate - rate).abs() < tolerance {
        rate = new_rate
        found = true
      } else {
        rate = new_rate
      }
    }
    iteration = iteration + 1
  }

  if found {
    @value.Number(rate)
  } else {
    @value.Err(@error.NumError)
  }
}

/// IPMT function: interest payment
pub fn fn_ipmt(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 4 { return @value.Err(@error.ValueError) }
  let rate = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let per = match args[1].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let nper = match args[2].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let pv = match args[3].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }

  let pmt = match fn_pmt([@value.Number(rate), @value.Number(nper), @value.Number(pv)]) {
    @value.Number(p) => p
    _ => return @value.Err(@error.ValueError)
  }

  // Calculate remaining principal at period per-1
  let mut remaining = pv
  for i = 1; i < per.to_int(); i = i + 1 {
    let interest = remaining * rate
    let principal = pmt - interest
    remaining = remaining + principal
  }

  let ipmt = remaining * rate
  @value.Number(ipmt)
}

/// PPMT function: principal payment
pub fn fn_ppmt(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 4 { return @value.Err(@error.ValueError) }
  let rate = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let per = match args[1].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let nper = match args[2].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let pv = match args[3].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }

  let pmt = match fn_pmt([@value.Number(rate), @value.Number(nper), @value.Number(pv)]) {
    @value.Number(p) => p
    _ => return @value.Err(@error.ValueError)
  }

  let ipmt = match fn_ipmt([@value.Number(rate), @value.Number(per), @value.Number(nper), @value.Number(pv)]) {
    @value.Number(i) => i
    _ => return @value.Err(@error.ValueError)
  }

  @value.Number(pmt - ipmt)
}

/// EFFECT function: effective annual interest rate
pub fn fn_effect(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let nominal_rate = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let npery = match args[1].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  if npery <= 0.0 { return @value.Err(@error.NumError) }
  let effect = (1.0 + nominal_rate / npery).pow(npery) - 1.0
  @value.Number(effect)
}

/// NOMINAL function: nominal annual interest rate
pub fn fn_nominal(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let effect_rate = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let npery = match args[1].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  if npery <= 0.0 { return @value.Err(@error.NumError) }
  let nominal = ((1.0 + effect_rate).pow(1.0 / npery) - 1.0) * npery
  @value.Number(nominal)
}

/// SLN function: straight-line depreciation
pub fn fn_sln(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 3 { return @value.Err(@error.ValueError) }
  let cost = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let salvage = match args[1].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let life = match args[2].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  if life == 0.0 { return @value.Err(@error.DivZero) }
  @value.Number((cost - salvage) / life)
}

/// SYD function: sum-of-years' digits depreciation
pub fn fn_syd(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 4 { return @value.Err(@error.ValueError) }
  let cost = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let salvage = match args[1].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let life = match args[2].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let per = match args[3].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let sum_years = life * (life + 1.0) / 2.0
  if sum_years == 0.0 { return @value.Err(@error.DivZero) }
  let dep = (cost - salvage) * (life - per + 1.0) / sum_years
  @value.Number(dep)
}

/// DDB function: double-declining balance depreciation
pub fn fn_ddb(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 4 { return @value.Err(@error.ValueError) }
  let cost = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let salvage = match args[1].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let life = match args[2].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let per = match args[3].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let factor = if args.length() >= 5 {
    match args[4].as_number() { Ok(v) => v, Err(_) => 2.0 }
  } else { 2.0 }

  if life == 0.0 { return @value.Err(@error.DivZero) }
  let rate = factor / life
  let mut book_value = cost
  for i = 1; i < per.to_int(); i = i + 1 {
    let dep = book_value * rate
    if book_value - dep < salvage {
      book_value = salvage
    } else {
      book_value = book_value - dep
    }
  }
  let dep = book_value * rate
  if book_value - dep < salvage {
    @value.Number(book_value - salvage)
  } else {
    @value.Number(dep)
  }
}

/// FVSCHEDULE function: future value with schedule of rates
pub fn fn_fvschedule(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 2 { return @value.Err(@error.ValueError) }
  let principal = match args[0].as_number() { Ok(v) => v, Err(_) => return @value.Err(@error.ValueError) }
  let mut fv = principal
  for i = 1; i < args.length(); i = i + 1 {
    match args[i].as_number() {
      Ok(rate) => fv = fv * (1.0 + rate)
      Err(_) => return @value.Err(@error.ValueError)
    }
  }
  @value.Number(fv)
}

/// MIRR function: modified internal rate of return
pub fn fn_mirr(args : Array[@value.Value]) -> @value.Value {
  if args.length() < 3 { return @value.Err(@error.ValueError) }
  let finance_rate = match args[args.length() - 2].as_number() {
    Ok(v) => v
    Err(_) => return @value.Err(@error.ValueError)
  }
  let reinvest_rate = match args[args.length() - 1].as_number() {
    Ok(v) => v
    Err(_) => return @value.Err(@error.ValueError)
  }

  let n = args.length() - 2
  let mut pv_neg = 0.0
  let mut fv_pos = 0.0
  let n_int = n.to_int()

  for i = 0; i < n_int; i = i + 1 {
    match args[i].as_number() {
      Ok(cf) => {
        if cf < 0.0 {
          pv_neg = pv_neg + cf / (1.0 + finance_rate).pow((i + 1).to_double())
        } else {
          fv_pos = fv_pos + cf * (1.0 + reinvest_rate).pow((n_int - i - 1).to_double())
        }
      }
      Err(_) => return @value.Err(@error.ValueError)
    }
  }

  if pv_neg == 0.0 { return @value.Err(@error.DivZero) }
  let mirr = (fv_pos / (-pv_neg)).pow(1.0 / (n - 1).to_double()) - 1.0
  @value.Number(mirr)
}
