vim.o.completeopt = "menu,menuone,noselect,noinsert"

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup {
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
  preselect = cmp.PreselectMode.Item,
	mapping = {
		['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false }),
		['<C-y>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-f>'] = cmp.mapping.scroll_docs(-4),
		['<C-b>'] = cmp.mapping.scroll_docs(4),
		['<C-q>'] = cmp.mapping.close(),

		['<Down>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
			else
				fallback()
			end
		end, { "i", "s" }),

		['<Up>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
			else
				fallback()
			end
		end, { "i", "s" }),

		['<Tab>'] = cmp.mapping(function(callback)
			if luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			elseif cmp.visible() then
				cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
			else
				callback()
			end
		end, { "i", "s" }),

		['<S-Tab>'] = cmp.mapping(function(callback)
			if luasnip.jumpable(-1) then
				luasnip.jump(-1)
			elseif cmp.visible() then
				cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
			else
				callback()
			end
		end, { "i", "s" }),
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp", priority = 100 },
		{ name = "path", priority = 100 },
		{ name = "nvim_lsp_signature_help", priority = 80 },
		{ name = "nvim_lua", priority = 50 },
		{ name = "emoji", priority = 50 },
		{ name = "luasnip", priority = 40 },
	}, {
		{ name = "buffer", priority = 50 },
	}),
	formatting = {
		format = require("lspkind").cmp_format({
			with_text = true,
			menu = {
				buffer = "[Buffer]",
				nvim_lsp = "[LSP]",
				cmp_tabnine = "[TabNine]",
				luasnip = "[LuaSnip]",
				nvim_lua = "[Lua]",
				latex_symbols = "[LaTeX]",
				path = "[Path]",
				omni = "[Omni]",
				spell = "[Spell]",
				emoji = "[Emoji]",
				calc = "[Calc]",
				treesitter = "[TS]",
				dictionary = "[Dictionary]",
				mocword = "[mocword]",
			},
		}),
	},
}


-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})
-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	})
})


-- autopair
do
	cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done({ map_char = { tex = "" } }))
	local autopairs = require('nvim-autopairs')
	local Rule = require('nvim-autopairs.rule')
	autopairs.setup{}
	autopairs.add_rule(Rule('"""', '"""', 'nim'))
	autopairs.add_rule(Rule('{.', '.', 'nim'))
end
