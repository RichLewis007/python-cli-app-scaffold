"""Main CLI application entry point."""

import sys
from pathlib import Path
from typing import Optional

import typer
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.text import Text

from python_cli_app_scaffold import __version__

# Initialize Typer app and Rich console
app = typer.Typer(
    name="mycli",
    help="A modern Python CLI utility scaffold",
    add_completion=False,
    rich_markup_mode="rich",
)
console = Console()


def version_callback(value: bool) -> None:
    """Show version and exit."""
    if value:
        console.print(f"mycli version {__version__}", style="bold green")
        raise typer.Exit()


@app.callback()
def main(
    version: Optional[bool] = typer.Option(
        None,
        "--version",
        "-v",
        help="Show version and exit",
        callback=version_callback,
        is_eager=True,
    ),
) -> None:
    """A modern Python CLI utility scaffold."""
    pass


@app.command()
def hello(
    name: str = typer.Argument(..., help="Name to greet"),
    fancy: bool = typer.Option(False, "--fancy", "-f", help="Use fancy formatting"),
) -> None:
    """Greet someone by name."""
    try:
        if fancy:
            text = Text()
            text.append("Hello, ", style="bold blue")
            text.append(name, style="bold green underline")
            text.append("! 👋", style="bold yellow")
            console.print(text)
        else:
            console.print(f"Hello, {name}!")
    except Exception as e:
        console.print(f"[red]Error:[/red] {e}", style="bold")
        raise typer.Exit(code=1)


@app.command()
def info() -> None:
    """Show information about this CLI tool."""
    table = Table(title="CLI Tool Information", show_header=True, header_style="bold magenta")
    table.add_column("Property", style="cyan", no_wrap=True)
    table.add_column("Value", style="green")

    table.add_row("Name", "mycli")
    table.add_row("Version", __version__)
    table.add_row("Python Version", f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}")

    console.print(table)


@app.command()
def example(
    file: Optional[Path] = typer.Option(None, "--file", "-f", help="Path to a file"),
    count: int = typer.Option(1, "--count", "-c", help="Number of times to repeat"),
) -> None:
    """Example command showing file operations and options."""
    if file:
        if file.exists():
            console.print(f"[green]File exists:[/green] {file}")
            console.print(f"[green]Size:[/green] {file.stat().st_size} bytes")
        else:
            console.print(f"[red]File not found:[/red] {file}")
            raise typer.Exit(code=1)
    else:
        panel = Panel(
            f"This is an example command that repeats {count} time(s).\n"
            "Use --file to specify a file path.",
            title="Example Command",
            border_style="blue",
        )
        console.print(panel)


if __name__ == "__main__":
    app()
