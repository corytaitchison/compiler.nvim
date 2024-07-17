--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/languages/cs.lua

local ms = 1000 -- wait time
local language = require("compiler.languages.cs")
local example = require("compiler.utils").get_tests_dir("code samples/languages/cs/")

coroutine.resume(coroutine.create(function()
  local co = coroutine.running()
  local function sleep()
    vim.defer_fn(function() coroutine.resume(co) end, ms)
    coroutine.yield()
  end

  -- Build and run
  vim.api.nvim_set_current_dir(example .. "build-and-run/")
  language.action("option1")
  sleep()

  -- Build
  vim.api.nvim_set_current_dir(example .. "build/")
  language.action("option2")
  sleep()

  -- Run
  language.action("option3")
  sleep()

  -- Build solution (without .solution file)
  vim.api.nvim_set_current_dir(example .. "solution-nofile/")
  language.action("option4")
  sleep()

  -- Build solution
  vim.api.nvim_set_current_dir(example .. "solution/")
  language.action("option4")
  sleep()

  -- Build and run dotnet
  vim.api.nvim_set_current_dir(example .. "build-and-run-dotnet/")
  language.action("option5")
  sleep()

  -- Build dotnet
  vim.api.nvim_set_current_dir(example .. "build-dotnet/")
  language.action("option6")
  sleep()

  -- Watch dotnet (requires aspnet)
  language.action("option7")
  sleep()
end))
