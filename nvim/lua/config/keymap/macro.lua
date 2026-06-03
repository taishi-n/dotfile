local util = require "utils.util"

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

vim.keymap.set("n", "Q", keymap_toggle_macro, { expr = true, desc = "Start or stop macro recording" })
vim.keymap.set("n", "<C-q>", function()
    if vim.fn.reg_recording() == "" then
        return keymap_play_macro()
    else
        return keymap_cancel_macro()
    end
end, { expr = true, desc = "Play or cancel macro recording" })
vim.keymap.set("n", "@", "<Nop>", { desc = "Disable macro replay prefix" })
vim.keymap.set("n", "@:", "@:", { desc = "Repeat last ex command" })
