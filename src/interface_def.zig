const std = @import("std");
const core = @import("syntetica_core");
const raylib = core.rl;
const raygui = core.rlgui;

const IR = core.ui.ir; 
const Element = core.ui.meta.Element;

fn uiHookScreenHeight(_: IR.Element) i32 {
    return raylib.getScreenHeight();
}

fn uiHookScreenWidth(_: IR.Element) i32 {
    return raylib.getScreenWidth();
}

fn hkTxtSize(_: IR.Element) i32 {
    return raygui.getStyle(.default, .{ .default = .text_size }) + 4;
//    return 16;
}

fn hkFitTextButton(elem: IR.Element) i32 {
    return raygui.getTextWidth(elem.decl_ptr.specific.element.data.button.text) + 10;
}

fn hkSwitchToSettings(ir: *IR) void {
    const root_ptr = ir.getElementByID(1) catch unreachable;
    root_ptr.data_id = if(root_ptr.data_id == 1) 0 else 1;
}
fn hkOpenProjectDialog(ir: *IR) void {
    _ = ir;
}
const top_bar: Element = .container(.{
    .size = .{ .w = .grow, .h = .exact(40) },
    .color = .gray,
    .padding = .padding(5, 5, 5, 5),
    .children = &.{
        .element(.button, .{ .h = .grow, .w = .hook(hkFitTextButton) }, .{"Syntetica"}, .{
            .active = hkOpenProjectDialog, 
        }),
        .spacer(.exact(5)),
        .element(.button, .{ .h = .grow, .w = .hook(hkFitTextButton) }, .{"Options"}, .{
            .active = hkSwitchToSettings,
        }),
    }
});

pub const root: Element = .container(.{
    .size = .hook(uiHookScreenWidth, uiHookScreenHeight),
    .direction = .top_to_bottom,
    .children = &.{
        top_bar,
        .switchContainer(.{
            .size = .grow(),
            .uid = 1,
            .children = &.{
                main,
                config,
            }
        })
    },
});

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
/// MAIN INTERFACE ////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

const left_bar: Element = .container(.{
    .size = .{ .w = .exact(250), .h = .grow },
    .color = .blue,
    .direction = .top_to_bottom,
    .padding = .padding(5, 5, 5, 5),
    .children = &.{
        .element(.button, .{ .h = .exact(40), .w = .grow }, .{"Test"}, .{}),
        .element(.button, .{ .h = .exact(40), .w = .grow }, .{"Test"}, .{}),
        .spacer(.grow),
        .element(.button, .{ .h = .exact(40), .w = .grow }, .{"Test"}, .{}),
        .element(.button, .{ .h = .exact(40), .w = .grow }, .{"Test"}, .{}),
    }
});
const right_bar: Element = .container(.{
    .size = .{.w = .exact(250), .h = .grow},
    .color = .blue,
    .direction = .top_to_bottom,
    .padding = .padding(5, 5, 5, 5),
    .children = &.{
        .element(.button, .{ .h = .exact(40), .w = .grow }, .{"Test"}, .{}),
        .element(.button, .{ .h = .exact(40), .w = .grow }, .{"Test"}, .{}),
        .spacer(.grow),
        .element(.button, .{ .h = .exact(40), .w = .grow }, .{"Test"}, .{}),
        .element(.button, .{ .h = .exact(40), .w = .grow }, .{"Test"}, .{}),
    }
});
const central: Element = .container(.{
    .size = .grow(),
    .direction = .top_to_bottom,
    .children = &.{
        .container(.{
            .size = .grow(),
            .color = .black,
            .children = &.{},
        }),
        .container(.{
            .size = .{.w = .grow, .h = .exact(200)},
            .color = .dark_blue,
            .children = &.{},
        })
    },
});

const main: Element = .container(.{
    .size = .grow(),
    .children = &.{
        left_bar,
        central,
        right_bar,
    },
});

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
/// CONFIG MENU ///////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

pub const config: Element = .container(.{
    .size = .grow(),
    .children = &.{
        config_choose,
        .spacer(.exact(10)),
        config_setter,
    },
});

fn hkConfigSwitchToMain(ir: *IR) void {
    const c = ir.getElementByID(2) catch unreachable;
    c.data_id = 0;
}
fn hkConfigSwitchToGUI(ir: *IR) void {
    const c = ir.getElementByID(2) catch unreachable;
    c.data_id = 1;
}
pub const config_choose: Element = .container(.{
    .size = .{ .w = .exact(300), .h = .grow },
    .direction = .top_to_bottom,
    .children = &.{
        .element(.button, .{ .h = .exact(70), .w = .grow }, .{"Main"}, .{
            .active = hkConfigSwitchToMain,
        }),
        .element(.button, .{ .h = .exact(70), .w = .grow }, .{"GUI"}, .{
            .active = hkConfigSwitchToGUI,
        }),
    },
});
pub const config_setter: Element = .switchContainer(.{
    .uid = 2,
    .size = .grow(),
    .children = &.{
        config_panel_main,
        config_panel_gui,
    },
});
pub const config_panel_main: Element = .container(.{
    .direction = .top_to_bottom,
    .size = .grow(),
    .children = &.{
        .element(.label, .{ .h = .hook(hkTxtSize), .w = .grow }, .{"Configure main engine settings"}, .{}),
        .element(.button, .{ .h = .exact(70), .w = .grow }, .{"test"}, .{}),
    }
});
pub const config_panel_gui: Element = .container(.{
    .direction = .top_to_bottom,
    .size = .grow(),
    .children = &.{
        .element(.button, .{ .h = .exact(70), .w = .grow }, .{"gui or smth"}, .{}),
    }
});
