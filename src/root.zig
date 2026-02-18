//! This is the root module of the syntetica user interface (not limited to just GUI!!)

const std = @import("std");
const core = @import("syntetica_core");
const raylib = core.rl;
const raygui = core.rlgui;

const Project = @import("Project.zig");
const layout = @import("interface_def.zig");

const IR = core.ui.ir;

const EngineConf = struct {
    rando_shit: bool = false,
};

const gpa: std.mem.Allocator = std.heap.page_allocator;
var files: core.fs.Collection.Managed = undefined;

pub fn main() !void {
    files = try core.fs.Collection.Managed.init("data", gpa);

    const w = raylib.getScreenWidth();
    const h = raylib.getScreenHeight();

    raylib.initWindow(w, h, "Syntetica Engine");
    raylib.setWindowState(.{
        .window_resizable = true,
        .window_undecorated = true,
    });

    raygui.loadStyleDefault();
    raygui.setStyle(.default, .{ .default = .text_size }, 20);

    var ir: IR = try .init(std.heap.page_allocator, &layout.root);
    var data: core.ui.renderer.FreeList = try .init(std.heap.page_allocator);

    core.ui.solver.recalculate(&ir);

    const path = try std.fs.cwd().realpathAlloc(gpa, "examples/test_proj");
    var proj_test: Project = try .init(
        gpa, 
        path,
        &files
    );
    try proj_test.create();

    while(!raylib.windowShouldClose()) {
        var last_w: i32 = 0;
        var last_h: i32 = 0;
        if(raylib.getScreenWidth() != last_w or raylib.getScreenHeight() != last_h) 
            core.ui.solver.recalculate(&ir);

        ir.pollEvents();

        // render //////////////////////
        raylib.beginDrawing();
        defer raylib.endDrawing();

        core.ui.renderer.drawTree(.initScalar(0), &data, &ir.tree[ir.root_id]);

        last_w = raylib.getScreenWidth();
        last_h = raylib.getScreenHeight();
    }
}
