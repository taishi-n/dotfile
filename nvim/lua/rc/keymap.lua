-- vim:fdm=marker:fmr=--\ Section,■■
-- キーマッピング関連。
-- そのキーマップが適切に動くようにするための関数や autocmd もここに載せる。

local M = {}

local util = require "rc.util"

-- local
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gj")
vim.keymap.set("v", "j", "gj")
vim.keymap.set("v", "k", "gj")
vim.keymap.set("n", "<Tab>", "%")
vim.keymap.set("v", "<Tab>", "%")
vim.keymap.set("n", "Y", "y$")
vim.keymap.set('n', 's', '<NOP>', { noremap = true }) -- for telescope
vim.keymap.set("n", "Y", "y$")

vim.keymap.set("n", "Z", function()
    vim.opt_local.wrap = not vim.opt_local.wrap:get()
end, { silent = true, nowait = true })

vim.api.nvim_create_augroup("vimrc_temporal", { clear = true })

function M.temporal_attention()
    vim.opt_local.cursorline = true
    vim.opt_local.cursorcolumn = true
    vim.api.nvim_create_autocmd("CursorMoved", {
        once = true,
        group = "vimrc_temporal",
        callback = function()
            vim.opt_local.cursorline = false
            vim.opt_local.cursorcolumn = false
        end,
    })
end

function M.temporal_relnum()
    vim.opt_local.relativenumber = true
    vim.api.nvim_create_autocmd("CursorMoved", {
        once = true,
        group = "vimrc_temporal",
        callback = function()
            vim.opt_local.relativenumber = false
        end,
    })
end

function M.expr_temporal_attention()
    M.temporal_attention()
    M.temporal_relnum()
    return ""
end

-- Section1 input Japanese character

vim.keymap.set({ "n", "x", "o" }, "fj", "f<C-k>j", {})
vim.keymap.set({ "x", "o" }, "tj", "t<C-k>j", {})
vim.keymap.set({ "n", "x", "o" }, "Fj", "F<C-k>j", {})
vim.keymap.set({ "x", "o" }, "Tj", "T<C-k>j", {})

vim.fn.digraph_setlist {
    -- これを設定することで， fjj を本来の fj と同じ効果にできる．
    { "jj", "j" },
    -- カッコ
    { "j(", "（" },
    { "j)", "）" },
    { "j[", "「" },
    { "j]", "」" },
    { "j{", "『" },
    { "j}", "』" },
    { "j<", "【" },
    { "j>", "】" },

    -- 句読点
    { "j,", "，" },
    { "j.", "．" },
    { "j!", "！" },
    { "j?", "？" },
    { "j:", "：" },

    -- その他の記号
    { "j~", "〜" },
    { "j/", "・" },
    { "js", "␣" },
    { "j ", "　" },
    { "zs", "​" },
}

--- 面倒がらずにちゃんと <C-w> 使おうよ…と思ったがやっぱり面倒くさい
for _, char in ipairs {
    "x", -- exchange! 知らなかった
    "h",
    "j",
    "k",
    "l",
    "H",
    "J",
    "K",
    "L",
    "=",
} do
    vim.keymap.set("n", "s" .. char, "<C-w>" .. char, {})
end

-- Section1 operator/text editing

-- どうせ空行1行なんて put するようなもんじゃないし、空行で上書きされるの嫌よね
vim.keymap.set("n", "dd", function()
    if vim.v.count1 == 1 and vim.v.register == [["]] and vim.fn.getline "." == "" then
        return [["_dd]]
    else
        return "dd"
    end
end, { expr = true })

vim.keymap.set("i", "<C-r><C-r>", [[<C-g>u<C-r>"]], {})
vim.keymap.set("i", "<C-r><CR>", [[<C-g>u<C-r>0]], {})
vim.keymap.set("i", "<C-r><Space>", [[<C-g>u<C-r>+]], {})
vim.keymap.set("c", "<C-r><C-r>", [[<C-r>"]], {})
vim.keymap.set("c", "<C-r><CR>", [[<C-r>0]], {})
vim.keymap.set("c", "<C-r><Space>", [[<C-r>+]], {})

vim.keymap.set("n", "<Space>p", util.cmdcr "put +", {})
vim.keymap.set("n", "<Space>P", util.cmdcr "put! +", {})

-- Section1 motion/text object

-- Section2 charwise motion

-- smart home/end
vim.keymap.set({ "n", "x" }, "<Space>h", function()
    local str_before_cursor = vim.fn.strpart(vim.fn.getline ".", 0, vim.fn.col "." - 1)
    local move_cmd
    -- カーソル前がインデントしかないかどうかでコマンドを変える
    if vim.regex([[^\s*$]]):match_str(str_before_cursor) then
        move_cmd = "0"
    else
        move_cmd = "^"
    end

    util.motion_autoselect {
        function()
            vim.cmd("normal! g" .. move_cmd)
        end,
        function()
            vim.cmd("normal! " .. move_cmd)
        end,
    }
end)
vim.keymap.set("o", "<Space>h", "^")

-- smart end
vim.keymap.set("n", "<Space>l", function()
    util.motion_autoselect {
        function()
            vim.cmd "normal! g$"
        end,
        function()
            vim.cmd "normal! $"
        end,
    }
end)

-- vim.keymap.set("x", "<Space>l", "$h")
-- VISUAL モードにおいても基本的には行末移動。ただし、
-- 矩形選択時かつカーソルが既に行末にある時に限り、
-- 選択した行範囲にあるすべての行末を覆えるような長方形とする。
vim.keymap.set("x", "<Space>l", function()
    local cursor = vim.fn.getcurpos()
    local lnum_cursor = cursor[2]
    local col_cursor = cursor[3]
    local line_cursor = vim.fn.getline(lnum_cursor)

    -- 行末移動
    vim.fn.cursor { lnum_cursor, #line_cursor }
    local new_col_cursor = vim.fn.getcurpos()[3]
    -- 行末移動によりカーソルの位置が変わっていたらそこで処理を終了する
    if col_cursor ~= new_col_cursor then
        return
    end

    -- 矩形選択、かつすでにカーソルが既に行末にある場合
    if vim.fn.mode(1) == "\u{16}" then
        local other_end = vim.fn.getpos "v"
        local lnum_other = other_end[2]
        local lnum_start = util.ifexpr(lnum_cursor > lnum_other, lnum_other, lnum_cursor)
        local lnum_end = util.ifexpr(lnum_cursor > lnum_other, lnum_cursor, lnum_other)
        local lines = vim.fn.getline(lnum_start, lnum_end)
        local dispwidth_max = 0
        for _, line in ipairs(lines) do
            local dispwidth = vim.fn.strdisplaywidth(line)
            if dispwidth_max < dispwidth then
                dispwidth_max = dispwidth
            end
        end
        local dispwidth_cursor = vim.fn.strdisplaywidth(vim.fn.getline(lnum_cursor))
        vim.pretty_print { max = dispwidth_max, cur = dispwidth_cursor }
        if dispwidth_max > dispwidth_cursor then
            vim.pretty_print { #line_cursor, dispwidth_max - dispwidth_cursor }
            vim.fn.cursor { lnum_cursor, #line_cursor, dispwidth_max - dispwidth_cursor, dispwidth_max }
        end
    end
end)

vim.keymap.set("o", "u", "t_")
vim.keymap.set("o", "U", function()
    for _ = 1, vim.v.count1, 1 do
        vim.fn.search("[A-Z]", "", vim.fn.line ".")
    end
end)

vim.keymap.set({ "n", "x", "o" }, "m)", "])")
vim.keymap.set({ "n", "x", "o" }, "m}", "]}")
vim.keymap.set("x", "m]", "i]o``")
vim.keymap.set("x", "m(", "i)``")
vim.keymap.set("x", "m{", "i}``")
vim.keymap.set("x", "m[", "i]``")

vim.keymap.set("n", "dm]", "vi]o``d")
vim.keymap.set("n", "dm(", "vi)``d")
vim.keymap.set("n", "dm{", "vi}``d")
vim.keymap.set("n", "dm[", "vi]``d")

vim.keymap.set("n", "cm]", "vi]o``c")
vim.keymap.set("n", "cm(", "vi)``c")
vim.keymap.set("n", "cm{", "vi}``c")
vim.keymap.set("n", "cm[", "vi]``c")

vim.keymap.set({ "x", "o" }, [[a']], [[2i']])
vim.keymap.set({ "x", "o" }, [[a"]], [[2i"]])
vim.keymap.set({ "x", "o" }, [[a`]], [[2i`]])
vim.keymap.set({ "x", "o" }, [[m']], [[a']])
vim.keymap.set({ "x", "o" }, [[m"]], [[a"]])
vim.keymap.set({ "x", "o" }, [[m`]], [[a`]])

-- Section2 linewise motion
vim.keymap.set("n", "<Space>m", "<Plug>(matchup-%)")

vim.keymap.set("n", "j", function()
    if vim.v.count == 0 then
        return "gj"
    else
        return "j"
    end
end, { expr = true })
vim.keymap.set("n", "k", function()
    if vim.v.count == 0 then
        return "gk"
    else
        return "k"
    end
end, { expr = true })
vim.keymap.set("x", "j", function()
    if vim.v.count == 0 and vim.fn.mode(0) == "v" then
        return "gj"
    else
        return "j"
    end
end, { expr = true })
vim.keymap.set("x", "k", function()
    if vim.v.count == 0 and vim.fn.mode(0) == "v" then
        return "gk"
    else
        return "k"
    end
end, { expr = true })

-- Vertical WORD (vWORD) 単位での移動
_G.vimrc.state.par_motion_continuous = false
util.autocmd_vimrc "CursorMoved" {
    callback = function()
        _G.vimrc.state.par_motion_continuous = false
    end,
}

-- <C-j>/<C-k> は基本的に `{` / `}` モーションと同じだが、
-- 連続した <C-j>/<C-k> による移動では jumplist が更新されない
function _G.vimrc.motion.smart_par(forward)
    vim.cmd(table.concat {
        util.ifexpr(_G.vimrc.state.par_motion_continuous, "keepjumps ", ""),
        "normal! ",
        tostring(vim.v.count1),
        util.ifexpr(forward, "}", "{"),
    })
end

vim.keymap.set(
    { "n", "x", "o" },
    "<C-j>",
    util.cmdcr "call v:lua.vimrc.motion.smart_par(v:true)"
    .. util.cmdcr "lua _G.vimrc.state.par_motion_continuous = true"
)
vim.keymap.set(
    { "n", "x", "o" },
    "<C-k>",
    util.cmdcr "call v:lua.vimrc.motion.smart_par(v:false)"
    .. util.cmdcr "lua _G.vimrc.state.par_motion_continuous = true"
)

-- vertical f motion
-- TODO: プラグイン化したくなってきたのう
local vertical_f_char
local vertical_f_pattern

local ns_id = vim.api.nvim_create_namespace "verticalf"

local function vertical_f(ctx, forward)
    local pattern
    if forward then
        pattern = [[^\%>.l\s*\zs]]
    else
        pattern = [[^\%<.l\s*\zs]]
    end

    local delta = util.ifexpr(forward, 1, -1)
    local start_line = vim.fn.line "." + delta
    local end_line = vim.fn.line(util.ifexpr(forward, "w$", "w0"))
    local chars = {}
    for line = start_line, end_line, delta do
        ---@type string
        local linestr = vim.fn.getline(line)
        if #linestr ~= 0 then
            local _, e = linestr:find "^%s*"
            local char = linestr:sub(e + 1, e + 1)

            if chars[char] == nil then
                chars[char] = 1
            else
                chars[char] = chars[char] + 1
            end
            if chars[char] == ctx.count1 then
                vim.api.nvim_buf_add_highlight(0, ns_id, "VisualBlue", line - 1, e, e + 1)
            end
        end
    end

    vim.opt_local.cursorline = true
    vim.cmd "redraw"
    local char
    if ctx.repeated then
        char = vertical_f_char
    else
        char = vim.fn.nr2char(vim.fn.getchar())
        vertical_f_char = char
    end

    vertical_f_pattern = pattern .. [[\V]] .. vim.fn.escape(char, [[\/]])

    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    vim.opt_local.cursorline = false

    local flag = "W"
    if not forward then
        flag = flag .. "b"
    end
    for _ = 1, ctx.count1, 1 do
        vim.fn.search(vertical_f_pattern, flag)
    end
end

local function get_initial_ctx()
    return {
        repeated = false,
        count = vim.v.count,
        count1 = vim.v.count1,
        set_count = vim.v.count == vim.v.count1,
    }
end

-- Section1 Macros

-- マクロの記録レジスタは "aq のような一般のレジスタを指定するのと同様の
-- インターフェースで変更するようにし、デフォルトレジスタを q とする。
-- マクロ自己再帰呼出しによるループや、マクロの中でマクロを呼び出すことは簡単にはできないようにしてある。
-- （もちろんレジスタを直に書き換えれば可能）
-- デフォルトのレジスタ @q は Vim の開始ごとに初期化される。

local function keymap_toggle_macro()
    if util.to_bool(vim.fn.reg_recording()) then
        -- 既に記録中の時は止める
        return "q"
    end
    -- 無名レジスタには格納できないようにする & デフォルトを q にする

    local register = vim.v.register
    if register == [["]] then
        register = "q"
    end
    return "q" .. register
end

_G.vimrc.state.last_played_macro_register = "q"

local function keymap_play_macro()
    -- 無名レジスタには格納できないようにする
    -- & デフォルトを前回再生したマクロにする
    local register = vim.v.register
    if register == [["]] then
        register = _G.vimrc.state.last_played_macro_register
    end
    _G.vimrc.state.last_played_macro_register = register
    if vim.fn.getreg(register, nil, nil) == "" then
        vim.api.nvim_echo({ { ("Register @%s is empty."):format(register), "Error" } }, true, {})
        return ""
    end

    vim.api.nvim_echo({ { ("Playing macro: @%s"):format(register), "Error" } }, false, {})
    return "@" .. register
end

local function keymap_cancel_macro()
    local register = vim.fn.reg_recording()
    if register == "" then
        return ""
    end
    return table.concat {
        -- 現在のレジスタに入っているコマンド列を一旦 reg_content に退避
        util.cmdcr(("let reg_content = @%s"):format(register)),
        -- マクロの記録を停止
        "q",
        -- 対象としていたレジスタの中身を先程退避したものに入れ替える
        util.cmdcr(("let @%s = reg_content"):format(register)),
        -- キャンセルした旨を表示
        util.cmdcr(("echo 'Recording cancelled: @%s'"):format(register)),
    }
end

vim.keymap.set("n", "Q", keymap_toggle_macro, { expr = true })
vim.keymap.set("n", "<C-q>", function()
    if vim.fn.reg_recording() == "" then
        return keymap_play_macro()
    else
        return keymap_cancel_macro()
    end
end, { expr = true })
vim.keymap.set("n", "@", "<Nop>")
vim.keymap.set("n", "@:", "@:")

-- Section1 特殊キー
for i = 1, 12, 1 do
    vim.keymap.set({ "n", "x", "o" }, ("<F%s>"):format(i), "<Nop>")
end
vim.keymap.set({ "n", "x", "o", "i", "c", "s" }, "<M-F1>", "<Nop>")
vim.keymap.set({ "i", "c", "s" }, "<F1>", "<Nop>")
vim.keymap.set({ "n", "x", "o" }, "<Space>", "<Nop>")
vim.keymap.set({ "n", "x", "o" }, "<CR>", "<Nop>")

-- Section1 その他
vim.keymap.set("n", "<C-h>", "g;")
vim.keymap.set("n", "<C-g>", "g,")

vim.keymap.set("v", "<C-a>", "<C-a>gv")
vim.keymap.set("v", "<C-x>", "<C-x>gv")

-- 直前の単語の upper/lower case を入れ替える。
-- vimrc 読書会より。
-- thanks to thinca
vim.keymap.set("i", "<C-l>", "<Esc>g~vbgi")

vim.keymap.set("n", "gf", "gF")

vim.keymap.set({ "i", "c" }, "<C-v>u", "<C-r>=nr2char(0x)<Left>")

-- https://github.com/ompugao/vim-bundle/blob/074e7b22320ad4bfba4da5516e53b498ace35a89/vimrc
vim.keymap.set("v", "I", function()
    return util.ifexpr(vim.fn.mode(0) == "V", "<C-v>0o$I", "I")
end, { expr = true })
vim.keymap.set("v", "A", function()
    return util.ifexpr(vim.fn.mode(0) == "V", "<C-v>0o$A", "A")
end, { expr = true })

return M
