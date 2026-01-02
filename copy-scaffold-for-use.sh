#!/usr/bin/env bash

# file: copy-scaffold-for-use.sh
# Author: Rich Lewis - GitHub @RichLewis007

set -e  # Exit on error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get the parent directory (where the new project should be created)
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

# Constants
OLD_NAME="python_cli_app_scaffold"
OLD_NAME_HYPHEN="python-cli-app-scaffold"

# Prompt for new project directory name
echo "Enter the new project directory name:"
read -r PROJECT_DIR

if [ -z "$PROJECT_DIR" ]; then
    echo "Error: Project directory name cannot be empty"
    exit 1
fi

# Determine the full path for the new project directory
# If PROJECT_DIR contains a path (has "/" or starts with "/"), use it as-is
# Otherwise, create it in the parent directory
if [[ "$PROJECT_DIR" == /* ]] || [[ "$PROJECT_DIR" == */* ]]; then
    # User provided a path (absolute or relative with slashes)
    TARGET_DIR="$PROJECT_DIR"
    # Extract just the directory name for package naming
    DIR_NAME=$(basename "$PROJECT_DIR")
else
    # Just a name, create in parent directory
    TARGET_DIR="$PARENT_DIR/$PROJECT_DIR"
    DIR_NAME="$PROJECT_DIR"
fi

# Check if directory already exists
if [ -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' already exists"
    exit 1
fi

# Derive package names from directory name (not full path)
# For pyproject.toml name field: use hyphens (lowercase)
PACKAGE_NAME_HYPHEN=$(echo "$DIR_NAME" | tr '[:upper:]' '[:lower:]')
# For Python imports and directory names: use underscores (lowercase)
PACKAGE_NAME=$(echo "$DIR_NAME" | tr '[:upper:]' '[:lower:]' | tr '-' '_')
# For command name: use directory name with dashes preserved (lowercase)
CMD_NAME_DEFAULT=$(echo "$DIR_NAME" | tr '[:upper:]' '[:lower:]')

# Derive command name (default to directory name with dashes)
echo "Enter the command name (press Enter to use '$CMD_NAME_DEFAULT'):"
read -r CMD_NAME
if [ -z "$CMD_NAME" ]; then
    CMD_NAME="$CMD_NAME_DEFAULT"
fi

# Prompt for app description
echo "Enter the app description:"
read -r APP_DESCRIPTION

if [ -z "$APP_DESCRIPTION" ]; then
    echo "Error: App description cannot be empty"
    exit 1
fi

# Copy the scaffold directory contents to the new location
echo "Copying scaffold files to '$TARGET_DIR'..."
mkdir -p "$TARGET_DIR"

# Copy all files including hidden ones (cp -a preserves attributes and copies recursively)
# The /. pattern copies the contents of the directory, not the directory itself
cp -a "$SCRIPT_DIR"/. "$TARGET_DIR"/

# Remove .git directory if it exists (we don't want to copy git history)
rm -rf "$TARGET_DIR/.git"

# Remove the script itself from the copy (optional, but cleaner)
rm -f "$TARGET_DIR/$(basename "$0")"

# Change to the new directory
cd "$TARGET_DIR"

# Rename package directory
if [ -d "src/$OLD_NAME" ]; then
    mv "src/$OLD_NAME" "src/$PACKAGE_NAME"
fi

# Update imports in Python files (using sed - adjust for your system)
if find . -type f -name "*.py" 2>/dev/null | grep -q .; then
    find . -type f -name "*.py" -exec sed -i '' "s/$OLD_NAME/$PACKAGE_NAME/g" {} +
fi

# Update pyproject.toml
if [ -f "pyproject.toml" ]; then
    # Replace package name in [project] name field (use hyphens)
    sed -i '' "s/$OLD_NAME_HYPHEN/$PACKAGE_NAME_HYPHEN/g" pyproject.toml
    # Replace package name in import paths (use underscores)
    sed -i '' "s/$OLD_NAME/$PACKAGE_NAME/g" pyproject.toml
    # Replace command name
    sed -i '' "s/mycli/$CMD_NAME/g" pyproject.toml
    # Update pytest coverage path (use underscores for Python module path)
    sed -i '' "s/--cov=$OLD_NAME/--cov=$PACKAGE_NAME/g" pyproject.toml
    # Update description (use Python for robust handling of special characters)
    python3 <<PYTHON_SCRIPT
import re

description = """$APP_DESCRIPTION"""
# Convert newlines to spaces for single-line TOML string
description = ' '.join(description.split())
# Escape quotes for TOML (backslashes in user input are preserved as-is)
escaped_description = description.replace('"', '\\\\"')

with open('pyproject.toml', 'r') as f:
    content = f.read()

# Replace the description line
content = re.sub(
    r'description = ".*"',
    f'description = "{escaped_description}"',
    content,
    count=1
)

with open('pyproject.toml', 'w') as f:
    f.write(content)
PYTHON_SCRIPT
fi

# Update main.py if it exists
if [ -f "src/$PACKAGE_NAME/main.py" ]; then
    sed -i '' "s/mycli/$CMD_NAME/g" "src/$PACKAGE_NAME/main.py"
    sed -i '' "s/$OLD_NAME/$PACKAGE_NAME/g" "src/$PACKAGE_NAME/main.py"
fi

# Update README.md if it exists
if [ -f "README.md" ]; then
    # Replace command name references
    sed -i '' "s/mycli/$CMD_NAME/g" README.md
    # Replace package name references (both hyphen and underscore versions)
    sed -i '' "s/$OLD_NAME_HYPHEN/$PACKAGE_NAME_HYPHEN/g" README.md
    sed -i '' "s/$OLD_NAME/$PACKAGE_NAME/g" README.md
fi

echo ""
echo "✓ Scaffold copied and set up successfully!"
echo "  Project directory: $TARGET_DIR"
echo "  Package name: $PACKAGE_NAME_HYPHEN"
echo "  Python module: $PACKAGE_NAME"
echo "  Command name: $CMD_NAME"
echo "  Description: $APP_DESCRIPTION"
echo ""
echo "Next steps:"
echo "  1. cd $TARGET_DIR"
echo "  2. Customize the project as needed"
echo "  3. Run ./install.sh --editable to install the CLI tool in an editable state for your use."
echo 
echo "  Note: You can continue developing your CLI tool in the editable state, and it will be automatically updated when you make changes to the source code."