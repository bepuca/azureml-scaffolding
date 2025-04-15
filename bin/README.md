# Script-based CLI

As [mentioned in the project `README.md`], the main interface of this project is
the script-based command-line interface (CLI) implemented in this folder. This
document describes some details for developers interested in understanding the
inner workings and/or modifying the CLI.

- A command is an executable script without extension in this folder. To make
  a script executable, it needs a shebang line at the top and it needs to be made
  executable by `chmod +x script_name`.
- Commands are organized into subfolders for logical grouping.
- [`bin/help`] has the following properties:
  - The displayed help comes from the line starting with `#?` in the script.
  - Commands are grouped by the `[...]` right after the `#?` line.
  - Only executable scripts without extension and without a prefix `_` are
    displayed. The non-displayed scripts are considered private.
- `bin/lib` is a special folder that contains scripts and libraries that are
  not intended to be executed directly. They are used by other scripts in the
  `bin` folder. There are two types of content:
  - `<file>.sh` files are shell scripts that are sourced. By convention, they
    define only functions. All functions defined in such files are named
    `<file>::<function>`. This way, it is easier to identify the source of the
    function. For example, in `run.sh` we define the function `run::local`.
  - `_<file>` files are executable scripts never meant to be executed directly
    by the user. They are used by other scripts.
- Check existing scripts for the usual patterns such as argument parsing.
- It is important that all public scripts (displayed in the help) expose a `-h`
  or `--help` option that displays the help.

[mentioned in the project `README.md`]: ../README.md#usage
[`bin/help`]: help
