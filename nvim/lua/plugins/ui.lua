local M = {}

function M.lualine()
    _G.debug_lualine = {}
    require("lualine").setup {
        sections = {
            lualine_b = {
                function()
                    return [[%f %m]]
                end,
            },
            lualine_y = {
                function()
                    local branch = vim.fn["gina#component#repo#branch"]()
                    local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
                    if branch == "" then
                        return cwd
                    else
                        return cwd .. " │ " .. vim.fn["gina#component#repo#branch"]()
                    end
                end,
            },
            lualine_z = {
                function()
                    local n = #tostring(vim.fn.line "$")
                    n = math.max(n, 3)
                    return "%" .. n .. [[l/%-3L:%-2c]]
                end,
            },
        },
        options = {
            theme = "everforest",
            section_separators = { "", "" },
            component_separators = { "", "" },
            globalstatus = true,
            refresh = {
                statusline = 10000,
                -- statusline = 1000,
                tabline = 10000,
                winbar = 10000,
            },
        },
    }
end

function M.oil()
    require("oil").setup {
        default_file_explorer = true,
        columns = {
            "icon",
        },
        view_options = {
            show_hidden = true,
        },
    }

    vim.keymap.set("n", "<Leader>e", "<Cmd>Oil<CR>", { desc = "Open parent directory" })
end

function M.everforest()
    local wezterm_color_scheme = vim.env.WEZTERM_COLOR_SCHEME or ""
    if wezterm_color_scheme == "" then
        return
    end

    if wezterm_color_scheme:find("Everforest", 1, true) == nil then
        return
    end

    if wezterm_color_scheme:find("Hard", 1, true) then
        vim.g.everforest_background = "hard"
    elseif wezterm_color_scheme:find("Medium", 1, true) then
        vim.g.everforest_background = "medium"
    elseif wezterm_color_scheme:find("Soft", 1, true) then
        vim.g.everforest_background = "soft"
    end
end

function M.telescope()
    local actions = require "telescope.actions"
    local telescope = require "telescope"

    telescope.setup {
        defaults = {
            vimgrep_arguments = {
                "rg",
                "--line-number",
                "--no-heading",
                "--color=never",
                "--hidden",
                "--with-filename",
                "--column",
                -- '--smart-case'
            },
            prompt_prefix = "𝜻",
            find_command = {
                "rg",
                "--ignore",
                "--hidden",
                "--files",
            },
            mappings = {
                n = {
                    ["<Esc>"] = actions.close,
                },
            },
        },
    }

    pcall(telescope.load_extension, "bibtex")

    vim.keymap.set("n", "so", "<Cmd>Telescope git_files<cr>", { desc = "Telescope git files" })
    vim.keymap.set("n", "sO", "<Cmd>Telescope find_files<cr>", { desc = "Telescope find files" })
    vim.keymap.set("n", "sb", "<Cmd>Telescope buffers<cr>", { desc = "Telescope buffers" })
    vim.keymap.set("n", "sg", "<Cmd>Telescope live_grep<cr>", { desc = "Telescope live grep" })
    vim.keymap.set("n", "tq", "<Cmd>Telescope quickfix<cr>", { desc = "Telescope quickfix" })
end

return M
