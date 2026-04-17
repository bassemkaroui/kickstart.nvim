# Architectural Patterns

## Plugin Organization Pattern (Lazy.nvim)

Plugins follow the lazy.nvim spec format with consistent structure:

```lua
return {
  {
    'owner/plugin-name',
    dependencies = { 'dep/plugin' },
    event = 'VimEnter',           -- lazy-load trigger
    cmd = { 'CommandName' },      -- or command-based loading
    keys = { { '<leader>x', fn } },
    opts = { option = value },    -- passed to setup()
    config = function()           -- custom initialization
      require('plugin').setup({})
    end,
  },
}
```

**Examples:**

- `init.lua:1008-1056` - conform.nvim with `formatters_by_ft` and `format_on_save`
- `lua/kickstart/plugins/lint.lua` - nvim-lint with `linters_by_ft` and `try_lint` autocmd
- `lua/custom/plugins/init.lua:1-50` - toggleterm with opts pattern
- `lua/custom/plugins/init.lua:165-220` - harpoon v2 with complex config

**Pattern Location:** `init.lua:181-266` (core keymaps), `init.lua:657-759` (LSP keymaps)

## LSP Configuration Pattern

1. **Server table definition** (`init.lua:810-1006`):

    ```lua
    local servers = {
      pyright = {},
      lua_ls = {
        settings = { Lua = { completion = { callSnippet = 'Replace' } } }
      },
    }
    ```

2. **Capability extension** (`init.lua:794-799`):

    - Base capabilities from `vim.lsp.protocol`
    - Extended with blink.cmp completions
    - Folding range support added

3. **Single LspAttach autocommand** (`init.lua:657-759`):
    - All buffer-local keymaps set here
    - Document highlight on CursorHold
    - Inlay hints toggle support

## Formatting Pipeline

Two-layer approach:

1. **Conform.nvim** (primary): `init.lua:1008-1056`

    - Per-filetype mapping via `formatters_by_ft` (lua, python, markdown, json, html, yaml, sh/bash/zsh, terraform)
    - Format on save via `format_on_save` (disabled for C/C++)
    - Formatter option overrides via `formatters` (e.g. `shfmt.prepend_args = { '-i', '4' }`)

2. **LSP fallback**: `require('conform').format { lsp_format = 'fallback' }` — when no conform formatter is registered for a filetype, delegates to `vim.lsp.buf.format` (e.g. ruff LSP handles Python formatting if the conform entry is absent)

## Linting Pipeline

Two sources of diagnostics:

1. **LSP diagnostics**: each configured server (`init.lua` servers table) contributes via `vim.lsp.buf.diagnostic`. Notably, `ruff` LSP provides live Python lint diagnostics + code actions; it reads rules from the nearest project `pyproject.toml` (or `ruff.toml` / `.ruff.toml`) via upward discovery, falling back to the user-level `~/.config/ruff/ruff.toml` (stowed from `~/.dotfiles/ruff/tag-default/.config/ruff/ruff.toml`).

2. **nvim-lint** (non-LSP tools): `lua/kickstart/plugins/lint.lua`

    - `linters_by_ft` maps filetype → CLI linter (`markdown → markdownlint`, `make → checkmake`, `python → mypy`)
    - `try_lint()` autocmd fires on `BufEnter`, `BufWritePost`, `InsertLeave` (only when `vim.bo.modifiable`)
    - Tools installed via `mason-tool-installer` entries in `init.lua` (alongside the LSP servers)

## Custom Change Markers

User modifications marked with comment pattern:

```lua
-- <CUSTOM CHANGE>
-- --<CUSTOM CHANGE>
```

Locations: Throughout `init.lua`, search for `CUSTOM CHANGE`

## Plugin Loading Strategies

| Strategy                | Use Case           | Example                   |
| ----------------------- | ------------------ | ------------------------- |
| `event = "VeryLazy"`    | Non-critical UI    | lualine, trouble          |
| `event = "VimEnter"`    | Startup visibility | dashboard                 |
| `event = "BufReadPost"` | File-dependent     | treesitter                |
| `event = "InsertEnter"` | Editing features   | autopairs                 |
| `cmd = {...}`           | Command-only       | `:Neogit`, `:DapContinue` |
| `keys = {...}`          | Keymap-triggered   | harpoon, flash            |
| `ft = {...}`            | Filetype-specific  | markdown-preview          |

## Diagnostic Display Pattern

Configuration at `init.lua:763-788`:

- Severity-sorted (highest first)
- Virtual text for ERROR/WARN only
- Rounded float borders
- Nerd Font icons (signs)

## Two-File Plugin Architecture

- **`init.lua`**: Core plugins (treesitter, telescope, lsp, completion)
- **`lua/custom/plugins/init.lua`**: User additions (57 plugins)
- **`lua/kickstart/plugins/`**: Optional kickstart modules (neo-tree, debug, gitsigns)

## Testing Pattern

**neotest** (`lua/custom/plugins/init.lua`): In-editor test runner with inline results, summary panel, and DAP integration.

- Adapter: `neotest-python` with `pytest` runner
- Python binary resolved from `venv-selector.nvim` (falls back to `python3`)
- Keymaps under `<leader>t`: run nearest (`tr`), run file (`tf`), summary (`ts`), output (`to`/`tO`), debug (`td`), watch (`tW`), stop (`tS`)
- Debug strategy delegates to existing DAP/debugpy config

## REPL/Terminal Pattern

Multiple terminal integrations:

- `toggleterm.nvim`: Floating terminal (`<A-t>`)
- `iron.nvim`: Language REPL (IPython)

Pattern: `lua/custom/plugins/init.lua:1-30` (toggleterm), `lua/custom/plugins/init.lua:500-550` (iron)

## Mason + LSPConfig Integration Pattern

**Definition:** Language servers declared in a `servers` table, auto-installed via Mason, configured via `nvim-lspconfig`.

**Rationale:** Centralizes server configuration; enables automatic installation; separates server list from setup logic.

**Examples:**

- `init.lua:810-1005` - Server definitions table with per-server settings
- `init.lua:1010-1050` - Mason-lspconfig setup handler iterates server table
