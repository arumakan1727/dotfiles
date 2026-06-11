-- hover は basedpyright に任せ、ruff は lint / organize imports / format に専念させる
return {
  on_attach = function(client, _)
    client.server_capabilities.hoverProvider = false
  end,
}
