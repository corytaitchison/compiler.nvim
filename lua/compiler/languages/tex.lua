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
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local entry_point = utils.os_path(vim.fn.getcwd() .. "/main.tex")            -- working_directory/main.tex
  local final_message = "--task finished--"


  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- LaTeX compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build & watch project → " .. entry_point,
          cmd = "latexmk -pdf -interaction=nonstopmode -synctex=1 -pvc " .. entry_point
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- LaTeX compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output ..                                                -- clean
                " && mkdir -p " .. output_dir ..                                     -- mkdir
                " && gcc " .. files .. " -o " .. output .. " " .. arguments ..       -- compile
                " && echo " .. entry_point ..                                        -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option3" then
    local task = overseer.new_task({
      name = "- C compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run program → " .. entry_point,
          cmd = output ..                                                    -- run
                " && echo " .. output ..                                     -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option4" then
    local entry_points
    local tasks = {}
    local task

    -- if .solution file exists in working dir
    local solution_file = utils.get_solution_file()
    if solution_file then
      local config = utils.parse_solution_file(solution_file)
      local executable

      for entry, variables in pairs(config) do
        if variables.executable then
          executable = utils.os_path(variables.executable)
          goto continue
        end
        entry_point = utils.os_path(variables.entry_point)
        files = utils.find_files_to_compile(entry_point, "*.c")
        output = utils.os_path(variables.output)
        output_dir = utils.os_path(output:match("^(.-[/\\])[^/\\]*$"))
        arguments = variables.arguments or arguments -- optional
        task = { "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output ..                                                -- clean
                " && mkdir -p " .. output_dir ..                                     -- mkdir
                " && gcc " .. files .. " -o " .. output .. " " .. arguments ..       -- compile
                " && echo " .. entry_point ..                                        -- echo
                " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, task) -- store all the tasks we've created
        ::continue::
      end

      if executable then
        task = { "shell", name = "- Run program → " .. executable,
          cmd = executable ..                                                -- run
                " && echo " .. executable ..                                 -- echo
                " && echo '" .. final_message .. "'"
        }
      else
        task = {}
      end

      task = overseer.new_task({
        name = "- C compiler", strategy = { "orchestrator",
          tasks = {
            tasks, -- Build all the programs in the solution in parallel
            task   -- Then run the solution executable
          }}})
      task:start()
      vim.cmd("OverseerOpen")

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.c")

      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point)
        files = utils.find_files_to_compile(entry_point, "*.c")
        output_dir = utils.os_path(entry_point:match("^(.-[/\\])[^/\\]*$") .. "bin")  -- entry_point/bin
        output = utils.os_path(output_dir .. "/program")                              -- entry_point/bin/program
        task = { "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output ..                                                -- clean
                " && mkdir -p " .. output_dir ..                                     -- mkdir
                " && gcc " .. files .. " -o " .. output .. " " .. arguments ..       -- compile
                " && echo " .. entry_point ..                                        -- echo
                " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({ -- run all tasks we've created in parallel
        name = "- C compiler", strategy = { "orchestrator", tasks = tasks }
      })
      task:start()
      vim.cmd("OverseerOpen")
    end
  elseif selected_option == "option5" then
    require("compiler.languages.make").run_makefile()                        -- run
  end
end

return M
