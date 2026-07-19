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

## Phase 1 — stock vim.pack baseline ✅ DONE

- [x] `git checkout upstream/master -- init.lua lua/kickstart/ lua/custom/plugins/init.lua`
      (`init.lua` 1549 → 983 lines; custom plugins 1215 → 13-line auto-loader)
- [x] Nothing custom loads: `lua/custom/plugins/` holds only upstream's loader, and
      it finds no sibling modules. Our specs stay retrievable from `custom_config`.
- [x] Boot `NVIM_APPNAME=nvim-trial nvim` — `vim.pack` installed **19 plugins**
- [x] Stock kickstart verified working
- [x] Startup recorded

### Results

Startup, headless, three runs: **85 / 96 / 68 ms** (19 plugins).
Not comparable to the 120–173 ms baseline yet — that config has 76 plugins.

Functional checks all pass:

| Check | Result |
| ----- | ------ |
| `#vim.pack.get()` | 19 |
| treesitter lua parser | OK |
| `require` telescope / conform / blink.cmp / mason / which-key / gitsigns / fidget / mini.ai | all OK |
| `lua_ls` configured | true |
| colorscheme | `tokyonight-night` |
| errors on clean boot | none |

11 treesitter parsers built into `~/.local/share/nvim-trial/site/parser/`.

### Gotchas found (relevant to later phases)

- **Headless does not block on the install prompt.** `vim.pack`'s `confirm`
  defaults to `true`, but under `--headless` it proceeds automatically. No need to
  pass `confirm = false` for scripted boots.
- **Clone failures are transient and resumable.** `mini.nvim` died once with
  `GnuTLS recv error (-24)` / `early EOF` mid-clone. Simply re-running the boot
  installed it — `vim.pack` keeps what's already on disk. Expect this on big repos;
  it is not a config error.
- **Treesitter installs need a live session.** With `-c 'qa!'` nvim exits before
  parser builds finish, so they re-download every run. Give it time:
  `nvim --headless -c 'lua vim.wait(150000, function() return false end)' -c 'qa!'`
- **Parsers land in `site/parser/`**, not under the plugin dir.

## Phase 2 — re-apply our `init.lua` changes (28 hunks)

Line ranges refer to `custom_config:init.lua`. Work top-down; boot after each
group.

### Options, keymaps, diagnostics

- [x] 1 · `84-92` (+3) — mise shims prepended to `PATH` for LSP/formatter discovery
- [x] 2 · `94-114` (+5/-1) — `have_nerd_font`, related globals
- [x] 3 · `120-138` (+13) — custom options block
- [x] 4 · `183-237` (+43) — `termguicolors` + options for nvim-notify etc.
- [x] 5 · `246-271` (+20/-1) — `vim.diagnostic.config`, incl. the `on_jump` fix
- [x] 6 · `299-320` (+16) — tab management keymaps
- [x] 7 · `327-381` (+49) — Python `<leader>mi` type-ignore helper + more keymaps

### Plugin-adjacent config still living in `init.lua`

- [x] 8 · `432-438` (+1) — gitsigns `current_line_blame`
- [x] 9 · `467-476` (+1/-1) — which-key `<leader>b` group
- [x] 10 · `508-514` (+1) — todo-comments tweak
- [x] 11 · `536-560` (+15/-5) — telescope `defaults`
- [x] 12 · `565-593` (+17/-3) — telescope keymaps (`<leader>sf` etc.)
- [x] 13 · `648-693` (+40) — custom telescope picker
- [x] 14 · `704-712` (+3/-1) — opts tweak
- [x] 15 · `714-725` (+6) — blink.cmp capabilities wiring

### LSP — the big one

- [x] 16 · `820-987` (**+160**/-1) — full LSP server table (pyright, ruff, lua_ls,
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

`vim.pack` has no `event`/`ft`/`cmd`/`keys` system — only a `load` option
(boolean, or a function "fully responsible for loading plugin", per
`:help pack.txt`). Our current setup uses **94 distinct triggers**:

| Trigger type | Distinct triggers |
| ------------ | ----------------- |
| `keys`       | 65                |
| `cmd`        | 18                |
| `event`      | 6                 |
| `ft`         | 5                 |

### Prior art (checked 2026-07-19)

- **Kickstart itself dropped lazy-loading.** The migration author, `oriori1703`,
  in [kickstart#1630](https://github.com/nvim-lua/kickstart.nvim/issues/1630):
  *"I'm experimenting with migrating to `vim.pack` despite the missing lazy
  loading functionality."* Upstream has no answer to copy — [PR #2005](https://github.com/nvim-lua/kickstart.nvim/pull/2005)
  simply doesn't lazy-load.
- **The vim.pack author advises restraint.** echasnovski's
  [guide](https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack):
  *"vim.pack is designed with lazy loading in mind, but definitely not as a front
  and center use case. Use it moderately."* and warns that *"extreme lazy loading
  usually comes with a hidden cognitive overhead both when using and maintaining
  the config."* He frames two useful modes: **load-not-during-startup** (cheap,
  big win) vs **load-just-before-needed** (expensive, marginal win).
- **A real 72-plugin migration got *faster* without per-trigger lazy-loading.**
  [Fredrik Averpil](https://fredrikaverpil.github.io/blog/2026/04/15/from-lazy.nvim-to-vim.pack/)
  abandoned `event`/`ft`/`cmd`/`keys` entirely, deferred everything behind
  `VimEnter` via a small queue, and reports **40 ms with 72 plugins** — *"actually
  starts up faster than with lazy.nvim."* Our config is 76 plugins at 120–173 ms,
  so this is a directly comparable datapoint.
- **Neovim core has no lazy-loading on the roadmap.** [#34763](https://github.com/neovim/neovim/issues/34763)
  is the `vim.pack` tracking issue; nothing there adds declarative triggers.

### Three options, cheapest first

**Option A — defer everything past startup (recommended).** No per-plugin
triggers at all. Colorscheme and anything affecting first draw loads eagerly;
everything else goes behind `vim.schedule()` or a `VimEnter` queue:

```lua
vim.schedule(function()
  vim.pack.add { 'https://github.com/...' }
end)
```

This is echasnovski's "load not during startup" mode and what Averpil shipped.
It replaces all 94 triggers with roughly one mechanism.

**Option B — `lz.n` for declarative triggers.** [lumen-oss/lz.n](https://github.com/lumen-oss/lz.n)
supports `keys`/`ft`/`cmd`/`event`/`colorscheme` with a spec shape close to
lazy.nvim's, and plugs into vim.pack as a `load` function:

```lua
vim.pack.add { 'https://github.com/lumen-oss/lz.n' }
vim.pack.add({
  { src = 'https://github.com/nvim-telescope/telescope.nvim', data = { cmd = 'Telescope' } },
}, { load = require('lz.n').load })
```

Requires Neovim >= 0.12 (we're on 0.12.2). **Caveat that matters for us:** until
[neovim#35550](https://github.com/neovim/neovim/issues/35550) is fixed (still open
as of 2026-07-19 — `nvim_exec_autocmds` rejects mixed list/map tables), `keys`
cannot be passed through vim.pack's `data` field, so key specs must be registered
via a direct `require('lz.n').load { ... }` call instead. Since `keys` is 65 of
our 94 triggers, that workaround is the common path, not an edge case.

**Option C — hand-written autocmds/keymap stubs per trigger.** ~5–10 lines of
boilerplate × 94, with edge cases around visual-mode maps, expr maps, which-key
registration, and buffer-local scope. Only worth it for a handful of plugins that
Options A and B can't cover.

### Decision procedure

- [ ] Measure eager-everything startup
- [ ] If within ~2× baseline: **stop**, ship it eager (Option A already applied)
- [ ] If slow: apply Option A broadly, re-measure
- [ ] Only if *specific* plugins still hurt: Option B for those, or C as last resort

Candidate first deferrals if needed: `harpoon` (5.9 ms), `schemastore.nvim`
(4.2 ms), `yazi.nvim` (2.5 ms), `markdown-preview.nvim`, `remote-nvim.nvim`, the
DAP stack.

### Other things lazy.nvim did that nobody's library replaces

Per Averpil's writeup, budget for these regardless of which option we pick:

- [ ] **Cross-plugin config.** No dependency graph in `vim.pack`; he used a
      `_G.Config` registry with deep-merge to share settings between plugins.
- [ ] **Ordering.** `vim.pack.add` loads in list order — dependencies go first, by hand.
- [ ] **`build` steps.** Wire `PackChanged` autocmds manually.

## Done criteria

- [ ] `:checkhealth` clean
- [ ] LSP attaches for Python and Lua; ruff diagnostics appear
- [ ] Format-on-save works for all 10 allow-listed filetypes
- [ ] Debugger starts (`<leader>d` keymaps); neotest runs a pytest test
- [ ] Telescope, neo-tree, neogit, harpoon, toggleterm all usable
- [ ] Doppler loader still works from its two keymaps
- [ ] Startup time acceptable vs baseline
- [ ] Daily-drive it via `NVIM_APPNAME=nvim-trial` for a week before merging
