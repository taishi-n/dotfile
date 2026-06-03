-- vim:fdm=marker:fmr=--\ Section,■■
-- キーマッピング関連。
-- そのキーマップが適切に動くようにするための関数や autocmd もここに載せる。

local M = {}

local util = require "utils.util"

-- local
vim.keymap.set("n", "<Tab>", "%", { desc = "Jump to matching pair" })
vim.keymap.set("v", "<Tab>", "%", { desc = "Jump to matching pair" })
vim.keymap.set("n", "Y", "y$", { desc = "Yank to end of line" })
vim.keymap.set("n", "s", "<NOP>", { noremap = true, desc = "Disable s prefix for telescope" }) -- for telescope

vim.keymap.set("n", "Z", function()
    vim.opt_local.wrap = not vim.opt_local.wrap:get()
end, { silent = true, nowait = true, desc = "Toggle line wrap" })

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

vim.keymap.set({ "n", "x", "o" }, "fj", "f<C-k>j", { desc = "Type Japanese digraph with j prefix" })
vim.keymap.set({ "x", "o" }, "tj", "t<C-k>j", { desc = "Type Japanese digraph with t prefix" })
vim.keymap.set({ "n", "x", "o" }, "Fj", "F<C-k>j", { desc = "Type Japanese digraph with F prefix" })
vim.keymap.set({ "x", "o" }, "Tj", "T<C-k>j", { desc = "Type Japanese digraph with T prefix" })

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
    vim.keymap.set("n", "s" .. char, "<C-w>" .. char, { desc = ("Window command s%s"):format(char) })
end

-- Section1 operator/text editing

-- どうせ空行1行なんて put するようなもんじゃないし、空行で上書きされるの嫌よね
vim.keymap.set("n", "dd", function()
    if vim.v.count1 == 1 and vim.v.register == [["]] and vim.fn.getline "." == "" then
        return [["_dd]]
    else
        return "dd"
    end
end, { expr = true, desc = "Delete line without clobbering clipboard on blank line" })

vim.keymap.set("i", "<C-r><C-r>", [[<C-g>u<C-r>"]], { desc = "Insert unnamed register" })
vim.keymap.set("i", "<C-r><CR>", [[<C-g>u<C-r>0]], { desc = "Insert yank register" })
vim.keymap.set("i", "<C-r><Space>", [[<C-g>u<C-r>+]], { desc = "Insert clipboard register" })
vim.keymap.set("c", "<C-r><C-r>", [[<C-r>"]], { desc = "Insert unnamed register" })
vim.keymap.set("c", "<C-r><CR>", [[<C-r>0]], { desc = "Insert yank register" })
vim.keymap.set("c", "<C-r><Space>", [[<C-r>+]], { desc = "Insert clipboard register" })

vim.keymap.set("n", "<Space>p", util.cmdcr "put +", { desc = "Put clipboard after cursor" })
vim.keymap.set("n", "<Space>P", util.cmdcr "put! +", { desc = "Put clipboard before cursor" })

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
end, { desc = "Move to line start" })
vim.keymap.set("o", "<Space>h", "^", { desc = "Move to line start" })

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
end, { desc = "Move to line end" })

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
end, { desc = "Move to line end" })

vim.keymap.set("o", "u", "t_", { desc = "Move to before underscore" })
vim.keymap.set("o", "U", function()
    for _ = 1, vim.v.count1, 1 do
        vim.fn.search("[A-Z]", "", vim.fn.line ".")
    end
end, { desc = "Move to next uppercase letter" })

vim.keymap.set({ "n", "x", "o" }, "m)", "])", { desc = "Jump to matching )" })
vim.keymap.set({ "n", "x", "o" }, "m}", "]}", { desc = "Jump to matching }" })
vim.keymap.set("x", "m]", "i]o``", { desc = "Select inside []" })
vim.keymap.set("x", "m(", "i)``", { desc = "Select inside ()" })
vim.keymap.set("x", "m{", "i}``", { desc = "Select inside {}" })
vim.keymap.set("x", "m[", "i]``", { desc = "Select inside []" })

vim.keymap.set("n", "dm]", "vi]o``d", { desc = "Delete inside []" })
vim.keymap.set("n", "dm(", "vi)``d", { desc = "Delete inside ()" })
vim.keymap.set("n", "dm{", "vi}``d", { desc = "Delete inside {}" })
vim.keymap.set("n", "dm[", "vi]``d", { desc = "Delete inside []" })

vim.keymap.set("n", "cm]", "vi]o``c", { desc = "Change inside []" })
vim.keymap.set("n", "cm(", "vi)``c", { desc = "Change inside ()" })
vim.keymap.set("n", "cm{", "vi}``c", { desc = "Change inside {}" })
vim.keymap.set("n", "cm[", "vi]``c", { desc = "Change inside []" })

vim.keymap.set({ "x", "o" }, [[a']], [[2i']], { desc = "Select quoted text" })
vim.keymap.set({ "x", "o" }, [[a"]], [[2i"]], { desc = "Select quoted text" })
vim.keymap.set({ "x", "o" }, [[a`]], [[2i`]], { desc = "Select quoted text" })
vim.keymap.set({ "x", "o" }, [[m']], [[a']], { desc = "Move to quoted text" })
vim.keymap.set({ "x", "o" }, [[m"]], [[a"]], { desc = "Move to quoted text" })
vim.keymap.set({ "x", "o" }, [[m`]], [[a`]], { desc = "Move to quoted text" })

-- Section2 linewise motion
vim.keymap.set("n", "<Space>m", "<Plug>(matchup-%)", { desc = "Match parentheses" })

vim.keymap.set("n", "j", function()
    if vim.v.count == 0 then
        return "gj"
    else
        return "j"
    end
end, { expr = true, desc = "Move down by screen line" })
vim.keymap.set("n", "k", function()
    if vim.v.count == 0 then
        return "gk"
    else
        return "k"
    end
end, { expr = true, desc = "Move up by screen line" })
vim.keymap.set("x", "j", function()
    if vim.v.count == 0 and vim.fn.mode(0) == "v" then
        return "gj"
    else
        return "j"
    end
end, { expr = true, desc = "Move down by screen line in visual mode" })
vim.keymap.set("x", "k", function()
    if vim.v.count == 0 and vim.fn.mode(0) == "v" then
        return "gk"
    else
        return "k"
    end
end, { expr = true, desc = "Move up by screen line in visual mode" })

-- Paragraph motion
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
    util.cmdcr "call v:lua.vimrc.motion.smart_par(v:true)" .. util.cmdcr "lua _G.vimrc.state.par_motion_continuous = true",
    { desc = "Move down by paragraph" }
)
vim.keymap.set(
    { "n", "x", "o" },
    "<C-k>",
    util.cmdcr "call v:lua.vimrc.motion.smart_par(v:false)" .. util.cmdcr "lua _G.vimrc.state.par_motion_continuous = true",
    { desc = "Move up by paragraph" }
)

require "config.keymap.macro"

-- Section1 特殊キー
for i = 1, 12, 1 do
    vim.keymap.set({ "n", "x", "o" }, ("<F%s>"):format(i), "<Nop>", { desc = "Disable function key" })
end
vim.keymap.set({ "n", "x", "o", "i", "c", "s" }, "<M-F1>", "<Nop>", { desc = "Disable Meta-F1" })
vim.keymap.set({ "i", "c", "s" }, "<F1>", "<Nop>", { desc = "Disable F1" })
vim.keymap.set({ "n", "x", "o" }, "<Space>", "<Nop>", { desc = "Disable Space in normal mode" })
vim.keymap.set({ "n", "x", "o" }, "<CR>", "<Nop>", { desc = "Disable Enter in normal mode" })

-- Section1 その他
vim.keymap.set("n", "<C-h>", "g;", { desc = "Jump to older change" })
vim.keymap.set("n", "<C-g>", "g,", { desc = "Jump to newer change" })

-- 直前の単語の upper/lower case を入れ替える。
-- vimrc 読書会より。
-- thanks to thinca
vim.keymap.set("i", "<C-l>", "<Esc>g~vbgi", { desc = "Swap case of previous word" })

vim.keymap.set("n", "gf", "gF", { desc = "Jump to file path as line number" })

vim.keymap.set({ "i", "c" }, "<C-v>u", "<C-r>=nr2char(0x)<Left>", { desc = "Insert Unicode codepoint" })

-- https://github.com/ompugao/vim-bundle/blob/074e7b22320ad4bfba4da5516e53b498ace35a89/vimrc
vim.keymap.set("v", "I", function()
    return util.ifexpr(vim.fn.mode(0) == "V", "<C-v>0o$I", "I")
end, { expr = true, desc = "Insert at line start in blockwise visual mode" })
vim.keymap.set("v", "A", function()
    return util.ifexpr(vim.fn.mode(0) == "V", "<C-v>0o$A", "A")
end, { expr = true, desc = "Append at line end in blockwise visual mode" })

return M
