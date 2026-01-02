# Python CLI Utility Scaffold

A modern, production-ready scaffold for building Python CLI utilities using the latest tools and best practices.

**Author:** [Rich Lewis](https://RichLewis.com) - GitHub [@RichLewis007](https://github.com/RichLewis007)

## Features

- 🚀 **Modern Tooling**: Uses `uv` for fast dependency management
- 🎯 **Typer Framework**: Type-safe CLI with automatic help generation
- 🎨 **Rich Output**: Beautiful terminal output with Rich library
- 📦 **src/ Layout**: Professional package structure
- 🔧 **Entry Points**: Install as system command (package name ≠ command name)
- ✅ **Testing Ready**: Includes pytest and coverage setup
- 🔍 **Code Quality**: Configured with ruff and mypy
- 📝 **Template Ready**: Easy to copy and customize for new projects

## Requirements

- **Python 3.14.2** (managed by uv) - [uv usage guide](HELP-USING-UV.md)
- **uv** package manager ([Installation guide](https://docs.astral.sh/uv/getting-started/installation/))
- **Bash 5** (macOS: `brew install bash`)

## Quick Start

### 1. Install uv and Python 3.14.2

**Install uv** (if not already installed):

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Install Python 3.14.2** using uv:

```bash
uv python install 3.14.2
```

> **New to uv?** See the [uv usage guide](HELP-USING-UV.md) for detailed instructions on using uv for Python development.

### 2. Copy the Scaffold to a new Project dir

Make the script executable and run it:

```bash
chmod +x copy-scaffold-for-use.sh
./copy-scaffold-for-use.sh
```

The script will:

1. **Prompt you for the new project directory name** - Enter the name for your new project directory
2. **Prompt you for the command name** - Enter the command name for your CLI tool (press Enter to use the package name as default)
3. **Prompt you for the app description** - Enter a description for your CLI tool (this will be set in `pyproject.toml`)
4. **Copy all scaffold files** - Copies all files (including hidden ones) to the new directory
5. **Clean up the copy** - Removes `.git` directory (so each new project starts fresh) and removes the `copy-scaffold-for-use.sh` script itself from the copy
6. **Automatically customize the project**:

   - **Package directory** (`src/python_cli_app_scaffold/`):

     - Renames to `src/<package_name>/` (where package name is derived from your project directory name, with underscores)

   - **Python files**:

     - Updates all import statements to use the new package name
     - Updates the command name in `main.py`

   - **`pyproject.toml`**:
     - Updates the package `name` field (uses hyphens, e.g., `my-tool`)
     - Updates the `description` field with your provided description
     - Updates the `[project.scripts]` entry with your command name (e.g., `mytool = "my_tool.main:app"`)
     - Updates pytest coverage path to use the new package name

The script automatically derives:

- **Package name (hyphenated)**: Used in `pyproject.toml` name field (e.g., `my-tool`)
- **Package name (underscored)**: Used for Python module/import paths (e.g., `my_tool`)
- Both are derived from your project directory name (converted to lowercase)

### 3. Edit the Python code to implement your CLI tool

### 4. Install this new CLI Tool to be used system-wide

Run the installation script:

```bash
chmod +x install.sh
./install.sh
```

The script will:

- Check for uv installation
- Ensure Python 3.14.2 is available
- Prompt for editable or normal installation
- Install the CLI tool into uv's isolated tool environment (under `uv tool dir`)
- Link executables to the tool executable directory (`uv tool dir --bin`)
- Help ensure the tool directory is in your PATH using `uv tool update-shell`

#### Installation Options

**Installation Locations** (applies to both install types):

Both editable and normal installs use the same directory structure:

- **Executable directory**: The executable is linked to the default uv/XDG executable directory (usually `$HOME/.local/bin`, unless you've set `$XDG_DATA_HOME/bin` to override it). See the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir/latest/) for details.

  Find this directory on your system:

  ```bash
  uv tool dir --bin
  ```

  Example output: `/Users/USERNAME/.local/bin`

  This directory should be in your `$PATH`, so the app will be executable from any directory in your terminal.

- **Tool environment**: The package is installed in uv's isolated tool environment (in an app-named folder).

  Find this directory:

  ```bash
  uv tool dir
  ```

  Example output: `/Users/USERNAME/.local/share/uv/tools`

**Installation Types:**

- **Editable install** (recommended for development):

  ```bash
  ./install.sh --editable
  # or
  ./install.sh -e
  ```

  Creates a symbolic link from the tool environment to your source directory. Changes to source code reflect immediately without reinstall. Perfect for active development.

- **Normal install** (production):

  ```bash
  ./install.sh --normal
  # or
  ./install.sh -n
  ```

  Copies the package into the tool environment as a static installation. Changes to source code won't be reflected until you reinstall. Use this for production deployments or when you want a stable, immutable installation.

- **Set default mode**:
  ```bash
  ./install.sh --set-default editable
  # or
  ./install.sh --set-default normal
  ```
  Saves your preference to `~/.python_cli_scaffold_config`

### 5. Verify Installation

```bash
mycli --help
mycli hello "World" --fancy
mycli version
```

## Project Structure

```
.
├── src/
│   └── python_cli_app_scaffold/  # Package directory (rename this)
│       ├── __init__.py
│       └── main.py                    # Main CLI entry point
├── tests/                             # Test directory
│   └── test_main.py
├── pyproject.toml                     # Project configuration
├── install.sh                         # Installation script
├── README.md
├── LICENSE
└── .gitignore
```

## Development

### Using uv

This project uses `uv` for dependency management. Key commands:

```bash
# Sync dependencies
uv sync

# Add a dependency
uv add <package-name>

# Add a dev dependency
uv add --dev <package-name>

# Run Python in the project environment
uv run python

# Run commands in the project environment
uv run pytest
uv run mycli --help
```

### Running Tests

```bash
uv run pytest
uv run pytest --cov        # With coverage
```

### Code Quality

```bash
# Linting with ruff
uv run ruff check .

# Type checking with mypy
uv run mypy src/
```

## Customization Guide

### Changing Package Name

1. Rename `src/python_cli_app_scaffold/` to `src/your_package_name/`
2. Update `pyproject.toml`:
   - Change `name = "your-package-name"`
   - Update `[project.scripts]` to use your package: `yourcli = "your_package_name.main:app"`
3. Update imports in `main.py`: `from your_package_name import __version__`

### Changing Command Name

1. In `pyproject.toml`, change the `[project.scripts]` key:
   ```toml
   [project.scripts]
   yourcommand = "your_package_name.main:app"
   ```
2. In `src/your_package_name/main.py`, update the `name` parameter:
   ```python
   app = typer.Typer(name="yourcommand", ...)
   ```

### Adding Commands

Add new commands to `main.py`:

```python
@app.command()
def your_command(
    arg: str = typer.Argument(..., help="Description"),
    flag: bool = typer.Option(False, "--flag", help="Flag description"),
) -> None:
    """Command description."""
    console.print(f"Doing something with {arg}")
```

See [Typer documentation](https://typer.tiangolo.com/) for more examples.

## Using as a Template

To use this scaffold for a new project, make the script executable and run it:

```bash
chmod +x copy-scaffold-for-use.sh
./copy-scaffold-for-use.sh
```

The script will handle copying and customizing the scaffold automatically. Then:

1. Edit the Python code to implement your CLI tool
2. Update author information in `pyproject.toml` if needed
3. Install and use!

## License

MIT License - see LICENSE file for details

## Author

**[Rich Lewis](https://RichLewis.com)** - [GitHub @RichLewis007](https://github.com/RichLewis007)

## Resources

- [uv Documentation](https://docs.astral.sh/uv/)
- [Typer Documentation](https://typer.tiangolo.com/)
- [Rich Documentation](https://rich.readthedocs.io/)
- [Python Packaging Guide](https://packaging.python.org/)
