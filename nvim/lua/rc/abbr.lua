vim.cmd [==[
    cnoreabbrev <expr> w (getcmdtype() .. getcmdline() ==# ":'<,'>w") ? "\<C-u>w" : "w"
    cnoreabbrev <expr> w2 (getcmdtype() .. getcmdline() ==# ":w2") ? "w" : "w2"
    cnoreabbrev <expr> w] (getcmdtype() .. getcmdline() ==# ":w]") ? "w" : "w]"
]==]

---@alias abbrrule {from: string, to: string, prepose?: string, prepose_nospace?: string}

---@param rules abbrrule[]
local function make_abbrev(rules)
    -- 文字列のキーに対して常に0のvalue を格納することで、文字列の hashset を実現。
    ---@type table<string, abbrrule[]>
    local abbr_dict_rule = {}

    for _, rule in ipairs(rules) do
        local key = rule.from
        if abbr_dict_rule[key] == nil then
            abbr_dict_rule[key] = {}
        end
        table.insert(abbr_dict_rule[key], rule)
    end

    for key, rules_with_key in pairs(abbr_dict_rule) do
        ---コマンドラインが特定の内容だったら、それに対応する値を返す。
        ---@type table<string, string>
        local d = {}

        for _, rule in ipairs(rules_with_key) do
            local required_pattern = rule.from
            if rule.prepose_nospace ~= nil then
                required_pattern = rule.prepose_nospace .. required_pattern
            elseif rule.prepose ~= nil then
                required_pattern = rule.prepose .. " " .. required_pattern
            end
            d[required_pattern] = rule.to
        end

        vim.cmd(([[
        cnoreabbrev <expr> %s (getcmdtype()==# ":") ? get(%s, getcmdline(), %s) : %s
        ]]):format(key, vim.fn.string(d), vim.fn.string(key), vim.fn.string(key)))
    end
end

make_abbrev {
    { from = "c",                to = "CocCommand" },
    { from = "cc",               to = "CocConfig" },
    { from = "cl",               to = "CocList" },
    { from = "clc",              to = "CocLocalConfig" },
    { from = "cq",               to = "CocQuickfix" },
    { from = "cr",               to = "CocRestart" },
    { from = "fmt",              to = 'call CocActionAsync("format")' },
    { from = "open",             to = "!open" },
    { from = "ssf",              to = "syntax sync fromstart" },
    { from = "sfs",              to = "setfiletype satysfi" },
    { prepose = "CocCommand",    from = "s",                          to = "snippets.editSnippets" },
    { prepose = "CocCommand",    from = "r",                          to = "rust-analyzer.reload" },
    { prepose = "CocList",       from = "e",                          to = "extensions" },
    { prepose_nospace = "'<,'>", from = "m",                          to = "MakeTable" },
    { from = "isort",            to = "!isort --profile black %" },
}
