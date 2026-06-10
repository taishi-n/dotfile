function toText(value) {
  if (value == null) {
    return ""
  }
  return String(value)
}

function toNumber(value, fallback) {
  const n = Number(value)
  return Number.isFinite(n) ? n : fallback
}

export function formatter(results) {
  for (const result of results ?? []) {
    const output = {
      lineNumber: toNumber(result.lineNumber, 1),
      columnNumber: toNumber(result.columnNumber, 1),
      severity: toText(result.severity) || "error",
      ruleName: toText(result.ruleName ?? result.ruleNames?.[0] ?? "markdownlint"),
      ruleDescription: toText(result.ruleDescription ?? result.description ?? "markdownlint violation"),
      errorDetail: toText(result.errorDetail ?? result.errorContext ?? ""),
    }
    console.log(JSON.stringify(output))
  }
}

export default formatter
