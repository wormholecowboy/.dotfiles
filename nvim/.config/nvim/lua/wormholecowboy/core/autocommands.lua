-- Create a single augroup for all autocommands in this file for better organization
local augroup = vim.api.nvim_create_augroup("WormholeCowboyAutocommands", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  desc = "Hightlight selection on yank",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Defer setting keymaps until after startup and plugins have had time to load.
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  desc = "Set global keymaps after startup",
  pattern = "*",
  callback = function()
    -- Defer to next event loop tick to ensure plugins are loaded, especially with lazy.nvim
    vim.schedule(function()
      -- Keymap to show the full path of the current buffer
      vim.keymap.set("n", "<leader>ub", function()
        local full_path = vim.fn.expand("%:p")
        print(full_path)
      end, { buffer = 0, desc = "CWD: current buffer" })

      -- Keymap to engage "Writing Mode"
      vim.keymap.set("n", "<leader>q", function()
        vim.cmd("ZenMode")
        -- Use setup.buffer to apply settings for the current buffer only
        require("cmp").setup.buffer({ enabled = false })
        vim.wo.wrap = true
        vim.wo.linebreak = true
        vim.cmd("CodeiumDisable")
        vim.o.so = 1
      end, { buffer = 0, desc = "Writing Mode" })

      -- Keymap to log the variable under the cursor
      vim.keymap.set("n", "<leader>lv", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local ft = vim.bo[bufnr].filetype
        local lnum = vim.fn.line(".")
        local col = vim.fn.col(".")
        local line_content = vim.fn.getline(lnum)
        local text_to_log = nil

        -- Try to find text within the nearest enclosing parentheses on the current line
        local start_paren = string.find(line_content:sub(1, col), "%(", 1, true) -- Find last '(' before cursor
        local end_paren = string.find(line_content:sub(col), "%)", 1, true) -- Find first ')' after cursor

        if start_paren and end_paren then
          -- Adjust end_paren index relative to the start of the line
          end_paren = col + end_paren - 1
          -- Ensure the found parentheses form a pair around the cursor
          if start_paren < end_paren then
            -- Extract text between parentheses (exclusive)
            text_to_log = string.sub(line_content, start_paren + 1, end_paren - 1)
          end
        end

        -- Fallback to word under cursor if parentheses logic didn't find anything suitable
        if not text_to_log then
          text_to_log = vim.fn.expand("<cword>")
        end

        -- Trim whitespace from the extracted text
        text_to_log = vim.fn.trim(text_to_log)

        local line_to_insert = nil
        if text_to_log and #text_to_log > 0 then
          if ft == "javascript" or ft == "javascriptreact" or ft == "typescript" or ft == "typescriptreact" then
            -- Add variable name for clarity in JS/TS logs
            line_to_insert = "console.log('" .. text_to_log .. ":', " .. text_to_log .. ")"
          elseif ft == "python" then
            -- Add variable name for clarity in Python logs
            line_to_insert = "print(f'" .. text_to_log .. ": {" .. text_to_log .. "}')"
          end
        end

        if line_to_insert then
          -- Insert the log/print statement below the current line
          vim.api.nvim_buf_set_lines(bufnr, lnum, lnum, false, { line_to_insert })
          -- Optional: Move cursor to the new line
          -- vim.api.nvim_win_set_cursor(0, {lnum + 1, 0})
        else
          print("Could not determine variable/expression to log or unsupported filetype: " .. ft)
        end
      end, { noremap = true, silent = true, desc = "Log variable/expression under cursor" })
    end)
  end,
})

-- vim.diagnostic.config({virtual_text = false, underline = true})
-- this will disable lsp diagnostics
--
-- toggle script for lsp diagnostic
vim.api.nvim_create_user_command("DiagnosticsToggleVirtualText", function()
  local current_value = vim.diagnostic.config().virtual_text
  if current_value then
    vim.diagnostic.config({ virtual_text = false })
  else
    vim.diagnostic.config({ virtual_text = true })
  end
end, {}) --
--
