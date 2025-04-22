local has_words_before = function()
	if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
		return false
	end
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

return {
	{
		"hrsh7th/nvim-cmp",
		dir = require("lazy-nix-helper").get_plugin_path("nvim-cmp"),
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{ "L3MON4D3/LuaSnip", dir = require("lazy-nix-helper").get_plugin_path("luasnip") },
			{ "saadparwaiz1/cmp_luasnip", dir = require("lazy-nix-helper").get_plugin_path("cmp_luasnip") },

			-- Adds LSP completion capabilities
			{
				"hrsh7th/cmp-nvim-lsp",
				dir = require("lazy-nix-helper").get_plugin_path("cmp-nvim-lsp"),
			},
			{
				"hrsh7th/cmp-nvim-lsp-signature-help",
				dir = require("lazy-nix-helper").get_plugin_path("cmp-nvim-lsp-signature-help"),
			},

			-- Adds a number of user-friendly snippets
			{
				"rafamadriz/friendly-snippets",
				dir = require("lazy-nix-helper").get_plugin_path("friendly-snippets"),
			},
			-- LSP Kind
			{
				"onsails/lspkind.nvim",
				dir = require("lazy-nix-helper").get_plugin_path("lspkind.nvim"),
				config = function()
					local lspkind = require("lspkind")
					lspkind.init({
						symbol_map = {
							Copilot = "",
						},
					})

					vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
				end,
			},
			-- Copilot Compare
			{
				"zbirenbaum/copilot-cmp",
				dir = require("lazy-nix-helper").get_plugin_path("copilot-cmp"),
				config = function()
					require("copilot_cmp").setup()
				end,
			},
		},
		config = function()
			-- [[ Configure nvim-cmp ]]
			-- See `:help cmp`
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()
			luasnip.config.setup({})
			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete({}),
					["<CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					}),
					["<C-z>"] = cmp.mapping(function(fallback)
						if require("copilot.suggestion").is_visible() then
							require("copilot.suggestion").accept()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() and has_words_before() then
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
						elseif luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "nvim_lsp_signature_help" },
					{ name = "copilot", group_index = 2 },
				},
				formatting = {
					format = require("lspkind").cmp_format({
						mode = "symbol",
						max_width = 50,
						symbol_map = { Copilot = "" },
					}),
				},
			})
		end,
	},
}
