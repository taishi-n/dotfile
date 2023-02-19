-- vim:fdm=marker:fmr=§§,■■

local util = require "rc.util"

-- §§1 表示設定

util.autocmd_vimrc "StdinReadPost" {
    command = "set nomodified",
}

util.autocmd_vimrc { "WinLeave", "FocusLost", "InsertEnter" } {
    desc = "temporal attention の設定初期化",
    callback = function()
        vim.opt_local.cursorline = false
        vim.opt_local.cursorcolumn = false
        vim.opt_local.relativenumber = false
    end,
}

util.autocmd_vimrc "Syntax" {
    desc = "minlines と maxlines の設定",
    command = "syn sync minlines=500 maxlines=1000",
}

util.autocmd_vimrc { "VimEnter", "WinEnter" } {
    desc = "全角スペースハイライト (https://qiita.com/tmsanrinsha/items/d6c11f2b7788eb24c776)",
    command = [[
        highlight link UnicodeSpaces Error
        match UnicodeSpaces /[\u180E\u2000-\u200A\u2028\u2029\u202F\u205F\u3000]/
    ]],
}

util.autocmd_vimrc "ColorScheme" {
    desc = "UnicodeSpaces を Error 色にハイライトする",
    command = "highlight link UnicodeSpaces Error",
}

util.autocmd_vimrc "VimResized" {
    desc = "ウィンドウの画面幅を揃える",
    command = [[Normal! <C-w>=]],
}


-- §§1 editor の機能

util.autocmd_vimrc "InsertLeave" {
    desc = "挿入モードを抜けたら paste モードを off にする",
    callback = function()
        vim.o.paste = false
    end,
}

local function auto_mkdir()
    local dir = vim.fn.expand("<afile>:p:h", nil, nil)
    local is_empty = vim.fn.empty(dir) == 1
    local is_url = vim.fn.match(dir, [[^\w\+://]]) >= 0
    local is_directory = vim.fn.isdirectory(dir) == 1
    if is_empty or is_url or is_directory then
        return
    end
    if util.to_bool(vim.v.cmdbang) then
        vim.fn.mkdir(dir, "p")
        return
    end

    vim.fn.inputsave()
    vim.cmd [[echohl Question]]
    local result = vim.ui.input({
        prompt = ([=["%s" does not exist. Create? [y/N]]=]):format(dir),
        -- highlight = "Question",
        default = "",
    }, function(result)
        if result == "y" then
            vim.fn.mkdir(dir, "p")
        end
    end)
    vim.fn.inputrestore()
end

util.autocmd_vimrc "BufWritePre" {
    desc = "保存時に必要があれば自動で mkdir する",
    callback = auto_mkdir,
}

util.autocmd_vimrc "TextYankPost" {
    desc = "無名レジスタへの yank 操作のときのみ， + レジスタに内容を移す（delete のときはしない）",
    callback = function()
        local event = vim.v.event
        if event.operator == "y" and event.regname == "" then
            vim.fn.setreg("+", vim.fn.getreg('"', nil, nil))
        end
    end,
}

util.autocmd_vimrc "VimEnter" {
    desc = "マクロ用のレジスタを消去",
    callback = function()
        vim.fn.setreg("q", "")
    end,
}

util.autocmd_vimrc "QuickfixCmdPost" {
    pattern = { "l*" },
    command = "lwin",
}

util.autocmd_vimrc "QuickfixCmdPost" {
    pattern = { "[^l]*" },
    command = "cwin",
}

util.autocmd_vimrc "CmdwinEnter" {
    callback = function(meta)
        local buf = meta.buf
        vim.wo.number = false
        vim.wo.relativenumber = false
        vim.wo.signcolumn = "no"
        vim.wo.foldcolumn = "0"
        vim.api.nvim_buf_set_keymap(buf, "n", "<C-f>", "<C-f>", {})
        vim.api.nvim_buf_set_keymap(buf, "n", "<C-u>", "<C-u>", {})
        vim.api.nvim_buf_set_keymap(buf, "n", "<C-b>", "<C-b>", {})
        vim.api.nvim_buf_set_keymap(buf, "n", "<C-d>", "<C-d>", {})
        vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":q<CR>", {})
        vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "<CR>", { nowait = true })
    end,
}
