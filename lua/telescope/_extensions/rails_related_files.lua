local has_telescope, telescope = pcall(require, 'telescope')
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local builtin = require("telescope.builtin")
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local previewers = require "telescope.previewers"
local make_entry = require "telescope.make_entry"

if not has_telescope then
  error('This plugin requires nvim-telescope/telescope.nvim')
end

M = {}

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

M.rails_related_files = function(opts)
  local current_file = vim.fn.expand("%:p")
  local views_dir = ""
  local controller_file = ""

  if not string.find(current_file, "app/views/") and not string.find(current_file, "app/controllers/") then
    print("No files to find")
    return false
  end

  if string.find(current_file, "app/views") then
    controller_file = string.sub(current_file, 0, string.find(current_file, "/[^/]*$")) .. "_controller"
    controller_file = controller_file:gsub("views", "controllers"):gsub("/_", "_")
    controller_file = controller_file .. ".rb"
    views_dir = string.sub(current_file, 0, string.find(current_file, "/[^/]*$")) .. "*"
  end

  if string.find(current_file, "app/controllers") then
    controller_file = current_file
    views_dir = current_file:gsub("app/controllers/", "app/views/"):gsub("_controller.rb", "/*")
  end

  local command = table.concat({"ls -dp ", views_dir, " ", views_dir, "*/* ", controller_file, " | egrep -v /$"})
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()

  local files = {}
  for token in string.gmatch(result, "[^%s]+") do
     table.insert(files, token)
  end

  opts = opts or {}

  pickers.new(opts, {
    prompt_title = "Related files",
    finder = finders.new_table {
      results = files,
      entry_maker = function(line)
        return make_entry.set_default_entry_mt({
          ordinal = line,
          display = "app/" .. split(line, "app/")[2],
          filename = line,
        }, opts)
      end,
    },
    sorter = conf.generic_sorter(opts),
    previewer = conf.file_previewer(opts)
  }):find()
end

return telescope.register_extension {
  exports = {
    rails_related_files = M.rails_related_files
  },
}
