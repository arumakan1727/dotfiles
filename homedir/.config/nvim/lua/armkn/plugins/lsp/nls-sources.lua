local nls = require("null-ls")
local formatter = nls.builtins.formatting
local linter = nls.builtins.diagnostics

local function root_has_file(files)
	return function(null_ls_utils)
		return null_ls_utils.root_has_file(files)
	end
end

return {
	-- formatter
	formatter.black,
	formatter.buf,
	formatter.isort,
	formatter.markdownlint,
	formatter.prettier.with({ condition = root_has_file({ "package.json" }) }),
	formatter.rubocop,
	formatter.shfmt,
	formatter.stylua,

	-- linter
	linter.buf,
	linter.cppcheck,
	linter.erb_lint,
	linter.hadolint,
	linter.misspell,
	linter.rubocop,
	linter.shellcheck,
	linter.golangci_lint,
}
