# Porting `custom_config` from lazy.nvim to `vim.pack`

Working document for the `vimpack-trial` branch. Tick boxes as you go; this file
is the state that survives between sessions.

## Safety model

- This branch lives in a **git worktree** at `~/.config/nvim-trial`, created with
  `git worktree add -b vimpack-trial ~/.config/nvim-trial custom_config`.
- `custom_config` and the stowed `~/.config/nvim` symlink are **never touched**.
- Run the trial with a separate app name so it uses its own plugin/state dirs:

  ```bash
  NVIM_APPNAME=nvim-trial nvim
  ```

  Data lands in `~/.local/share/nvim-trial` and `~/.local/state/nvim-trial`.
  Your daily `nvim` keeps working no matter how broken this branch gets.

- **Abort the whole experiment** at any time:

  ```bash
  git worktree remove --force ~/.config/nvim-trial
  git branch -D vimpack-trial
  rm -rf ~/.local/share/nvim-trial ~/.local/state/nvim-trial
  ```

## Baseline to beat

Measured on `custom_config` (lazy.nvim, 54 of 76 plugins deferred), headless:

| Run | Startup |
| --- | ------- |
| 1   | 120 ms  |
| 2   | 173 ms  |
| 3   | 166 ms  |

Slowest single `require`s: `harpoon` 5.9 ms, `schemastore.catalog` 4.2 ms,
`yazi` 2.5 ms, `telescope.config` 1.8 ms.

Re-measure the port with:

```bash
NVIM_APPNAME=nvim-trial nvim --headless --startuptime /tmp/st.txt -c 'qa!'
awk '{print $1}' /tmp/st.txt | grep -E '^[0-9]+\.' | sort -n | tail -1
```

## Method

`init.lua` and `lua/custom/plugins/init.lua` are ported in **opposite directions**.

- **`init.lua`** — start from `upstream/master`'s version (983 lines, a working
  `vim.pack` reference with build hooks, `vim.loader`, section structure) and
  re-apply our changes on top. Hand-converting our 1549-line version would mean
  reinventing all of that.
- **`lua/custom/plugins/init.lua`** — no upstream counterpart, so convert in place.

### Finding our changes faithfully

Do **not** rely on `-- <CUSTOM CHANGE>` markers. Of the 601 added lines in
`init.lua`, only 48 are marked — about 92% of our changes carry no marker. The
authoritative delta is the diff against the last shared lazy.nvim ancestor:

```bash
git diff upstream/lazy custom_config -- init.lua
```

Because `custom_config` merged `upstream/lazy` in `8e6f550`, that diff is exactly
our customizations with no upstream noise. It is 28 hunks, +600/-41.

## Phase 1 — stock vim.pack baseline

- [ ] `git checkout upstream/master -- init.lua lua/kickstart/` in the worktree
- [ ] Delete/park `lua/custom/plugins/init.lua` so nothing custom loads yet
- [ ] Boot `NVIM_APPNAME=nvim-trial nvim`, let `vim.pack` install upstream's set
- [ ] Confirm a stock kickstart works: LSP attaches, treesitter highlights, `:checkhealth` clean
- [ ] Record startup time for reference

Goal: prove `vim.pack` itself works here before adding anything of ours.

## Phase 2 — re-apply our `init.lua` changes (28 hunks)

Line ranges refer to `custom_config:init.lua`. Work top-down; boot after each
group.

### Options, keymaps, diagnostics

- [ ] 1 · `84-92` (+3) — mise shims prepended to `PATH` for LSP/formatter discovery
- [ ] 2 · `94-114` (+5/-1) — `have_nerd_font`, related globals
- [ ] 3 · `120-138` (+13) — custom options block
- [ ] 4 · `183-237` (+43) — `termguicolors` + options for nvim-notify etc.
- [ ] 5 · `246-271` (+20/-1) — `vim.diagnostic.config`, incl. the `on_jump` fix
- [ ] 6 · `299-320` (+16) — tab management keymaps
- [ ] 7 · `327-381` (+49) — Python `<leader>mi` type-ignore helper + more keymaps

### Plugin-adjacent config still living in `init.lua`

- [ ] 8 · `432-438` (+1) — gitsigns `current_line_blame`
- [ ] 9 · `467-476` (+1/-1) — which-key `<leader>b` group
- [ ] 10 · `508-514` (+1) — todo-comments tweak
- [ ] 11 · `536-560` (+15/-5) — telescope `defaults`
- [ ] 12 · `565-593` (+17/-3) — telescope keymaps (`<leader>sf` etc.)
- [ ] 13 · `648-693` (+40) — custom telescope picker
- [ ] 14 · `704-712` (+3/-1) — opts tweak
- [ ] 15 · `714-725` (+6) — blink.cmp capabilities wiring

### LSP — the big one

- [ ] 16 · `820-987` (**+160**/-1) — full LSP server table (pyright, ruff, lua_ls,
      bashls, jsonls, yamlls, ansible, docker, gitlab-ci, helm, sql, markdown)

### Formatting / completion

- [ ] 17 · `1036-1065` (+20/-1) — conform setup
- [ ] 18 · `1085-1103` (+12/-2) — `format_on_save` allow-list (`enabled_filetypes`)
- [ ] 19 · `1110-1129` (+14/-6) — `formatters_by_ft` + `shfmt` args
- [ ] 20 · `1148-1164` (+8/-6) — blink.cmp keymaps
- [ ] 21 · `1187-1196` (+4) — `<A-CR>` mapping
- [ ] 22 · `1204-1272` (**+60**/-2) — blink.cmp sources, docs popup, emoji/dadbod
- [ ] 23 · `1278-1288` (+3/-2) — blink fuzzy impl

### Editing / treesitter / tail

- [ ] 24 · `1342-1348` (+1/-1) — mini.surround / mini config
- [ ] 25 · `1368-1386` (+10/-1) — plugin `init` function
- [ ] 26 · `1425-1498` (**+68**) — native treesitter incremental selection (`<A-i>`),
      replaces the removed `nvim-treesitter.configs` module
- [ ] 27 · `1506-1522` (+6/-6) — kickstart module requires
- [ ] 28 · `1544-1549` (+1) — `require('custom.doppler').setup()`

### Carry-over decisions already made (keep these)

- [ ] `lua_ls` formatting stays disabled — stylua-via-conform owns Lua
- [ ] mini.ai next/last objects stay remapped to `aa`/`ii`
- [ ] `format_on_save` stays an allow-list; keep it in sync with `formatters_by_ft`

## Phase 3 — port 76 plugins (eagerly first)

Convert each to `vim.pack.add`. **Do not port lazy-loading yet** — see Phase 4.
Boot after each batch.

### Already eager under lazy.nvim (22)

- [ ] `fga.nvim` — `hedengran/fga.nvim`
- [ ] `git-worktree.nvim` — `polarmutex/git-worktree.nvim`
- [ ] `gitsigns.nvim` — `lewis6991/gitsigns.nvim`
- [ ] `guess-indent.nvim` — `NMAC427/guess-indent.nvim`
- [ ] `harpoon` — `ThePrimeagen/harpoon`
- [ ] `indent-blankline.nvim` — `lukas-reineke/indent-blankline.nvim`
- [ ] `lualine.nvim` — `nvim-lualine/lualine.nvim`
- [ ] `mini.nvim` — `nvim-mini/mini.nvim`
- [ ] `neo-tree.nvim` — `nvim-neo-tree/neo-tree.nvim`
- [ ] `noice.nvim` — `folke/noice.nvim`
- [ ] `nvim-dap-ui` — `rcarriga/nvim-dap-ui`
- [ ] `nvim-lspconfig` — `neovim/nvim-lspconfig`
- [ ] `nvim-nio` — `nvim-neotest/nvim-nio`
- [ ] `nvim-treesitter` — `nvim-treesitter/nvim-treesitter` (branch `main`)
- [ ] `nvim-treesitter-context` — `nvim-treesitter/nvim-treesitter-context`
- [ ] `nvim-ufo` — `kevinhwang91/nvim-ufo`
- [ ] `otter.nvim` — `jmbuhr/otter.nvim`
- [ ] `toggleterm.nvim` — `akinsho/toggleterm.nvim`
- [ ] `tokyonight.nvim` — `folke/tokyonight.nvim`
- [ ] `vim-surround` — `tpope/vim-surround`
- [ ] `vim-tmux-navigator` — `christoomey/vim-tmux-navigator`
- [ ] `vim-visual-multi` — `mg979/vim-visual-multi`

### Currently deferred (54)

`lazy.nvim` itself is on this list and simply disappears — do not port it.
`nvim-web-devicons` may be replaced by `mini.icons` (upstream `ec3f448`).

- [ ] `FixCursorHold.nvim` — `antoinemadec/FixCursorHold.nvim`
- [ ] `LuaSnip` — `L3MON4D3/LuaSnip`
- [ ] `bigfile.nvim` — `LunarVim/bigfile.nvim`
- [ ] `blink-emoji.nvim` — `moyiz/blink-emoji.nvim`
- [ ] `blink.cmp` — `saghen/blink.cmp`
- [ ] `blink.compat` — `saghen/blink.compat`
- [ ] `claudecode.nvim` — `coder/claudecode.nvim`
- [ ] `cmp-dotenv` — `SergioRibera/cmp-dotenv`
- [ ] `cmp-sql` — `ray-x/cmp-sql`
- [ ] `conform.nvim` — `stevearc/conform.nvim`
- [ ] `diffview.nvim` — `sindrets/diffview.nvim`
- [ ] `fidget.nvim` — `j-hui/fidget.nvim`
- [ ] `flash.nvim` — `folke/flash.nvim`
- [ ] `friendly-snippets` — `rafamadriz/friendly-snippets`
- [ ] `goto-preview` — `rmagatti/goto-preview`
- [ ] `iron.nvim` — `Vigemus/iron.nvim`
- [ ] ~~`lazy.nvim`~~ — dropped, replaced by `vim.pack`
- [ ] `markdown-preview.nvim` — `iamcco/markdown-preview.nvim` (has a build step)
- [ ] `mason-lspconfig.nvim` — `mason-org/mason-lspconfig.nvim`
- [ ] `mason-tool-installer.nvim` — `WhoIsSethDaniel/mason-tool-installer.nvim`
- [ ] `mason.nvim` — `mason-org/mason.nvim`
- [ ] `neogen` — `danymat/neogen`
- [ ] `neogit` — `NeogitOrg/neogit`
- [ ] `neotest` — `nvim-neotest/neotest`
- [ ] `neotest-python` — `nvim-neotest/neotest-python`
- [ ] `nui.nvim` — `MunifTanjim/nui.nvim`
- [ ] `nvim-autopairs` — `windwp/nvim-autopairs`
- [ ] `nvim-dap` — `mfussenegger/nvim-dap`
- [ ] `nvim-dap-python` — `mfussenegger/nvim-dap-python`
- [ ] `nvim-dap-virtual-text` — `theHamsta/nvim-dap-virtual-text`
- [ ] `nvim-lint` — `mfussenegger/nvim-lint`
- [ ] `nvim-notify` — `rcarriga/nvim-notify`
- [ ] `nvim-transparent` — `xiyaowong/nvim-transparent`
- [ ] `nvim-web-devicons` — `nvim-tree/nvim-web-devicons` (or swap to `mini.icons`)
- [ ] `plenary.nvim` — `nvim-lua/plenary.nvim`
- [ ] `promise-async` — `kevinhwang91/promise-async`
- [ ] `remote-nvim.nvim` — `amitds1997/remote-nvim.nvim`
- [ ] `schemastore.nvim` — `b0o/schemastore.nvim`
- [ ] `snacks.nvim` — `folke/snacks.nvim`
- [ ] `telescope.nvim` — `nvim-telescope/telescope.nvim`
- [ ] `telescope-fzf-native.nvim` — `nvim-telescope/telescope-fzf-native.nvim` (build step)
- [ ] `telescope-ui-select.nvim` — `nvim-telescope/telescope-ui-select.nvim`
- [ ] `todo-comments.nvim` — `folke/todo-comments.nvim`
- [ ] `trouble.nvim` — `folke/trouble.nvim`
- [ ] `twilight.nvim` — `folke/twilight.nvim`
- [ ] `venv-selector.nvim` — `linux-cultist/venv-selector.nvim`
- [ ] `vim-dadbod` — `tpope/vim-dadbod`
- [ ] `vim-dadbod-completion` — `kristijanhusak/vim-dadbod-completion`
- [ ] `vim-dadbod-ui` — `kristijanhusak/vim-dadbod-ui`
- [ ] `vim-dotenv` — `tpope/vim-dotenv`
- [ ] `vim-fugitive` — `tpope/vim-fugitive`
- [ ] `which-key.nvim` — `folke/which-key.nvim`
- [ ] `yazi.nvim` — `mikavilpas/yazi.nvim`
- [ ] `zen-mode.nvim` — `folke/zen-mode.nvim`

### Things with no direct `vim.pack` equivalent

- [ ] **Dependency ordering.** lazy.nvim resolved `dependencies` automatically.
      `vim.pack.add` loads in list order — put dependencies first by hand
      (`plenary` before telescope/neotest, `nui` before neo-tree/noice,
      `promise-async` before `nvim-ufo`, `nvim-nio` before `neotest`).
- [ ] **Build steps.** lazy.nvim's `build` becomes a `PackChanged` autocmd; see
      upstream's `run_build` helper in its `init.lua` for the pattern
      (`telescope-fzf-native`, `markdown-preview`).
- [ ] **`opts` tables.** lazy.nvim called `setup(opts)` for you. Under `vim.pack`
      every plugin needs an explicit `require('x').setup{...}`.

## Phase 4 — add deferral only where measured

Port everything eager first, then re-measure against the 120–173 ms baseline.

**Only then** decide what to defer. `vim.pack` has no `event`/`ft`/`cmd`/`keys`
system — only a `load` option (boolean, or a function that is "fully responsible
for loading plugin", per `:help pack.txt`). Reproducing our current setup by hand
means writing trigger logic for **94 distinct triggers**:

| Trigger type | Distinct triggers |
| ------------ | ----------------- |
| `keys`       | 65                |
| `cmd`        | 18                |
| `event`      | 6                 |
| `ft`         | 5                 |

- [ ] Measure eager-everything startup
- [ ] If within ~2x baseline: **stop**, ship it eager
- [ ] If slow: defer only the measured-worst offenders, not all 54

Candidate first deferrals if needed: `harpoon`, `schemastore.nvim`, `yazi.nvim`,
`markdown-preview.nvim`, `remote-nvim.nvim`, the DAP stack.

## Done criteria

- [ ] `:checkhealth` clean
- [ ] LSP attaches for Python and Lua; ruff diagnostics appear
- [ ] Format-on-save works for all 10 allow-listed filetypes
- [ ] Debugger starts (`<leader>d` keymaps); neotest runs a pytest test
- [ ] Telescope, neo-tree, neogit, harpoon, toggleterm all usable
- [ ] Doppler loader still works from its two keymaps
- [ ] Startup time acceptable vs baseline
- [ ] Daily-drive it via `NVIM_APPNAME=nvim-trial` for a week before merging
