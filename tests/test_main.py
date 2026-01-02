"""Tests for the main CLI application."""

from typer.testing import CliRunner

from python_cli_app_scaffold.main import app

runner = CliRunner()


def test_hello_command() -> None:
    """Test the hello command."""
    result = runner.invoke(app, ["hello", "World"])
    assert result.exit_code == 0
    assert "Hello, World" in result.stdout


def test_hello_command_fancy() -> None:
    """Test the hello command with fancy flag."""
    result = runner.invoke(app, ["hello", "World", "--fancy"])
    assert result.exit_code == 0
    assert "World" in result.stdout


def test_version_command() -> None:
    """Test the version command via --version flag."""
    result = runner.invoke(app, ["--version"])
    assert result.exit_code == 0
    assert "version" in result.stdout.lower()


def test_info_command() -> None:
    """Test the info command."""
    result = runner.invoke(app, ["info"])
    assert result.exit_code == 0
    assert "mycli" in result.stdout


def test_example_command() -> None:
    """Test the example command."""
    result = runner.invoke(app, ["example", "--count", "2"])
    assert result.exit_code == 0
    assert "example" in result.stdout.lower()


def test_help_command() -> None:
    """Test the help command."""
    result = runner.invoke(app, ["--help"])
    assert result.exit_code == 0
    assert "mycli" in result.stdout
