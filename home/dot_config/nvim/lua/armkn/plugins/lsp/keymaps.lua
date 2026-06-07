local M = {}

function M.on_attach(client, bufnr)
	local function buf_keymap(mode, lhs, rhs, opts)
		local o = vim.tbl_extend("force", {
			buffer = bufnr,
			silent = true,
		}, opts)

		vim.keymap.set(mode, lhs, rhs, o)
	end

	buf_keymap("n", "<LocalLeader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
	buf_keymap("n", "<LocalLeader>ci", "<cmd>LspInfo<cr>", { desc = "Lsp Info" })
	buf_keymap("n", "<LocalLeader>cI", "<cmd>NullLsInfo<cr>", { desc = "Null-ls Info" })
	buf_keymap("n", "<LocalLeader>cr", vim.lsp.buf.rename, { desc = "Rename symbol" })
	buf_keymap("n", "<LocalLeader>cf", M.format, { desc = "Format Document" })
	buf_keymap("v", "<LocalLeader>cf", M.format, { desc = "Format Range" })
	buf_keymap("n", "<LocalLeader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
	buf_keymap("v", "<LocalLeader>ca", vim.lsp.buf.code_action, { desc = "Code Action (Range)" })

	buf_keymap("n", "gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Goto Definition" })
	buf_keymap("n", "gr", "<cmd>Telescope lsp_references<cr>", { desc = "References" })
	buf_keymap("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
	buf_keymap("n", "gi", "<cmd>Telescope lsp_implementations<cr>", { desc = "Goto Implementation" })
	buf_keymap("n", "gt", "<cmd>Telescope lsp_type_definitions<cr>", { desc = "Goto Type Definition" })
	buf_keymap("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
	buf_keymap("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature Help" })
	buf_keymap("i", "<c-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })

	buf_keymap("n", "]d", M.diagnostic_goto("next"), { desc = "Next Diagnostic" })
	buf_keymap("n", "[d", M.diagnostic_goto("prev"), { desc = "Prev Diagnostic" })
	buf_keymap("n", "]e", M.diagnostic_goto("next", "ERROR"), { desc = "Next Error" })
	buf_keymap("n", "[e", M.diagnostic_goto("prev", "ERROR"), { desc = "Prev Error" })
	buf_keymap("n", "]w", M.diagnostic_goto("next", "WARN"), { desc = "Next Warning" })
	buf_keymap("n", "[w", M.diagnostic_goto("prev", "WARN"), { desc = "Prev Warning" })
end

function M.format()
	local buf = vim.api.nvim_get_current_buf()
	local ft = vim.bo[buf].filetype
	local have_nls = #require("null-ls.sources").get_available(ft, "NULL_LS_FORMATTING") > 0
	vim.lsp.buf.format({
		bufnr = buf,
		name = have_nls and "null-ls" or nil,
	})
end

function M.diagnostic_goto(d, severity)
	local go = (d == "next") and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
	severity = severity and vim.diagnostic.severity[severity] or nil
	return function()
		go({ severity = severity })
	end
end

return M
