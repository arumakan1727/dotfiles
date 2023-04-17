local lspconfig = require("lspconfig")

-- mason = false, -- set to false if you don't want this server to be installed with mason
---@type lspconfig.options
return {
	bashls = {},
	clangd = { mason = false },
	cmake = {},
	cssls = {},
	dartls = {},
	dockerls = {},
	emmet_ls = {},
	gopls = {},
	hls = {},
	html = {},
	jdtls = {},
	jsonls = {},
	lua_ls = {},
	nimls = {},
	ocamllsp = {},
	phpactor = {},
	pyright = { mason = false },
	rust_analyzer = {},
	solargraph = {},
	vimls = {},
	volar = {},
	yamlls = {},

	denols = {
		root_dir = lspconfig.util.root_pattern("deno.json"),
		single_file_support = false,
		init_options = {
			lint = true,
			unstable = true,
		},
	},
	tsserver = {
		root_dir = lspconfig.util.root_pattern("package.json"),
		single_file_support = false,
	},
}
