local enable_ai = function()
  local current_dir = vim.fn.getcwd()
  local home_dir = os.getenv("HOME") or os.getenv("USERPROFILE")
  local code_path = home_dir .. "/code"

  -- if git repo is filed under ~/code/work/private, do not allow AI
  local private_path = code_path .. "/work/private"
  local is_code_private = string.find(current_dir, private_path) == 1

  if is_code_private then
    return false
  else
    return true
  end
end

return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = true,
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          accept = false,     -- disable built-in keymapping
        },
      })

      -- hide copilot suggestions when cmp menu is open
      -- to prevent odd behavior/garbled up suggestions
      local cmp_status_ok, cmp = pcall(require, "cmp")
      if cmp_status_ok then
        cmp.event:on("menu_opened", function()
          vim.b.copilot_suggestion_hidden = true
        end)

        cmp.event:on("menu_closed", function()
          vim.b.copilot_suggestion_hidden = false
        end)
      end

      -- disable copilot if we are in a private project
      if not enable_ai() then
        vim.cmd("Copilot disable")
      end
    end,
  },

}
