const std = @import("std");
const builtin = @import("builtin");

pub const MAX_COMMANDS: u8 = 10;
pub const MAX_OPTIONS: u8 = 20;

const Byte = u8;
const Slice = []const Byte;
const Slices = []const Slice;

pub const Command = struct {
    name: Slice, // Name of the command
    func: fnType, // Function to execute the command
    req: Slices = &.{}, // Required options
    opt: Slices = &.{}, // Optional options
    const fnType = *const fn ([]const Option) bool;
};

pub const Option = struct {
    name: Slice, // Name of the option
    func: ?fnType = null, // Function to execute the option
    short: Byte, // Short form, e.g., -n|-N
    long: Slice, // Long form, e.g., --name
    value: Slice = "", // Value of the option
    const fnType = *const fn (Slice) bool;
};

pub const Error = error{
    NoArgsProvided,
    UnknownCommand,
    UnknownOption,
    MissingRequiredOption,
    UnexpectedArgument,
    CommandExecutionFailed,
    TooManyCommands,
    TooManyOptions,
};

pub fn start(commands: []const Command, options: []const Option, debug: bool) !void {
    if (commands.len > MAX_COMMANDS) {
        return error.TooManyCommands;
    }
    if (options.len > MAX_OPTIONS) {
        return error.TooManyOptions;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    try startWithArgs(commands, options, args, debug);
}

pub fn startWithArgs(commands: []const Command, options: []const Option, args: anytype, debug: bool) !void {
    if (args.len < 2) {
        if (debug) std.debug.print("No command provided by user!\n", .{});
        return Error.NoArgsProvided;
    }

    const command_name = args[1];
    const cmd: Command = for (commands) |cmd| {
        if (std.mem.eql(u8, cmd.name, command_name)) break cmd;
    } else {
        if (debug) std.debug.print("Unknown command: {s}\n", .{command_name});
        return Error.UnknownCommand;
    };

    if (debug) std.debug.print("Detected command: {s}\n", .{cmd.name});

    var detected_options: [MAX_OPTIONS]Option = undefined;
    var detected_len: usize = 0;
    var i: usize = 2;

    while (i < args.len) : (i += 1) {
        const arg = args[i];

        if (std.mem.startsWith(u8, arg, "-")) {
            const option_name = if (std.mem.startsWith(u8, arg[1..], "-")) arg[2..] else arg[1..];

            var opt: Option = for (options) |opt| {
                if (std.mem.eql(u8, option_name, opt.long) or (option_name.len == 1 and option_name[0] == opt.short))
                    break opt;
            } else {
                if (debug) std.debug.print("Unknown option: {s}\n", .{arg});
                return Error.UnknownOption;
            };

            if (i + 1 < args.len and !std.mem.startsWith(u8, args[i + 1], "-")) {
                opt.value = args[i + 1];
                i += 1;
            }

            if (detected_len >= MAX_OPTIONS) {
                return error.TooManyOptions;
            }

            detected_options[detected_len] = opt;
            detected_len += 1;
        } else {
            if (debug) std.debug.print("Unexpected argument: {s}\n", .{arg});
            return Error.UnexpectedArgument;
        }
    }

    const used_options = detected_options[0..detected_len];

    for (cmd.req) |req_option| {
        for (used_options) |opt| {
            if (std.mem.eql(u8, req_option, opt.name)) break;
        } else {
            if (debug) std.debug.print("Missing required option: {s}\n", .{req_option});
            return Error.MissingRequiredOption;
        }
    }

    if (!cmd.func(used_options)) {
        return Error.CommandExecutionFailed;
    } else {
        for (used_options) |opt| {
            if (opt.func) |func| {
                if (!func(opt.value)) {
                    if (debug) std.debug.print("Option function execution failed: {s}\n", .{opt.name});
                    return Error.CommandExecutionFailed;
                }
            }
        }
    }

    if (debug) std.debug.print("Command executed successfully: {s}\n", .{cmd.name});
}
