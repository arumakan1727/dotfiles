local M = {}

M.root_patterns = { ".git", "Makefile" }

--- @param cwd string
--- @param dirname string
--- @return string | nil
function M.find_dir_in_ancestors(cwd, dirname)
	local homedir = vim.loop.os_homedir()
	while cwd and cwd ~= homedir do
		local d = cwd .. "/" .. dirname
		if vim.fn.isdirectory(d) ~= 0 then
			return d
		end
		cwd = vim.fn.fnamemodify(cwd, ":h")
	end
	return nil
end

-- From https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/init.lua#
-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@return string
function M.get_root()
	---@type string?
	local path = vim.api.nvim_buf_get_name(0)
	path = path ~= "" and vim.loop.fs_realpath(path) or nil
	---@type string[]
	local roots = {}
	if path then
		for _, client in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
			local workspace = client.config.workspace_folders
			local paths = workspace and vim.tbl_map(function(ws)
				return vim.uri_to_fname(ws.uri)
			end, workspace) or client.config.root_dir and { client.config.root_dir } or {}
			for _, p in ipairs(paths) do
				local r = vim.loop.fs_realpath(p)
				if path:find(r, 1, true) then
					roots[#roots + 1] = r
				end
			end
		end
	end
	table.sort(roots, function(a, b)
		return #a > #b
	end)
	---@type string?
	local root = roots[1]
	if not root then
		path = path and vim.fs.dirname(path) or vim.loop.cwd()
		---@type string?
		root = vim.fs.find(M.root_patterns, { path = path, upward = true })[1]
		root = root and vim.fs.dirname(root) or vim.loop.cwd()
	end
	---@cast root string
	return root
end

---@param on_attach fun(client: integer, buffer: integer)
function M.autocmd_lsp_attach(on_attach)
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local buffer = args.buf
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			on_attach(client, buffer)
		end,
	})
end

---@param ft string|table<string>
---@param callback function
function M.autocmd_filetype(ft, callback)
	vim.api.nvim_create_autocmd("FileType", {
		pattern = ft,
		callback = callback,
	})
end

return M
