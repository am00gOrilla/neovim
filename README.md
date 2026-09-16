# Neovim development config

Python, Node.js/TypeScript, Go, and C/C++ development with completion, diagnostics,
formatting, debugging, project search, and terminal tasks. Existing Rust support,
themes, sessions, and navigation shortcuts are retained.

Requires **Neovim 0.12+** for the installed Tree-sitter main branch. Verified locally
with Neovim 0.12.5 on macOS. Keep `lazy-lock.json` with the config so plugin versions
can be restored together.

## Setup

Install Git, ripgrep (`rg`), `fzf`, `fd`, Python with venv support, Node.js/npm, Go,
and a C/C++ compiler. CMake/CTest are needed for the C/C++ build/test shortcuts.
A Nerd Font and your platform's clipboard provider enable icons and clipboard keys.

On a fresh machine, open Neovim and run these in order, allowing each to finish:

```vim
:Lazy restore
:MasonToolsInstall
:DevParsersInstall
```

Mason installs language servers, formatters, the Tree-sitter CLI, and the Python,
Node.js, Go, and C/C++ debug adapters. Parser and tool installation is explicit;
opening Neovim does not schedule a full tool/parser installation. To update later,
use `:Lazy update`, `:MasonToolsUpdate`, and `:TSUpdate`.

Language runtimes and project dependencies belong to each project. Mason does not
replace `uv sync`, your Node package manager, `go mod download`, or the C/C++ build.
Launch Neovim from the project directory so project-specific runtime managers and
`.vscode/launch.json` discovery have the expected context.

## Language workflows

| Language | Completion/diagnostics | Formatting on save | Debugging |
| --- | --- | --- | --- |
| Python | Pyrefly + Ruff | Ruff fixes, import sorting, then formatting | debugpy |
| JS/TS/React | TypeScript language server + ESLint in configured projects | prettierd (supports project-local Prettier) | VS Code JS debugger |
| Go | gopls | goimports, then gofumpt | Delve |
| C/C++ | clangd with background index | clang-format | CodeLLDB |

### Python environments

For an existing uv project, run `uv sync`. For a new environment, use `uv venv` or
`python3 -m venv .venv`. Install your project's dependencies and `pytest` there.

Run/debug interpreter priority is the buffer's selected environment, project
`.venv` or `venv`, the shell environment active when Neovim started, then the original
Python on PATH. Pyrefly receives the project interpreter; VenvSelect updates the
language servers when you select a different environment. Pyrefly's own explicit
interpreter configuration takes precedence for type checking.

The selected interpreter is sent through Pyrefly's
[initialization options](https://pyrefly.org/en/docs/IDE/#pythonpath), including
when VenvSelect restarts the server. A broken project environment (for example,
after removing its underlying Python installation) warns once instead of silently
falling back. Run `uv sync --frozen` from a uv project to rebuild it from the lockfile,
then restart Neovim to refresh the interpreter and diagnostics.

- `<Space>vs`: select an environment; `<Space>vc`: restore a cached selection.
- `:lua print(require('dev').python())`: inspect the run/debug interpreter.
- debugpy lives in Mason's environment, so it need not be installed in every project.

### Node.js / TypeScript

Install dependencies using the project's package manager. ESLint needs the project's
ESLint package and configuration. The run shortcut lists `package.json` scripts;
`packageManager` or a local lockfile selects npm, pnpm, yarn, or bun. In a workspace
package without either, npm is the fallback; use the terminal for custom workspace commands.

`<F5>` can launch a JavaScript file or attach to a process started with `--inspect`.
For transpiled TypeScript/TSX, use your build's source maps and a project launch
configuration, or attach to the project's running dev process. The generic Node
launch configuration does not transpile TSX or configure custom loaders.

### Go

Run builds/tests from a file within a module. Run uses the current directory's whole
package; test and build cover `./...` from the nearest module/workspace root. `<F5>`
offers package debugging, package tests, and process attachment.

### C/C++

Generate a compile database so clangd sees your actual include paths and flags:

```sh
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Debug
```

clangd discovers a conventional `build/compile_commands.json`. For a different build
directory, configure `CompileFlags.CompilationDatabase` in the project's `.clangd`.
Build before starting the debugger, then choose the executable with `<F5>`.
The build/test shortcuts default to `build`; override for a buffer with
`:let b:cmake_build_dir = 'out/debug'`. Use the terminal for Make/Meson/custom builds.

## Main shortcuts

Leader is **Space**. Press it to browse which-key help.

| Keys | Action |
| --- | --- |
| `<C-p>` | Asynchronous project file search, sorted by directory proximity |
| `<Space>ff` / `<Space>fg` | Project files / live grep |
| `<Space>fs` / `<Space>fd` | Document symbols / diagnostics |
| `<Space>e` / `<Space>E` | Switch focus between explorer and editor / reveal current file |
| `<C-b>` | Show / hide the explorer sidebar |
| `gd` / `gr` / `gi` / `K` | Definition / references / implementation / hover |
| `<Space>cr` / `<Space>ca` | Rename / code action |
| `<Space>ce` | Diagnostic popup |
| `<Space>gf` / `rf` | Format buffer or visual selection / format buffer |
| `<Space>uf` | Toggle format on save for this buffer |
| `<Space>mr` / `:DevRun` | Run Python file, Go package, or choose a Node script |
| `<Space>mt` / `:DevTest` | pytest, package-manager test, Go tests, or CTest |
| `<Space>mb` / `:DevBuild` | Node build script, Go build, or CMake build |
| `<F5>` / `<Space>b` | Start/continue debugger / toggle breakpoint |
| `<F2>` / `<F3>` / `<F4>` | Step into / over / out |
| `<F6>` / `<F7>` / `<F8>` | Conditional breakpoint / terminate / run last |
| `<Space>du` / `<Space>dl` | Toggle debugger UI / load project `.vscode/launch.json` |
| `<C-\>` / `<Space>th` / `<Space>tf` | Toggle terminal / horizontal / floating |
| `<Tab>` / `<S-Tab>` / `<Space><Space>` | Next / previous / last buffer |
| `<Space>ss` / `<Space>sl` / `<Space>sd` | Save / list / delete sessions |
| `<Space>gp` / `<Space>gb` / `gfd` | Git hunk / blame / file diff |
| `<Space>u` | Undo tree |
| `zR` / `zM` | Open / close all folds |
| `<Space>tsm` | Theme selector |
| `<Space>y` / `<Space>p` | Clipboard yank / paste |

Tasks save the current buffer before running and keep output in a terminal buffer.
Use `:noautocmd write` to bypass formatting for one save. Automatic formatting has a
500 ms limit and skips buffers over 1 MiB; manual formatting remains available.

### Explorer and editor focus

In normal mode, `Space e` moves to the explorer, opening it if necessary. Press it
again to return to your last code split. The sidebar stays open during focus changes
and when you open a file with Enter. Expanded folders stay expanded as you browse.

Inside the explorer, Tab, Shift-Tab, Esc, or Ctrl-l return to the last editor without
closing the sidebar or cycling code buffers. Ctrl-b explicitly shows/hides the
sidebar; showing it from the editor keeps focus on your code. `Space E` reveals the
current file, while `Space nf` always focuses the filesystem explorer.

## Review changes

- Replaced the removed Mason LSP handler API with `vim.lsp.config` / `vim.lsp.enable`.
- Deferred debugging, search, explorer, Git tools, and other optional plugins.
- Removed unconditional parser installation and startup tool checks.
- Used Conform's stdin formatters, with Ruff fixes before the final format pass.
- Corrected React/shell parser-to-filetype handling and kept Tree-sitter indentation.
- Pinned Telescope to v0.2.1, whose previews use Neovim's Tree-sitter API instead of the removed `ft_to_lang` API.
- Added missing Node debug support, managed debugpy/Delve installation, and portable CodeLLDB launch.
- Stopped diagnostic updates during insertion and automatic popups every 100 ms.
- Added language-specific indentation, persistent undo, and project tasks.
- Fixed file-search shell/path handling and Git worktree/non-Git project discovery.

API references: [Mason migration](https://github.com/mason-org/mason-lspconfig.nvim/blob/main/CHANGELOG.md),
[Pyrefly interpreter settings](https://pyrefly.org/en/docs/IDE/),
[Conform](https://github.com/stevearc/conform.nvim),
[Tree-sitter](https://github.com/nvim-treesitter/nvim-treesitter).

## Checks

On this machine, five warm headless startup measurements had a median of **180.5 ms
before / 41.0 ms after** (about 77% lower). Plugins loaded during initial setup fell
from **46 to 16**. These measurements exclude language-server readiness and full UI
interaction; the first startup on a fresh machine will differ.

Use `:checkhealth vim.lsp`, `:ConformInfo`, `:checkhealth mason`, and `:Lazy profile`
when troubleshooting. `:DapShowLog` shows debugger failures. Restart Neovim after
changing plugin setup. Environment/task regression checks can be run with:

```sh
nvim --headless -u NONE -l tests/dev.lua
nvim --headless -u NONE -l tests/python-lsp.lua
```

To check actual Telescope file previews and highlighting with the installed plugins/parsers:

```sh
nvim --headless -i NONE -c 'luafile tests/telescope-preview.lua'
```

To check explorer focus, opening files, and sidebar visibility with multiple code splits:

```sh
nvim --headless -i NONE -c 'luafile tests/explorer.lua'
```
