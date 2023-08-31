local lspconfig = require("lspconfig")

-- mason = false, -- set to false if you don't want this server to be installed with mason
return {
	bashls = {},
	clangd = {
		mason = false,
		filetypes = { "c", "cpp", "cc", "cxx", "objc", "objcpp", "cuda"  },
		cmd = {
			"clangd",
			"--print-options",
			"--background-index",
			"--all-scopes-completion",
			"--header-insertion-decorators",
			"--header-insertion=iwyu",
			"--completion-style=detailed",
			"-j=4",
		},
	},
	cmake = {},
	cssls = {},
	dartls = {},
	dockerls = {},
	emmet_ls = {},
	gopls = {},
	html = {},
	jdtls = {},
	jsonls = {},
	lua_ls = {},
	pyright = {},
	rust_analyzer = {},
	solargraph = {},
	vimls = {},
	volar = {},
	yamlls = {
		settings = {
			yaml = {
				keyOrdering = false,
			},
		},
	},

	denols = {
		mason = false,
		root_dir = lspconfig.util.root_pattern("deno.json"),
		single_file_support = false,
		init_options = {
			lint = true,
			unstable = true,
		},
	},
	tsserver = {
		mason = false,
		root_dir = lspconfig.util.root_pattern("package.json"),
		single_file_support = false,
	},
}
