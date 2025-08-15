const std = @import("std");
const cli = @import("cli.zig");
const cmd = @import("commands.zig");

pub fn main() !void {
    // Define available commands
    const commands = [_]cli.Command{
        cli.Command{
            .name = "hello",
            .func = &cmd.methods.commands.helloFn,
            .opt = &.{"name"},  // "name" is optional for the hello command
        },
        cli.Command{
            .name = "help",
            .func = &cmd.methods.commands.helpFn,
        },
    };

    // Define available options
    const options = [_]cli.Option{
        cli.Option{
            .name = "name",
            .short = 'n',
            .long = "name",
            .func = &cmd.methods.options.nameFn,
        },
    };

    // Start the CLI application
    try cli.start(&commands, &options, false);
}