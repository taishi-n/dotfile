local M = {}

function M.gitsigns()
    require("gitsigns").setup {
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns
            local function map(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
            end

            vim.keymap.set("n", "]c", function()
                if vim.wo.diff then
                    return "]c"
                end
                vim.schedule(gs.next_hunk)
                return "<Ignore>"
            end, { buffer = bufnr, desc = "Next git hunk", expr = true })
            vim.keymap.set("n", "[c", function()
                if vim.wo.diff then
                    return "[c"
                end
                vim.schedule(gs.prev_hunk)
                return "<Ignore>"
            end, { buffer = bufnr, desc = "Previous git hunk", expr = true })

            map({ "n", "v" }, "<Leader>gs", gs.stage_hunk, "Stage git hunk")
            map({ "n", "v" }, "<Leader>gr", gs.reset_hunk, "Reset git hunk")
            map("n", "<Leader>gS", gs.stage_buffer, "Stage buffer")
            map("n", "<Leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
            map("n", "<Leader>gR", gs.reset_buffer, "Reset buffer")
            map("n", "<Leader>gp", gs.preview_hunk, "Preview git hunk")
            map("n", "<Leader>gb", function()
                gs.blame_line { full = true }
            end, "Blame line")
            map("n", "<Leader>gd", gs.diffthis, "Diff against index")
            map("n", "<Leader>gD", function()
                gs.diffthis "~"
            end, "Diff against previous commit")
            map("n", "<Leader>gt", gs.toggle_current_line_blame, "Toggle line blame")
        end,
    }
end

return M
