const std = @import("std");
const cli = @import("cli.zig");
const cmd = @import("commands.zig");

pub fn main() !void {
    // Define available commands
    const commands = [_]cli.Command{
        cli.Command{
            .name = "hello",
            .func = &cmd.methods.commands.helloFn,
            .req = &.{"greeting"},
            .opt = &.{"name"}, // "name" is optional for the hello command
        },
        cli.Command{
            .name = "help",
            .func = &cmd.methods.commands.helpFn,
        },
        cli.Command{
            .name = "ing",
            .func = &longRunningCommandFn,
        }
    };

    // Define available options
    const options = [_]cli.Option{ 
        cli.Option{
        .name = "name",
        .short = 'n',
        .long = "name",
        .func = &cmd.methods.options.nameFn,
    },
     cli.Option{
        .name = "greeting",
        .short = 'g',
        .long = "greeting",
        .func = &cmd.methods.options.greetingFn,
     } ,
     };

    // Start the CLI application
    try cli.start(&commands, &options, false);
}

pub fn longRunningCommandFn(_: []const cli.Option) bool {
    var spinner = cli.Spinner.init("Processing...") catch |err| {
        std.debug.print("Failed to initialize spinner: {}\n", .{err});
        return false;
    };

    // Simulate work
    var i: usize = 0;
    while (i < 50) : (i += 1) {
        spinner.tick() catch |err| {
            std.debug.print("\nerror:{}\n", .{err});
        };
        std.Thread.sleep(100 * std.time.ns_per_ms);
    }

    spinner.stop("Done processing!") catch |err| {
        std.debug.print("\nerror:{}\n", .{err});
    };
    return true;
}


