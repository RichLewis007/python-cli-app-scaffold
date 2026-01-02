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

### 3. Next Steps in Your New Project

After copying the scaffold, switch to your new project directory and read the getting started guide:

```bash
cd <your-project-directory>
cat Next-steps-after-copying-scaffold.md
```

**📖 [Next-steps-after-copying-scaffold.md](Next-steps-after-copying-scaffold.md)** contains:

- Setting up dependencies with `uv sync`
- Testing your CLI tool locally
- Installing system-wide (editable mode recommended for development)
- Development workflow and best practices
- Running tests and code quality checks
- Adding new commands
- Customization tips

> **Note:** The next steps guide is automatically copied to your new project directory. Read it there for instructions specific to your new project.

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

For development instructions, see the [Next-steps-after-copying-scaffold.md](Next-steps-after-copying-scaffold.md) guide, which covers:

- Development workflow (editable installs, testing locally)
- Using `uv` for dependency management
- Running tests and code quality checks
- Using the optional Makefile
- Setting up pre-commit hooks

> **Note:** Development instructions are in the next steps guide, which is copied to your new project directory when you use the scaffold.

## Customization

The scaffold automatically customizes package names, command names, and imports when you copy it. For manual customization after copying, see the [Next-steps-after-copying-scaffold.md](Next-steps-after-copying-scaffold.md) guide.

For adding new commands and working with Typer, see the [Typer documentation](https://typer.tiangolo.com/).

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
