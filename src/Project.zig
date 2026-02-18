//! For managing projects

// module
const std = @import("std");
const core = @import("syntetica_core");

// alias
const Project = @This();
const Allocator = std.mem.Allocator;
const Collection = core.fs.Collection;

const default_build_source = @embedFile("res/default_build.zig");

gpa: Allocator,
path: []u8,
root_dir: std.fs.Dir,
synt_data: *Collection.Managed,

pub fn init(gpa: Allocator, path: []const u8, synt_data: *Collection.Managed) !Project {
    return .{
        .gpa = gpa,
        .path = try gpa.dupe(u8, path),
        .root_dir = try std.fs.openDirAbsolute(path, .{}),
        .synt_data = synt_data
    };
}

pub fn create(self: *Project) !void {
    // initialize the project directory using zig 
    // TODO: make this use the engine's zig instead of system's
    var init_process: std.process.Child = .init(&.{"zig", "init", "--minimal"}, self.gpa);
    init_process.cwd = self.path;
    init_process.stdin_behavior = .Ignore;
    init_process.stderr_behavior = .Inherit;
    init_process.stdout_behavior = .Inherit;
    const result = try init_process.spawnAndWait();
    if(result.Exited != 0) {
        std.debug.print("unable to initialize, error {}\n", .{result.Exited});
        return error.ZigFailed;
    }

    var build_f = try self.root_dir.createFile("build.zig", .{});
    _ = try build_f.write(default_build_source);

    // src/ directory
    try self.root_dir.makeDir("src");
    var src_dir = try self.root_dir.openDir("src", .{});
    defer src_dir.close();

    try src_dir.makeDir("system");
    try src_dir.makeDir("component");

    var f = try src_dir.createFile("main.zig", .{});
    f.close();

    // .syntectica/ directory
    try self.root_dir.makeDir(".syntetica");
    var synt_dir = try self.root_dir.openDir(".syntetica", .{});
    defer synt_dir.close();

    f = try synt_dir.createFile("component_group.zig", .{});
    f.close();

    f = try synt_dir.createFile("system_group.zig", .{});
    f.close();

    try synt_dir.makeDir("modules");
    try synt_dir.makeDir("resources");
}

pub fn load(self: *Project) !void {
    _ = self;
}
