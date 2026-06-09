-- bytecode キャッシュを最優先で有効化する。あらゆる require より前に置くこと
-- (後に置くとその module がキャッシュに乗らない)。
vim.loader.enable()

require("armkn.config.options")
require("armkn.config.keymaps")
require("armkn.config.commands")
require("armkn.config.autocmds")
require("armkn.config.lazy")
