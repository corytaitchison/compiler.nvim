--- LaTeX language actions

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "1 - Build and watch project", value = "option1" },
  { text = "2 - Build and open project", value = "option2" },
  { text = "3 - Build project", value = "option3" },
  { text = "4 - Clean", value = "option4" },
  { text = "5 - Deep Clean", value = "option5" },
  { text = "6 - Run Makefile", value = "option6" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  -- local utils = require("compiler.utils")
  local overseer = require("overseer")
  -- local entry_point = "'" .. utils.os_path(vim.fn.getcwd() .. "/main.tex") .. "'"
  local filename = vim.fn.expand("%:t")
  local entry_point = "'" .. vim.fn.expand("%:p") .. "'"
  local final_message = "--task finished--"


  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- LaTeX compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build & watch project → " .. filename,
          cmd = "latexmk -pdf -interaction=nonstopmode -synctex=1 -pvc " .. entry_point
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- LaTeX compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build & open project → " .. filename,
          cmd = "latexmk -pdf -interaction=nonstopmode -synctex=1 -pv " .. entry_point ..
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option3" then
    local task = overseer.new_task({
      name = "- LaTeX compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build project → " .. filename,
          cmd = "latexmk -pdf -interaction=nonstopmode -synctex=1 " .. entry_point ..
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option4" then
    local task = overseer.new_task({
      name = "- LaTeX compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Clean → " .. filename,
          cmd = "latexmk -c" ..
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option5" then
    local task = overseer.new_task({
      name = "- LaTeX compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Deep Clean → " .. filename,
          cmd = "latexmk -C" ..
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option6" then
    require("compiler.languages.make").run_makefile()                        -- run
  end
end

return M
