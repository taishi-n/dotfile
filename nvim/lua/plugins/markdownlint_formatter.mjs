export default function markdownlintFormatter(options) {
    const { logMessage, results = [] } = options
    for (const result of results) {
        logMessage(
            JSON.stringify({
                fileName: result.fileName,
                lineNumber: result.lineNumber,
                columnNumber: result.columnNumber ?? null,
                ruleName: result.ruleName ?? result.ruleNames?.join("/") ?? "markdownlint",
                ruleDescription: result.ruleDescription ?? "markdownlint violation",
                errorDetail: result.errorDetail ?? result.errorContext ?? "",
                severity: result.severity ?? "error",
            })
        )
    }
}
