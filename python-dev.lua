-- ~/.config/nvim/lua/plugins/python-dev.lua
local function safe(fn, name)
  local ok, err = pcall(fn)
  if not ok then
    vim.notify(("Python dev config error in %s: %s"):format(name or "?", err), vim.log.levels.ERROR)
  end
end

return {
  -- Ensure tools & prepend Mason bin path
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "basedpyright",
        "ruff",     -- CLI + native LSP server ("ruff")
        "debugpy",
      })
      opts.PATH = "prepend"
    end,
  },

  -- LSP: basedpyright + ruff (native)
  {
    "AstroNvim/astrolsp",
    opts = {
      servers = { "basedpyright", "ruff" },
      config = {
          basedpyright = (function()
          -- Build settings from CONDA_PREFIX so basedpyright uses your env
          local settings = {
            python = {
              analysis = {
                autoImportCompletions = true,
                useLibraryCodeForTypes = true,
                typeCheckingMode = "basic",
              },
              -- we'll fill venvPath/venv below
            },
            basedpyright = {
              analysis = {
                inlayHints = {
                  variableTypes = true,
                  functionReturnTypes = true,
                  callArgumentNames = true,
                },
              },
            },
          }
        
          local cmd_env = {}
          local conda = os.getenv("CONDA_PREFIX")
          if conda and #conda > 0 then
            -- derive env name and parent "envs" dir from CONDA_PREFIX
            local sep = package.config:sub(1,1)
            local env_name = conda:match("[^"..sep.."]+$") or "conda"
            local envs_path = conda:sub(1, #conda - (#env_name + 1))
        
            settings.python.venvPath = envs_path
            settings.python.venv = env_name
        
            -- run the LSP process with the env on PATH (helps 3rd-party tooling hooks)
            if vim.fn.has("win32") == 1 then
              cmd_env.CONDA_PREFIX = conda
              cmd_env.VIRTUAL_ENV = conda
              cmd_env.PATH = conda .. "\\Scripts;" .. conda .. ";" .. (vim.env.PATH or "")
            else
              cmd_env.CONDA_PREFIX = conda
              cmd_env.VIRTUAL_ENV = conda
              cmd_env.PATH = conda .. "/bin:" .. (vim.env.PATH or "")
            end
          end
        
          return {
            cmd_env = cmd_env,
            settings = settings,
          }
        end)(),
        ruff = {
          on_attach = function(client, _)
            client.server_capabilities.hoverProvider = false
          end,
        },
      },
      -- We format via conform (below)
      formatting = { disabled = { "basedpyright", "ruff" } },
    },
  },

  -- Formatting via Ruff CLI (no null-ls)
  {
    "stevearc/conform.nvim",
    opts = {
      notify_on_error = true,
      format_on_save = { timeout_ms = 1500, lsp_fallback = true },
      formatters_by_ft = {
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
      },
    },
  },

  -- DAP adapter install via Mason
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = { ensure_installed = { "python" }, automatic_setup = true },
  },

  -- DAP Python with bullet-proof debugpy discovery
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      safe(function()
        local ok, dap_python = pcall(require, "dap-python")
        if not ok then return end

        local python_path = vim.fn.exepath("python3")
        if python_path == "" then python_path = "python" end

        local ok_mason, registry = pcall(require, "mason-registry")
        if ok_mason and registry and type(registry.get_package) == "function" then
          local ok_pkg, pkg = pcall(registry.get_package, "debugpy")
          if ok_pkg and pkg and type(pkg.is_installed) == "function" and pkg:is_installed()
             and type(pkg.get_install_path) == "function" then
            local install_path = pkg:get_install_path()
            if type(install_path) == "string" and #install_path > 0 then
              if vim.fn.has("win32") == 1 == true then
                local p = install_path .. "\\venv\\Scripts\\python.exe"
                if vim.loop.fs_stat(p) then python_path = p end
              else
                local p = install_path .. "/venv/bin/python"
                if vim.loop.fs_stat(p) then python_path = p end
              end
            end
          end
        end

        dap_python.setup(python_path)
        dap_python.test_runner = "pytest"
      end, "dap-python setup")
    end,
  },

  -- Minimal plugin to set diagnostics + mappings safely
  {
    "AstroNvim/astrocore",
    opts = {
      -- Keep astrocore simple; set mappings only
      mappings = {
        n = {
          -- Format (Ruff via conform)
          ["<leader>lf"] = {
            function()
              local ok, conform = pcall(require, "conform")
              if ok then conform.format({ async = true }) end
            end,
            desc = "Format (Ruff)",
          },

          -- DAP basics (guarded)
          ["<leader>dt"] = {
            function()
              local ok, dap = pcall(require, "dap")
              if ok then dap.toggle_breakpoint() end
            end,
            desc = "DAP: toggle breakpoint",
          },
          ["<F5>"] = {
            function()
              local ok, dap = pcall(require, "dap")
              if ok then dap.continue() end
            end,
            desc = "DAP: continue",
          },
          ["<F10>"] = {
            function()
              local ok, dap = pcall(require, "dap")
              if ok then dap.step_over() end
            end,
            desc = "DAP: step over",
          },
          ["<F11>"] = {
            function()
              local ok, dap = pcall(require, "dap")
              if ok then dap.step_into() end
            end,
            desc = "DAP: step into",
          },
          ["<S-F11>"] = {
            function()
              local ok, dap = pcall(require, "dap")
              if ok then dap.step_out() end
            end,
            desc = "DAP: step out",
          },

          -- Toggle diagnostics (buffer-local)
          ["<leader>td"] = {
            function()
              if vim.b.diag_disabled then
                vim.diagnostic.enable(0)
                vim.b.diag_disabled = false
                vim.notify("Diagnostics enabled", vim.log.levels.INFO)
              else
                vim.diagnostic.disable(0)
                vim.b.diag_disabled = true
                vim.notify("Diagnostics disabled", vim.log.levels.WARN)
              end
            end,
            desc = "Toggle diagnostics (buffer)",
          },
        },
      },
    },
    config = function(_, opts)
      -- Apply astrocore defaults first
      require("astrocore").setup(opts)

      -- Now set diagnostics visibility (hide warnings; only show errors)
      safe(function()
        vim.diagnostic.config({
          severity_sort = true,
          virtual_text = { severity = { min = vim.diagnostic.severity.ERROR } },
          signs       = { severity = { min = vim.diagnostic.severity.ERROR } },
          underline   = { severity = { min = vim.diagnostic.severity.ERROR } },
          float       = { severity = { min = vim.diagnostic.severity.ERROR } },
        })
      end, "diagnostic.config")
    end,
  },
}
