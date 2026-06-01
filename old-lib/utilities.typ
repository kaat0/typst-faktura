////////////////////////////////
// # Utility Functions
////////////////////////////////

// Constants
#let currency-precision = 2
#let default-locale = "de"
#let default-region = "DE"
#let default-currency = "EUR"

/// Currency configuration with symbol, placement, and ISO code.
#let currency-config = (
  "EUR": (
    symbol: "€",
    placement: "suffix", // suffix or prefix
    iso: "EUR",
    decimal-sep: (",", "."), // (de, en)
    thousands-sep: (".", ","), // (de, en)
  ),
  "USD": (
    symbol: "$",
    placement: "prefix",
    iso: "USD",
    decimal-sep: ("", "."),
    thousands-sep: ("", ","),
  ),
  "GBP": (
    symbol: "£",
    placement: "prefix",
    iso: "GBP",
    decimal-sep: ("", "."),
    thousands-sep: ("", ","),
  ),
  "CHF": (
    symbol: "CHF",
    placement: "prefix",
    iso: "CHF",
    decimal-sep: (",", "."),
    thousands-sep: ("'", "'"),
  ),
  "JPY": (
    symbol: "¥",
    placement: "prefix",
    iso: "JPY",
    decimal-sep: ("", "."),
    thousands-sep: ("", ","),
    precision: 0, // No decimal places for JPY
  ),
)

/// Date format patterns by region.
#let date-formats = (
  "US": "[month]/[day]/[year]",
  "GB": "[day]/[month]/[year]",
  "DE": "[day].[month].[year]",
  "AT": "[day].[month].[year]",
  "CH": "[day].[month].[year]",
  "FR": "[day]/[month]/[year]",
  "IT": "[day]/[month]/[year]",
  "ES": "[day]/[month]/[year]",
  "NL": "[day]-[month]-[year]",
  "BE": "[day].[month].[year]",
  "ISO": "[year]-[month]-[day]",
)

/// Gets the date format for a given region.
/// Falls back to ISO format if region not found.
#let get-date-format(region) = {
  date-formats.at(region, default: date-formats.at("ISO"))
}

/// Determines locale-specific formatting rules.
/// Returns a dict with decimal-sep, thousands-sep, and other formatting rules.
#let get-locale-formatting(locale, region) = {
  // Extract base language
  let lang = locale.split("-").first()
  
  // Determine number formatting based on locale and region
  let decimal-sep = if lang == "de" or region in ("DE", "AT", "CH") {
    ","
  } else if lang == "fr" or region in ("FR", "BE") {
    ","
  } else {
    "."
  }
  
  let thousands-sep = if lang == "de" or region in ("DE", "AT") {
    "."
  } else if region == "CH" {
    "'"
  } else if lang == "fr" or region in ("FR", "BE") {
    " "
  } else {
    ","
  }
  
  (
    decimal-sep: decimal-sep,
    thousands-sep: thousands-sep,
    date-format: get-date-format(region),
  )
}

/// Adds thousands separators to an integer part string.
/// 
/// - integer-part (str): The integer part of a number as a string
/// - separator (str): The thousands separator character to use (e.g., ".", ",", "'")
/// Returns the formatted string with thousands separators, or the original string if no separator needed.
#let add-thousands-separators(integer-part, separator) = {
  if separator == "" or integer-part.len() <= 3 {
    integer-part
  } else {
    let chars = integer-part.split("")
    let len = chars.len()
    // Calculate remainder when dividing by 3
    // Use integer division by calculating how many full groups of 3 we have
    let full-groups = calc.floor(len / 3)
    let remainder = len - (full-groups * 3)
    // First group size is remainder, or 3 if remainder == 0
    let first-group-size = if remainder == 0 { 3 } else { remainder }
    
    // Build result string directly
    let result = ""
    
    // First group
    for j in range(first-group-size) {
      result = result + chars.at(j)
    }
    
    // Remaining groups of 3
    let pos = first-group-size
    while pos < len {
      if result != "" {
        result = result + separator
      }
      for j in range(pos, calc.min(pos + 3, len)) {
        result = result + chars.at(j)
      }
      pos = pos + 3
    }
    
    result
  }
}

/// Formats a number as currency with locale-specific formatting.
/// 
/// Typst can't format numbers yet, so we use this workaround:
/// https://github.com/typst/typst/issues/180#issuecomment-1484069775
/// 
/// - number (float): The number to format
/// - locale (str): Locale for formatting (e.g., "de", "en", "fr")
/// - region (str): Region code (e.g., "DE", "US", "GB")
/// - currency (str): Currency code (e.g., "EUR", "USD", "GBP")
/// - show-symbol (bool): Whether to show the currency symbol
/// - epc-format (bool): If true, format for EPC QR code (dot as decimal separator, no thousands separators, force 2 decimal places)
#let format-currency(
  number,
  locale: default-locale,
  region: default-region,
  currency: default-currency,
  show-symbol: true,
  epc-format: false
) = {
  assert(currency-precision > 0)
  
  // Get currency configuration
  let curr-config = currency-config.at(currency, default: currency-config.at("EUR"))
  let precision = if epc-format { 2 } else { curr-config.at("precision", default: currency-precision) }
  
  // Round to specified precision
  let rounded = calc.round(number, digits: precision)
  let number-str = str(rounded)
  
  // Split into integer and decimal parts
  let parts-initial = number-str.split(".")
  let integer-part-initial = parts-initial.first()
  let decimal-part-initial = if parts-initial.len() > 1 { parts-initial.at(1) } else { "" }
  
  // Ensure decimal part has correct precision
  if precision > 0 {
    // Pad decimal part with zeros if needed
    let decimal-len = decimal-part-initial.len()
    let zeros-needed = precision - decimal-len
    if zeros-needed > 0 {
      for _ in range(zeros-needed) {
        decimal-part-initial = decimal-part-initial + "0"
      }
    }
  } else {
    decimal-part-initial = ""
  }
  
  // Get locale-specific formatting (or use EPC format)
  let formatting = if epc-format {
    (decimal-sep: ".", thousands-sep: "", date-format: get-date-format(region))
  } else {
    get-locale-formatting(locale, region)
  }
  
  // Get integer and decimal parts (before applying thousands separators)
  let integer-part = integer-part-initial
  let decimal-part = decimal-part-initial
  
  // Add thousands separators to integer part (skip if EPC format)
  if not epc-format {
    integer-part = add-thousands-separators(integer-part, formatting.thousands-sep)
  }
  
  // Reconstruct number string
  number-str = integer-part + (if decimal-part != "" { formatting.decimal-sep + decimal-part } else { "" })
  
  // Add currency symbol
  if show-symbol and not epc-format {
    let symbol = curr-config.symbol
    let placement = curr-config.placement
    if placement == "prefix" {
      number-str = symbol + (if symbol != "CHF" { " " } else { "" }) + number-str
    } else {
      number-str = number-str + " " + symbol
    }
  }
  
  number-str
}
