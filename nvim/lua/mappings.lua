require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<leader>db", "<cmd> bdelete <cr>")
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- RSpec commands
local function find_spec_file(file_path)
  -- If already in a spec file, return it
  if string.match(file_path, "_spec%.rb$") then
    return file_path
  end

  -- Get the project root (assuming it's where we find .git or Gemfile)
  local root = vim.fn.getcwd()

  -- Remove project root from file path to get relative path
  local relative_path = string.gsub(file_path, "^" .. root .. "/", "")

  local spec_path = nil

  -- Handle controllers: app/controllers/path/to/file_controller.rb -> spec/requests/path/to/file_controller_spec.rb
  if string.match(relative_path, "^app/controllers/") then
    spec_path = string.gsub(relative_path, "^app/controllers/", "spec/requests/")
    spec_path = string.gsub(spec_path, "%.rb$", "_spec.rb")
  -- Handle app files: app/path/to/file.rb -> spec/path/to/file_spec.rb
  elseif string.match(relative_path, "^app/") then
    spec_path = string.gsub(relative_path, "^app/", "spec/")
    spec_path = string.gsub(spec_path, "%.rb$", "_spec.rb")
  -- Handle lib files: lib/path/to/file.rb -> spec/path/to/file_spec.rb
  elseif string.match(relative_path, "^lib/") then
    spec_path = string.gsub(relative_path, "^lib/", "spec/")
    spec_path = string.gsub(spec_path, "%.rb$", "_spec.rb")
  else
    -- For other files, try to find a corresponding spec in the same relative structure
    spec_path = string.gsub(relative_path, "%.rb$", "_spec.rb")
    if not string.match(spec_path, "^spec/") then
      spec_path = "spec/" .. spec_path
    end
  end

  if spec_path then
    local full_spec_path = root .. "/" .. spec_path
    if vim.fn.filereadable(full_spec_path) == 1 then
      return full_spec_path
    end
  end

  return nil
end

local function run_rspec_file()
  local file = vim.fn.expand "%:p"
  local spec_file = find_spec_file(file)

  if spec_file then
    vim.cmd("split | terminal bundle exec rspec " .. spec_file)
  else
    vim.notify("No spec found", vim.log.levels.WARN)
  end
end

local function run_rspec_line()
  local file = vim.fn.expand "%:p"
  local line = vim.fn.line "."
  local spec_file = find_spec_file(file)

  if spec_file then
    if string.match(file, "_spec%.rb$") then
      -- If we're in a spec file, use the current line
      vim.cmd("split | terminal bundle exec rspec " .. spec_file .. ":" .. line)
    else
      -- If we're in a source file, just run the whole spec
      vim.cmd("split | terminal bundle exec rspec " .. spec_file)
    end
  else
    vim.notify("No spec found", vim.log.levels.WARN)
  end
end

map("n", "<leader>rs", run_rspec_file, { desc = "Run RSpec file" })
map("n", "<leader>rl", run_rspec_line, { desc = "Run RSpec at line" })

-- YAML sort command
local function sort_yaml_file()
  local file = vim.fn.expand "%:p"
  if string.match(file, "%.ya?ml$") then
    vim.cmd("!bundle exec yaml-sort -i " .. file)
    vim.cmd "edit" -- Reload the file to show changes
  else
    vim.notify("Not a YAML file", vim.log.levels.WARN)
  end
end

map("n", "<leader>ry", sort_yaml_file, { desc = "Sort YAML file" })
