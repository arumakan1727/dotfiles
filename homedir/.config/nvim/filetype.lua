vim.filetype.add({
	extension = {
		bnf = "ebnf",
		ebnf = "ebnf",
	},
	filename = {
		[".flake8"] = "cfg",
	},
})

local util = require("armkn.utils")
util.autocmd_filetype({ "go", "lua", "tsv" }, function()
	vim.bo.expandtab = false
end)
