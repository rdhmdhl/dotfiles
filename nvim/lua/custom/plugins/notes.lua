return {
  dir = "~/code/nvim-notes",
  name = "notes",
  config = function()
    require("notes").setup({
      notes_dir = "~/notes",
    })
  end
}
