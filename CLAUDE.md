# Claude Development Notes for blockr.fredr

> **Developer guides:** [dev/README.md](dev/README.md)

## Must Follow

1. Use `bquote()` for expressions (not `parse(text = glue::glue())`)
2. Add optional fields to `allow_empty_state = c("frequency", ...)`
3. Include ALL constructor params in state list
4. Use `"(none)"` for optional parameters (consistent with blockr.ggplot)
5. Never add `Author:` or `Maintainer:` to DESCRIPTION

## Common Fixes

- Block won't render → Add to `allow_empty_state`
- State initialization error → Check that optional params use `"(none)"` not `""`
- Expression includes unwanted params → Check `!= "(none)"` before including in expression

## Patterns

### Optional Parameters

```r
# UI
selectInput(
  choices = c("Default" = "(none)", "Option 1" = "val1", ...),
  selected = if (is.null(param)) "(none)" else param
)

# Server
r_param <- reactiveVal(if (is.null(param)) "(none)" else param)

# Expression
if (!is.null(param) && param != "(none)") {
  # Include param in expression
} else {
  # Omit param from expression
}

# Block constructor
new_data_block(
  ...,
  allow_empty_state = c("frequency"),  # Add optional params here
  ...
)
```

## More

See [dev/README.md](dev/README.md) for complete documentation.
