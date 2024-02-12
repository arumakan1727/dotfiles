vim.filetype.add({
	extension = {
		bnf = "ebnf",
		ebnf = "ebnf",
		envrc = "sh",
		snippets = "snippets",

		---@param path string
		---@param bufnr integer
		sample = function(path, bufnr)
			return vim.filetype.match({ buf = bufnr, filename = path:gsub("%.sample$", "") })
		end,
	},
	filename = {
		[".envrc"] = "sh",
		[".flake8"] = "cfg",
	},
	pattern = {
		['.env.*'] = 'sh',
	},
})

local util = require("armkn.utils")
util.autocmd_filetype({ "go", "lua", "tsv" }, function()
	vim.bo.expandtab = false
end)
