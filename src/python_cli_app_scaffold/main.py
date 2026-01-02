"""Main CLI application entry point."""

import typer
from rich.console import Console
from rich.text import Text

from python_cli_app_scaffold import __version__

# Initialize Typer app and Rich console
app = typer.Typer(
    name="mycli",
    help="A modern Python CLI utility scaffold",
    add_completion=False,
)
console = Console()


@app.command()
def hello(
    name: str = typer.Argument(..., help="Name to greet"),
    fancy: bool = typer.Option(False, "--fancy", "-f", help="Use fancy formatting"),
) -> None:
    """Greet someone by name."""
    if fancy:
        text = Text()
        text.append("Hello, ", style="bold blue")
        text.append(name, style="bold green underline")
        text.append("! 👋", style="bold yellow")
        console.print(text)
    else:
        console.print(f"Hello, {name}!")


@app.command()
def version() -> None:
    """Show the version of this CLI tool."""
    console.print(f"mycli version {__version__}", style="bold green")


if __name__ == "__main__":
    app()
