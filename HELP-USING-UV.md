# Using uv for Python Development

If you're new to `uv`, this guide will help you get started with all the basics you need for Python development.

**Author:** [Rich Lewis](https://RichLewis.com) - GitHub [@RichLewis007](https://github.com/RichLewis007)

## What is uv?

`uv` is a fast Python package installer and resolver written in Rust. It's designed to be a drop-in replacement for `pip`, `pip-tools`, `virtualenv`, and more. Key features include:

- **Fast**: Written in Rust, significantly faster than traditional Python tools
- **Python Management**: Automatically installs and manages Python versions
- **Dependency Resolution**: Fast and reliable dependency resolution
- **Virtual Environments**: Built-in virtual environment management
- **Project Management**: Handles project dependencies and environments seamlessly

## Installation

### Installing uv

Install `uv` using the official installer:

**macOS and Linux:**

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Windows (PowerShell):**

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

**Alternative methods:**

- Via pip: `pip install uv`
- Via pipx: `pipx install uv`
- Via Homebrew (macOS): `brew install uv`

After installation, you may need to restart your terminal or run:

```bash
source $HOME/.cargo/env  # If using the default installation
```

Or add `uv` to your PATH. See the [uv installation guide](https://docs.astral.sh/uv/getting-started/installation/) for platform-specific details.

### Updating uv

If you installed `uv` using the standalone installer, you can update it:

```bash
uv self update
```

### Verifying Installation

Check that `uv` is installed:

```bash
uv --version
```

## Python Version Management

### Installing Python Versions

`uv` can automatically install and manage Python versions for you. To install Python 3.14.2:

```bash
uv python install 3.14.2
```

You can install any Python version, or multiple versions at once:

```bash
uv python install 3.12
uv python install 3.11
uv python install 3.14.2
# Or install multiple at once:
uv python install 3.10 3.11 3.12
```

### Listing Installed Python Versions

See what Python versions you have installed:

```bash
uv python list
```

To see only installed versions (not available ones):

```bash
uv python list --only-installed
```

### Using Python in Projects

When you run `uv sync` or `uv run` in a project, `uv` will automatically use the correct Python version as specified in `pyproject.toml`.

You can also explicitly pin a Python version for a project:

```bash
uv python pin 3.14.2
```

This creates a `.python-version` file that `uv` will use for this project.

### Finding Python Installation Location

Find where a specific Python version is installed:

```bash
uv python find 3.14.2
```

## Project Setup

### Syncing Dependencies

When you clone or start a project, sync all dependencies:

```bash
uv sync
```

This will:

- Create a virtual environment (if it doesn't exist)
- Install the correct Python version (if needed)
- Install all project dependencies from `pyproject.toml`
- Install dev dependencies (from `[dependency-groups]`)

### Running Commands in the Project Environment

Run any command in the project's virtual environment:

```bash
uv run python script.py
uv run pytest
uv run mycli --help
```

You can also run Python interactively:

```bash
uv run python
```

### Checking Python Version

Verify which Python version is being used:

```bash
uv run python --version
```

## Dependency Management

### Adding Dependencies

Add a new dependency to your project:

```bash
uv add requests
```

This will:

- Add the package to `pyproject.toml` under `[project.dependencies]`
- Install it in the virtual environment
- Update the lock file (if using one)

Add a specific version:

```bash
uv add "requests>=2.31.0"
```

### Adding Dev Dependencies

Add a development dependency:

```bash
uv add --dev pytest
```

Or using the modern dependency groups syntax:

```bash
uv add --group dev pytest
```

This adds it to `[dependency-groups]` in `pyproject.toml`.

### Removing Dependencies

Remove a dependency:

```bash
uv remove requests
```

Remove a dev dependency:

```bash
uv remove --dev pytest
```

Or:

```bash
uv remove --group dev pytest
```

### Updating Dependencies

Update all dependencies to their latest compatible versions:

```bash
uv sync --upgrade
```

Update a specific package:

```bash
uv add "requests@latest"
```

### Listing Dependencies

See what's installed in your project:

```bash
uv pip list
```

## Virtual Environments

### Understanding uv's Virtual Environments

`uv` automatically manages virtual environments for you. When you run `uv sync`, it creates a virtual environment in `.venv` (or uses the one specified in your configuration).

### Activating the Virtual Environment

While `uv run` automatically uses the project's virtual environment, you can also activate it manually:

```bash
source .venv/bin/activate  # On macOS/Linux
.venv\Scripts\activate     # On Windows
```

However, with `uv`, you typically don't need to activate - just use `uv run`!

### Virtual Environment Location

By default, `uv` creates virtual environments in `.venv` in your project directory. You can create one with a specific Python version:

```bash
uv venv --python 3.14.2
```

Or specify a custom name:

```bash
uv venv --python 3.14.2 custom-env-name
```

## Common Development Workflows

### Starting a New Project

1. **Create your project directory:**

   ```bash
   mkdir my-project
   cd my-project
   ```

2. **Initialize with uv:**

   ```bash
   uv init
   ```

   Or if you're using this scaffold, copy it and customize it.

3. **Add dependencies:**

   ```bash
   uv add typer rich
   ```

4. **Sync the environment:**

   ```bash
   uv sync
   ```

5. **Run your code:**
   ```bash
   uv run python src/my_project/main.py
   ```

### Working with an Existing Project

1. **Clone the repository:**

   ```bash
   git clone https://github.com/user/project.git
   cd project
   ```

2. **Sync dependencies:**

   ```bash
   uv sync
   ```

3. **Run commands:**
   ```bash
   uv run pytest
   uv run mycli --help
   ```

### Running Tests

Run tests with pytest:

```bash
uv run pytest
```

With coverage:

```bash
uv run pytest --cov
```

### Code Quality Tools

Run linting:

```bash
uv run ruff check .
```

Run type checking:

```bash
uv run mypy src/
```

## Advanced Features

### Lock Files

`uv` can generate lock files for reproducible builds:

```bash
uv lock
```

This creates a `uv.lock` file that pins exact versions of all dependencies.

### Installing from Lock Files

Install exactly what's in the lock file:

```bash
uv sync --frozen
```

### Tool Installation

Install tools globally (like `pytest`, `black`, etc.):

```bash
uv tool install pytest
```

This installs tools in an isolated environment managed by `uv`.

### Project vs Global Tools

- **Project tools**: Installed via `uv add --dev` or `uv add --group dev`
- **Global tools**: Installed via `uv tool install`

Use project tools for development dependencies, global tools for system-wide utilities.

## Troubleshooting

### uv can't find Python 3.14.2

If `uv` can't find Python 3.14.2, make sure you've installed it:

```bash
uv python install 3.14.2
```

### Python version mismatch

If you see version mismatch errors, ensure your `pyproject.toml` specifies the correct Python version and that you've installed it:

```bash
uv python install 3.14.2
uv sync
```

### Dependency conflicts

If you encounter dependency conflicts, try:

```bash
uv sync --upgrade
```

Or check your `pyproject.toml` for conflicting version requirements.

### Virtual environment issues

If you're having issues with the virtual environment, you can recreate it:

```bash
rm -rf .venv
uv sync
```

## Quick Reference

### Essential Commands

```bash
# Python management
uv python install 3.14.2    # Install Python version
uv python list               # List installed versions
uv python pin 3.14.2         # Pin version for project

# Dependency management
uv sync                      # Sync all dependencies
uv add package              # Add a dependency
uv add --dev package        # Add dev dependency
uv remove package           # Remove dependency
uv sync --upgrade           # Update all dependencies

# Running commands
uv run python script.py     # Run in project environment
uv run pytest               # Run tests
uv run mycli --help         # Run CLI tool

# Virtual environments
uv venv                     # Create virtual environment
uv sync                     # Create venv and sync (automatic)
```

## More Information

For comprehensive documentation, see:

- [uv Documentation](https://docs.astral.sh/uv/)
- [uv Python Management](https://docs.astral.sh/uv/python/)
- [uv Project Management](https://docs.astral.sh/uv/projects/)
- [uv Dependency Management](https://docs.astral.sh/uv/pip/)

## Author

**[Rich Lewis](https://RichLewis.com)** - [GitHub @RichLewis007](https://github.com/RichLewis007)
