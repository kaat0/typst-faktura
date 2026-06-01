#import "locales.typ": default-lang, default-region

#let get-text-block(
  block-type,
  variant: "default",
  lang: default-lang,
  region: default-region,
  locale: none,
  placeholders: (:)
) = {
  // Construct locale identifier (e.g., "de-DE")
  let locale-id = if locale != none {
    locale
  } else {
    lang + "-" + region
  }
  
  // Load YAML file for the locale
  let locale-path = "../locales/" + locale-id + ".yaml"
  let locale-data = yaml(locale-path)
  
  // Extract text-block from labels section
  let text-value = if "labels" in locale-data and block-type in locale-data.labels {
    locale-data.labels.at(block-type)
  } else {
    // Fallback: try text_blocks section if it exists
    if "text_blocks" in locale-data and block-type in locale-data.text_blocks {
      locale-data.text_blocks.at(block-type)
    } else {
      panic("Text block '" + block-type + "' not found in locale file: " + locale-path)
    }
  }
  
  // Replace placeholders if provided
  let result = text-value
  for (key, value) in placeholders {
    result = result.replace(key, str(value))
  }
  
  // Return as content
  [#result]
}

