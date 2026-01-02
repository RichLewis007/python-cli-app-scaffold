# Next Steps: Getting Started with Your New CLI Project

Welcome! You've successfully copied the scaffold. This guide will help you get started with your new CLI project.

## What Just Happened?

The scaffold has been customized for your project:

- ✅ Package directory renamed to match your project name
- ✅ All imports updated to use your package name
- ✅ Command name set in `pyproject.toml` and `main.py`
- ✅ Project description updated
- ✅ Git history removed (fresh start)

## Quick Start

### 1. Set Up Local Project Development Environment

First, set up dependencies for **local project development** (in your project directory):

```bash
uv sync
```

This creates a **local virtual environment** (`.venv` in your project) and:

- Creates a virtual environment (`.venv`) in your project directory
- Installs Python 3.14.2 (if needed)
- Installs all project dependencies
- Installs development dependencies (pytest, ruff, mypy)
- Installs your package in development mode (so you can test it locally)

> **Note:** This sets up your project for local development. The CLI tool is only available within this project directory using `uv run`.

### 2. Test Your CLI Tool Locally

Test your CLI tool in the local project environment:

```bash
# Run the CLI tool using uv (uses the local .venv)
uv run <your-command-name> --help

# Or run as a Python module
uv run python -m <your_package_name>.main --help
```

Replace `<your-command-name>` with the command name you chose, and `<your_package_name>` with your package name (with underscores).

### 3. Install System-Wide (Optional - For Development)

To use your CLI tool **from anywhere** on your system (not just in the project directory), install it system-wide in uv's isolated tool environment:

```bash
chmod +x install.sh
./install.sh --editable
```

Or use the short form:

```bash
./install.sh -e
```

**What this does:**

- Installs your CLI tool into **uv's isolated tool environment** (separate from your project's `.venv`)
- Links the executable to your system PATH (usually `~/.local/bin`)
- Makes the command available from any directory
- Uses **editable mode** so changes to source code are reflected immediately

**Why editable mode?** This is the standard practice for Python CLI development. Changes to your source code will be reflected immediately without reinstalling.

> **Key Difference:**
>
> - `uv sync` → Sets up **local project development** (`.venv` in project, use `uv run`)
> - `./install.sh --editable` → Sets up **system-wide access** (uv tool environment, use from anywhere)

### 4. Verify Installation

Test that your CLI tool is working:

```bash
<your-command-name> --help
<your-command-name> --version
```

### 5. Uninstall (If Needed)

To remove the system-wide installation:

```bash
uv tool uninstall <your-package-name>
```

Replace `<your-package-name>` with your package name from `pyproject.toml` (the `name` field, typically with hyphens like `my-tool`).

**What this does:**
- Removes the tool from uv's tool environment
- Removes the command from your PATH
- Stops exposing the command system-wide

> **Note:** This only uninstalls the system-wide installation. Your local project environment (`.venv` created by `uv sync`) remains untouched. If you want to clean that up, you can delete the `.venv` directory manually.

## Development Workflow

### Making Changes

1. **Edit your code** in `src/<your_package_name>/main.py`
2. **Test immediately** - if installed in editable mode, changes are live!
3. **Run tests**: `uv run pytest`
4. **Check code quality**: `uv run ruff check .`

### Running During Development

You have several options:

**Option 1: Local project development (using `uv sync` setup)**

```bash
# Uses the local .venv created by uv sync
uv run <your-command-name> --help
# or
uv run python -m <your_package_name>.main --help
```

- ✅ No system-wide installation needed
- ✅ Works only in the project directory
- ✅ Uses the local `.venv` virtual environment

**Option 2: System-wide (editable install in uv tool environment)** - Recommended for active development

```bash
./install.sh --editable
<your-command-name> --help  # Run from anywhere
```

- ✅ Available from any directory
- ✅ Uses uv's isolated tool environment (separate from project `.venv`)
- ✅ Changes reflect immediately (editable mode)

**Option 3: Activate local venv manually (optional)**

```bash
source .venv/bin/activate  # Activate local venv
uv run <your-command-name> --help
```

- Same as Option 1, but with explicit venv activation

### Adding New Commands

Edit `src/<your_package_name>/main.py` to add new commands:

```python
@app.command()
def your_new_command(
    arg: str = typer.Argument(..., help="Description"),
    flag: bool = typer.Option(False, "--flag", help="Flag description"),
) -> None:
    """Command description."""
    console.print(f"Doing something with {arg}")
```

See the [Typer documentation](https://typer.tiangolo.com/) for more examples.

### Running Tests

```bash
# Run all tests
uv run pytest

# Run with coverage
uv run pytest --cov

# Run specific test file
uv run pytest tests/test_main.py
```

### Code Quality

```bash
# Check for issues
uv run ruff check .

# Auto-fix issues
uv run ruff check --fix .

# Format code
uv run ruff format .

# Type checking
uv run mypy src/
```

Or use the Makefile (if you have `make`):

```bash
make test      # Run tests
make lint       # Check code
make lint-fix   # Fix issues
make format     # Format code
make check      # Run all checks
```

## Project Structure

Your project structure:

```
.
├── src/
│   └── <your_package_name>/     # Your package (customized)
│       ├── __init__.py
│       └── main.py              # Main CLI entry point
├── tests/                       # Test directory
│   ├── __init__.py
│   └── test_main.py
├── pyproject.toml               # Project configuration
├── install.sh                   # Installation script
├── README.md                    # Project documentation
├── HELP-USING-UV.md             # Guide for using uv
├── Makefile                     # Development shortcuts (optional)
└── .pre-commit-config.yaml      # Pre-commit hooks (optional)
```

## Customization

### Update Author Information

Edit `pyproject.toml` to update author information:

```toml
authors = [
    {name = "Your Name", email = "your.email@example.com"},
]
```

### Update Project URLs

Edit `pyproject.toml` to add your repository URLs:

```toml
[project.urls]
Homepage = "https://github.com/yourusername/your-repo"
Repository = "https://github.com/yourusername/your-repo"
Issues = "https://github.com/yourusername/your-repo/issues"
```

### Add Dependencies

```bash
# Add a runtime dependency
uv add requests

# Add a development dependency
uv add --dev pytest-mock
```

## Production Deployment

When you're ready to release:

1. **Update version** in `pyproject.toml`
2. **Install normally** (not editable):
   ```bash
   ./install.sh --normal
   ```
3. **Test the installation**
4. **Distribute** (if desired) - see [Python Packaging Guide](https://packaging.python.org/)

## Getting Help

- **uv usage**: See `HELP-USING-UV.md` in this directory
- **Typer docs**: https://typer.tiangolo.com/
- **Rich docs**: https://rich.readthedocs.io/
- **Python packaging**: https://packaging.python.org/

## Next Steps

1. ✅ Sync dependencies: `uv sync`
2. ✅ Test locally: `uv run <your-command-name> --help`
3. ✅ Install editable: `./install.sh --editable`
4. ✅ Start coding: Edit `src/<your_package_name>/main.py`
5. ✅ Write tests: Add tests in `tests/`
6. ✅ Iterate: Make changes, test, repeat!

Happy coding! 🚀
