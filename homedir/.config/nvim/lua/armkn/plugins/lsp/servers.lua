local lspconfig = require("lspconfig")

---@type lspconfig.options
return {
	bashls = {},
	clangd = {},
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
	pyright = {},
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
