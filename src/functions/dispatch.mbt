// MoonSheet Function Dispatcher
// Routes function calls to the appropriate implementation

/// Dispatch a function call by name
/// Returns the computed value or an error
pub fn dispatch(name : String, args : Array[@value.Value]) -> @value.Value {
  let upper_name = name.to_upper()
  match upper_name {
    // Math functions
    "SUM" => fn_sum(args)
    "PRODUCT" => fn_product(args)
    "ABS" => fn_abs(args)
    "ROUND" => fn_round(args)
    "FLOOR" => fn_floor(args)
    "CEILING" => fn_ceiling(args)
    "MOD" => fn_mod(args)
    "POWER" => fn_power(args)
    "SQRT" => fn_sqrt(args)
    "EXP" => fn_exp(args)
    "LN" => fn_ln(args)
    "LOG" => fn_log(args)
    "LOG10" => fn_log10(args)
    "SIN" => fn_sin(args)
    "COS" => fn_cos(args)
    "TAN" => fn_tan(args)
    "ASIN" => fn_asin(args)
    "ACOS" => fn_acos(args)
    "ATAN" => fn_atan(args)
    "ATAN2" => fn_atan2(args)
    "MIN" => fn_min(args)
    "MAX" => fn_max(args)
    "PI" => fn_pi(args)
    "SIGN" => fn_sign(args)
    "TRUNC" => fn_trunc(args)
    "INT" => fn_int(args)
    "DEGREES" => fn_degrees(args)
    "RADIANS" => fn_radians(args)
    "SUMIF" => fn_sumif(args)
    "SUMSQ" => fn_sumsq(args)
    "FACT" => fn_fact(args)
    "RAND" => fn_rand(args)
    "GCD" => fn_gcd(args)
    "LCM" => fn_lcm(args)

    // Text functions
    "LEFT" => fn_left(args)
    "RIGHT" => fn_right(args)
    "MID" => fn_mid(args)
    "LEN" => fn_len(args)
    "UPPER" => fn_upper(args)
    "LOWER" => fn_lower(args)
    "TRIM" => fn_trim(args)
    "CONCAT" => fn_concat(args)
    "REPLACE" => fn_replace(args)
    "SUBSTITUTE" => fn_substitute(args)
    "FIND" => fn_find(args)
    "SEARCH" => fn_search(args)
    "REPT" => fn_rept(args)
    "VALUE" => fn_value(args)
    "TEXT" => fn_text(args)
    "PROPER" => fn_proper(args)
    "CLEAN" => fn_clean(args)
    "EXACT" => fn_exact(args)
    "T" => fn_t(args)
    "CHAR" => fn_char(args)
    "CODE" => fn_code(args)

    // Logical functions
    "IF" => fn_if(args)
    "AND" => fn_and(args)
    "OR" => fn_or(args)
    "NOT" => fn_not(args)
    "XOR" => fn_xor(args)
    "IFERROR" => fn_iferror(args)
    "IFNA" => fn_ifna(args)
    "TRUE" => fn_true(args)
    "FALSE" => fn_false(args)
    "ISNUMBER" => fn_isnumber(args)
    "ISTEXT" => fn_istext(args)
    "ISLOGICAL" => fn_islogical(args)
    "ISERROR" => fn_iserror(args)
    "ISEMPTY" => fn_isempty(args)
    "ISNONTEXT" => fn_isnontext(args)
    "ISREF" => fn_isref(args)
    "NA" => fn_na(args)
    "ERROR.TYPE" => fn_error_type(args)
    "IFS" => fn_ifs(args)
    "SWITCH" => fn_switch(args)

    // Date/time functions
    "DATE" => fn_date(args)
    "TODAY" => fn_today(args)
    "NOW" => fn_now(args)
    "TIME" => fn_time(args)
    "YEAR" => fn_year(args)
    "MONTH" => fn_month(args)
    "DAY" => fn_day(args)
    "HOUR" => fn_hour(args)
    "MINUTE" => fn_minute(args)
    "SECOND" => fn_second(args)
    "WEEKDAY" => fn_weekday(args)
    "EOMONTH" => fn_eomonth(args)
    "DATEDIF" => fn_datedif(args)
    "DAYS360" => fn_days360(args)
    "WEEKNUM" => fn_weeknum(args)
    "DATEVALUE" => fn_datevalue(args)
    "TIMEVALUE" => fn_timevalue(args)

    // Statistical functions
    "AVERAGE" => fn_average(args)
    "COUNT" => fn_count(args)
    "COUNTA" => fn_counta(args)
    "COUNTIF" => fn_countif(args)
    "AVERAGEIF" => fn_averageif(args)
    "MEDIAN" => fn_median(args)
    "MODE" => fn_mode(args)
    "STDEV" => fn_stdev(args)
    "STDEVP" => fn_stdevp(args)
    "VAR" => fn_var(args)
    "VARP" => fn_varp(args)
    "LARGE" => fn_large(args)
    "SMALL" => fn_small(args)
    "RANK" => fn_rank(args)
    "PERCENTILE" => fn_percentile(args)
    "QUARTILE" => fn_quartile(args)
    "SUMPRODUCT" => fn_sumproduct(args)
    "GEOMEAN" => fn_geomean(args)
    "HARMEAN" => fn_harmean(args)
    "AVEDEV" => fn_avedev(args)
    "DEVSQ" => fn_devsq(args)

    _ => @value.Err(@error.NameError)
  }
}

/// Check if a function exists
pub fn has_function(name : String) -> Bool {
  let upper_name = name.to_upper()
  let result = dispatch(name, [])
  match result {
    @value.Err(@error.NameError) => false
    _ => true
  }
}

/// Get the count of available functions
pub fn function_count() -> Int {
  95
}

/// List all function names
pub fn list_functions() -> Array[String] {
  [
    "SUM", "PRODUCT", "ABS", "ROUND", "FLOOR", "CEILING", "MOD", "POWER", "SQRT",
    "EXP", "LN", "LOG", "LOG10", "SIN", "COS", "TAN", "ASIN", "ACOS", "ATAN", "ATAN2",
    "MIN", "MAX", "PI", "SIGN", "TRUNC", "INT", "DEGREES", "RADIANS", "SUMIF", "SUMSQ",
    "FACT", "RAND", "GCD", "LCM",
    "LEFT", "RIGHT", "MID", "LEN", "UPPER", "LOWER", "TRIM", "CONCAT", "REPLACE",
    "SUBSTITUTE", "FIND", "SEARCH", "REPT", "VALUE", "TEXT", "PROPER", "CLEAN", "EXACT",
    "T", "CHAR", "CODE",
    "IF", "AND", "OR", "NOT", "XOR", "IFERROR", "IFNA", "TRUE", "FALSE",
    "ISNUMBER", "ISTEXT", "ISLOGICAL", "ISERROR", "ISEMPTY", "ISNONTEXT", "ISREF",
    "NA", "ERROR.TYPE", "IFS", "SWITCH",
    "DATE", "TODAY", "NOW", "TIME", "YEAR", "MONTH", "DAY", "HOUR", "MINUTE", "SECOND",
    "WEEKDAY", "EOMONTH", "DATEDIF", "DAYS360", "WEEKNUM", "DATEVALUE", "TIMEVALUE",
    "AVERAGE", "COUNT", "COUNTA", "COUNTIF", "AVERAGEIF", "MEDIAN", "MODE",
    "STDEV", "STDEVP", "VAR", "VARP", "LARGE", "SMALL", "RANK", "PERCENTILE", "QUARTILE",
    "SUMPRODUCT", "GEOMEAN", "HARMEAN", "AVEDEV", "DEVSQ"
  ]
}

/// Get function category
pub fn function_category(name : String) -> String {
  let upper_name = name.to_upper()
  let math_funcs = ["SUM", "PRODUCT", "ABS", "ROUND", "FLOOR", "CEILING", "MOD", "POWER", "SQRT", "EXP", "LN", "LOG", "LOG10", "SIN", "COS", "TAN", "ASIN", "ACOS", "ATAN", "ATAN2", "MIN", "MAX", "PI", "SIGN", "TRUNC", "INT", "DEGREES", "RADIANS", "SUMIF", "SUMSQ", "FACT", "RAND", "GCD", "LCM"]
  let text_funcs = ["LEFT", "RIGHT", "MID", "LEN", "UPPER", "LOWER", "TRIM", "CONCAT", "REPLACE", "SUBSTITUTE", "FIND", "SEARCH", "REPT", "VALUE", "TEXT", "PROPER", "CLEAN", "EXACT", "T", "CHAR", "CODE"]
  let logical_funcs = ["IF", "AND", "OR", "NOT", "XOR", "IFERROR", "IFNA", "TRUE", "FALSE", "ISNUMBER", "ISTEXT", "ISLOGICAL", "ISERROR", "ISEMPTY", "ISNONTEXT", "ISREF", "NA", "ERROR.TYPE", "IFS", "SWITCH"]
  let date_funcs = ["DATE", "TODAY", "NOW", "TIME", "YEAR", "MONTH", "DAY", "HOUR", "MINUTE", "SECOND", "WEEKDAY", "EOMONTH", "DATEDIF", "DAYS360", "WEEKNUM", "DATEVALUE", "TIMEVALUE"]
  let stat_funcs = ["AVERAGE", "COUNT", "COUNTA", "COUNTIF", "AVERAGEIF", "MEDIAN", "MODE", "STDEV", "STDEVP", "VAR", "VARP", "LARGE", "SMALL", "RANK", "PERCENTILE", "QUARTILE", "SUMPRODUCT", "GEOMEAN", "HARMEAN", "AVEDEV", "DEVSQ"]
  if math_funcs.contains(upper_name) { "Math" }
  else if text_funcs.contains(upper_name) { "Text" }
  else if logical_funcs.contains(upper_name) { "Logical" }
  else if date_funcs.contains(upper_name) { "Date/Time" }
  else if stat_funcs.contains(upper_name) { "Statistical" }
  else { "Unknown" }
}
