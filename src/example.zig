const std = @import("std");
const cli = @import("cli");

pub fn main() !void {
    const commands = [_]cli.Command{
        cli.Command{
            .name = "test",
            .req = &.{"help"},
            .func = struct {
                fn function(options: []const cli.Option) bool {
                    _ = options;
                    cli.print("🦀 🦎\n", .{});
                    return true;
                }
            }.function,
        },
        cli.Command{
            .name = "ing",
            .func = struct {
                fn function(options: []const cli.Option) bool {
                    _ = options;
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
            }.function,
        },
    };

    const options = [_]cli.Option{
        cli.Option{
            .name = "help",
            .long = "help",
            .short = 'h',
            .value = "default",
            .func = struct {
                fn function(something: []const u8) bool {
                    cli.print("option value:{s}\n", .{something});
                    return true;
                }
            }.function,
        },
    };

    try cli.startWithArgs(&commands, &options, [_][:0]const u8{"exe", "ing", "--help", "wow"}, true);
}