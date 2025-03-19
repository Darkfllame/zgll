//! Simple opengl loader, entirely written in Zig. All functions are under `zgll.GL`, all constants and function got their suffix removed (`GL_` and `gl`) for easier typing. Don't expect much updates, might do extension loader soon...
//!
//! ### Beware though
//! This library was mostly made in a night, so expect typos, incoherent names and more...

const std = @import("std");
const builtin = @import("builtin");

const assert = std.debug.assert;

const WIN32 = true and
    builtin.os.tag == .windows and
    builtin.cpu.arch == .x86;

var glLib: ?std.DynLib = null;
var getProcFunc: ?GL.ProcLoader = null;

fn procLoader(name: [*:0]const u8) callconv(.C) ?*const anyopaque {
    if (glLib) |*lib| {
        return (if (getProcFunc) |getProc|
            getProc(name)
        else
            null) orelse
            lib.lookup(*anyopaque, @ptrCast(std.mem.span(name)));
    } else return null;
}

fn openLib() !void {
    glLib = null;
    const names: []const []const u8 = switch (builtin.os.tag) {
        .macos => &.{
            "../Frameworks/OpenGL.framework/OpenGL",
            "/Library/Frameworks/OpenGL.framework/OpenGL",
            "/System/Library/Frameworks/OpenGL.framework/OpenGL",
            "/System/Library/Frameworks/OpenGL.framework/Versions/Current/OpenGL",
        },
        .windows => &.{"opengl32.dll"},
        else => &.{ "libGL.so.1", "libGL.so" },
    };
    inline for (names, 1..) |name, i| {
        glLib = std.DynLib.open(name) catch |e|
            if (i != names.len) continue else return e;
        break;
    }
    getProcFunc = glLib.?.lookup(GL.ProcLoader, switch (builtin.os.tag) {
        .windows => "wglGetProcAddress",
        .macos => "glXGetProcAddressARB",
        else => {
            getProcFunc = null;
            return;
        },
    });
}
fn closeLib() void {
    if (glLib) |*lib| {
        lib.close();
        glLib = null;
    }
}

/// Use `.init()` along with an existing variable of this type
/// to load the current context's OpenGL functions.
const GL = @This();
//#region struct
comptime {
    if (@sizeOf(c_int) != 4) {
        @compileError("c_int isn't 4 bytes (32 bits), try changing target platform");
    }
}

pub const ProcLoader = *const fn (name: [*:0]const u8) callconv(.C) ?*const anyopaque;
pub const Version = struct {
    major: u8,
    minor: u8,

    pub fn new(major: u8, minor: u8) Version {
        return .{ .major = major, .minor = minor };
    }
    pub fn order(self: Version, lhs: Version) std.math.Order {
        if (self.major == lhs.major) {
            if (self.minor == lhs.minor)
                return .eq
            else if (self.minor > lhs.minor)
                return .gt
            else if (self.minor < lhs.minor)
                return .lt;
            unreachable;
        } else if (self.major > lhs.major)
            return .gt
        else if (self.major < lhs.major)
            return .lt;
        unreachable;
    }
};

pub const Enum = @import("GLenum.zig").Enum;
pub const Bitfield = @import("GLbitfield.zig").Bitfield;
pub const Byte = i8;
pub const UByte = u8;
pub const Short = i16;
pub const UShort = u16;
pub const Int = i32;
pub const UInt = u32;
pub const Clampx = i32;
pub const Sizei = i32;
pub const Float = f32;
pub const Clampf = f32;
pub const Double = f64;
pub const Clampd = f64;
pub const Char = u8;
pub const Half = u16;
pub const Fixed = i32;
pub const Intptr = isize;
pub const Sizeiptr = isize;
pub const Int64 = i64;
pub const UInt64 = u64;
pub const Sync = ?*opaque {};
pub const DebugProc = *const fn (source: Enum, @"type": Enum, id: UInt, severity: Enum, length: Sizei, message: [*:0]const Char, ud: ?*const anyopaque) callconv(.C) void;

pub const APIENTRY: std.builtin.CallingConvention = if (WIN32) .{ .x86_stdcall = .{} } else .c;

version: Version,

//#region fields
//#region OpenGL 1.0
ptr_glCullFace: ?*const fn (mode: Enum) callconv(APIENTRY) void,
ptr_glFrontFace: ?*const fn (mode: Enum) callconv(APIENTRY) void,
ptr_glHint: ?*const fn (target: Enum, mode: Enum) callconv(APIENTRY) void,
ptr_glLineWidth: ?*const fn (width: Float) callconv(APIENTRY) void,
ptr_glPointSize: ?*const fn (size: Float) callconv(APIENTRY) void,
ptr_glPolygonMode: ?*const fn (face: Enum, mode: Enum) callconv(APIENTRY) void,
ptr_glScissor: ?*const fn (x: Int, y: Int, width: Sizei, height: Sizei) callconv(APIENTRY) void,
ptr_glTexParameterf: ?*const fn (target: Enum, pname: Enum, param: Float) callconv(APIENTRY) void,
ptr_glTexParameterfv: ?*const fn (target: Enum, pname: Enum, params: [*]const Float) callconv(APIENTRY) void,
ptr_glTexParameteri: ?*const fn (target: Enum, pname: Enum, param: Int) callconv(APIENTRY) void,
ptr_glTexParameteriv: ?*const fn (target: Enum, pname: Enum, param: [*]const Int) callconv(APIENTRY) void,
ptr_glTexImage1D: ?*const fn (target: Enum, level: Int, internalformat: Int, width: Sizei, border: Int, format: Enum, @"type": Enum, pixels: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glTexImage2D: ?*const fn (target: Enum, level: Int, internalformat: Int, width: Sizei, height: Sizei, border: Int, format: Enum, @"type": Enum, pixels: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glDrawBuffer: ?*const fn (buf: Enum) callconv(APIENTRY) void,
ptr_glClear: ?*const fn (mask: Bitfield) callconv(APIENTRY) void,
ptr_glClearColor: ?*const fn (red: Float, green: Float, blue: Float, alpha: Float) callconv(APIENTRY) void,
ptr_glClearStencil: ?*const fn (s: Int) callconv(APIENTRY) void,
ptr_glClearDepth: ?*const fn (depth: Double) callconv(APIENTRY) void,
ptr_glStencilMask: ?*const fn (mask: UInt) callconv(APIENTRY) void,
ptr_glColorMask: ?*const fn (red: bool, green: bool, blue: bool, alpha: bool) callconv(APIENTRY) void,
ptr_glDepthMask: ?*const fn (flag: bool) callconv(APIENTRY) void,
ptr_glDisable: ?*const fn (cap: Enum) callconv(APIENTRY) void,
ptr_glEnable: ?*const fn (cap: Enum) callconv(APIENTRY) void,
ptr_glFinish: ?*const fn () callconv(APIENTRY) void,
ptr_glFlush: ?*const fn () callconv(APIENTRY) void,
ptr_glBlendFunc: ?*const fn (sfactor: Enum, dfactor: Enum) callconv(APIENTRY) void,
ptr_glLogicOp: ?*const fn (opcode: Enum) callconv(APIENTRY) void,
ptr_glStencilFunc: ?*const fn (func: Enum, ref: Int, mask: UInt) callconv(APIENTRY) void,
ptr_glStencilOp: ?*const fn (fail: Enum, zfail: Enum, zpass: Enum) callconv(APIENTRY) void,
ptr_glDepthFunc: ?*const fn (func: Enum) callconv(APIENTRY) void,
ptr_glPixelStoref: ?*const fn (pname: Enum, param: Float) callconv(APIENTRY) void,
ptr_glPixelStorei: ?*const fn (pname: Enum, param: Int) callconv(APIENTRY) void,
ptr_glReadBuffer: ?*const fn (src: Enum) callconv(APIENTRY) void,
ptr_glReadPixels: ?*const fn (x: Int, y: Int, width: Sizei, height: Sizei, format: Enum, @"type": Enum, pixels: [*]u8) callconv(APIENTRY) void,
ptr_glGetBooleanv: ?*const fn (pname: Enum, data: [*]bool) callconv(APIENTRY) void,
ptr_glGetDoublev: ?*const fn (pname: Enum, data: [*]Double) callconv(APIENTRY) void,
ptr_glGetError: ?*const fn () callconv(APIENTRY) Enum,
ptr_glGetFloatv: ?*const fn (pname: Enum, data: [*]Double) callconv(APIENTRY) void,
ptr_glGetIntegerv: ?*const fn (pname: Enum, data: [*]Int) callconv(APIENTRY) void,
ptr_glGetString: ?*const fn (pname: Enum) callconv(APIENTRY) ?[*:0]const u8,
ptr_glGetTexImage: ?*const fn (target: Enum, level: Int, format: Enum, @"type": Enum, pixels: [*]u8) callconv(APIENTRY) void,
ptr_glGetTexParameterfv: ?*const fn (target: Enum, pname: Enum, params: [*]Float) callconv(APIENTRY) void,
ptr_glGetTexParameteriv: ?*const fn (target: Enum, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetTexLevelParameterfv: ?*const fn (target: Enum, level: Int, pname: Enum, params: [*]Float) callconv(APIENTRY) void,
ptr_glGetTexLevelParameteriv: ?*const fn (target: Enum, level: Int, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glIsEnabled: ?*const fn (cap: Enum) callconv(APIENTRY) bool,
ptr_glDepthRange: ?*const fn (n: Double, f: Double) callconv(APIENTRY) void,
ptr_glViewport: ?*const fn (x: Int, y: Int, width: Sizei, height: Sizei) callconv(APIENTRY) void,
ptr_glNewList: ?*const fn (list: UInt, mode: Enum) callconv(APIENTRY) void,
ptr_glEndList: ?*const fn () callconv(APIENTRY) void,
ptr_glCallList: ?*const fn (list: UInt) callconv(APIENTRY) void,
ptr_glCallLists: ?*const fn (n: Sizei, @"type": Enum, lists: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glDeleteLists: ?*const fn (list: UInt, range: Sizei) callconv(APIENTRY) void,
ptr_glGenLists: ?*const fn (range: Sizei) callconv(APIENTRY) UInt,
ptr_glListBase: ?*const fn (base: UInt) callconv(APIENTRY) void,
ptr_glBegin: ?*const fn (mode: Enum) callconv(APIENTRY) void,
ptr_glBitmap: ?*const fn (width: Sizei, height: Sizei, xorig: Float, yorig: Float, xmove: Float, ymove: Float, bitmap: [*]const UByte) callconv(APIENTRY) void,
ptr_glColor3b: ?*const fn (red: Byte, green: Byte, blue: Byte) callconv(APIENTRY) void,
ptr_glColor3bv: ?*const fn (v: *const [3]Byte) callconv(APIENTRY) void,
ptr_glColor3d: ?*const fn (red: Double, green: Double, blue: Double) callconv(APIENTRY) void,
ptr_glColor3dv: ?*const fn (v: *const [3]Double) callconv(APIENTRY) void,
ptr_glColor3f: ?*const fn (red: Float, green: Float, blue: Float) callconv(APIENTRY) void,
ptr_glColor3fv: ?*const fn (v: *const [3]Float) callconv(APIENTRY) void,
ptr_glColor3i: ?*const fn (red: Int, green: Int, blue: Int) callconv(APIENTRY) void,
ptr_glColor3iv: ?*const fn (v: *const [3]Int) callconv(APIENTRY) void,
ptr_glColor3s: ?*const fn (red: Short, green: Short, blue: Short) callconv(APIENTRY) void,
ptr_glColor3sv: ?*const fn (v: *const [3]Short) callconv(APIENTRY) void,
ptr_glColor3ub: ?*const fn (red: UByte, green: UByte, blue: UByte) callconv(APIENTRY) void,
ptr_glColor3ubv: ?*const fn (v: *const [3]UByte) callconv(APIENTRY) void,
ptr_glColor3ui: ?*const fn (red: UInt, green: UInt, blue: UInt) callconv(APIENTRY) void,
ptr_glColor3uiv: ?*const fn (v: *const [3]UInt) callconv(APIENTRY) void,
ptr_glColor3us: ?*const fn (red: UShort, green: UShort, blue: UShort) callconv(APIENTRY) void,
ptr_glColor3usv: ?*const fn (v: *const [3]UShort) callconv(APIENTRY) void,
ptr_glColor4b: ?*const fn (red: Byte, green: Byte, blue: Byte, alpha: Byte) callconv(APIENTRY) void,
ptr_glColor4bv: ?*const fn (v: *const [4]Byte) callconv(APIENTRY) void,
ptr_glColor4d: ?*const fn (red: Double, green: Double, blue: Double, alpha: Double) callconv(APIENTRY) void,
ptr_glColor4dv: ?*const fn (v: *const [4]Double) callconv(APIENTRY) void,
ptr_glColor4f: ?*const fn (red: Float, green: Float, blue: Float, alpha: Float) callconv(APIENTRY) void,
ptr_glColor4fv: ?*const fn (v: *const [4]Float) callconv(APIENTRY) void,
ptr_glColor4i: ?*const fn (red: Int, green: Int, blue: Int, alpha: Int) callconv(APIENTRY) void,
ptr_glColor4iv: ?*const fn (v: *const [4]Int) callconv(APIENTRY) void,
ptr_glColor4s: ?*const fn (red: Short, green: Short, blue: Short, alpha: Short) callconv(APIENTRY) void,
ptr_glColor4sv: ?*const fn (v: *const [4]Short) callconv(APIENTRY) void,
ptr_glColor4ub: ?*const fn (red: UByte, green: UByte, blue: UByte, alpha: UByte) callconv(APIENTRY) void,
ptr_glColor4ubv: ?*const fn (v: *const [4]UByte) callconv(APIENTRY) void,
ptr_glColor4ui: ?*const fn (red: UInt, green: UInt, blue: UInt, alpha: UInt) callconv(APIENTRY) void,
ptr_glColor4uiv: ?*const fn (v: *const [4]UInt) callconv(APIENTRY) void,
ptr_glColor4us: ?*const fn (red: UShort, green: UShort, blue: UShort, alpha: UShort) callconv(APIENTRY) void,
ptr_glColor4usv: ?*const fn (v: *const [4]UShort) callconv(APIENTRY) void,
ptr_glEdgeFlag: ?*const fn (flag: bool) callconv(APIENTRY) void,
ptr_glEdgeFlagv: ?*const fn (flag: [*]const bool) callconv(APIENTRY) void,
ptr_glEnd: ?*const fn () callconv(APIENTRY) void,
ptr_glIndexd: ?*const fn (c: Double) callconv(APIENTRY) void,
ptr_glIndexdv: ?*const fn (c: [*]const Double) callconv(APIENTRY) void,
ptr_glIndex: ?*const fn (c: Float) callconv(APIENTRY) void,
ptr_glIndexv: ?*const fn (c: [*]const Float) callconv(APIENTRY) void,
ptr_glIndexi: ?*const fn (c: Int) callconv(APIENTRY) void,
ptr_glIndexiv: ?*const fn (c: [*]const Int) callconv(APIENTRY) void,
ptr_glIndexs: ?*const fn (c: Short) callconv(APIENTRY) void,
ptr_glIndexsv: ?*const fn (c: [*]const Short) callconv(APIENTRY) void,
ptr_glNormal3b: ?*const fn (nx: Byte, ny: Byte, nz: Byte) callconv(APIENTRY) void,
ptr_glNormal3bv: ?*const fn (v: [*]const [3]Byte) callconv(APIENTRY) void,
ptr_glNormal3d: ?*const fn (nx: Double, ny: Double, nz: Double) callconv(APIENTRY) void,
ptr_glNormal3dv: ?*const fn (v: [*]const [3]Double) callconv(APIENTRY) void,
ptr_glNormal3f: ?*const fn (nx: Float, ny: Float, nz: Float) callconv(APIENTRY) void,
ptr_glNormal3fv: ?*const fn (v: [*]const [3]Float) callconv(APIENTRY) void,
ptr_glNormal3i: ?*const fn (nx: Int, ny: Int, nz: Int) callconv(APIENTRY) void,
ptr_glNormal3iv: ?*const fn (v: [*]const [3]Int) callconv(APIENTRY) void,
ptr_glNormal3s: ?*const fn (nx: Short, ny: Short, nz: Short) callconv(APIENTRY) void,
ptr_glNormal3sv: ?*const fn (v: [*]const [3]Short) callconv(APIENTRY) void,
ptr_glRasterPos2d: ?*const fn (x: Double, y: Double) callconv(APIENTRY) void,
ptr_glRasterPos2dv: ?*const fn (v: [*]const [2]Double) callconv(APIENTRY) void,
ptr_glRasterPos2f: ?*const fn (x: Float, y: Float) callconv(APIENTRY) void,
ptr_glRasterPos2fv: ?*const fn (v: [*]const [2]Float) callconv(APIENTRY) void,
ptr_glRasterPos2i: ?*const fn (x: Int, y: Int) callconv(APIENTRY) void,
ptr_glRasterPos2iv: ?*const fn (v: [*]const [2]Int) callconv(APIENTRY) void,
ptr_glRasterPos2s: ?*const fn (x: Short, y: Short) callconv(APIENTRY) void,
ptr_glRasterPos2sv: ?*const fn (v: [*]const [2]Short) callconv(APIENTRY) void,
ptr_glRasterPos3d: ?*const fn (x: Double, y: Double, z: Double) callconv(APIENTRY) void,
ptr_glRasterPos3dv: ?*const fn (v: [*]const [2]Double) callconv(APIENTRY) void,
ptr_glRasterPos3f: ?*const fn (x: Float, y: Float, z: Float) callconv(APIENTRY) void,
ptr_glRasterPos3fv: ?*const fn (v: [*]const [2]Float) callconv(APIENTRY) void,
ptr_glRasterPos3i: ?*const fn (x: Int, y: Int, z: Int) callconv(APIENTRY) void,
ptr_glRasterPos3iv: ?*const fn (v: [*]const [3]Int) callconv(APIENTRY) void,
ptr_glRasterPos3s: ?*const fn (x: Short, y: Short, z: Short) callconv(APIENTRY) void,
ptr_glRasterPos3sv: ?*const fn (v: [*]const [3]Short) callconv(APIENTRY) void,
ptr_glRasterPos4d: ?*const fn (x: Double, y: Double, z: Double, w: Double) callconv(APIENTRY) void,
ptr_glRasterPos4dv: ?*const fn (v: [*]const [4]Double) callconv(APIENTRY) void,
ptr_glRasterPos4f: ?*const fn (x: Float, y: Float, z: Float, w: Float) callconv(APIENTRY) void,
ptr_glRasterPos4fv: ?*const fn (v: [*]const [4]Float) callconv(APIENTRY) void,
ptr_glRasterPos4i: ?*const fn (x: Int, y: Int, z: Int, w: Int) callconv(APIENTRY) void,
ptr_glRasterPos4iv: ?*const fn (v: [*]const [4]Int) callconv(APIENTRY) void,
ptr_glRasterPos4s: ?*const fn (x: Short, y: Short, z: Short, w: Short) callconv(APIENTRY) void,
ptr_glRasterPos4sv: ?*const fn (v: [*]const [4]Short) callconv(APIENTRY) void,
ptr_glRectd: ?*const fn (x1: Double, y1: Double, x2: Double, y2: Double) callconv(APIENTRY) void,
ptr_glRectdv: ?*const fn (v1: [*]const [2]Double, v2: [*]const [2]Double) callconv(APIENTRY) void,
ptr_glRectf: ?*const fn (x1: Float, y1: Float, x2: Float, y2: Float) callconv(APIENTRY) void,
ptr_glRectfv: ?*const fn (v1: [*]const [2]Float, v2: [*]const [2]Float) callconv(APIENTRY) void,
ptr_glRecti: ?*const fn (x1: Int, y1: Int, x2: Int, y2: Int) callconv(APIENTRY) void,
ptr_glRectiv: ?*const fn (v1: [*]const [2]Int, v2: [*]const [2]Int) callconv(APIENTRY) void,
ptr_glRects: ?*const fn (x1: Short, y1: Short, x2: Short, y2: Short) callconv(APIENTRY) void,
ptr_glRectsv: ?*const fn (v1: [*]const [2]Short, v2: [*]const [2]Short) callconv(APIENTRY) void,
ptr_glTexCoord1d: ?*const fn (s: Double) callconv(APIENTRY) void,
ptr_glTexCoord1dv: ?*const fn (v: [*]const Double) callconv(APIENTRY) void,
ptr_glTexCoord1f: ?*const fn (s: Float) callconv(APIENTRY) void,
ptr_glTexCoord1fv: ?*const fn (v: [*]const Float) callconv(APIENTRY) void,
ptr_glTexCoord1i: ?*const fn (s: Int) callconv(APIENTRY) void,
ptr_glTexCoord1iv: ?*const fn (v: [*]const Int) callconv(APIENTRY) void,
ptr_glTexCoord1s: ?*const fn (s: Short) callconv(APIENTRY) void,
ptr_glTexCoord1sv: ?*const fn (v: [*]const Short) callconv(APIENTRY) void,
ptr_glTexCoord2d: ?*const fn (s: Double, t: Double) callconv(APIENTRY) void,
ptr_glTexCoord2dv: ?*const fn (v: [*]const [2]Double) callconv(APIENTRY) void,
ptr_glTexCoord2f: ?*const fn (s: Float, t: Float) callconv(APIENTRY) void,
ptr_glTexCoord2fv: ?*const fn (v: [*]const [2]Float) callconv(APIENTRY) void,
ptr_glTexCoord2i: ?*const fn (s: Int, t: Int) callconv(APIENTRY) void,
ptr_glTexCoord2iv: ?*const fn (v: [*]const [2]Int) callconv(APIENTRY) void,
ptr_glTexCoord2s: ?*const fn (s: Short, t: Short) callconv(APIENTRY) void,
ptr_glTexCoord2sv: ?*const fn (v: [*]const [2]Short) callconv(APIENTRY) void,
ptr_glTexCoord3d: ?*const fn (s: Double, t: Double, r: Double) callconv(APIENTRY) void,
ptr_glTexCoord3dv: ?*const fn (v: [*]const [3]Double) callconv(APIENTRY) void,
ptr_glTexCoord3f: ?*const fn (s: Float, t: Float, r: Float) callconv(APIENTRY) void,
ptr_glTexCoord3fv: ?*const fn (v: [*]const [3]Float) callconv(APIENTRY) void,
ptr_glTexCoord3i: ?*const fn (s: Int, t: Int, r: Int) callconv(APIENTRY) void,
ptr_glTexCoord3iv: ?*const fn (v: [*]const [3]Int) callconv(APIENTRY) void,
ptr_glTexCoord3s: ?*const fn (s: Short, t: Short, r: Short) callconv(APIENTRY) void,
ptr_glTexCoord3sv: ?*const fn (v: [*]const [3]Short) callconv(APIENTRY) void,
ptr_glTexCoord4d: ?*const fn (s: Double, t: Double, r: Double, q: Double) callconv(APIENTRY) void,
ptr_glTexCoord4dv: ?*const fn (v: [*]const [4]Double) callconv(APIENTRY) void,
ptr_glTexCoord4f: ?*const fn (s: Float, t: Float, r: Float, q: Float) callconv(APIENTRY) void,
ptr_glTexCoord4fv: ?*const fn (v: [*]const [4]Float) callconv(APIENTRY) void,
ptr_glTexCoord4i: ?*const fn (s: Int, t: Int, r: Int, q: Int) callconv(APIENTRY) void,
ptr_glTexCoord4iv: ?*const fn (v: [*]const [4]Int) callconv(APIENTRY) void,
ptr_glTexCoord4s: ?*const fn (s: Short, t: Short, r: Short, q: Short) callconv(APIENTRY) void,
ptr_glTexCoord4sv: ?*const fn (v: [*]const [4]Short) callconv(APIENTRY) void,
ptr_glVertex2d: ?*const fn (x: Double, y: Double) callconv(APIENTRY) void,
ptr_glVertex2dv: ?*const fn (v: [*]const [2]Double) callconv(APIENTRY) void,
ptr_glVertex2f: ?*const fn (x: Float, y: Float) callconv(APIENTRY) void,
ptr_glVertex2fv: ?*const fn (v: [*]const [2]Float) callconv(APIENTRY) void,
ptr_glVertex2i: ?*const fn (x: Int, y: Int) callconv(APIENTRY) void,
ptr_glVertex2iv: ?*const fn (v: [*]const [2]Int) callconv(APIENTRY) void,
ptr_glVertex2s: ?*const fn (x: Short, y: Short) callconv(APIENTRY) void,
ptr_glVertex2sv: ?*const fn (v: [*]const [2]Short) callconv(APIENTRY) void,
ptr_glVertex3d: ?*const fn (x: Double, y: Double, z: Double) callconv(APIENTRY) void,
ptr_glVertex3dv: ?*const fn (v: [*]const [3]Double) callconv(APIENTRY) void,
ptr_glVertex3f: ?*const fn (x: Float, y: Float, z: Float) callconv(APIENTRY) void,
ptr_glVertex3fv: ?*const fn (v: [*]const [3]Float) callconv(APIENTRY) void,
ptr_glVertex3i: ?*const fn (x: Int, y: Int, z: Int) callconv(APIENTRY) void,
ptr_glVertex3iv: ?*const fn (v: [*]const [3]Int) callconv(APIENTRY) void,
ptr_glVertex3s: ?*const fn (x: Short, y: Short, z: Short) callconv(APIENTRY) void,
ptr_glVertex3sv: ?*const fn (v: [*]const [3]Short) callconv(APIENTRY) void,
ptr_glVertex4d: ?*const fn (x: Double, y: Double, z: Double, w: Double) callconv(APIENTRY) void,
ptr_glVertex4dv: ?*const fn (v: [*]const [4]Double) callconv(APIENTRY) void,
ptr_glVertex4f: ?*const fn (x: Float, y: Float, z: Float, w: Float) callconv(APIENTRY) void,
ptr_glVertex4fv: ?*const fn (v: [*]const [4]Float) callconv(APIENTRY) void,
ptr_glVertex4i: ?*const fn (x: Int, y: Int, z: Int, w: Int) callconv(APIENTRY) void,
ptr_glVertex4iv: ?*const fn (v: [*]const [4]Int) callconv(APIENTRY) void,
ptr_glVertex4s: ?*const fn (x: Short, y: Short, z: Short, w: Short) callconv(APIENTRY) void,
ptr_glVertex4sv: ?*const fn (v: [*]const [4]Short) callconv(APIENTRY) void,
ptr_glClipPlane: ?*const fn (plane: Enum, equation: [*]const Double) callconv(APIENTRY) void,
ptr_glColorMaterial: ?*const fn (face: Enum, mode: Enum) callconv(APIENTRY) void,
ptr_glFogf: ?*const fn (pname: Enum, param: Float) callconv(APIENTRY) void,
ptr_glFogfv: ?*const fn (pname: Enum, params: [*]const Float) callconv(APIENTRY) void,
ptr_glFogi: ?*const fn (pname: Enum, param: Int) callconv(APIENTRY) void,
ptr_glFogiv: ?*const fn (pname: Enum, params: [*]const Int) callconv(APIENTRY) void,
ptr_glLightf: ?*const fn (light: Enum, pname: Enum, param: Float) callconv(APIENTRY) void,
ptr_glLightfv: ?*const fn (light: Enum, pname: Enum, params: [*]const Float) callconv(APIENTRY) void,
ptr_glLighti: ?*const fn (light: Enum, pname: Enum, param: Int) callconv(APIENTRY) void,
ptr_glLightiv: ?*const fn (light: Enum, pname: Enum, params: [*]const Int) callconv(APIENTRY) void,
ptr_glLightModelf: ?*const fn (pname: Enum, param: Float) callconv(APIENTRY) void,
ptr_glLightModelfv: ?*const fn (pname: Enum, params: [*]const Float) callconv(APIENTRY) void,
ptr_glLightModeli: ?*const fn (pname: Enum, param: Int) callconv(APIENTRY) void,
ptr_glLightModeliv: ?*const fn (pname: Enum, params: [*]const Int) callconv(APIENTRY) void,
ptr_glLineStipple: ?*const fn (factor: Int, pattern: UShort) callconv(APIENTRY) void,
ptr_glMaterialf: ?*const fn (face: Enum, pname: Enum, param: Float) callconv(APIENTRY) void,
ptr_glMaterialfv: ?*const fn (face: Enum, pname: Enum, params: [*]const Float) callconv(APIENTRY) void,
ptr_glMateriali: ?*const fn (face: Enum, pname: Enum, param: Int) callconv(APIENTRY) void,
ptr_glMaterialiv: ?*const fn (face: Enum, pname: Enum, params: [*]const Int) callconv(APIENTRY) void,
ptr_glPolygonStipple: ?*const fn (mask: [*]const UByte) callconv(APIENTRY) void,
ptr_glShadeModel: ?*const fn (mode: Enum) callconv(APIENTRY) void,
ptr_glTexEnvf: ?*const fn (target: Enum, pname: Enum, param: Float) callconv(APIENTRY) void,
ptr_glTexEnvfv: ?*const fn (target: Enum, pname: Enum, params: [*]const Float) callconv(APIENTRY) void,
ptr_glTexEnvi: ?*const fn (target: Enum, pname: Enum, param: Int) callconv(APIENTRY) void,
ptr_glTexEnviv: ?*const fn (target: Enum, pname: Enum, params: [*]const Int) callconv(APIENTRY) void,
ptr_glTexGend: ?*const fn (coord: Enum, pname: Enum, param: Double) callconv(APIENTRY) void,
ptr_glTexGendv: ?*const fn (coord: Enum, pname: Enum, params: [*]const Double) callconv(APIENTRY) void,
ptr_glTexGenf: ?*const fn (coord: Enum, pname: Enum, param: Float) callconv(APIENTRY) void,
ptr_glTexGenfv: ?*const fn (coord: Enum, pname: Enum, params: [*]const Float) callconv(APIENTRY) void,
ptr_glTexGeni: ?*const fn (coord: Enum, pname: Enum, param: Int) callconv(APIENTRY) void,
ptr_glTexGeniv: ?*const fn (coord: Enum, pname: Enum, params: [*]const Int) callconv(APIENTRY) void,
ptr_glFeedbackBuffer: ?*const fn (size: Sizei, @"type": Enum, buffer: [*]Float) callconv(APIENTRY) void,
ptr_glSelectBuffer: ?*const fn (size: Sizei, buffer: [*]UInt) callconv(APIENTRY) void,
ptr_glRenderMode: ?*const fn (mode: Enum) callconv(APIENTRY) Int,
ptr_glInitNames: ?*const fn () callconv(APIENTRY) void,
ptr_glLoadName: ?*const fn (name: UInt) callconv(APIENTRY) void,
ptr_glPassThrough: ?*const fn (token: Float) callconv(APIENTRY) void,
ptr_glPopName: ?*const fn () callconv(APIENTRY) void,
ptr_glPushName: ?*const fn (name: UInt) callconv(APIENTRY) void,
ptr_glClearAccum: ?*const fn (red: Float, green: Float, blue: Float, alpha: Float) callconv(APIENTRY) void,
ptr_glClearIndex: ?*const fn (c: Float) callconv(APIENTRY) void,
ptr_glIndexMask: ?*const fn (mask: UInt) callconv(APIENTRY) void,
ptr_glAccum: ?*const fn (op: Enum, value: Float) callconv(APIENTRY) void,
ptr_glPopAttrib: ?*const fn () callconv(APIENTRY) void,
ptr_glPushAttrib: ?*const fn (mask: Bitfield) callconv(APIENTRY) void,
ptr_glMap1d: ?*const fn (target: Enum, @"u1": Double, @"u2": Double, stride: Int, order: Int, points: [*]const Double) callconv(APIENTRY) void,
ptr_glMap1f: ?*const fn (target: Enum, @"u1": Float, @"u2": Float, stride: Int, order: Int, points: [*]const Float) callconv(APIENTRY) void,
ptr_glMap2d: ?*const fn (target: Enum, @"u1": Double, @"u2": Double, ustride: Int, uorder: Int, v1: Double, v2: Double, vstride: Int, vorder: Int, points: [*]const Double) callconv(APIENTRY) void,
ptr_glMap2f: ?*const fn (target: Enum, @"u1": Float, @"u2": Float, ustride: Int, uorder: Int, v1: Float, v2: Float, vstride: Int, vorder: Int, points: [*]const Float) callconv(APIENTRY) void,
ptr_glMapGrid1d: ?*const fn (un: Int, @"u1": Double, @"u2": Double) callconv(APIENTRY) void,
ptr_glMapGrid1f: ?*const fn (un: Int, @"u1": Float, @"u2": Float) callconv(APIENTRY) void,
ptr_glMapGrid2d: ?*const fn (un: Int, @"u1": Double, @"u2": Double, vn: Int, v1: Double, v2: Double) callconv(APIENTRY) void,
ptr_glMapGrid2f: ?*const fn (un: Int, @"u1": Float, @"u2": Float, vn: Int, v1: Float, v2: Float) callconv(APIENTRY) void,
ptr_glEvalCoord1d: ?*const fn (u: Double) callconv(APIENTRY) void,
ptr_glEvalCoord1dv: ?*const fn (u: [*]const Double) callconv(APIENTRY) void,
ptr_glEvalCoord1f: ?*const fn (u: Float) callconv(APIENTRY) void,
ptr_glEvalCoord1fv: ?*const fn (u: [*]const Float) callconv(APIENTRY) void,
ptr_glEvalCoord2d: ?*const fn (u: Double, v: Double) callconv(APIENTRY) void,
ptr_glEvalCoord2dv: ?*const fn (u: [*]const Double) callconv(APIENTRY) void,
ptr_glEvalCoord2f: ?*const fn (u: Float, v: Float) callconv(APIENTRY) void,
ptr_glEvalCoord2fv: ?*const fn (u: [*]const Float) callconv(APIENTRY) void,
ptr_glEvalMesh1: ?*const fn (mode: Enum, @"i1": Int, @"i2": Int) callconv(APIENTRY) void,
ptr_glEvalPoint1: ?*const fn (i: Int) callconv(APIENTRY) void,
ptr_glEvalMesh2: ?*const fn (mode: Enum, @"i1": Int, @"i2": Int, j1: Int, j2: Int) callconv(APIENTRY) void,
ptr_glEvalPoint2: ?*const fn (i: Int, j: Int) callconv(APIENTRY) void,
ptr_glAlphaFunc: ?*const fn (func: Enum, ref: Float) callconv(APIENTRY) void,
ptr_glPixelZoom: ?*const fn (xfactor: Float, yfactor: Float) callconv(APIENTRY) void,
ptr_glPixelTransferf: ?*const fn (pname: Enum, param: Float) callconv(APIENTRY) void,
ptr_glPixelTransferi: ?*const fn (pname: Enum, param: Int) callconv(APIENTRY) void,
ptr_glPixelMapfv: ?*const fn (map: Enum, mapsize: Sizei, values: [*]const Float) callconv(APIENTRY) void,
ptr_glPixelMapuiv: ?*const fn (map: Enum, mapsize: Sizei, values: [*]const UInt) callconv(APIENTRY) void,
ptr_glPixelMapusv: ?*const fn (map: Enum, mapsize: Sizei, values: [*]const UShort) callconv(APIENTRY) void,
ptr_glCopyPixels: ?*const fn (x: Int, y: Int, width: Sizei, height: Sizei, @"type": Enum) callconv(APIENTRY) void,
ptr_glDrawPixels: ?*const fn (width: Sizei, height: Sizei, format: Enum, @"type": Enum, pixels: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glGetClipPlane: ?*const fn (plane: Enum, equation: [*]Double) callconv(APIENTRY) void,
ptr_glGetLightfv: ?*const fn (light: Enum, pname: Enum, params: [*]Float) callconv(APIENTRY) void,
ptr_glGetLightiv: ?*const fn (light: Enum, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetMapdv: ?*const fn (target: Enum, query: Enum, v: [*]Double) callconv(APIENTRY) void,
ptr_glGetMapfv: ?*const fn (target: Enum, query: Enum, v: [*]Float) callconv(APIENTRY) void,
ptr_glGetMapiv: ?*const fn (target: Enum, query: Enum, v: [*]Int) callconv(APIENTRY) void,
ptr_glGetMaterialfv: ?*const fn (face: Enum, pname: Enum, params: [*]Float) callconv(APIENTRY) void,
ptr_glGetMaterialiv: ?*const fn (face: Enum, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetPixelMapfv: ?*const fn (map: Enum, values: [*]Float) callconv(APIENTRY) void,
ptr_glGetPpixelMapUiv: ?*const fn (map: Enum, values: [*]UInt) callconv(APIENTRY) void,
ptr_glGetPpixelMapUsv: ?*const fn (map: Enum, values: [*]UShort) callconv(APIENTRY) void,
ptr_glGetPolygonStipple: ?*const fn (mask: [*]UByte) callconv(APIENTRY) void,
ptr_glGetTexEnvfv: ?*const fn (target: Enum, pname: Enum, params: [*]Float) callconv(APIENTRY) void,
ptr_glGetTexEnviv: ?*const fn (target: Enum, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetTexGendv: ?*const fn (coord: Enum, pname: Enum, params: [*]Double) callconv(APIENTRY) void,
ptr_glGetTexGenfv: ?*const fn (coord: Enum, pname: Enum, params: [*]Float) callconv(APIENTRY) void,
ptr_glGetTexGeniv: ?*const fn (coord: Enum, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glIsList: ?*const fn (list: UInt) callconv(APIENTRY) bool,
ptr_glFrustrul: ?*const fn (left: Double, right: Double, bottom: Double, top: Double, zNear: Double, zFar: Double) callconv(APIENTRY) void,
ptr_glLoadIdentity: ?*const fn () callconv(APIENTRY) void,
ptr_glLoadMatrixf: ?*const fn (m: [*]const Float) callconv(APIENTRY) void,
ptr_glLoadMatrixd: ?*const fn (m: [*]const Double) callconv(APIENTRY) void,
ptr_glMatrixMode: ?*const fn (mode: Enum) callconv(APIENTRY) void,
ptr_glMultMatrixf: ?*const fn (m: [*]const Float) callconv(APIENTRY) void,
ptr_glMultMatrixd: ?*const fn (m: [*]const Double) callconv(APIENTRY) void,
ptr_glOrtho: ?*const fn (left: Double, right: Double, bottom: Double, top: Double, zNear: Double, zFar: Double) callconv(APIENTRY) void,
ptr_glPopMatrix: ?*const fn () callconv(APIENTRY) void,
ptr_glPushMatrix: ?*const fn () callconv(APIENTRY) void,
ptr_glRotated: ?*const fn (ane: Double, x: Double, y: Double, z: Double) callconv(APIENTRY) void,
ptr_glRotatef: ?*const fn (ane: Float, x: Float, y: Float, z: Float) callconv(APIENTRY) void,
ptr_glScaled: ?*const fn (x: Double, y: Double, z: Double) callconv(APIENTRY) void,
ptr_glScalef: ?*const fn (x: Float, y: Float, z: Float) callconv(APIENTRY) void,
ptr_glTranslated: ?*const fn (x: Double, y: Double, z: Double) callconv(APIENTRY) void,
ptr_glTranslatef: ?*const fn (x: Float, y: Float, z: Float) callconv(APIENTRY) void,
//#endregion
//#region OpenGL 1.1
ptr_glDrawArrays: ?*const fn (mode: Enum, first: Int, count: Sizei) callconv(APIENTRY) void,
ptr_glDrawElements: ?*const fn (mode: Enum, count: Sizei, @"type": Enum, indices: usize) callconv(APIENTRY) void,
ptr_glGetPointerv: ?*const fn (pname: Enum, params: [*]?*anyopaque) callconv(APIENTRY) void,
ptr_glPolygonOffset: ?*const fn (factor: Float, units: Float) callconv(APIENTRY) void,
ptr_glCopyTexImage1D: ?*const fn (target: Enum, level: Int, internalFormat: Enum, x: Int, y: Int, width: Sizei, border: Int) callconv(APIENTRY) void,
ptr_glCopyTexImage2D: ?*const fn (target: Enum, level: Int, internalformat: Enum, x: Int, y: Int, widht: Sizei, height: Sizei, border: Int) callconv(APIENTRY) void,
ptr_glCopyTexSubImage1D: ?*const fn (target: Enum, level: Int, internalFormat: Enum, xoffset: Int, x: Int, y: Int, width: Sizei) callconv(APIENTRY) void,
ptr_glCopyTexSubImage2D: ?*const fn (target: Enum, level: Int, internalformat: Enum, xoffset: Int, yoffset: Int, x: Int, y: Int, width: Sizei, height: Sizei) callconv(APIENTRY) void,
ptr_glTextSubImage1D: ?*const fn (target: Enum, level: Int, xoffset: Int, width: Sizei, format: Enum, @"type": Enum, pixels: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glTextSubImage2D: ?*const fn (target: Enum, level: Int, xoffset: Int, yoffset: Int, width: Sizei, height: Sizei, format: Enum, @"type": Enum, pixels: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glBindTexture: ?*const fn (target: Enum, texture: UInt) callconv(APIENTRY) void,
ptr_glDeleteTextures: ?*const fn (n: Sizei, textures: [*]const UInt) callconv(APIENTRY) void,
ptr_glGenTextures: ?*const fn (n: Sizei, textures: [*]UInt) callconv(APIENTRY) void,
ptr_glIsTexture: ?*const fn (texture: UInt) callconv(APIENTRY) bool,
ptr_glArrayElement: ?*const fn (i: Int) callconv(APIENTRY) void,
ptr_glColorPointer: ?*const fn (size: Int, @"type": Enum, stride: Sizei, pointer: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glDisableClientState: ?*const fn (array: Enum) callconv(APIENTRY) void,
ptr_glEdgeFlagPointer: ?*const fn (stride: Sizei, pointer: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glEnableClientState: ?*const fn (array: Enum) callconv(APIENTRY) void,
ptr_glIndexPointer: ?*const fn (@"type": Enum, stride: Sizei, pointer: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glInterleavedArrays: ?*const fn (format: Enum, stride: Sizei, pointer: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glNormalPointer: ?*const fn (@"type": Enum, stride: Sizei, pointer: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glTexCoordPointer: ?*const fn (size: Int, @"type": Enum, stride: Sizei, pointer: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glVertexPointer: ?*const fn (size: Int, @"type": Enum, stride: Sizei, pointer: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glAreTexturesResident: ?*const fn (n: Sizei, textures: [*]const UInt, residences: [*]bool) callconv(APIENTRY) bool,
ptr_glPrioritizeTextures: ?*const fn (n: Sizei, textures: [*]const UInt, priorities: [*]const Float) callconv(APIENTRY) void,
ptr_glIndexub: ?*const fn (c: UByte) callconv(APIENTRY) void,
ptr_glIndexubv: ?*const fn (c: [*]const UByte) callconv(APIENTRY) void,
ptr_glPopClientAttrib: ?*const fn () callconv(APIENTRY) void,
ptr_glPushClientAttrib: ?*const fn (mask: Bitfield) callconv(APIENTRY) void,
//#endregion
//#region OpenGL 1.2
ptr_glDrawRangeElements: ?*const fn (mode: Enum, start: UInt, end: UInt, count: Sizei, @"type": Enum, indices: usize) callconv(APIENTRY) void,
ptr_glTexImage3D: ?*const fn (target: Enum, level: Int, internalFormat: Int, width: Sizei, height: Sizei, depth: Sizei, border: Int, format: Enum, @"type": Enum, pixels: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glTexSubImage3D: ?*const fn (target: Enum, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, width: Sizei, height: Sizei, depth: Sizei, format: Enum, @"type": Enum, pixels: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glCopyTexSubImage3D: ?*const fn (target: Enum, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, x: Int, y: Int, width: Sizei, height: Sizei) callconv(APIENTRY) void,
//#endregion
//#region OpenGL 1.3
ptr_glActiveTexture: ?*const fn (texture: Enum) callconv(APIENTRY) void,
ptr_glSampleCoverage: ?*const fn (value: Float, invert: bool) callconv(APIENTRY) void,
ptr_glCompressedTexImage3D: ?*const fn (texture: Enum, level: Int, internalFormat: Enum, width: Sizei, height: Sizei, depth: Sizei, border: Int, imageSize: Sizei, data: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glCompressedTexImage2D: ?*const fn (texture: Enum, level: Int, internalFormat: Enum, width: Sizei, height: Sizei, border: Int, imageSize: Sizei, data: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glCompressedTexImage1D: ?*const fn (texture: Enum, level: Int, internalFormat: Enum, width: Sizei, border: Int, imageSize: Sizei, data: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glCompressedTexSubImage3D: ?*const fn (texture: Enum, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, width: Sizei, height: Sizei, depth: Sizei, format: Enum, imageSize: Sizei, data: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glCompressedTexSubImage2D: ?*const fn (texture: Enum, level: Int, xoffset: Int, yoffset: Int, width: Sizei, height: Sizei, format: Enum, imageSize: Sizei, data: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glCompressedTexSubImage1D: ?*const fn (texture: Enum, level: Int, xoffset: Int, width: Sizei, format: Enum, imageSize: Sizei, data: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glGetCompressedTexImage: ?*const fn (texture: Enum, level: Int, img: ?*anyopaque) callconv(APIENTRY) void,
ptr_glClientActiveTexture: ?*const fn (texture: Enum) callconv(APIENTRY) void,
ptr_glMultiTexCoord1d: ?*const fn (texture: Enum, s: Double) callconv(APIENTRY) void,
ptr_glMultiTexCoord1dv: ?*const fn (texture: Enum, v: *const Double) callconv(APIENTRY) void,
ptr_glMultiTexCoord1f: ?*const fn (texture: Enum, s: Float) callconv(APIENTRY) void,
ptr_glMultiTexCoord1fv: ?*const fn (texture: Enum, v: *const Float) callconv(APIENTRY) void,
ptr_glMultiTexCoord1i: ?*const fn (texture: Enum, s: Int) callconv(APIENTRY) void,
ptr_glMultiTexCoord1iv: ?*const fn (texture: Enum, v: *const Int) callconv(APIENTRY) void,
ptr_glMultiTexCoord1s: ?*const fn (texture: Enum, s: Short) callconv(APIENTRY) void,
ptr_glMultiTexCoord1sv: ?*const fn (texture: Enum, v: *const Short) callconv(APIENTRY) void,
ptr_glMultiTexCoord2d: ?*const fn (texture: Enum, s: Double, t: Double) callconv(APIENTRY) void,
ptr_glMultiTexCoord2dv: ?*const fn (texture: Enum, v: *const [2]Double) callconv(APIENTRY) void,
ptr_glMultiTexCoord2f: ?*const fn (texture: Enum, s: Float, t: Float) callconv(APIENTRY) void,
ptr_glMultiTexCoord2fv: ?*const fn (texture: Enum, v: *const [2]Float) callconv(APIENTRY) void,
ptr_glMultiTexCoord2i: ?*const fn (texture: Enum, s: Int, t: Int) callconv(APIENTRY) void,
ptr_glMultiTexCoord2iv: ?*const fn (texture: Enum, v: *const [2]Int) callconv(APIENTRY) void,
ptr_glMultiTexCoord2s: ?*const fn (texture: Enum, s: Short, t: Short) callconv(APIENTRY) void,
ptr_glMultiTexCoord2sv: ?*const fn (texture: Enum, v: *const [2]Short) callconv(APIENTRY) void,
ptr_glMultiTexCoord3d: ?*const fn (texture: Enum, s: Double, t: Double, r: Double) callconv(APIENTRY) void,
ptr_glMultiTexCoord3dv: ?*const fn (texture: Enum, v: *const [3]Double) callconv(APIENTRY) void,
ptr_glMultiTexCoord3f: ?*const fn (texture: Enum, s: Float, t: Float, r: Float) callconv(APIENTRY) void,
ptr_glMultiTexCoord3fv: ?*const fn (texture: Enum, v: *const [3]Float) callconv(APIENTRY) void,
ptr_glMultiTexCoord3i: ?*const fn (texture: Enum, s: Int, t: Int, r: Int) callconv(APIENTRY) void,
ptr_glMultiTexCoord3iv: ?*const fn (texture: Enum, v: *const [3]Int) callconv(APIENTRY) void,
ptr_glMultiTexCoord3s: ?*const fn (texture: Enum, s: Short, t: Short, r: Short) callconv(APIENTRY) void,
ptr_glMultiTexCoord3sv: ?*const fn (texture: Enum, v: *const [3]Short) callconv(APIENTRY) void,
ptr_glMultiTexCoord4d: ?*const fn (texture: Enum, s: Double, t: Double, r: Double, q: Double) callconv(APIENTRY) void,
ptr_glMultiTexCoord4dv: ?*const fn (texture: Enum, v: *const [4]Double) callconv(APIENTRY) void,
ptr_glMultiTexCoord4f: ?*const fn (texture: Enum, s: Float, t: Float, r: Float, q: Float) callconv(APIENTRY) void,
ptr_glMultiTexCoord4fv: ?*const fn (texture: Enum, v: *const [4]Float) callconv(APIENTRY) void,
ptr_glMultiTexCoord4i: ?*const fn (texture: Enum, s: Int, t: Int, r: Int, q: Int) callconv(APIENTRY) void,
ptr_glMultiTexCoord4iv: ?*const fn (texture: Enum, v: *const [4]Int) callconv(APIENTRY) void,
ptr_glMultiTexCoord4s: ?*const fn (texture: Enum, s: Short, t: Short, r: Short, q: Short) callconv(APIENTRY) void,
ptr_glMultiTexCoord4sv: ?*const fn (texture: Enum, v: *const [4]Short) callconv(APIENTRY) void,
ptr_glLoadTransposeMatrixf: ?*const fn (m: [*]const Float) callconv(APIENTRY) void,
ptr_glLoadTransposeMatrixd: ?*const fn (m: [*]const Double) callconv(APIENTRY) void,
ptr_glMultTransposeMatrixf: ?*const fn (m: [*]const Float) callconv(APIENTRY) void,
ptr_glMultTransposeMatrixd: ?*const fn (m: [*]const Double) callconv(APIENTRY) void,
//#endregion
//#region OpenGL 1.4
ptr_glBlendFuncSeparate: ?*const fn (sfactorRGB: Enum, dfactorRGB: Enum, sfactorAlpha: Enum, dfactorAlpha: Enum) callconv(APIENTRY) void,
ptr_glMultiDrawArrays: ?*const fn (mode: Enum, first: [*]const Int, count: [*]const Sizei, drawcount: Sizei) callconv(APIENTRY) void,
ptr_glMultiDrawElements: ?*const fn (mode: Enum, count: [*]const Sizei, @"type": Enum, indices: [*]const usize, drawcount: Sizei) callconv(APIENTRY) void,
ptr_glPointParameterf: ?*const fn (pname: Enum, param: Float) callconv(APIENTRY) void,
ptr_glPointParameterfv: ?*const fn (pname: Enum, params: [*]const Float) callconv(APIENTRY) void,
ptr_glPointParameteri: ?*const fn (pname: Enum, param: Int) callconv(APIENTRY) void,
ptr_glPointParameteriv: ?*const fn (pname: Enum, params: [*]const Int) callconv(APIENTRY) void,
ptr_glFogCoordf: ?*const fn (coord: Float) callconv(APIENTRY) void,
ptr_glFogCoordfv: ?*const fn (coord: [*]const Float) callconv(APIENTRY) void,
ptr_glFogCoordd: ?*const fn (coord: Double) callconv(APIENTRY) void,
ptr_glFogCoorddv: ?*const fn (coord: [*]const Double) callconv(APIENTRY) void,
ptr_glFogCoordPointer: ?*const fn (@"type": Enum, stride: Sizei, pointer: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glSecondaryColor3b: ?*const fn (red: Byte, green: Byte, blue: Byte) callconv(APIENTRY) void,
ptr_glSecondaryColor3bv: ?*const fn (v: *const [3]Byte) callconv(APIENTRY) void,
ptr_glSecondaryColor3d: ?*const fn (red: Double, green: Double, blue: Double) callconv(APIENTRY) void,
ptr_glSecondaryColor3dv: ?*const fn (v: *const [3]Double) callconv(APIENTRY) void,
ptr_glSecondaryColor3f: ?*const fn (red: Float, green: Float, blue: Float) callconv(APIENTRY) void,
ptr_glSecondaryColor3fv: ?*const fn (v: *const [3]Float) callconv(APIENTRY) void,
ptr_glSecondaryColor3i: ?*const fn (red: Int, green: Int, blue: Int) callconv(APIENTRY) void,
ptr_glSecondaryColor3iv: ?*const fn (v: *const [3]Int) callconv(APIENTRY) void,
ptr_glSecondaryColor3s: ?*const fn (red: Short, green: Short, blue: Short) callconv(APIENTRY) void,
ptr_glSecondaryColor3sv: ?*const fn (v: *const [3]Short) callconv(APIENTRY) void,
ptr_glSecondaryColor3ub: ?*const fn (red: UByte, green: UByte, blue: UByte) callconv(APIENTRY) void,
ptr_glSecondaryColor3ubv: ?*const fn (v: *const [3]UByte) callconv(APIENTRY) void,
ptr_glSecondaryColor3ui: ?*const fn (red: UInt, green: UInt, blue: UInt) callconv(APIENTRY) void,
ptr_glSecondaryColor3uiv: ?*const fn (v: *const [3]UInt) callconv(APIENTRY) void,
ptr_glSecondaryColor3us: ?*const fn (red: UShort, green: UShort, blue: UShort) callconv(APIENTRY) void,
ptr_glSecondaryColor3usv: ?*const fn (v: *const [3]UShort) callconv(APIENTRY) void,
ptr_glSecondaryColorPointer: ?*const fn (size: Int, @"type": Enum, stride: Sizei, pointer: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glWindowPos2d: ?*const fn (x: Double, y: Double) callconv(APIENTRY) void,
ptr_glWindowPos2dv: ?*const fn (v: *const [2]Double) callconv(APIENTRY) void,
ptr_glWindowPos2f: ?*const fn (x: Float, y: Float) callconv(APIENTRY) void,
ptr_glWindowPos2fv: ?*const fn (v: *const [2]Float) callconv(APIENTRY) void,
ptr_glWindowPos2i: ?*const fn (x: Int, y: Int) callconv(APIENTRY) void,
ptr_glWindowPos2iv: ?*const fn (v: *const [2]Int) callconv(APIENTRY) void,
ptr_glWindowPos2s: ?*const fn (x: Short, y: Short) callconv(APIENTRY) void,
ptr_glWindowPos2sv: ?*const fn (v: *const [2]Short) callconv(APIENTRY) void,
ptr_glWindowPos3d: ?*const fn (x: Double, y: Double, z: Double) callconv(APIENTRY) void,
ptr_glWindowPos3dv: ?*const fn (v: *const [3]Double) callconv(APIENTRY) void,
ptr_glWindowPos3f: ?*const fn (x: Float, y: Float, z: Float) callconv(APIENTRY) void,
ptr_glWindowPos3fv: ?*const fn (v: *const [3]Float) callconv(APIENTRY) void,
ptr_glWindowPos3i: ?*const fn (x: Int, y: Int, z: Int) callconv(APIENTRY) void,
ptr_glWindowPos3iv: ?*const fn (v: *const [3]Int) callconv(APIENTRY) void,
ptr_glWindowPos3s: ?*const fn (x: Short, y: Short, z: Short) callconv(APIENTRY) void,
ptr_glWindowPos3sv: ?*const fn (v: *const [3]Short) callconv(APIENTRY) void,
ptr_glBlendColor: ?*const fn (red: Float, green: Float, blue: Float, alpha: Float) callconv(APIENTRY) void,
ptr_glBlendEquation: ?*const fn (mode: Enum) callconv(APIENTRY) void,
//#endregion
//#region OpenGL 1.5
ptr_glGenQueries: ?*const fn (n: Sizei, ids: [*]UInt) callconv(APIENTRY) void,
ptr_glDeleteQueries: ?*const fn (n: Sizei, ids: [*]const UInt) callconv(APIENTRY) void,
ptr_glIsQuery: ?*const fn (id: UInt) callconv(APIENTRY) bool,
ptr_glBeginQuery: ?*const fn (target: Enum, id: UInt) callconv(APIENTRY) void,
ptr_glEndQuery: ?*const fn (target: Enum) callconv(APIENTRY) void,
ptr_glGetQueryiv: ?*const fn (target: Enum, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetQueryObjectiv: ?*const fn (id: UInt, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetQueryObjectuiv: ?*const fn (id: UInt, pname: Enum, params: [*]UInt) callconv(APIENTRY) void,
ptr_glBindBuffer: ?*const fn (target: Enum, buffer: UInt) callconv(APIENTRY) void,
ptr_glDeleteBuffers: ?*const fn (n: Sizei, buffers: [*]const UInt) callconv(APIENTRY) void,
ptr_glGenBuffers: ?*const fn (n: Sizei, buffers: [*]UInt) callconv(APIENTRY) void,
ptr_glIsBuffer: ?*const fn (buffer: UInt) callconv(APIENTRY) bool,
ptr_glBufferData: ?*const fn (target: Enum, size: Sizeiptr, data: ?*const anyopaque, usage: Enum) callconv(APIENTRY) void,
ptr_glBufferSubData: ?*const fn (target: Enum, offset: Intptr, size: Sizeiptr, data: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glGetBufferSubData: ?*const fn (target: Enum, offset: Intptr, size: Sizeiptr, data: ?*anyopaque) callconv(APIENTRY) void,
ptr_glMapBuffer: ?*const fn (target: Enum, access: Enum) callconv(APIENTRY) ?*anyopaque,
ptr_glUnmapBuffer: ?*const fn (target: Enum) callconv(APIENTRY) bool,
ptr_glGetBufferParameteriv: ?*const fn (target: Enum, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetBufferPointerv: ?*const fn (target: Enum, pname: Enum, params: [*]?*anyopaque) callconv(APIENTRY) void,
//#endregion

//#region OpenGL 2.0
ptr_glBlendEquationSeparate: ?*const fn (modeRGB: Enum, modeAplha: Enum) callconv(APIENTRY) void,
ptr_glDrawBuffers: ?*const fn (n: Sizei, bufs: [*]const Enum) callconv(APIENTRY) void,
ptr_glStencilOpSeparate: ?*const fn (face: Enum, sfail: Enum, dpfail: Enum, dppass: Enum) callconv(APIENTRY) void,
ptr_glStencilFuncSeparate: ?*const fn (face: Enum, func: Enum, ref: Int, mask: UInt) callconv(APIENTRY) void,
ptr_glStencilMaskSeparate: ?*const fn (face: Enum, mask: UInt) callconv(APIENTRY) void,
ptr_glAttachShader: ?*const fn (program: UInt, shader: UInt) callconv(APIENTRY) void,
ptr_glBindAttribLocation: ?*const fn (program: UInt, index: UInt, name: [*:0]const Char) callconv(APIENTRY) void,
ptr_glCompileShader: ?*const fn (shader: UInt) callconv(APIENTRY) void,
ptr_glCreateProgram: ?*const fn () callconv(APIENTRY) UInt,
ptr_glCreateShader: ?*const fn (@"type": Enum) callconv(APIENTRY) UInt,
ptr_glDeleteProgram: ?*const fn (program: UInt) callconv(APIENTRY) void,
ptr_glDeleteShader: ?*const fn (shader: UInt) callconv(APIENTRY) void,
ptr_glDetachShader: ?*const fn (program: UInt, shader: UInt) callconv(APIENTRY) void,
ptr_glDisableVertexAttribArray: ?*const fn (index: UInt) callconv(APIENTRY) void,
ptr_glEnableVertexAttribArray: ?*const fn (index: UInt) callconv(APIENTRY) void,
ptr_glGetActiveAttrib: ?*const fn (program: UInt, index: UInt, bufSize: Sizei, length: [*]Sizei, size: [*]Int, @"type": [*]Enum, name: [*:0]Char) callconv(APIENTRY) void,
ptr_glGetActiveUniform: ?*const fn (program: UInt, index: UInt, bufSize: Sizei, length: [*]Sizei, size: [*]Int, @"type": [*]Enum, name: [*:0]Char) callconv(APIENTRY) void,
ptr_glGetAttachedShaders: ?*const fn (program: UInt, maxCount: Sizei, count: ?*Sizei, shaders: [*]UInt) callconv(APIENTRY) void,
ptr_glGetAttribLocation: ?*const fn (program: UInt, name: [*:0]const Char) callconv(APIENTRY) Int,
ptr_glGetProgramiv: ?*const fn (program: UInt, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetProgramInfoLog: ?*const fn (program: UInt, bufSize: Sizei, length: ?*Sizei, infoLog: [*]Char) callconv(APIENTRY) void,
ptr_glGetShaderiv: ?*const fn (program: UInt, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetShaderInfoLog: ?*const fn (shader: UInt, bufSize: Sizei, length: ?*Sizei, infoLog: [*]Char) callconv(APIENTRY) void,
ptr_glGetShaderSource: ?*const fn (shader: UInt, bufSize: Sizei, length: ?*Sizei, source: [*]Char) callconv(APIENTRY) void,
ptr_glGetUniformLocation: ?*const fn (shader: UInt, name: [*:0]const Char) callconv(APIENTRY) Int,
ptr_glGetUniformfv: ?*const fn (program: UInt, location: Int, params: [*]Float) callconv(APIENTRY) void,
ptr_glGetUniformiv: ?*const fn (program: UInt, location: Int, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetVertexAttribdv: ?*const fn (program: UInt, pname: Enum, params: [*]Double) callconv(APIENTRY) void,
ptr_glGetVertexAttribfv: ?*const fn (program: UInt, pname: Enum, params: [*]Float) callconv(APIENTRY) void,
ptr_glGetVertexAttribiv: ?*const fn (program: UInt, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetVertexAttribPointerv: ?*const fn (index: UInt, pname: Enum, pointer: [*]?*anyopaque) callconv(APIENTRY) void,
ptr_glIsProgram: ?*const fn (program: UInt) callconv(APIENTRY) bool,
ptr_glIsShader: ?*const fn (shader: UInt) callconv(APIENTRY) bool,
ptr_glLinkProgram: ?*const fn (program: UInt) callconv(APIENTRY) void,
ptr_glShaderSource: ?*const fn (shader: UInt, count: Sizei, string: [*]const [*]const Char, length: ?[*]const Int) callconv(APIENTRY) void,
ptr_glUseProgram: ?*const fn (program: UInt) callconv(APIENTRY) void,
ptr_glUniform1f: ?*const fn (location: Int, v0: Float) callconv(APIENTRY) void,
ptr_glUniform2f: ?*const fn (location: Int, v0: Float, v1: Float) callconv(APIENTRY) void,
ptr_glUniform3f: ?*const fn (location: Int, v0: Float, v1: Float, v2: Float) callconv(APIENTRY) void,
ptr_glUniform4f: ?*const fn (location: Int, v0: Float, v1: Float, v2: Float, v3: Float) callconv(APIENTRY) void,
ptr_glUniform1i: ?*const fn (location: Int, v0: Int) callconv(APIENTRY) void,
ptr_glUniform2i: ?*const fn (location: Int, v0: Int, v1: Int) callconv(APIENTRY) void,
ptr_glUniform3i: ?*const fn (location: Int, v0: Int, v1: Int, v2: Int) callconv(APIENTRY) void,
ptr_glUniform4i: ?*const fn (location: Int, v0: Int, v1: Int, v2: Int, v3: Int) callconv(APIENTRY) void,
ptr_glUniform1fv: ?*const fn (location: Int, count: Sizei, value: [*]const Float) callconv(APIENTRY) void,
ptr_glUniform2fv: ?*const fn (location: Int, count: Sizei, value: [*]const [2]Float) callconv(APIENTRY) void,
ptr_glUniform3fv: ?*const fn (location: Int, count: Sizei, value: [*]const [3]Float) callconv(APIENTRY) void,
ptr_glUniform4fv: ?*const fn (location: Int, count: Sizei, value: [*]const [4]Float) callconv(APIENTRY) void,
ptr_glUniform1iv: ?*const fn (location: Int, count: Sizei, value: [*]const Int) callconv(APIENTRY) void,
ptr_glUniform2iv: ?*const fn (location: Int, count: Sizei, value: [*]const [2]Int) callconv(APIENTRY) void,
ptr_glUniform3iv: ?*const fn (location: Int, count: Sizei, value: [*]const [3]Int) callconv(APIENTRY) void,
ptr_glUniform4iv: ?*const fn (location: Int, count: Sizei, value: [*]const [4]Int) callconv(APIENTRY) void,
ptr_glUniformMatrix2fv: ?*const fn (location: Int, count: Sizei, transpose: bool, v: [*]const [2 * 2]Float) callconv(APIENTRY) void,
ptr_glUniformMatrix3fv: ?*const fn (location: Int, count: Sizei, transpose: bool, v: [*]const [3 * 3]Float) callconv(APIENTRY) void,
ptr_glUniformMatrix4fv: ?*const fn (location: Int, count: Sizei, transpose: bool, v: [*]const [4 * 4]Float) callconv(APIENTRY) void,
ptr_glValidateProgram: ?*const fn (program: UInt) callconv(APIENTRY) void,
ptr_glVertexAttrib1d: ?*const fn (index: UInt, x: Double) callconv(APIENTRY) void,
ptr_glVertexAttrib1dv: ?*const fn (index: UInt, v: *const Double) callconv(APIENTRY) void,
ptr_glVertexAttrib1f: ?*const fn (index: UInt, x: Float) callconv(APIENTRY) void,
ptr_glVertexAttrib1fv: ?*const fn (index: UInt, v: *const Float) callconv(APIENTRY) void,
ptr_glVertexAttrib1s: ?*const fn (index: UInt, x: Short) callconv(APIENTRY) void,
ptr_glVertexAttrib1sv: ?*const fn (index: UInt, v: *const Short) callconv(APIENTRY) void,
ptr_glVertexAttrib2d: ?*const fn (index: UInt, x: Double, y: Double) callconv(APIENTRY) void,
ptr_glVertexAttrib2dv: ?*const fn (index: UInt, v: *const [2]Double) callconv(APIENTRY) void,
ptr_glVertexAttrib2f: ?*const fn (index: UInt, x: Float, y: Float) callconv(APIENTRY) void,
ptr_glVertexAttrib2fv: ?*const fn (index: UInt, v: *const [2]Float) callconv(APIENTRY) void,
ptr_glVertexAttrib2s: ?*const fn (index: UInt, x: Short, y: Short) callconv(APIENTRY) void,
ptr_glVertexAttrib2sv: ?*const fn (index: UInt, v: *const [2]Short) callconv(APIENTRY) void,
ptr_glVertexAttrib3d: ?*const fn (index: UInt, x: Double, y: Double, z: Double) callconv(APIENTRY) void,
ptr_glVertexAttrib3dv: ?*const fn (index: UInt, v: *const [3]Double) callconv(APIENTRY) void,
ptr_glVertexAttrib3f: ?*const fn (index: UInt, x: Float, y: Float, z: Float) callconv(APIENTRY) void,
ptr_glVertexAttrib3fv: ?*const fn (index: UInt, v: *const [3]Float) callconv(APIENTRY) void,
ptr_glVertexAttrib3s: ?*const fn (index: UInt, x: Short, y: Short, z: Short) callconv(APIENTRY) void,
ptr_glVertexAttrib3sv: ?*const fn (index: UInt, v: *const [3]Short) callconv(APIENTRY) void,
ptr_glVertexAttrib4Nbv: ?*const fn (index: UInt, v: *const [4]Byte) callconv(APIENTRY) void,
ptr_glVertexAttrib4Niv: ?*const fn (index: UInt, v: *const [4]Int) callconv(APIENTRY) void,
ptr_glVertexAttrib4Nsv: ?*const fn (index: UInt, v: *const [4]Short) callconv(APIENTRY) void,
ptr_glVertexAttrib4Nub: ?*const fn (index: UInt, x: UByte, y: UByte, z: UByte, w: UByte) callconv(APIENTRY) void,
ptr_glVertexAttrib4Nubv: ?*const fn (index: UInt, v: *const [4]UByte) callconv(APIENTRY) void,
ptr_glVertexAttrib4Nuiv: ?*const fn (index: UInt, v: *const [4]UInt) callconv(APIENTRY) void,
ptr_glVertexAttrib4Nusv: ?*const fn (index: UInt, v: *const [4]UShort) callconv(APIENTRY) void,
ptr_glVertexAttrib4bv: ?*const fn (index: UInt, v: *const [4]Byte) callconv(APIENTRY) void,
ptr_glVertexAttrib4d: ?*const fn (index: UInt, x: Double, y: Double, z: Double, w: Double) callconv(APIENTRY) void,
ptr_glVertexAttrib4dv: ?*const fn (index: UInt, v: *const [4]Double) callconv(APIENTRY) void,
ptr_glVertexAttrib4f: ?*const fn (index: UInt, x: Float, y: Float, z: Float, w: Float) callconv(APIENTRY) void,
ptr_glVertexAttrib4fv: ?*const fn (index: UInt, v: *const [4]Float) callconv(APIENTRY) void,
ptr_glVertexAttrib4iv: ?*const fn (index: UInt, v: *const [4]Int) callconv(APIENTRY) void,
ptr_glVertexAttrib4s: ?*const fn (index: UInt, x: Short, y: Short, z: Short, w: Short) callconv(APIENTRY) void,
ptr_glVertexAttrib4sv: ?*const fn (index: UInt, v: *const [4]Short) callconv(APIENTRY) void,
ptr_glVertexAttrib4ubv: ?*const fn (index: UInt, v: *const [4]UByte) callconv(APIENTRY) void,
ptr_glVertexAttrib4uiv: ?*const fn (index: UInt, v: *const [4]UInt) callconv(APIENTRY) void,
ptr_glVertexAttrib4usv: ?*const fn (index: UInt, v: *const [4]UShort) callconv(APIENTRY) void,
ptr_glVertexAttribPointer: ?*const fn (index: UInt, size: Int, @"type": Enum, normalized: bool, stride: Sizei, pointer: usize) callconv(APIENTRY) void,
//#endregion
//#region OpenGL 2.1
ptr_glUniformMatrix2x3fv: ?*const fn (location: Int, count: Sizei, transpose: bool, v: *const [2 * 3]Float) callconv(APIENTRY) void,
ptr_glUniformMatrix3x2fv: ?*const fn (location: Int, count: Sizei, transpose: bool, v: *const [3 * 2]Float) callconv(APIENTRY) void,
ptr_glUniformMatrix2x4fv: ?*const fn (location: Int, count: Sizei, transpose: bool, v: *const [2 * 4]Float) callconv(APIENTRY) void,
ptr_glUniformMatrix4x2fv: ?*const fn (location: Int, count: Sizei, transpose: bool, v: *const [4 * 2]Float) callconv(APIENTRY) void,
ptr_glUniformMatrix3x4fv: ?*const fn (location: Int, count: Sizei, transpose: bool, v: *const [3 * 4]Float) callconv(APIENTRY) void,
ptr_glUniformMatrix4x3fv: ?*const fn (location: Int, count: Sizei, transpose: bool, v: *const [4 * 3]Float) callconv(APIENTRY) void,
//#endregion

//#region OpenGL 3.0
ptr_glColorMaski: ?*const fn (index: UInt, r: bool, g: bool, b: bool, a: bool) callconv(APIENTRY) void,
ptr_glGetBooleani_v: ?*const fn (target: Enum, index: UInt, data: [*]bool) callconv(APIENTRY) void,
ptr_glGetIntegeri_v: ?*const fn (target: Enum, index: UInt, data: [*]Int) callconv(APIENTRY) void,
ptr_glEnablei: ?*const fn (target: Enum, index: UInt) callconv(APIENTRY) void,
ptr_glDisablei: ?*const fn (target: Enum, index: UInt) callconv(APIENTRY) void,
ptr_glIsEnabledi: ?*const fn (target: Enum, index: UInt) callconv(APIENTRY) bool,
ptr_glBeginTransformFeedback: ?*const fn (primitiveMode: Enum) callconv(APIENTRY) void,
ptr_glEndTransformFeedback: ?*const fn () callconv(APIENTRY) void,
ptr_glBindBufferRange: ?*const fn (target: Enum, index: UInt, buffer: UInt, offset: Intptr, size: Sizeiptr) callconv(APIENTRY) void,
ptr_glBindBufferBase: ?*const fn (target: Enum, index: UInt, buffer: UInt) callconv(APIENTRY) void,
ptr_glTransformFeedbackVaryings: ?*const fn (program: UInt, count: Sizei, varyings: [*]const [*:0]const Char, bufferMode: Enum) callconv(APIENTRY) void,
ptr_glGetTransformFeedbackVarying: ?*const fn (program: UInt, index: UInt, bufSize: Sizei, length: ?*Sizei, size: ?*Sizei, @"type": *Enum, name: [*:0]Char) callconv(APIENTRY) void,
ptr_glClampColor: ?*const fn (target: Enum, clamp: Enum) callconv(APIENTRY) void,
ptr_glBeginConditionalRender: ?*const fn (id: UInt, mode: Enum) callconv(APIENTRY) void,
ptr_glEndConditionalRender: ?*const fn () callconv(APIENTRY) void,
ptr_glVertexAttribIPointer: ?*const fn (index: UInt, size: Int, @"type": Enum, stride: Sizei, pointer: usize) callconv(APIENTRY) void,
ptr_glGetVertexAttribIiv: ?*const fn (index: UInt, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetVertexAttribIuiv: ?*const fn (index: UInt, pname: Enum, params: [*]UInt) callconv(APIENTRY) void,
ptr_glVertexAttribI1i: ?*const fn (index: UInt, x: Int) callconv(APIENTRY) void,
ptr_glVertexAttribI2i: ?*const fn (index: UInt, x: Int, y: Int) callconv(APIENTRY) void,
ptr_glVertexAttribI3i: ?*const fn (index: UInt, x: Int, y: Int, z: Int) callconv(APIENTRY) void,
ptr_glVertexAttribI4i: ?*const fn (index: UInt, x: Int, y: Int, z: Int, w: Int) callconv(APIENTRY) void,
ptr_glVertexAttribI1ui: ?*const fn (index: UInt, x: UInt) callconv(APIENTRY) void,
ptr_glVertexAttribI2ui: ?*const fn (index: UInt, x: UInt, y: UInt) callconv(APIENTRY) void,
ptr_glVertexAttribI3ui: ?*const fn (index: UInt, x: UInt, y: UInt, z: UInt) callconv(APIENTRY) void,
ptr_glVertexAttribI4ui: ?*const fn (index: UInt, x: UInt, y: UInt, z: UInt, w: UInt) callconv(APIENTRY) void,
ptr_glVertexAttribI1iv: ?*const fn (index: UInt, v: *const Int) callconv(APIENTRY) void,
ptr_glVertexAttribI2iv: ?*const fn (index: UInt, v: *const [2]Int) callconv(APIENTRY) void,
ptr_glVertexAttribI3iv: ?*const fn (index: UInt, v: *const [3]Int) callconv(APIENTRY) void,
ptr_glVertexAttribI4iv: ?*const fn (index: UInt, v: *const [4]Int) callconv(APIENTRY) void,
ptr_glVertexAttribI1uiv: ?*const fn (index: UInt, v: *const UInt) callconv(APIENTRY) void,
ptr_glVertexAttribI2uiv: ?*const fn (index: UInt, v: *const [2]UInt) callconv(APIENTRY) void,
ptr_glVertexAttribI3uiv: ?*const fn (index: UInt, v: *const [3]UInt) callconv(APIENTRY) void,
ptr_glVertexAttribI4uiv: ?*const fn (index: UInt, v: *const [4]UInt) callconv(APIENTRY) void,
ptr_glVertexAttribI4bv: ?*const fn (index: UInt, v: *const [4]Byte) callconv(APIENTRY) void,
ptr_glVertexAttribI4sv: ?*const fn (index: UInt, v: *const [4]Short) callconv(APIENTRY) void,
ptr_glVertexAttribI4ubv: ?*const fn (index: UInt, v: *const [4]UByte) callconv(APIENTRY) void,
ptr_glVertexAttribI4usv: ?*const fn (index: UInt, v: *const [4]UShort) callconv(APIENTRY) void,
ptr_glGetUniformuiv: ?*const fn (program: UInt, location: Int, params: [*]UInt) callconv(APIENTRY) void,
ptr_glBindFragDataLocation: ?*const fn (program: UInt, color: UInt, name: [*:0]const Char) callconv(APIENTRY) void,
ptr_glGetFragDataLocation: ?*const fn (program: UInt, name: [*:0]const Char) callconv(APIENTRY) Int,
ptr_glUniform1ui: ?*const fn (location: Int, v0: UInt) callconv(APIENTRY) void,
ptr_glUniform2ui: ?*const fn (location: Int, v0: UInt, v1: UInt) callconv(APIENTRY) void,
ptr_glUniform3ui: ?*const fn (location: Int, v0: UInt, v1: UInt, v2: UInt) callconv(APIENTRY) void,
ptr_glUniform4ui: ?*const fn (location: Int, v0: UInt, v1: UInt, v2: UInt, v3: UInt) callconv(APIENTRY) void,
ptr_glUniform1uiv: ?*const fn (location: Int, count: Sizei, value: *const UInt) callconv(APIENTRY) void,
ptr_glUniform2uiv: ?*const fn (location: Int, count: Sizei, value: *const [2]UInt) callconv(APIENTRY) void,
ptr_glUniform3uiv: ?*const fn (location: Int, count: Sizei, value: *const [3]UInt) callconv(APIENTRY) void,
ptr_glUniform4uiv: ?*const fn (location: Int, count: Sizei, value: *const [4]UInt) callconv(APIENTRY) void,
ptr_glTexParameterIiv: ?*const fn (target: Enum, pname: Enum, params: [*]const Int) callconv(APIENTRY) void,
ptr_glTexParameterIuiv: ?*const fn (target: Enum, pname: Enum, params: [*]const UInt) callconv(APIENTRY) void,
ptr_glGetTexParameterIiv: ?*const fn (target: Enum, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetTexParameterIuiv: ?*const fn (target: Enum, pname: Enum, params: [*]UInt) callconv(APIENTRY) void,
ptr_glClearBufferiv: ?*const fn (buffer: Enum, drawBuffer: Int, value: [*]const Int) callconv(APIENTRY) void,
ptr_glClearBufferuiv: ?*const fn (buffer: Enum, drawBuffer: Int, value: [*]const UInt) callconv(APIENTRY) void,
ptr_glClearBufferfv: ?*const fn (buffer: Enum, drawBuffer: Int, value: [*]const Float) callconv(APIENTRY) void,
ptr_glClearBufferfi: ?*const fn (buffer: Enum, drawBuffer: Int, depth: Float, stencil: Int) callconv(APIENTRY) void,
ptr_glGetStringi: ?*const fn (buffer: Enum, index: UInt) callconv(APIENTRY) [*:0]const Char,
ptr_glIsRenderbuffer: ?*const fn (renderbuffer: UInt) callconv(APIENTRY) bool,
ptr_glBindRenderbuffer: ?*const fn (target: Enum, renderbuffer: UInt) callconv(APIENTRY) void,
ptr_glDeleteRenderbuffers: ?*const fn (n: Sizei, renderbuffers: [*]const UInt) callconv(APIENTRY) void,
ptr_glGenRenderbuffers: ?*const fn (n: Sizei, renderbuffers: [*]UInt) callconv(APIENTRY) void,
ptr_glRenderbufferStorage: ?*const fn (target: Enum, internalFormat: Enum, width: Sizei, height: Sizei) callconv(APIENTRY) void,
ptr_glGetRenderbufferParameteriv: ?*const fn (target: Enum, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glIsFramebuffer: ?*const fn (framebuffer: UInt) callconv(APIENTRY) bool,
ptr_glBindFramebuffer: ?*const fn (target: Enum, framebuffer: UInt) callconv(APIENTRY) void,
ptr_glDeleteFramebuffers: ?*const fn (n: Sizei, framebuffers: [*]const UInt) callconv(APIENTRY) void,
ptr_glGenFramebuffers: ?*const fn (n: Sizei, framebuffers: [*]UInt) callconv(APIENTRY) void,
ptr_glCheckFramebufferStatus: ?*const fn (target: Enum) callconv(APIENTRY) Enum,
ptr_glFramebufferTexture1D: ?*const fn (target: Enum, attachment: Enum, textarget: Enum, texture: UInt, level: Int) callconv(APIENTRY) void,
ptr_glFramebufferTexture2D: ?*const fn (target: Enum, attachment: Enum, textarget: Enum, texture: UInt, level: Int) callconv(APIENTRY) void,
ptr_glFramebufferTexture3D: ?*const fn (target: Enum, attachment: Enum, textarget: Enum, texture: UInt, level: Int, zoffset: Int) callconv(APIENTRY) void,
ptr_glFramebufferRenderbuffer: ?*const fn (target: Enum, attachment: Enum, textarget: Enum, renderbuffer: UInt) callconv(APIENTRY) void,
ptr_glGetFramebufferAttachmentParameteriv: ?*const fn (target: Enum, attachment: Enum, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGenerateMipmap: ?*const fn (target: Enum) callconv(APIENTRY) void,
ptr_glBlitFramebuffer: ?*const fn (srcX0: Int, srcY0: Int, srcX1: Int, srcY1: Int, dstX0: Int, dstY0: Int, dstX1: Int, dstY1: Int, mask: Bitfield, filter: Enum) callconv(APIENTRY) void,
ptr_glRenderbufferStorageMultisample: ?*const fn (target: Enum, samples: Sizei, internalFormat: Enum, width: Sizei, heught: Sizei) callconv(APIENTRY) void,
ptr_glFramebufferTextureLayer: ?*const fn (target: Enum, attachment: Enum, texture: UInt, level: Int, layer: Int) callconv(APIENTRY) void,
ptr_glMapBufferRange: ?*const fn (target: Enum, offset: Intptr, length: Sizeiptr, access: Bitfield) callconv(APIENTRY) ?*anyopaque,
ptr_glFlushMappedBufferRange: ?*const fn (target: Enum, offset: Intptr, length: Sizeiptr) callconv(APIENTRY) void,
ptr_glBindVertexArray: ?*const fn (array: UInt) callconv(APIENTRY) void,
ptr_glDeleteVertexArrays: ?*const fn (n: Sizei, arrays: [*]const UInt) callconv(APIENTRY) void,
ptr_glGenVertexArrays: ?*const fn (n: Sizei, arrays: [*]UInt) callconv(APIENTRY) void,
ptr_glIsVertexArray: ?*const fn (array: UInt) callconv(APIENTRY) bool,
//#endregion
//#region OpenGL 3.1
ptr_glDrawArraysInstanced: ?*const fn (mode: Enum, first: Int, count: Sizei, instancecount: Sizei) callconv(APIENTRY) void,
ptr_glDrawElementsInstanced: ?*const fn (mode: Enum, count: Sizei, @"type": Enum, indices: usize, instancecount: Sizei) callconv(APIENTRY) void,
ptr_glTexBuffer: ?*const fn (target: Enum, internalFormat: Enum, buffer: UInt) callconv(APIENTRY) void,
ptr_glPrimitiveRestartIndex: ?*const fn (index: UInt) callconv(APIENTRY) void,
ptr_glCopyBufferSubData: ?*const fn (readTarget: Enum, writeTarget: Enum, readOffset: Intptr, writeOffset: Intptr, size: Sizeiptr) callconv(APIENTRY) void,
ptr_glGetUniformIndices: ?*const fn (program: UInt, uniformCount: Sizei, uniformNames: [*]const [*:0]const Char, uniformIndices: [*]UInt) callconv(APIENTRY) void,
ptr_glGetActiveUniformsiv: ?*const fn (program: UInt, uniformCount: Sizei, uniformIndices: [*]const UInt, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetActiveUniformName: ?*const fn (program: UInt, uniformIndex: UInt, bufSize: Sizei, length: ?*Sizei, uniformName: [*]Char) callconv(APIENTRY) void,
ptr_glGetUniformBlockIndex: ?*const fn (program: UInt, uniformBlockName: [*:0]const Char) callconv(APIENTRY) UInt,
ptr_glGetActiveUniformBlockiv: ?*const fn (program: UInt, uniformBlockIndex: UInt, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetActiveUniformBlockName: ?*const fn (program: UInt, uniformBlockIndex: UInt, bufSize: Sizei, length: ?*Sizei, uniformBlockName: [*]Char) callconv(APIENTRY) void,
ptr_glUniformBlockBinding: ?*const fn (program: UInt, uniformBlockIndex: UInt, uniformBlockBinding: UInt) callconv(APIENTRY) void,
//#endregion
//#region OpenGL 3.2
ptr_glDrawElementsBaseVertex: ?*const fn (mode: Enum, count: Sizei, @"type": Enum, indices: usize, basevertex: Int) callconv(APIENTRY) void,
ptr_glDrawRangeElementsBaseVertex: ?*const fn (mode: Enum, start: UInt, end: UInt, count: Sizei, @"type": Enum, indices: usize, basevertex: Int) callconv(APIENTRY) void,
ptr_glDrawElementsInstancedBaseVertex: ?*const fn (mode: Enum, count: Sizei, @"type": Enum, indices: usize, instancecount: Sizei, basevertex: Int) callconv(APIENTRY) void,
ptr_glMultiDrawElementsBaseVertex: ?*const fn (mode: Enum, count: [*]const Sizei, @"type": Enum, indices: [*]const usize, drawcount: Sizei, basevertex: [*]const Int) callconv(APIENTRY) void,
ptr_glProvokingVertex: ?*const fn (mode: Enum) callconv(APIENTRY) void,
ptr_glFenceSync: ?*const fn (condition: Enum, flags: Bitfield) callconv(APIENTRY) Sync,
ptr_glIsSync: ?*const fn (sync: Sync) callconv(APIENTRY) bool,
ptr_glDeleteSync: ?*const fn (sync: Sync) callconv(APIENTRY) void,
ptr_glClientWaitSync: ?*const fn (sync: Sync, flags: Bitfield, timeout: UInt64) callconv(APIENTRY) Enum,
ptr_glWaitSync: ?*const fn (sync: Sync, flags: Bitfield, timeout: UInt64) callconv(APIENTRY) void,
ptr_glGetInteger64v: ?*const fn (pname: Enum, data: [*]Int64) callconv(APIENTRY) void,
ptr_glGetSynciv: ?*const fn (sync: Sync, pname: Enum, count: Sizei, length: ?*Sizei, values: [*]Int) callconv(APIENTRY) void,
ptr_glGetInteger64i_v: ?*const fn (target: Enum, index: UInt, data: [*]Int64) callconv(APIENTRY) void,
ptr_glGetBufferParameteri64v: ?*const fn (target: Enum, pname: Enum, params: [*]Int64) callconv(APIENTRY) void,
ptr_glFramebufferTexture: ?*const fn (target: Enum, attachment: Enum, texture: UInt, level: Int) callconv(APIENTRY) void,
ptr_glTexImage2DMultisample: ?*const fn (target: Enum, samples: Sizei, internalformat: Enum, width: Sizei, height: Sizei, fixedsamplelocations: bool) callconv(APIENTRY) void,
ptr_glTexImage3DMultisample: ?*const fn (target: Enum, samples: Sizei, internalformat: Enum, width: Sizei, height: Sizei, depth: Sizei, fixedsamplelocations: bool) callconv(APIENTRY) void,
ptr_glGetMultisamplefv: ?*const fn (pname: Enum, index: UInt, val: [*]Float) callconv(APIENTRY) void,
ptr_glSampleMaski: ?*const fn (maskNumber: UInt, mask: Bitfield) callconv(APIENTRY) void,
//#endregion
//#region OpenGL 3.3
ptr_glBindFragDataLocationIndexed: ?*const fn (program: UInt, colorNumber: UInt, index: UInt, name: [*:0]const Char) callconv(APIENTRY) void,
ptr_glGetFragDataIndex: ?*const fn (program: UInt, name: [*:0]const Char) callconv(APIENTRY) Int,
ptr_glGenSamplers: ?*const fn (count: Sizei, samplers: [*]UInt) callconv(APIENTRY) void,
ptr_glDeleteSamplers: ?*const fn (count: Sizei, samplers: [*]const UInt) callconv(APIENTRY) void,
ptr_glIsSampler: ?*const fn (sampler: UInt) callconv(APIENTRY) bool,
ptr_glBindSampler: ?*const fn (unit: UInt, sampler: UInt) callconv(APIENTRY) void,
ptr_glSamplerParameteri: ?*const fn (sampler: UInt, pname: Enum, param: Int) callconv(APIENTRY) void,
ptr_glSamplerParameteriv: ?*const fn (sampler: UInt, pname: Enum, param: [*]const Int) callconv(APIENTRY) void,
ptr_glSamplerParameterf: ?*const fn (sampler: UInt, pname: Enum, param: Float) callconv(APIENTRY) void,
ptr_glSamplerParameterfv: ?*const fn (sampler: UInt, pname: Enum, param: [*]const Float) callconv(APIENTRY) void,
ptr_glSamplerParameterIiv: ?*const fn (sampler: UInt, pname: Enum, param: [*]const Int) callconv(APIENTRY) void,
ptr_glSamplerParameterIuiv: ?*const fn (sampler: UInt, pname: Enum, param: [*]const UInt) callconv(APIENTRY) void,
ptr_glGetSamplerParameteriv: ?*const fn (sampler: UInt, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetSamplerParameterIiv: ?*const fn (sampler: UInt, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetSamplerParameterfv: ?*const fn (sampler: UInt, pname: Enum, params: [*]Float) callconv(APIENTRY) void,
ptr_glGetSamplerParameterIuiv: ?*const fn (sampler: UInt, pname: Enum, params: [*]UInt) callconv(APIENTRY) void,
ptr_glQueryCounter: ?*const fn (id: UInt, target: Enum) callconv(APIENTRY) void,
ptr_glGetQueryObjecti64v: ?*const fn (id: UInt, pname: Enum, params: [*]Int64) callconv(APIENTRY) void,
ptr_glGetQueryObjectui64v: ?*const fn (id: UInt, pname: Enum, params: [*]UInt64) callconv(APIENTRY) void,
ptr_glVertexAttribDivisor: ?*const fn (index: UInt, divisor: UInt) callconv(APIENTRY) void,
ptr_glVertexAttribP1ui: ?*const fn (index: UInt, @"type": Enum, normalized: bool, value: UInt) callconv(APIENTRY) void,
ptr_glVertexAttribP1uiv: ?*const fn (index: UInt, @"type": Enum, normalized: bool, value: *const UInt) callconv(APIENTRY) void,
ptr_glVertexAttribP2ui: ?*const fn (index: UInt, @"type": Enum, normalized: bool, value: UInt) callconv(APIENTRY) void,
ptr_glVertexAttribP2uiv: ?*const fn (index: UInt, @"type": Enum, normalized: bool, value: *const [2]UInt) callconv(APIENTRY) void,
ptr_glVertexAttribP3ui: ?*const fn (index: UInt, @"type": Enum, normalized: bool, value: UInt) callconv(APIENTRY) void,
ptr_glVertexAttribP3uiv: ?*const fn (index: UInt, @"type": Enum, normalized: bool, value: *const [3]UInt) callconv(APIENTRY) void,
ptr_glVertexAttribP4ui: ?*const fn (index: UInt, @"type": Enum, normalized: bool, value: UInt) callconv(APIENTRY) void,
ptr_glVertexAttribP4uiv: ?*const fn (index: UInt, @"type": Enum, normalized: bool, value: *const [4]UInt) callconv(APIENTRY) void,
ptr_glVertexP2ui: ?*const fn (@"type": Enum, value: UInt) callconv(APIENTRY) void,
ptr_glVertexP2uiv: ?*const fn (@"type": Enum, value: *const [2]UInt) callconv(APIENTRY) void,
ptr_glVertexP3ui: ?*const fn (@"type": Enum, value: UInt) callconv(APIENTRY) void,
ptr_glVertexP3uiv: ?*const fn (@"type": Enum, value: *const [3]UInt) callconv(APIENTRY) void,
ptr_glVertexP4ui: ?*const fn (@"type": Enum, value: UInt) callconv(APIENTRY) void,
ptr_glVertexP4uiv: ?*const fn (@"type": Enum, value: *const [4]UInt) callconv(APIENTRY) void,
ptr_glTexCoordP1ui: ?*const fn (@"type": Enum, coords: UInt) callconv(APIENTRY) void,
ptr_glTexCoordP1uiv: ?*const fn (@"type": Enum, coords: *const UInt) callconv(APIENTRY) void,
ptr_glTexCoordP2ui: ?*const fn (@"type": Enum, coords: UInt) callconv(APIENTRY) void,
ptr_glTexCoordP2uiv: ?*const fn (@"type": Enum, coords: *const [2]UInt) callconv(APIENTRY) void,
ptr_glTexCoordP3ui: ?*const fn (@"type": Enum, coords: UInt) callconv(APIENTRY) void,
ptr_glTexCoordP3uiv: ?*const fn (@"type": Enum, coords: *const [3]UInt) callconv(APIENTRY) void,
ptr_glTexCoordP4ui: ?*const fn (@"type": Enum, coords: UInt) callconv(APIENTRY) void,
ptr_glTexCoordP4uiv: ?*const fn (@"type": Enum, coords: *const [4]UInt) callconv(APIENTRY) void,
ptr_glMultiTexCoordP1ui: ?*const fn (texture: Enum, @"type": Enum, coords: UInt) callconv(APIENTRY) void,
ptr_glMultiTexCoordP1uiv: ?*const fn (texture: Enum, @"type": Enum, coords: *const UInt) callconv(APIENTRY) void,
ptr_glMultiTexCoordP2ui: ?*const fn (texture: Enum, @"type": Enum, coords: UInt) callconv(APIENTRY) void,
ptr_glMultiTexCoordP2uiv: ?*const fn (texture: Enum, @"type": Enum, coords: *const [2]UInt) callconv(APIENTRY) void,
ptr_glMultiTexCoordP3ui: ?*const fn (texture: Enum, @"type": Enum, coords: UInt) callconv(APIENTRY) void,
ptr_glMultiTexCoordP3uiv: ?*const fn (texture: Enum, @"type": Enum, coords: *const [3]UInt) callconv(APIENTRY) void,
ptr_glMultiTexCoordP4ui: ?*const fn (texture: Enum, @"type": Enum, coords: UInt) callconv(APIENTRY) void,
ptr_glMultiTexCoordP4uiv: ?*const fn (texture: Enum, @"type": Enum, coords: *const [4]UInt) callconv(APIENTRY) void,
ptr_glNormalP3ui: ?*const fn (@"type": Enum, coords: UInt) callconv(APIENTRY) void,
ptr_glNormalP3uiv: ?*const fn (@"type": Enum, coords: *const [3]UInt) callconv(APIENTRY) void,
ptr_glColorP3ui: ?*const fn (@"type": Enum, color: UInt) callconv(APIENTRY) void,
ptr_glColorP3uiv: ?*const fn (@"type": Enum, color: *const [3]UInt) callconv(APIENTRY) void,
ptr_glColorP4ui: ?*const fn (@"type": Enum, color: UInt) callconv(APIENTRY) void,
ptr_glColorP4uiv: ?*const fn (@"type": Enum, color: *const [4]UInt) callconv(APIENTRY) void,
ptr_glSecondaryColorP3ui: ?*const fn (@"type": Enum, color: UInt) callconv(APIENTRY) void,
ptr_glSecondaryColorP3uiv: ?*const fn (@"type": Enum, color: *const [3]UInt) callconv(APIENTRY) void,
//#endregion

//#region OpenGL 4.0
ptr_glMinSampleShading: ?*const fn (value: Float) callconv(APIENTRY) void,
ptr_glBlendEquationi: ?*const fn (buf: UInt, mode: Enum) callconv(APIENTRY) void,
ptr_glBlendEquationSeparatei: ?*const fn (buf: UInt, modeRGB: Enum, modeAlpha: Enum) callconv(APIENTRY) void,
ptr_glBlendFunci: ?*const fn (buf: UInt, src: Enum, dst: Enum) callconv(APIENTRY) void,
ptr_glBlendFuncSeparatei: ?*const fn (buf: UInt, srcRGB: Enum, dstRGB: Enum, srcAlpha: Enum, dstAlpha: Enum) callconv(APIENTRY) void,
ptr_glDrawArraysIndirect: ?*const fn (mode: Enum, indirect: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glDrawElementsIndirect: ?*const fn (mode: Enum, @"type": Enum, indirect: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glUniform1d: ?*const fn (location: Int, x: Double) callconv(APIENTRY) void,
ptr_glUniform2d: ?*const fn (location: Int, x: Double, y: Double) callconv(APIENTRY) void,
ptr_glUniform3d: ?*const fn (location: Int, x: Double, y: Double, z: Double) callconv(APIENTRY) void,
ptr_glUniform4d: ?*const fn (location: Int, x: Double, y: Double, z: Double, w: Double) callconv(APIENTRY) void,
ptr_glUniform1dv: ?*const fn (location: Int, count: Sizei, value: [*]const Double) callconv(APIENTRY) void,
ptr_glUniform2dv: ?*const fn (location: Int, count: Sizei, value: [*]const [2]Double) callconv(APIENTRY) void,
ptr_glUniform3dv: ?*const fn (location: Int, count: Sizei, value: [*]const [3]Double) callconv(APIENTRY) void,
ptr_glUniform4dv: ?*const fn (location: Int, count: Sizei, value: [*]const [4]Double) callconv(APIENTRY) void,
ptr_glUniformMatrix2dv: ?*const fn (location: Int, count: Sizei, transpose: bool, value: [*]const [2 * 2]Double) callconv(APIENTRY) void,
ptr_glUniformMatrix3dv: ?*const fn (location: Int, count: Sizei, transpose: bool, value: [*]const [3 * 3]Double) callconv(APIENTRY) void,
ptr_glUniformMatrix4dv: ?*const fn (location: Int, count: Sizei, transpose: bool, value: [*]const [4 * 4]Double) callconv(APIENTRY) void,
ptr_glUniformMatrix2x3dv: ?*const fn (location: Int, count: Sizei, transpose: bool, value: [*]const [2 * 3]Double) callconv(APIENTRY) void,
ptr_glUniformMatrix2x4dv: ?*const fn (location: Int, count: Sizei, transpose: bool, value: [*]const [2 * 4]Double) callconv(APIENTRY) void,
ptr_glUniformMatrix3x2dv: ?*const fn (location: Int, count: Sizei, transpose: bool, value: [*]const [3 * 2]Double) callconv(APIENTRY) void,
ptr_glUniformMatrix3x4dv: ?*const fn (location: Int, count: Sizei, transpose: bool, value: [*]const [3 * 4]Double) callconv(APIENTRY) void,
ptr_glUniformMatrix4x2dv: ?*const fn (location: Int, count: Sizei, transpose: bool, value: [*]const [4 * 2]Double) callconv(APIENTRY) void,
ptr_glUniformMatrix4x3dv: ?*const fn (location: Int, count: Sizei, transpose: bool, value: [*]const [4 * 3]Double) callconv(APIENTRY) void,
ptr_glGetUniformdv: ?*const fn (program: UInt, location: Int, params: [*]Double) callconv(APIENTRY) void,
ptr_glGetSubroutineUniformLocation: ?*const fn (program: UInt, shadertype: Enum, name: [*:0]const Char) callconv(APIENTRY) Int,
ptr_glGetSubroutineIndex: ?*const fn (program: UInt, shadertype: Enum, name: [*:0]const Char) callconv(APIENTRY) UInt,
ptr_glGetActiveSubroutineUniformiv: ?*const fn (program: UInt, shadertype: Enum, index: UInt, pname: Enum, values: [*]Int) callconv(APIENTRY) void,
ptr_glGetActiveSubroutineUniformName: ?*const fn (program: UInt, shadertype: Enum, index: UInt, bufSize: Sizei, length: ?*Sizei, name: [*]Char) callconv(APIENTRY) void,
ptr_glGetActiveSubroutineName: ?*const fn (program: UInt, shadertype: Enum, index: UInt, bufSize: Sizei, length: ?*Sizei, name: [*]Char) callconv(APIENTRY) void,
ptr_glUniformSubroutinesuiv: ?*const fn (shadertype: Enum, count: Sizei, indices: [*]const UInt) callconv(APIENTRY) void,
ptr_glGetUniformSubroutineuiv: ?*const fn (shadertype: Enum, location: Int, params: [*]UInt) callconv(APIENTRY) void,
ptr_glGetProgramStageiv: ?*const fn (program: UInt, shadertype: Enum, pname: Enum, values: [*]Int) callconv(APIENTRY) void,
ptr_glPatchParameteri: ?*const fn (pname: Enum, value: Int) callconv(APIENTRY) void,
ptr_glPatchParameterfv: ?*const fn (pname: Enum, values: [*]const Float) callconv(APIENTRY) void,
ptr_glBindTransformFeedback: ?*const fn (target: Enum, id: UInt) callconv(APIENTRY) void,
ptr_glDeleteTransformFeedbacks: ?*const fn (n: Sizei, ids: [*]const UInt) callconv(APIENTRY) void,
ptr_glGenTransformFeedbacks: ?*const fn (n: Sizei, ids: [*]UInt) callconv(APIENTRY) void,
ptr_glIsTransformFeedback: ?*const fn (id: UInt) callconv(APIENTRY) bool,
ptr_glPauseTransformFeedback: ?*const fn () callconv(APIENTRY) void,
ptr_glResumeTransformFeedback: ?*const fn () callconv(APIENTRY) void,
ptr_glDrawTransformFeedback: ?*const fn (mode: Enum, id: UInt) callconv(APIENTRY) void,
ptr_glDrawTransformFeedbackStream: ?*const fn (mode: Enum, id: UInt, stream: UInt) callconv(APIENTRY) void,
ptr_glBeginQueryIndexed: ?*const fn (target: Enum, index: UInt, id: UInt) callconv(APIENTRY) void,
ptr_glEndQueryIndexed: ?*const fn (target: Enum, index: UInt) callconv(APIENTRY) void,
ptr_glGetQueryIndexediv: ?*const fn (target: Enum, index: UInt, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
//#endregion
//#region OpenGL 4.1
ptr_glReleaseShaderCompiler: ?*const fn () callconv(APIENTRY) void,
ptr_glShaderBinary: ?*const fn (count: Sizei, shaders: [*]const UInt, binaryFormat: Enum, binary: ?*const anyopaque, length: Sizei) callconv(APIENTRY) void,
ptr_glGetShaderPrecisionFormat: ?*const fn (shadertype: Enum, precisiontype: Enum, range: *Int, precision: *Int) callconv(APIENTRY) void,
ptr_glDepthRangef: ?*const fn (n: Float, f: Float) callconv(APIENTRY) void,
ptr_glClearDepthf: ?*const fn (d: Float) callconv(APIENTRY) void,
ptr_glGetProgramBinary: ?*const fn (program: UInt, bufSize: Sizei, length: ?*Sizei, binaryFormat: [*]Enum, binary: ?*anyopaque) callconv(APIENTRY) void,
ptr_glProgramBinary: ?*const fn (program: UInt, binaryFormat: Enum, binary: ?*const anyopaque, length: Sizei) callconv(APIENTRY) void,
ptr_glProgramParameteri: ?*const fn (program: UInt, pname: Enum, value: Int) callconv(APIENTRY) void,
ptr_glUseProgramStages: ?*const fn (pipeline: UInt, stages: Bitfield, program: UInt) callconv(APIENTRY) void,
ptr_glActiveShaderProgram: ?*const fn (pipeline: UInt, program: UInt) callconv(APIENTRY) void,
ptr_glCreateShaderProgramv: ?*const fn (@"type": Enum, count: Sizei, strings: [*]const [*:0]const Char) callconv(APIENTRY) UInt,
ptr_glBindProgramPipeline: ?*const fn (pipeline: UInt) callconv(APIENTRY) void,
ptr_glDeleteProgramPipelines: ?*const fn (n: Sizei, pipelines: [*]const UInt) callconv(APIENTRY) void,
ptr_glGenProgramPipelines: ?*const fn (n: Sizei, pipelines: [*]UInt) callconv(APIENTRY) void,
ptr_glIsProgramPipeline: ?*const fn (pipeline: UInt) callconv(APIENTRY) bool,
ptr_glGetProgramPipelineiv: ?*const fn (pipeline: UInt, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glProgramUniform1i: ?*const fn (program: UInt, location: Int, v0: Int) callconv(APIENTRY) void,
ptr_glProgramUniform1iv: ?*const fn (program: UInt, location: Int, count: Sizei, value: [*]const Int) callconv(APIENTRY) void,
ptr_glProgramUniform1f: ?*const fn (program: UInt, location: Int, v0: Float) callconv(APIENTRY) void,
ptr_glProgramUniform1fv: ?*const fn (program: UInt, location: Int, count: Sizei, value: [*]const Float) callconv(APIENTRY) void,
ptr_glProgramUniform1d: ?*const fn (program: UInt, location: Int, v0: Double) callconv(APIENTRY) void,
ptr_glProgramUniform1dv: ?*const fn (program: UInt, location: Int, count: Sizei, value: [*]const Double) callconv(APIENTRY) void,
ptr_glProgramUniform1ui: ?*const fn (program: UInt, location: Int, v0: UInt) callconv(APIENTRY) void,
ptr_glProgramUniform1uiv: ?*const fn (program: UInt, location: Int, count: Sizei, value: [*]const UInt) callconv(APIENTRY) void,
ptr_glProgramUniform2i: ?*const fn (program: UInt, location: Int, v0: Int, v1: Int) callconv(APIENTRY) void,
ptr_glProgramUniform2iv: ?*const fn (program: UInt, location: Int, count: Sizei, value: [*]const [2]Int) callconv(APIENTRY) void,
ptr_glProgramUniform2f: ?*const fn (program: UInt, location: Int, v0: Float, v1: Float) callconv(APIENTRY) void,
ptr_glProgramUniform2fv: ?*const fn (program: UInt, location: Int, count: Sizei, value: [*]const [2]Float) callconv(APIENTRY) void,
ptr_glProgramUniform2d: ?*const fn (program: UInt, location: Int, v0: Double, v1: Double) callconv(APIENTRY) void,
ptr_glProgramUniform2dv: ?*const fn (program: UInt, location: Int, count: Sizei, value: [*]const [2]Double) callconv(APIENTRY) void,
ptr_glProgramUniform2ui: ?*const fn (program: UInt, location: Int, v0: UInt, v1: UInt) callconv(APIENTRY) void,
ptr_glProgramUniform2uiv: ?*const fn (program: UInt, location: Int, count: Sizei, value: [*]const [2]UInt) callconv(APIENTRY) void,
ptr_glProgramUniform3i: ?*const fn (program: UInt, location: Int, v0: Int, v1: Int, v2: Int) callconv(APIENTRY) void,
ptr_glProgramUniform3iv: ?*const fn (program: UInt, location: Int, count: Sizei, value: [*]const [3]Int) callconv(APIENTRY) void,
ptr_glProgramUniform3f: ?*const fn (program: UInt, location: Int, v0: Float, v1: Float, v2: Float) callconv(APIENTRY) void,
ptr_glProgramUniform3fv: ?*const fn (program: UInt, location: Int, count: Sizei, value: [*]const [3]Float) callconv(APIENTRY) void,
ptr_glProgramUniform3d: ?*const fn (program: UInt, location: Int, v0: Double, v1: Double, v2: Double) callconv(APIENTRY) void,
ptr_glProgramUniform3dv: ?*const fn (program: UInt, location: Int, count: Sizei, value: [*]const [3]Double) callconv(APIENTRY) void,
ptr_glProgramUniform3ui: ?*const fn (program: UInt, location: Int, v0: UInt, v1: UInt, v2: UInt) callconv(APIENTRY) void,
ptr_glProgramUniform3uiv: ?*const fn (program: UInt, location: Int, count: Sizei, value: [*]const [3]UInt) callconv(APIENTRY) void,
ptr_glProgramUniform4i: ?*const fn (program: UInt, location: Int, v0: Int, v1: Int, v2: Int, v3: Int) callconv(APIENTRY) void,
ptr_glProgramUniform4iv: ?*const fn (program: UInt, location: Int, count: Sizei, value: [*]const [4]Int) callconv(APIENTRY) void,
ptr_glProgramUniform4f: ?*const fn (program: UInt, location: Int, v0: Float, v1: Float, v2: Float, v3: Float) callconv(APIENTRY) void,
ptr_glProgramUniform4fv: ?*const fn (program: UInt, location: Int, count: Sizei, value: [*]const [4]Float) callconv(APIENTRY) void,
ptr_glProgramUniform4d: ?*const fn (program: UInt, location: Int, v0: Double, v1: Double, v2: Double, v3: Double) callconv(APIENTRY) void,
ptr_glProgramUniform4dv: ?*const fn (program: UInt, location: Int, count: Sizei, value: [*]const [4]Double) callconv(APIENTRY) void,
ptr_glProgramUniform4ui: ?*const fn (program: UInt, location: Int, v0: UInt, v1: UInt, v2: UInt, v3: UInt) callconv(APIENTRY) void,
ptr_glProgramUniform4uiv: ?*const fn (program: UInt, location: Int, count: Sizei, value: [*]const [4]UInt) callconv(APIENTRY) void,
ptr_glProgramUniformMatrix2fv: ?*const fn (program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [2]Float) callconv(APIENTRY) void,
ptr_glProgramUniformMatrix3fv: ?*const fn (program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [3]Float) callconv(APIENTRY) void,
ptr_glProgramUniformMatrix4fv: ?*const fn (program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [4]Float) callconv(APIENTRY) void,
ptr_glProgramUniformMatrix2dv: ?*const fn (program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [2]Double) callconv(APIENTRY) void,
ptr_glProgramUniformMatrix3dv: ?*const fn (program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [3]Double) callconv(APIENTRY) void,
ptr_glProgramUniformMatrix4dv: ?*const fn (program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [4]Double) callconv(APIENTRY) void,
ptr_glProgramUniformMatrix2x3fv: ?*const fn (program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [2 * 3]Float) callconv(APIENTRY) void,
ptr_glProgramUniformMatrix3x2fv: ?*const fn (program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [3 * 2]Float) callconv(APIENTRY) void,
ptr_glProgramUniformMatrix2x4fv: ?*const fn (program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [2 * 4]Float) callconv(APIENTRY) void,
ptr_glProgramUniformMatrix4x2fv: ?*const fn (program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [4 * 2]Float) callconv(APIENTRY) void,
ptr_glProgramUniformMatrix3x4fv: ?*const fn (program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [3 * 4]Float) callconv(APIENTRY) void,
ptr_glProgramUniformMatrix4x3fv: ?*const fn (program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [4 * 3]Float) callconv(APIENTRY) void,
ptr_glProgramUniformMatrix2x3dv: ?*const fn (program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [2 * 3]Double) callconv(APIENTRY) void,
ptr_glProgramUniformMatrix3x2dv: ?*const fn (program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [3 * 2]Double) callconv(APIENTRY) void,
ptr_glProgramUniformMatrix2x4dv: ?*const fn (program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [2 * 4]Double) callconv(APIENTRY) void,
ptr_glProgramUniformMatrix4x2dv: ?*const fn (program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [4 * 2]Double) callconv(APIENTRY) void,
ptr_glProgramUniformMatrix3x4dv: ?*const fn (program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [3 * 4]Double) callconv(APIENTRY) void,
ptr_glProgramUniformMatrix4x3dv: ?*const fn (program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [4 * 3]Double) callconv(APIENTRY) void,
ptr_glValidateProgramPipeline: ?*const fn (pipeline: UInt) callconv(APIENTRY) void,
ptr_glGetProgramPipelineInfoLog: ?*const fn (pipeline: UInt, bufSize: Sizei, length: ?*Sizei, infoLog: [*]Char) callconv(APIENTRY) void,
ptr_glVertexAttribL1d: ?*const fn (index: UInt, x: Double) callconv(APIENTRY) void,
ptr_glVertexAttribL2d: ?*const fn (index: UInt, x: Double, y: Double) callconv(APIENTRY) void,
ptr_glVertexAttribL3d: ?*const fn (index: UInt, x: Double, y: Double, z: Double) callconv(APIENTRY) void,
ptr_glVertexAttribL4d: ?*const fn (index: UInt, x: Double, y: Double, z: Double, w: Double) callconv(APIENTRY) void,
ptr_glVertexAttribL1dv: ?*const fn (index: UInt, v: *const Double) callconv(APIENTRY) void,
ptr_glVertexAttribL2dv: ?*const fn (index: UInt, v: *const [2]Double) callconv(APIENTRY) void,
ptr_glVertexAttribL3dv: ?*const fn (index: UInt, v: *const [3]Double) callconv(APIENTRY) void,
ptr_glVertexAttribL4dv: ?*const fn (index: UInt, v: *const [4]Double) callconv(APIENTRY) void,
ptr_glVertexAttribLPointer: ?*const fn (index: UInt, size: Int, @"type": Enum, stride: Sizei, pointer: usize) callconv(APIENTRY) void,
ptr_glGetVertexAttribLdv: ?*const fn (index: UInt, pname: Enum, params: [*]Double) callconv(APIENTRY) void,
ptr_glViewportArrayv: ?*const fn (first: UInt, count: Sizei, v: [*]const [4]Float) callconv(APIENTRY) void,
ptr_glViewportIndexedf: ?*const fn (index: UInt, x: Float, y: Float, w: Float, h: Float) callconv(APIENTRY) void,
ptr_glViewportIndexedfv: ?*const fn (index: UInt, v: [*]const [4]Float) callconv(APIENTRY) void,
ptr_glScissorArrayv: ?*const fn (first: UInt, count: Sizei, v: [*]const [4]Int) callconv(APIENTRY) void,
ptr_glScissorIndexed: ?*const fn (index: UInt, left: Int, bottom: Int, width: Sizei, height: Sizei) callconv(APIENTRY) void,
ptr_glScissorIndexedv: ?*const fn (index: UInt, v: [*]const [4]Int) callconv(APIENTRY) void,
ptr_glDepthRangeArrayv: ?*const fn (first: UInt, count: Sizei, v: [*]const [3]Double) callconv(APIENTRY) void,
ptr_glDepthRangeIndexed: ?*const fn (index: UInt, n: Double, f: Double) callconv(APIENTRY) void,
ptr_glGetFloati_v: ?*const fn (target: Enum, index: UInt, data: [*]Float) callconv(APIENTRY) void,
ptr_glGetDoublei_v: ?*const fn (target: Enum, index: UInt, data: [*]Double) callconv(APIENTRY) void,
//#endregion
//#region OpenGL 4.2
ptr_glDrawArraysInstancedBaseInstance: ?*const fn (mode: Enum, first: Int, count: Sizei, instancecount: Sizei, baseinstance: UInt) callconv(APIENTRY) void,
ptr_glDrawElementsInstancedBaseInstance: ?*const fn (mode: Enum, count: Sizei, @"type": Enum, indices: usize, instancecount: Sizei, baseinstance: UInt) callconv(APIENTRY) void,
ptr_glDrawElementsInstancedBaseVertexBaseInstance: ?*const fn (mode: Enum, count: Sizei, @"type": Enum, indices: usize, instancecount: Sizei, basevertex: Int, baseinstance: UInt) callconv(APIENTRY) void,
ptr_glGetInternalformativ: ?*const fn (target: Enum, internalformat: Enum, pname: Enum, count: Sizei, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetActiveAtomicCounterBufferiv: ?*const fn (program: UInt, bufferIndex: UInt, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glBindImageTexture: ?*const fn (unit: UInt, texture: UInt, level: Int, layered: bool, layer: Int, access: Enum, format: Enum) callconv(APIENTRY) void,
ptr_glMemoryBarrier: ?*const fn (barriers: Bitfield) callconv(APIENTRY) void,
ptr_glTexStorage1D: ?*const fn (target: Enum, levels: Sizei, internalformat: Enum, width: Sizei) callconv(APIENTRY) void,
ptr_glTexStorage2D: ?*const fn (target: Enum, levels: Sizei, internalformat: Enum, width: Sizei, height: Sizei) callconv(APIENTRY) void,
ptr_glTexStorage3D: ?*const fn (target: Enum, levels: Sizei, internalformat: Enum, width: Sizei, height: Sizei, depth: Sizei) callconv(APIENTRY) void,
ptr_glDrawTransformFeedbackInstanced: ?*const fn (mode: Enum, id: UInt, instancecount: Sizei) callconv(APIENTRY) void,
ptr_glDrawTransformFeedbackStreamInstanced: ?*const fn (mode: Enum, id: UInt, stream: UInt, instancecount: Sizei) callconv(APIENTRY) void,
//#endregion
//#region OpenGL 4.3
ptr_glClearBufferData: ?*const fn (target: Enum, internalformat: Enum, format: Enum, @"type": Enum, data: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glClearBufferSubData: ?*const fn (target: Enum, internalformat: Enum, offset: Intptr, size: Sizeiptr, format: Enum, @"type": Enum, data: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glDispatchCompute: ?*const fn (num_groups_x: UInt, num_groups_y: UInt, num_groups_z: UInt) callconv(APIENTRY) void,
ptr_glDispatchComputeIndirect: ?*const fn (indirect: Intptr) callconv(APIENTRY) void,
ptr_glCopyImageSubData: ?*const fn (srcName: UInt, srcTarget: Enum, srcLevel: Int, srcX: Int, srcY: Int, srcZ: Int, dstName: UInt, dstTarget: Enum, dstLevel: Int, dstX: Int, dstY: Int, dstZ: Int, srcWidth: Sizei, srcHeight: Sizei, srcDepth: Sizei) callconv(APIENTRY) void,
ptr_glFramebufferParameteri: ?*const fn (target: Enum, pname: Enum, param: Int) callconv(APIENTRY) void,
ptr_glGetFramebufferParameteriv: ?*const fn (target: Enum, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetInternalformati64v: ?*const fn (target: Enum, internalformat: Enum, pname: Enum, count: Sizei, params: [*]Int64) callconv(APIENTRY) void,
ptr_glInvalidateTexSubImage: ?*const fn (texture: UInt, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, width: Sizei, height: Sizei, depth: Sizei) callconv(APIENTRY) void,
ptr_glInvalidateTexImage: ?*const fn (texture: UInt, level: Int) callconv(APIENTRY) void,
ptr_glInvalidateBufferSubData: ?*const fn (buffer: UInt, offset: Intptr, length: Sizeiptr) callconv(APIENTRY) void,
ptr_glInvalidateBufferData: ?*const fn (buffer: UInt) callconv(APIENTRY) void,
ptr_glInvalidateFramebuffer: ?*const fn (target: Enum, numAttachments: Sizei, attachments: [*]const Enum) callconv(APIENTRY) void,
ptr_glInvalidateSubFramebuffer: ?*const fn (target: Enum, numAttachments: Sizei, attachments: [*]const Enum, x: Int, y: Int, width: Sizei, height: Sizei) callconv(APIENTRY) void,
ptr_glMultiDrawArraysIndirect: ?*const fn (mode: Enum, indirect: ?*const anyopaque, drawcount: Sizei, stride: Sizei) callconv(APIENTRY) void,
ptr_glMultiDrawElementsIndirect: ?*const fn (mode: Enum, @"type": Enum, indirect: ?*const anyopaque, drawcount: Sizei, stride: Sizei) callconv(APIENTRY) void,
ptr_glGetProgramInterfaceiv: ?*const fn (program: UInt, programInterface: Enum, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetProgramResourceIndex: ?*const fn (program: UInt, programInterface: Enum, name: [*]const Char) callconv(APIENTRY) UInt,
ptr_glGetProgramResourceName: ?*const fn (program: UInt, programInterface: Enum, index: UInt, bufSize: Sizei, length: ?*Sizei, name: [*]Char) callconv(APIENTRY) void,
ptr_glGetProgramResourceiv: ?*const fn (program: UInt, programInterface: Enum, index: UInt, propCount: Sizei, props: [*]const Enum, count: Sizei, length: ?*Sizei, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetProgramResourceLocation: ?*const fn (program: UInt, programInterface: Enum, name: [*:0]const Char) callconv(APIENTRY) Int,
ptr_glGetProgramResourceLocationIndex: ?*const fn (program: UInt, programInterface: Enum, name: [*:0]const Char) callconv(APIENTRY) Int,
ptr_glShaderStorageBlockBinding: ?*const fn (program: UInt, storageBlockIndex: UInt, storageBlockBinding: UInt) callconv(APIENTRY) void,
ptr_glTexBufferRange: ?*const fn (target: Enum, internalformat: Enum, buffer: UInt, offset: Intptr, size: Sizeiptr) callconv(APIENTRY) void,
ptr_glTexStorage2DMultisample: ?*const fn (target: Enum, samples: Sizei, internalformat: Enum, width: Sizei, height: Sizei, fixedsamplelocations: bool) callconv(APIENTRY) void,
ptr_glTexStorage3DMultisample: ?*const fn (target: Enum, samples: Sizei, internalformat: Enum, width: Sizei, height: Sizei, depth: Sizei, fixedsamplelocations: bool) callconv(APIENTRY) void,
ptr_glTextureView: ?*const fn (texture: UInt, target: Enum, origtexture: UInt, internalformat: Enum, minlevel: UInt, numlevels: UInt, minlayer: UInt, numlayers: UInt) callconv(APIENTRY) void,
ptr_glBindVertexBuffer: ?*const fn (bindingindex: UInt, buffer: UInt, offset: Intptr, stride: Sizei) callconv(APIENTRY) void,
ptr_glVertexAttribFormat: ?*const fn (attribindex: UInt, size: Int, @"type": Enum, normalized: bool, relativeoffset: UInt) callconv(APIENTRY) void,
ptr_glVertexAttribIFormat: ?*const fn (attribindex: UInt, size: Int, @"type": Enum, relativeoffset: UInt) callconv(APIENTRY) void,
ptr_glVertexAttribLFormat: ?*const fn (attribindex: UInt, size: Int, @"type": Enum, relativeoffset: UInt) callconv(APIENTRY) void,
ptr_glVertexAttribBinding: ?*const fn (attribindex: UInt, bindingindex: UInt) callconv(APIENTRY) void,
ptr_glVertexBindingDivisor: ?*const fn (bindingindex: UInt, divisor: UInt) callconv(APIENTRY) void,
ptr_glDebugMessageControl: ?*const fn (source: Enum, @"type": Enum, severity: Enum, count: Sizei, ids: [*]const UInt, enabled: bool) callconv(APIENTRY) void,
ptr_glDebugMessageInsert: ?*const fn (source: Enum, @"type": Enum, id: UInt, severity: Enum, length: Sizei, buf: [*]const Char) callconv(APIENTRY) void,
ptr_glDebugMessageCallback: ?*const fn (callback: DebugProc, userParam: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glGetDebugMessageLog: ?*const fn (count: UInt, bufSize: Sizei, sources: [*]Enum, types: [*]Enum, ids: [*]UInt, severities: [*]Enum, lengths: [*]Sizei, messageLog: [*]Char) callconv(APIENTRY) UInt,
ptr_glPushDebugGroup: ?*const fn (source: Enum, id: UInt, length: Sizei, message: [*:0]const Char) callconv(APIENTRY) void,
ptr_glPopDebugGroup: ?*const fn () callconv(APIENTRY) void,
ptr_glObjectLabel: ?*const fn (identifier: Enum, name: UInt, length: Sizei, label: [*:0]const Char) callconv(APIENTRY) void,
ptr_glGetObjectLabel: ?*const fn (identifier: Enum, name: UInt, bufSize: Sizei, length: ?*Sizei, label: [*]Char) callconv(APIENTRY) void,
ptr_glObjectPtrLabel: ?*const fn (ptr: ?*const anyopaque, length: Sizei, label: [*:0]const Char) callconv(APIENTRY) void,
ptr_glGetObjectPtrLabel: ?*const fn (ptr: ?*const anyopaque, bufSize: Sizei, length: [*:0]Sizei, label: [*]Char) callconv(APIENTRY) void,
//#endregion
//#region OpenGL 4.4
ptr_glBufferStorage: ?*const fn (target: Enum, size: Sizeiptr, data: ?*const anyopaque, flags: Bitfield) callconv(APIENTRY) void,
ptr_glClearTexImage: ?*const fn (texture: UInt, level: Int, format: Enum, @"type": Enum, data: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glClearTexSubImage: ?*const fn (texture: UInt, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, width: Sizei, height: Sizei, depth: Sizei, format: Enum, @"type": Enum, data: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glBindBuffersBase: ?*const fn (target: Enum, first: UInt, count: Sizei, buffers: [*]const UInt) callconv(APIENTRY) void,
ptr_glBindBuffersRange: ?*const fn (target: Enum, first: UInt, count: Sizei, buffers: [*]const UInt, offsets: [*]const Intptr, sizes: [*]const Sizeiptr) callconv(APIENTRY) void,
ptr_glBindTextures: ?*const fn (first: UInt, count: Sizei, textures: [*]const UInt) callconv(APIENTRY) void,
ptr_glBindSamplers: ?*const fn (first: UInt, count: Sizei, samplers: [*]const UInt) callconv(APIENTRY) void,
ptr_glBindImageTextures: ?*const fn (first: UInt, count: Sizei, textures: [*]const UInt) callconv(APIENTRY) void,
ptr_glBindVertexBuffers: ?*const fn (first: UInt, count: Sizei, buffers: [*]const UInt, offsets: [*]const Intptr, strides: [*]const Sizei) callconv(APIENTRY) void,
//#endregion
//#region OpenGL 4.5
ptr_glClipControl: ?*const fn (origin: Enum, depth: Enum) callconv(APIENTRY) void,
ptr_glCreateTransformFeedbacks: ?*const fn (n: Sizei, ids: [*]UInt) callconv(APIENTRY) void,
ptr_glTransformFeedbackBufferBase: ?*const fn (xfb: UInt, index: UInt, buffer: UInt) callconv(APIENTRY) void,
ptr_glTransformFeedbackBufferRange: ?*const fn (xfb: UInt, index: UInt, buffer: UInt, offset: Intptr, size: Sizeiptr) callconv(APIENTRY) void,
ptr_glGetTransformFeedbackiv: ?*const fn (xfb: UInt, pname: Enum, param: [*]Int) callconv(APIENTRY) void,
ptr_glGetTransformFeedbacki_v: ?*const fn (xfb: UInt, pname: Enum, index: UInt, param: [*]Int) callconv(APIENTRY) void,
ptr_glGetTransformFeedbacki64_v: ?*const fn (xfb: UInt, pname: Enum, index: UInt, param: [*]Int64) callconv(APIENTRY) void,
ptr_glCreateBuffers: ?*const fn (n: Sizei, buffers: [*]UInt) callconv(APIENTRY) void,
ptr_glNamedBufferStorage: ?*const fn (buffer: UInt, size: Sizeiptr, data: ?*const anyopaque, flags: Bitfield) callconv(APIENTRY) void,
ptr_glNamedBufferData: ?*const fn (buffer: UInt, size: Sizeiptr, data: ?*const anyopaque, usage: Enum) callconv(APIENTRY) void,
ptr_glNamedBufferSubData: ?*const fn (buffer: UInt, offset: Intptr, size: Sizeiptr, data: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glCopyNamedBufferSubData: ?*const fn (readBuffer: UInt, writeBuffer: UInt, readOffset: Intptr, writeOffset: Intptr, size: Sizeiptr) callconv(APIENTRY) void,
ptr_glClearNamedBufferData: ?*const fn (buffer: UInt, internalformat: Enum, format: Enum, @"type": Enum, data: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glClearNamedBufferSubData: ?*const fn (buffer: UInt, internalformat: Enum, offset: Intptr, size: Sizeiptr, format: Enum, @"type": Enum, data: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glMapNamedBuffer: ?*const fn (buffer: UInt, access: Enum) callconv(APIENTRY) ?*anyopaque,
ptr_glMapNamedBufferRange: ?*const fn (buffer: UInt, offset: Intptr, length: Sizeiptr, access: Bitfield) callconv(APIENTRY) ?*anyopaque,
ptr_glUnmapNamedBuffer: ?*const fn (buffer: UInt) callconv(APIENTRY) bool,
ptr_glFlushMappedNamedBufferRange: ?*const fn (buffer: UInt, offset: Intptr, length: Sizeiptr) callconv(APIENTRY) void,
ptr_glGetNamedBufferParameteriv: ?*const fn (buffer: UInt, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetNamedBufferParameteri64v: ?*const fn (buffer: UInt, pname: Enum, params: [*]Int64) callconv(APIENTRY) void,
ptr_glGetNamedBufferPointerv: ?*const fn (buffer: UInt, pname: Enum, params: [*]?*anyopaque) callconv(APIENTRY) void,
ptr_glGetNamedBufferSubData: ?*const fn (buffer: UInt, offset: Intptr, size: Sizeiptr, data: ?*anyopaque) callconv(APIENTRY) void,
ptr_glCreateFramebuffers: ?*const fn (n: Sizei, framebuffers: [*]UInt) callconv(APIENTRY) void,
ptr_glNamedFramebufferRenderbuffer: ?*const fn (framebuffer: UInt, attachment: Enum, renderbuffertarget: Enum, renderbuffer: UInt) callconv(APIENTRY) void,
ptr_glNamedFramebufferParameteri: ?*const fn (framebuffer: UInt, pname: Enum, param: Int) callconv(APIENTRY) void,
ptr_glNamedFramebufferTexture: ?*const fn (framebuffer: UInt, attachment: Enum, texture: UInt, level: Int) callconv(APIENTRY) void,
ptr_glNamedFramebufferTextureLayer: ?*const fn (framebuffer: UInt, attachment: Enum, texture: UInt, level: Int, layer: Int) callconv(APIENTRY) void,
ptr_glNamedFramebufferDrawBuffer: ?*const fn (framebuffer: UInt, buf: Enum) callconv(APIENTRY) void,
ptr_glNamedFramebufferDrawBuffers: ?*const fn (framebuffer: UInt, n: Sizei, bufs: [*]const Enum) callconv(APIENTRY) void,
ptr_glNamedFramebufferReadBuffer: ?*const fn (framebuffer: UInt, src: Enum) callconv(APIENTRY) void,
ptr_glInvalidateNamedFramebufferData: ?*const fn (framebuffer: UInt, numAttachments: Sizei, attachments: [*]const Enum) callconv(APIENTRY) void,
ptr_glInvalidateNamedFramebufferSubData: ?*const fn (framebuffer: UInt, numAttachments: Sizei, attachments: [*]const Enum, x: Int, y: Int, width: Sizei, height: Sizei) callconv(APIENTRY) void,
ptr_glClearNamedFramebufferiv: ?*const fn (framebuffer: UInt, buffer: Enum, drawbuffer: Int, value: [*]const Int) callconv(APIENTRY) void,
ptr_glClearNamedFramebufferuiv: ?*const fn (framebuffer: UInt, buffer: Enum, drawbuffer: Int, value: [*]const UInt) callconv(APIENTRY) void,
ptr_glClearNamedFramebufferfv: ?*const fn (framebuffer: UInt, buffer: Enum, drawbuffer: Int, value: [*]const Float) callconv(APIENTRY) void,
ptr_glClearNamedFramebufferfi: ?*const fn (framebuffer: UInt, buffer: Enum, drawbuffer: Int, depth: Float, stencil: Int) callconv(APIENTRY) void,
ptr_glBlitNamedFramebuffer: ?*const fn (readFramebuffer: UInt, drawFramebuffer: UInt, srcX0: Int, srcY0: Int, srcX1: Int, srcY1: Int, dstX0: Int, dstY0: Int, dstX1: Int, dstY1: Int, mask: Bitfield, filter: Enum) callconv(APIENTRY) void,
ptr_glCheckNamedFramebufferStatus: ?*const fn (framebuffer: UInt, target: Enum) callconv(APIENTRY) Enum,
ptr_glGetNamedFramebufferParameteriv: ?*const fn (framebuffer: UInt, pname: Enum, param: [*]Int) callconv(APIENTRY) void,
ptr_glGetNamedFramebufferAttachmentParameteriv: ?*const fn (framebuffer: UInt, attachment: Enum, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glCreateRenderbuffers: ?*const fn (n: Sizei, renderbuffers: [*]UInt) callconv(APIENTRY) void,
ptr_glNamedRenderbufferStorage: ?*const fn (renderbuffer: UInt, internalformat: Enum, width: Sizei, height: Sizei) callconv(APIENTRY) void,
ptr_glNamedRenderbufferStorageMultisample: ?*const fn (renderbuffer: UInt, samples: Sizei, internalformat: Enum, width: Sizei, height: Sizei) callconv(APIENTRY) void,
ptr_glGetNamedRenderbufferParameteriv: ?*const fn (renderbuffer: UInt, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glCreateTextures: ?*const fn (target: Enum, n: Sizei, textures: [*]UInt) callconv(APIENTRY) void,
ptr_glTextureBuffer: ?*const fn (texture: UInt, internalformat: Enum, buffer: UInt) callconv(APIENTRY) void,
ptr_glTextureBufferRange: ?*const fn (texture: UInt, internalformat: Enum, buffer: UInt, offset: Intptr, size: Sizeiptr) callconv(APIENTRY) void,
ptr_glTextureStorage1D: ?*const fn (texture: UInt, levels: Sizei, internalformat: Enum, width: Sizei) callconv(APIENTRY) void,
ptr_glTextureStorage2D: ?*const fn (texture: UInt, levels: Sizei, internalformat: Enum, width: Sizei, height: Sizei) callconv(APIENTRY) void,
ptr_glTextureStorage3D: ?*const fn (texture: UInt, levels: Sizei, internalformat: Enum, width: Sizei, height: Sizei, depth: Sizei) callconv(APIENTRY) void,
ptr_glTextureStorage2DMultisample: ?*const fn (texture: UInt, samples: Sizei, internalformat: Enum, width: Sizei, height: Sizei, fixedsamplelocations: bool) callconv(APIENTRY) void,
ptr_glTextureStorage3DMultisample: ?*const fn (texture: UInt, samples: Sizei, internalformat: Enum, width: Sizei, height: Sizei, depth: Sizei, fixedsamplelocations: bool) callconv(APIENTRY) void,
ptr_glTextureSubImage1D: ?*const fn (texture: UInt, level: Int, xoffset: Int, width: Sizei, format: Enum, @"type": Enum, pixels: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glTextureSubImage2D: ?*const fn (texture: UInt, level: Int, xoffset: Int, yoffset: Int, width: Sizei, height: Sizei, format: Enum, @"type": Enum, pixels: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glTextureSubImage3D: ?*const fn (texture: UInt, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, width: Sizei, height: Sizei, depth: Sizei, format: Enum, @"type": Enum, pixels: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glCompressedTextureSubImage1D: ?*const fn (texture: UInt, level: Int, xoffset: Int, width: Sizei, format: Enum, imageSize: Sizei, data: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glCompressedTextureSubImage2D: ?*const fn (texture: UInt, level: Int, xoffset: Int, yoffset: Int, width: Sizei, height: Sizei, format: Enum, imageSize: Sizei, data: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glCompressedTextureSubImage3D: ?*const fn (texture: UInt, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, width: Sizei, height: Sizei, depth: Sizei, format: Enum, imageSize: Sizei, data: ?*const anyopaque) callconv(APIENTRY) void,
ptr_glCopyTextureSubImage1D: ?*const fn (texture: UInt, level: Int, xoffset: Int, x: Int, y: Int, width: Sizei) callconv(APIENTRY) void,
ptr_glCopyTextureSubImage2D: ?*const fn (texture: UInt, level: Int, xoffset: Int, yoffset: Int, x: Int, y: Int, width: Sizei, height: Sizei) callconv(APIENTRY) void,
ptr_glCopyTextureSubImage3D: ?*const fn (texture: UInt, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, x: Int, y: Int, width: Sizei, height: Sizei) callconv(APIENTRY) void,
ptr_glTextureParameterf: ?*const fn (texture: UInt, pname: Enum, param: Float) callconv(APIENTRY) void,
ptr_glTextureParameterfv: ?*const fn (texture: UInt, pname: Enum, param: [*]const Float) callconv(APIENTRY) void,
ptr_glTextureParameteri: ?*const fn (texture: UInt, pname: Enum, param: Int) callconv(APIENTRY) void,
ptr_glTextureParameterIiv: ?*const fn (texture: UInt, pname: Enum, params: [*]const Int) callconv(APIENTRY) void,
ptr_glTextureParameterIuiv: ?*const fn (texture: UInt, pname: Enum, params: [*]const UInt) callconv(APIENTRY) void,
ptr_glTextureParameteriv: ?*const fn (texture: UInt, pname: Enum, param: [*]const Int) callconv(APIENTRY) void,
ptr_glGenerateTextureMipmap: ?*const fn (texture: UInt) callconv(APIENTRY) void,
ptr_glBindTextureUnit: ?*const fn (unit: UInt, texture: UInt) callconv(APIENTRY) void,
ptr_glGetTextureImage: ?*const fn (texture: UInt, level: Int, format: Enum, @"type": Enum, bufSize: Sizei, pixels: ?*anyopaque) callconv(APIENTRY) void,
ptr_glGetCompressedTextureImage: ?*const fn (texture: UInt, level: Int, bufSize: Sizei, pixels: ?*anyopaque) callconv(APIENTRY) void,
ptr_glGetTextureLevelParameterfv: ?*const fn (texture: UInt, level: Int, pname: Enum, params: [*]Float) callconv(APIENTRY) void,
ptr_glGetTextureLevelParameteriv: ?*const fn (texture: UInt, level: Int, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetTextureParameterfv: ?*const fn (texture: UInt, pname: Enum, params: [*]Float) callconv(APIENTRY) void,
ptr_glGetTextureParameterIiv: ?*const fn (texture: UInt, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetTextureParameterIuiv: ?*const fn (texture: UInt, pname: Enum, params: [*]UInt) callconv(APIENTRY) void,
ptr_glGetTextureParameteriv: ?*const fn (texture: UInt, pname: Enum, params: [*]Int) callconv(APIENTRY) void,
ptr_glCreateVertexArrays: ?*const fn (n: Sizei, arrays: [*]UInt) callconv(APIENTRY) void,
ptr_glDisableVertexArrayAttrib: ?*const fn (vaobj: UInt, index: UInt) callconv(APIENTRY) void,
ptr_glEnableVertexArrayAttrib: ?*const fn (vaobj: UInt, index: UInt) callconv(APIENTRY) void,
ptr_glVertexArrayElementBuffer: ?*const fn (vaobj: UInt, buffer: UInt) callconv(APIENTRY) void,
ptr_glVertexArrayVertexBuffer: ?*const fn (vaobj: UInt, bindingindex: UInt, buffer: UInt, offset: Intptr, stride: Sizei) callconv(APIENTRY) void,
ptr_glVertexArrayVertexBuffers: ?*const fn (vaobj: UInt, first: UInt, count: Sizei, buffers: [*]const UInt, offsets: [*]const Intptr, strides: [*]const Sizei) callconv(APIENTRY) void,
ptr_glVertexArrayAttribBinding: ?*const fn (vaobj: UInt, attribindex: UInt, bindingindex: UInt) callconv(APIENTRY) void,
ptr_glVertexArrayAttribFormat: ?*const fn (vaobj: UInt, attribindex: UInt, size: Int, @"type": Enum, normalized: bool, relativeoffset: UInt) callconv(APIENTRY) void,
ptr_glVertexArrayAttribIFormat: ?*const fn (vaobj: UInt, attribindex: UInt, size: Int, @"type": Enum, relativeoffset: UInt) callconv(APIENTRY) void,
ptr_glVertexArrayAttribLFormat: ?*const fn (vaobj: UInt, attribindex: UInt, size: Int, @"type": Enum, relativeoffset: UInt) callconv(APIENTRY) void,
ptr_glVertexArrayBindingDivisor: ?*const fn (vaobj: UInt, bindingindex: UInt, divisor: UInt) callconv(APIENTRY) void,
ptr_glGetVertexArrayiv: ?*const fn (vaobj: UInt, pname: Enum, param: [*]Int) callconv(APIENTRY) void,
ptr_glGetVertexArrayIndexediv: ?*const fn (vaobj: UInt, index: UInt, pname: Enum, param: [*]Int) callconv(APIENTRY) void,
ptr_glGetVertexArrayIndexed64iv: ?*const fn (vaobj: UInt, index: UInt, pname: Enum, param: [*]Int64) callconv(APIENTRY) void,
ptr_glCreateSamplers: ?*const fn (n: Sizei, samplers: [*]UInt) callconv(APIENTRY) void,
ptr_glCreateProgramPipelines: ?*const fn (n: Sizei, pipelines: [*]UInt) callconv(APIENTRY) void,
ptr_glCreateQueries: ?*const fn (target: Enum, n: Sizei, ids: [*]UInt) callconv(APIENTRY) void,
ptr_glGetQueryBufferObjecti64v: ?*const fn (id: UInt, buffer: UInt, pname: Enum, offset: Intptr) callconv(APIENTRY) void,
ptr_glGetQueryBufferObjectiv: ?*const fn (id: UInt, buffer: UInt, pname: Enum, offset: Intptr) callconv(APIENTRY) void,
ptr_glGetQueryBufferObjectui64v: ?*const fn (id: UInt, buffer: UInt, pname: Enum, offset: Intptr) callconv(APIENTRY) void,
ptr_glGetQueryBufferObjectuiv: ?*const fn (id: UInt, buffer: UInt, pname: Enum, offset: Intptr) callconv(APIENTRY) void,
ptr_glMemoryBarrierByRegion: ?*const fn (barriers: Bitfield) callconv(APIENTRY) void,
ptr_glGetTextureSubImage: ?*const fn (texture: UInt, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, width: Sizei, height: Sizei, depth: Sizei, format: Enum, @"type": Enum, bufSize: Sizei, pixels: ?*anyopaque) callconv(APIENTRY) void,
ptr_glGetCompressedTextureSubImage: ?*const fn (texture: UInt, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, width: Sizei, height: Sizei, depth: Sizei, bufSize: Sizei, pixels: ?*anyopaque) callconv(APIENTRY) void,
ptr_glGetGraphicsResetStatus: ?*const fn () callconv(APIENTRY) Enum,
ptr_glGetnCompressedTexImage: ?*const fn (target: Enum, lod: Int, bufSize: Sizei, pixels: ?*anyopaque) callconv(APIENTRY) void,
ptr_glGetnTexImage: ?*const fn (target: Enum, level: Int, format: Enum, @"type": Enum, bufSize: Sizei, pixels: ?*anyopaque) callconv(APIENTRY) void,
ptr_glGetnUniformdv: ?*const fn (program: UInt, location: Int, bufSize: Sizei, params: [*]Double) callconv(APIENTRY) void,
ptr_glGetnUniformfv: ?*const fn (program: UInt, location: Int, bufSize: Sizei, params: [*]Float) callconv(APIENTRY) void,
ptr_glGetnUniformiv: ?*const fn (program: UInt, location: Int, bufSize: Sizei, params: [*]Int) callconv(APIENTRY) void,
ptr_glGetnUniformuiv: ?*const fn (program: UInt, location: Int, bufSize: Sizei, params: [*]UInt) callconv(APIENTRY) void,
ptr_glReadnPixels: ?*const fn (x: Int, y: Int, width: Sizei, height: Sizei, format: Enum, @"type": Enum, bufSize: Sizei, data: ?*anyopaque) callconv(APIENTRY) void,
ptr_glGetnMapdv: ?*const fn (target: Enum, query: Enum, bufSize: Sizei, v: [*]Double) callconv(APIENTRY) void,
ptr_glGetnMapfv: ?*const fn (target: Enum, query: Enum, bufSize: Sizei, v: [*]Float) callconv(APIENTRY) void,
ptr_glGetnMapiv: ?*const fn (target: Enum, query: Enum, bufSize: Sizei, v: [*]Int) callconv(APIENTRY) void,
ptr_glGetnPixelMapfv: ?*const fn (map: Enum, bufSize: Sizei, values: [*]Float) callconv(APIENTRY) void,
ptr_glGetnPixelMapuiv: ?*const fn (map: Enum, bufSize: Sizei, values: [*]UInt) callconv(APIENTRY) void,
ptr_glGetnPixelMapusv: ?*const fn (map: Enum, bufSize: Sizei, values: [*]UShort) callconv(APIENTRY) void,
ptr_glGetnPolygonStipple: ?*const fn (bufSize: Sizei, pattern: [*]UByte) callconv(APIENTRY) void,
ptr_glGetnColorTable: ?*const fn (target: Enum, format: Enum, @"type": Enum, bufSize: Sizei, table: ?*anyopaque) callconv(APIENTRY) void,
ptr_glGetnConvolutionFilter: ?*const fn (target: Enum, format: Enum, @"type": Enum, bufSize: Sizei, image: ?*anyopaque) callconv(APIENTRY) void,
ptr_glGetnSeparableFilter: ?*const fn (target: Enum, format: Enum, @"type": Enum, rowBufSize: Sizei, row: ?*anyopaque, columnBufSize: Sizei, column: ?*anyopaque, span: ?*anyopaque) callconv(APIENTRY) void,
ptr_glGetnHistogram: ?*const fn (target: Enum, reset: bool, format: Enum, @"type": Enum, bufSize: Sizei, values: ?*anyopaque) callconv(APIENTRY) void,
ptr_glGetnMinmax: ?*const fn (target: Enum, reset: bool, format: Enum, @"type": Enum, bufSize: Sizei, values: ?*anyopaque) callconv(APIENTRY) void,
ptr_glTextureBarrier: ?*const fn () callconv(APIENTRY) void,
//#endregion
//#region OpenGL 4.6
ptr_glSpecializeShader: ?*const fn (shader: UInt, pEntryPoint: [*:0]const Char, numSpecializationConstants: UInt, pConstantIndex: [*]const UInt, pConstantValue: [*]const UInt) callconv(APIENTRY) void,
ptr_glMultiDrawArraysIndirectCount: ?*const fn (mode: Enum, indirect: ?*const anyopaque, drawcount: Intptr, maxdrawcount: Sizei, stride: Sizei) callconv(APIENTRY) void,
ptr_glMultiDrawElementsIndirectCount: ?*const fn (mode: Enum, @"type": Enum, indirect: ?*const anyopaque, drawcount: Intptr, maxdrawcount: Sizei, stride: Sizei) callconv(APIENTRY) void,
ptr_glPolygonOffsetClamp: ?*const fn (factor: Float, units: Float, clamp: Float) callconv(APIENTRY) void,
//#endregion
//#endregion fields

pub fn init(self: *GL, loader: ?ProcLoader) !void {
    try loadFunctions(GL, self, loader);

    var version: [2]i32 = undefined;
    self.getIntegerv(GL.MAJOR_VERSION, @ptrCast(&version[0]));
    self.getIntegerv(GL.MINOR_VERSION, @ptrCast(&version[1]));
    self.version = .{
        .major = @intCast(version[0]),
        .minor = @intCast(version[1]),
    };
}
/// Add `ZGLL_PREFIX` constant to change the function pointer
/// prefix, default is `ptr_`.
pub fn loadFunctions(comptime T: type, v: *T, loader: ?GL.ProcLoader) !void {
    if (loader) |loaderFunc|
        initProc(T, v, loaderFunc)
    else {
        try openLib();

        initProc(T, v, procLoader);

        closeLib();
    }
}

inline fn initProc(comptime T: type, v: *T, loader: GL.ProcLoader) void {
    @setEvalBranchQuota(std.meta.fields(GL).len * 50);
    inline for (std.meta.fields(T)) |field| {
        const prefix = if (@hasDecl(T, "ZGLL_PREFIX"))
            T.ZGLL_PREFIX
        else
            "ptr_";
        if (comptime std.mem.startsWith(u8, field.name, prefix)) {
            @field(v, field.name) = @ptrCast(@alignCast(loader(field.name[prefix.len..])));
        }
    }
}

// TODO: Add documentation to wrapper functions

//#region functions
//#region OpenGL 1.0
/// - **Available since:** OpenGL 1.0
pub fn cullFace(self: *const GL, mode: Enum) void {
    return self.ptr_glCullFace.?(mode);
}
/// - **Available since:** OpenGL 1.0
pub fn frontFace(self: *const GL, mode: Enum) void {
    return self.ptr_glFrontFace.?(mode);
}
/// - **Available since:** OpenGL 1.0
pub fn hint(self: *const GL, target: Enum, mode: Enum) void {
    return self.ptr_glHint.?(target, mode);
}
/// - **Available since:** OpenGL 1.0
pub fn lineWidth(self: *const GL, width: Float) void {
    return self.ptr_glLineWidth.?(width);
}
/// - **Available since:** OpenGL 1.0
pub fn pointSize(self: *const GL, size: Float) void {
    return self.ptr_glPointSize.?(size);
}
/// - **Available since:** OpenGL 1.0
pub fn polygonMode(self: *const GL, face: Enum, mode: Enum) void {
    return self.ptr_glPolygonMode.?(face, mode);
}
/// - **Available since:** OpenGL 1.0
pub fn scissor(self: *const GL, x: Int, y: Int, width: Sizei, height: Sizei) void {
    return self.ptr_glScissor.?(x, y, width, height);
}
/// - **Available since:** OpenGL 1.0
pub fn texParameterf(self: *const GL, target: Enum, pname: Enum, param: Float) void {
    return self.ptr_glTexParameterf.?(target, pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn texParameterfv(self: *const GL, target: Enum, pname: Enum, params: [*]const Float) void {
    return self.ptr_glTexParameterfv.?(target, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn texParameteri(self: *const GL, target: Enum, pname: Enum, param: Int) void {
    return self.ptr_glTexParameteri.?(target, pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn texParameteriv(self: *const GL, target: Enum, pname: Enum, param: [*]const Int) void {
    return self.ptr_glTexParameteriv.?(target, pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn texImage1D(self: *const GL, target: Enum, level: Int, internalformat: Int, width: Sizei, border: Int, format: Enum, @"type": Enum, pixels: ?*const anyopaque) void {
    return self.ptr_glTexImage1D.?(target, level, internalformat, width, border, format, @"type", pixels);
}
/// - **Available since:** OpenGL 1.0
pub fn texImage2D(self: *const GL, target: Enum, level: Int, internalformat: Int, width: Sizei, height: Sizei, border: Int, format: Enum, @"type": Enum, pixels: ?*const anyopaque) void {
    return self.ptr_glTexImage2D.?(target, level, internalformat, width, height, border, format, @"type", pixels);
}
/// - **Available since:** OpenGL 1.0
pub fn drawBuffer(self: *const GL, buf: Enum) void {
    return self.ptr_glDrawBuffer.?(buf);
}
/// - **Available since:** OpenGL 1.0
pub fn clear(self: *const GL, mask: Bitfield) void {
    return self.ptr_glClear.?(mask);
}
/// - **Available since:** OpenGL 1.0
pub fn clearColor(self: *const GL, red: Float, green: Float, blue: Float, alpha: Float) void {
    return self.ptr_glClearColor.?(red, green, blue, alpha);
}
/// - **Available since:** OpenGL 1.0
pub fn clearStencil(self: *const GL, s: Int) void {
    return self.ptr_glClearStencil.?(s);
}
/// - **Available since:** OpenGL 1.0
pub fn clearDepth(self: *const GL, depth: Double) void {
    return self.ptr_glClearDepth.?(depth);
}
/// - **Available since:** OpenGL 1.0
pub fn stencilMask(self: *const GL, mask: UInt) void {
    return self.ptr_glStencilMask.?(mask);
}
/// - **Available since:** OpenGL 1.0
pub fn colorMask(self: *const GL, red: bool, green: bool, blue: bool, alpha: bool) void {
    return self.ptr_glColorMask.?(red, green, blue, alpha);
}
/// - **Available since:** OpenGL 1.0
pub fn depthMask(self: *const GL, flag: bool) void {
    return self.ptr_glDepthMask.?(flag);
}
/// - **Available since:** OpenGL 1.0
pub fn disable(self: *const GL, cap: Enum) void {
    return self.ptr_glDisable.?(cap);
}
/// - **Available since:** OpenGL 1.0
pub fn enable(self: *const GL, cap: Enum) void {
    return self.ptr_glEnable.?(cap);
}
/// - **Available since:** OpenGL 1.0
pub fn finish(self: *const GL) void {
    return self.ptr_glFinish.?();
}
/// - **Available since:** OpenGL 1.0
pub fn flush(self: *const GL) void {
    return self.ptr_glFlush.?();
}
/// - **Available since:** OpenGL 1.0
pub fn blendFunc(self: *const GL, sfactor: Enum, dfactor: Enum) void {
    return self.ptr_glBlendFunc.?(sfactor, dfactor);
}
/// - **Available since:** OpenGL 1.0
pub fn logicOp(self: *const GL, opcode: Enum) void {
    return self.ptr_glLogicOp.?(opcode);
}
/// - **Available since:** OpenGL 1.0
pub fn stencilFunc(self: *const GL, func: Enum, ref: Int, mask: UInt) void {
    return self.ptr_glStencilFunc.?(func, ref, mask);
}
/// - **Available since:** OpenGL 1.0
pub fn stencilOp(self: *const GL, fail: Enum, zfail: Enum, zpass: Enum) void {
    return self.ptr_glStencilOp.?(fail, zfail, zpass);
}
/// - **Available since:** OpenGL 1.0
pub fn depthFunc(self: *const GL, func: Enum) void {
    return self.ptr_glDepthFunc.?(func);
}
/// - **Available since:** OpenGL 1.0
pub fn pixelStoref(self: *const GL, pname: Enum, param: Float) void {
    return self.ptr_glPixelStoref.?(pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn pixelStorei(self: *const GL, pname: Enum, param: Int) void {
    return self.ptr_glPixelStorei.?(pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn readBuffer(self: *const GL, src: Enum) void {
    return self.ptr_glReadBuffer.?(src);
}
/// - **Available since:** OpenGL 1.0
pub fn readPixels(self: *const GL, x: Int, y: Int, width: Sizei, height: Sizei, format: Enum, @"type": Enum, pixels: [*]u8) void {
    return self.ptr_glReadPixels.?(x, y, width, height, format, @"type", pixels);
}
/// - **Available since:** OpenGL 1.0
pub fn getBooleanv(self: *const GL, pname: Enum, data: [*]bool) void {
    return self.ptr_glGetBooleanv.?(pname, data);
}
/// - **Available since:** OpenGL 1.0
pub fn getDoublev(self: *const GL, pname: Enum, data: [*]Double) void {
    return self.ptr_glGetDoublev.?(pname, data);
}
/// - **Available since:** OpenGL 1.0
pub fn getError(self: *const GL) Enum {
    return self.ptr_glGetError.?();
}
/// - **Available since:** OpenGL 1.0
pub fn getFloatv(self: *const GL, pname: Enum, data: [*]Double) void {
    return self.ptr_glGetFloatv.?(pname, data);
}
/// - **Available since:** OpenGL 1.0
pub fn getIntegerv(self: *const GL, pname: Enum, data: [*]Int) void {
    return self.ptr_glGetIntegerv.?(pname, data);
}
/// - **Available since:** OpenGL 1.0
pub fn getString(self: *const GL, pname: Enum) ?[*:0]const u8 {
    return self.ptr_glGetString.?(pname);
}
/// - **Available since:** OpenGL 1.0
pub fn getTexImage(self: *const GL, target: Enum, level: Int, format: Enum, @"type": Enum, pixels: [*]u8) void {
    return self.ptr_glGetTexImage.?(target, level, format, @"type", pixels);
}
/// - **Available since:** OpenGL 1.0
pub fn getTexParameterfv(self: *const GL, target: Enum, pname: Enum, params: [*]Float) void {
    return self.ptr_glGetTexParameterfv.?(target, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn getTexParameteriv(self: *const GL, target: Enum, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetTexParameteriv.?(target, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn getTexLevelParameterfv(self: *const GL, target: Enum, level: Int, pname: Enum, params: [*]Float) void {
    return self.ptr_glGetTexLevelParameterfv.?(target, level, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn getTexLevelParameteriv(self: *const GL, target: Enum, level: Int, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetTexLevelParameteriv.?(target, level, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn isEnabled(self: *const GL, cap: Enum) bool {
    return self.ptr_glIsEnabled.?(cap);
}
/// - **Available since:** OpenGL 1.0
pub fn depthRange(self: *const GL, n: Double, f: Double) void {
    return self.ptr_glDepthRange.?(n, f);
}
/// - **Available since:** OpenGL 1.0
pub fn viewport(self: *const GL, x: Int, y: Int, width: Sizei, height: Sizei) void {
    return self.ptr_glViewport.?(x, y, width, height);
}
/// - **Available since:** OpenGL 1.0
pub fn newList(self: *const GL, list: UInt, mode: Enum) void {
    return self.ptr_glNewList.?(list, mode);
}
/// - **Available since:** OpenGL 1.0
pub fn endList(self: *const GL) void {
    return self.ptr_glEndList.?();
}
/// - **Available since:** OpenGL 1.0
pub fn callList(self: *const GL, list: UInt) void {
    return self.ptr_glCallList.?(list);
}
/// - **Available since:** OpenGL 1.0
pub fn callLists(self: *const GL, n: Sizei, @"type": Enum, lists: ?*const anyopaque) void {
    return self.ptr_glCallLists.?(n, @"type", lists);
}
/// - **Available since:** OpenGL 1.0
pub fn deleteLists(self: *const GL, list: UInt, range: Sizei) void {
    return self.ptr_glDeleteLists.?(list, range);
}
/// - **Available since:** OpenGL 1.0
pub fn genLists(self: *const GL, range: Sizei) UInt {
    return self.ptr_glGenLists.?(range);
}
/// - **Available since:** OpenGL 1.0
pub fn listBase(self: *const GL, base: UInt) void {
    return self.ptr_glListBase.?(base);
}
/// - **Available since:** OpenGL 1.0
pub fn begin(self: *const GL, mode: Enum) void {
    return self.ptr_glBegin.?(mode);
}
/// - **Available since:** OpenGL 1.0
pub fn bitmap(self: *const GL, width: Sizei, height: Sizei, xorig: Float, yorig: Float, xmove: Float, ymove: Float, _bitmap: [*]const UByte) void {
    return self.ptr_glBitmap.?(width, height, xorig, yorig, xmove, ymove, _bitmap);
}
/// - **Available since:** OpenGL 1.0
pub fn color3b(self: *const GL, red: Byte, green: Byte, blue: Byte) void {
    return self.ptr_glColor3b.?(red, green, blue);
}
/// - **Available since:** OpenGL 1.0
pub fn color3bv(self: *const GL, v: *const [3]Byte) void {
    return self.ptr_glColor3bv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn color3d(self: *const GL, red: Double, green: Double, blue: Double) void {
    return self.ptr_glColor3d.?(red, green, blue);
}
/// - **Available since:** OpenGL 1.0
pub fn color3dv(self: *const GL, v: *const [3]Double) void {
    return self.ptr_glColor3dv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn color3f(self: *const GL, red: Float, green: Float, blue: Float) void {
    return self.ptr_glColor3f.?(red, green, blue);
}
/// - **Available since:** OpenGL 1.0
pub fn color3fv(self: *const GL, v: *const [3]Float) void {
    return self.ptr_glColor3fv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn color3i(self: *const GL, red: Int, green: Int, blue: Int) void {
    return self.ptr_glColor3i.?(red, green, blue);
}
/// - **Available since:** OpenGL 1.0
pub fn color3iv(self: *const GL, v: *const [3]Int) void {
    return self.ptr_glColor3iv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn color3s(self: *const GL, red: Short, green: Short, blue: Short) void {
    return self.ptr_glColor3s.?(red, green, blue);
}
/// - **Available since:** OpenGL 1.0
pub fn color3sv(self: *const GL, v: *const [3]Short) void {
    return self.ptr_glColor3sv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn color3ub(self: *const GL, red: UByte, green: UByte, blue: UByte) void {
    return self.ptr_glColor3ub.?(red, green, blue);
}
/// - **Available since:** OpenGL 1.0
pub fn color3ubv(self: *const GL, v: *const [3]UByte) void {
    return self.ptr_glColor3ubv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn color3ui(self: *const GL, red: UInt, green: UInt, blue: UInt) void {
    return self.ptr_glColor3ui.?(red, green, blue);
}
/// - **Available since:** OpenGL 1.0
pub fn color3uiv(self: *const GL, v: *const [3]UInt) void {
    return self.ptr_glColor3uiv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn color3us(self: *const GL, red: UShort, green: UShort, blue: UShort) void {
    return self.ptr_glColor3us.?(red, green, blue);
}
/// - **Available since:** OpenGL 1.0
pub fn color3usv(self: *const GL, v: *const [3]UShort) void {
    return self.ptr_glColor3usv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn color4b(self: *const GL, red: Byte, green: Byte, blue: Byte, alpha: Byte) void {
    return self.ptr_glColor4b.?(red, green, blue, alpha);
}
/// - **Available since:** OpenGL 1.0
pub fn color4bv(self: *const GL, v: *const [4]Byte) void {
    return self.ptr_glColor4bv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn color4d(self: *const GL, red: Double, green: Double, blue: Double, alpha: Double) void {
    return self.ptr_glColor4d.?(red, green, blue, alpha);
}
/// - **Available since:** OpenGL 1.0
pub fn color4dv(self: *const GL, v: *const [4]Double) void {
    return self.ptr_glColor4dv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn color4f(self: *const GL, red: Float, green: Float, blue: Float, alpha: Float) void {
    return self.ptr_glColor4f.?(red, green, blue, alpha);
}
/// - **Available since:** OpenGL 1.0
pub fn color4fv(self: *const GL, v: *const [4]Float) void {
    return self.ptr_glColor4fv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn color4i(self: *const GL, red: Int, green: Int, blue: Int, alpha: Int) void {
    return self.ptr_glColor4i.?(red, green, blue, alpha);
}
/// - **Available since:** OpenGL 1.0
pub fn color4iv(self: *const GL, v: *const [4]Int) void {
    return self.ptr_glColor4iv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn color4s(self: *const GL, red: Short, green: Short, blue: Short, alpha: Short) void {
    return self.ptr_glColor4s.?(red, green, blue, alpha);
}
/// - **Available since:** OpenGL 1.0
pub fn color4sv(self: *const GL, v: *const [4]Short) void {
    return self.ptr_glColor4sv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn color4ub(self: *const GL, red: UByte, green: UByte, blue: UByte, alpha: UByte) void {
    return self.ptr_glColor4ub.?(red, green, blue, alpha);
}
/// - **Available since:** OpenGL 1.0
pub fn color4ubv(self: *const GL, v: *const [4]UByte) void {
    return self.ptr_glColor4ubv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn color4ui(self: *const GL, red: UInt, green: UInt, blue: UInt, alpha: UInt) void {
    return self.ptr_glColor4ui.?(red, green, blue, alpha);
}
/// - **Available since:** OpenGL 1.0
pub fn color4uiv(self: *const GL, v: *const [4]UInt) void {
    return self.ptr_glColor4uiv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn color4us(self: *const GL, red: UShort, green: UShort, blue: UShort, alpha: UShort) void {
    return self.ptr_glColor4us.?(red, green, blue, alpha);
}
/// - **Available since:** OpenGL 1.0
pub fn color4usv(self: *const GL, v: *const [4]UShort) void {
    return self.ptr_glColor4usv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn edgeFlag(self: *const GL, flag: bool) void {
    return self.ptr_glEdgeFlag.?(flag);
}
/// - **Available since:** OpenGL 1.0
pub fn edgeFlagv(self: *const GL, flag: [*]const bool) void {
    return self.ptr_glEdgeFlagv.?(flag);
}
/// - **Available since:** OpenGL 1.0
pub fn end(self: *const GL) void {
    return self.ptr_glEnd.?();
}
/// - **Available since:** OpenGL 1.0
pub fn indexd(self: *const GL, c: Double) void {
    return self.ptr_glIndexd.?(c);
}
/// - **Available since:** OpenGL 1.0
pub fn indexdv(self: *const GL, c: [*]const Double) void {
    return self.ptr_glIndexdv.?(c);
}
/// - **Available since:** OpenGL 1.0
pub fn index(self: *const GL, c: Float) void {
    return self.ptr_glIndex.?(c);
}
/// - **Available since:** OpenGL 1.0
pub fn indexv(self: *const GL, c: [*]const Float) void {
    return self.ptr_glIndexv.?(c);
}
/// - **Available since:** OpenGL 1.0
pub fn indexi(self: *const GL, c: Int) void {
    return self.ptr_glIndexi.?(c);
}
/// - **Available since:** OpenGL 1.0
pub fn indexiv(self: *const GL, c: [*]const Int) void {
    return self.ptr_glIndexiv.?(c);
}
/// - **Available since:** OpenGL 1.0
pub fn indexs(self: *const GL, c: Short) void {
    return self.ptr_glIndexs.?(c);
}
/// - **Available since:** OpenGL 1.0
pub fn indexsv(self: *const GL, c: [*]const Short) void {
    return self.ptr_glIndexsv.?(c);
}
/// - **Available since:** OpenGL 1.0
pub fn normal3b(self: *const GL, nx: Byte, ny: Byte, nz: Byte) void {
    return self.ptr_glNormal3b.?(nx, ny, nz);
}
/// - **Available since:** OpenGL 1.0
pub fn normal3bv(self: *const GL, v: [*]const [3]Byte) void {
    return self.ptr_glNormal3bv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn normal3d(self: *const GL, nx: Double, ny: Double, nz: Double) void {
    return self.ptr_glNormal3d.?(nx, ny, nz);
}
/// - **Available since:** OpenGL 1.0
pub fn normal3dv(self: *const GL, v: [*]const [3]Double) void {
    return self.ptr_glNormal3dv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn normal3f(self: *const GL, nx: Float, ny: Float, nz: Float) void {
    return self.ptr_glNormal3f.?(nx, ny, nz);
}
/// - **Available since:** OpenGL 1.0
pub fn normal3fv(self: *const GL, v: [*]const [3]Float) void {
    return self.ptr_glNormal3fv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn normal3i(self: *const GL, nx: Int, ny: Int, nz: Int) void {
    return self.ptr_glNormal3i.?(nx, ny, nz);
}
/// - **Available since:** OpenGL 1.0
pub fn normal3iv(self: *const GL, v: [*]const [3]Int) void {
    return self.ptr_glNormal3iv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn normal3s(self: *const GL, nx: Short, ny: Short, nz: Short) void {
    return self.ptr_glNormal3s.?(nx, ny, nz);
}
/// - **Available since:** OpenGL 1.0
pub fn normal3sv(self: *const GL, v: [*]const [3]Short) void {
    return self.ptr_glNormal3sv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos2d(self: *const GL, x: Double, y: Double) void {
    return self.ptr_glRasterPos2d.?(x, y);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos2dv(self: *const GL, v: [*]const [2]Double) void {
    return self.ptr_glRasterPos2dv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos2f(self: *const GL, x: Float, y: Float) void {
    return self.ptr_glRasterPos2f.?(x, y);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos2fv(self: *const GL, v: [*]const [2]Float) void {
    return self.ptr_glRasterPos2fv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos2i(self: *const GL, x: Int, y: Int) void {
    return self.ptr_glRasterPos2i.?(x, y);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos2iv(self: *const GL, v: [*]const [2]Int) void {
    return self.ptr_glRasterPos2iv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos2s(self: *const GL, x: Short, y: Short) void {
    return self.ptr_glRasterPos2s.?(x, y);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos2sv(self: *const GL, v: [*]const [2]Short) void {
    return self.ptr_glRasterPos2sv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos3d(self: *const GL, x: Double, y: Double, z: Double) void {
    return self.ptr_glRasterPos3d.?(x, y, z);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos3dv(self: *const GL, v: [*]const [3]Double) void {
    return self.ptr_glRasterPos3dv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos3f(self: *const GL, x: Float, y: Float, z: Float) void {
    return self.ptr_glRasterPos3f.?(x, y, z);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos3fv(self: *const GL, v: [*]const [3]Float) void {
    return self.ptr_glRasterPos3fv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos3i(self: *const GL, x: Int, y: Int, z: Int) void {
    return self.ptr_glRasterPos3i.?(x, y, z);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos3iv(self: *const GL, v: [*]const [3]Int) void {
    return self.ptr_glRasterPos3iv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos3s(self: *const GL, x: Short, y: Short, z: Short) void {
    return self.ptr_glRasterPos3s.?(x, y, z);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos3sv(self: *const GL, v: [*]const [3]Short) void {
    return self.ptr_glRasterPos3sv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos4d(self: *const GL, x: Double, y: Double, z: Double, w: Double) void {
    return self.ptr_glRasterPos4d.?(x, y, z, w);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos4dv(self: *const GL, v: [*]const [4]Double) void {
    return self.ptr_glRasterPos4dv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos4f(self: *const GL, x: Float, y: Float, z: Float, w: Float) void {
    return self.ptr_glRasterPos4f.?(x, y, z, w);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos4fv(self: *const GL, v: [*]const [4]Float) void {
    return self.ptr_glRasterPos4fv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos4i(self: *const GL, x: Int, y: Int, z: Int, w: Int) void {
    return self.ptr_glRasterPos4i.?(x, y, z, w);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos4iv(self: *const GL, v: [*]const [4]Int) void {
    return self.ptr_glRasterPos4iv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos4s(self: *const GL, x: Short, y: Short, z: Short, w: Short) void {
    return self.ptr_glRasterPos4s.?(x, y, z, w);
}
/// - **Available since:** OpenGL 1.0
pub fn rasterPos4sv(self: *const GL, v: [*]const [4]Short) void {
    return self.ptr_glRasterPos4sv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn rectd(self: *const GL, x1: Double, y1: Double, x2: Double, y2: Double) void {
    return self.ptr_glRectd.?(x1, y1, x2, y2);
}
/// - **Available since:** OpenGL 1.0
pub fn rectdv(self: *const GL, v1: [*]const [2]Double, v2: [*]const [2]Double) void {
    return self.ptr_glRectdv.?(v1, v2);
}
/// - **Available since:** OpenGL 1.0
pub fn rectf(self: *const GL, x1: Float, y1: Float, x2: Float, y2: Float) void {
    return self.ptr_glRectf.?(x1, y1, x2, y2);
}
/// - **Available since:** OpenGL 1.0
pub fn rectfv(self: *const GL, v1: [*]const [2]Float, v2: [*]const [2]Float) void {
    return self.ptr_glRectfv.?(v1, v2);
}
/// - **Available since:** OpenGL 1.0
pub fn recti(self: *const GL, x1: Int, y1: Int, x2: Int, y2: Int) void {
    return self.ptr_glRecti.?(x1, y1, x2, y2);
}
/// - **Available since:** OpenGL 1.0
pub fn rectiv(self: *const GL, v1: [*]const [2]Int, v2: [*]const [2]Int) void {
    return self.ptr_glRectiv.?(v1, v2);
}
/// - **Available since:** OpenGL 1.0
pub fn rects(self: *const GL, x1: Short, y1: Short, x2: Short, y2: Short) void {
    return self.ptr_glRects.?(x1, y1, x2, y2);
}
/// - **Available since:** OpenGL 1.0
pub fn rectsv(self: *const GL, v1: [*]const [2]Short, v2: [*]const [2]Short) void {
    return self.ptr_glRectsv.?(v1, v2);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord1d(self: *const GL, s: Double) void {
    return self.ptr_glTexCoord1d.?(s);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord1dv(self: *const GL, v: [*]const Double) void {
    return self.ptr_glTexCoord1dv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord1f(self: *const GL, s: Float) void {
    return self.ptr_glTexCoord1f.?(s);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord1fv(self: *const GL, v: [*]const Float) void {
    return self.ptr_glTexCoord1fv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord1i(self: *const GL, s: Int) void {
    return self.ptr_glTexCoord1i.?(s);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord1iv(self: *const GL, v: [*]const Int) void {
    return self.ptr_glTexCoord1iv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord1s(self: *const GL, s: Short) void {
    return self.ptr_glTexCoord1s.?(s);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord1sv(self: *const GL, v: [*]const Short) void {
    return self.ptr_glTexCoord1sv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord2d(self: *const GL, s: Double, t: Double) void {
    return self.ptr_glTexCoord2d.?(s, t);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord2dv(self: *const GL, v: [*]const [2]Double) void {
    return self.ptr_glTexCoord2dv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord2f(self: *const GL, s: Float, t: Float) void {
    return self.ptr_glTexCoord2f.?(s, t);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord2fv(self: *const GL, v: [*]const [2]Float) void {
    return self.ptr_glTexCoord2fv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord2i(self: *const GL, s: Int, t: Int) void {
    return self.ptr_glTexCoord2i.?(s, t);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord2iv(self: *const GL, v: [*]const [2]Int) void {
    return self.ptr_glTexCoord2iv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord2s(self: *const GL, s: Short, t: Short) void {
    return self.ptr_glTexCoord2s.?(s, t);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord2sv(self: *const GL, v: [*]const [2]Short) void {
    return self.ptr_glTexCoord2sv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord3d(self: *const GL, s: Double, t: Double, r: Double) void {
    return self.ptr_glTexCoord3d.?(s, t, r);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord3dv(self: *const GL, v: [*]const [3]Double) void {
    return self.ptr_glTexCoord3dv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord3f(self: *const GL, s: Float, t: Float, r: Float) void {
    return self.ptr_glTexCoord3f.?(s, t, r);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord3fv(self: *const GL, v: [*]const [3]Float) void {
    return self.ptr_glTexCoord3fv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord3i(self: *const GL, s: Int, t: Int, r: Int) void {
    return self.ptr_glTexCoord3i.?(s, t, r);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord3iv(self: *const GL, v: [*]const [3]Int) void {
    return self.ptr_glTexCoord3iv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord3s(self: *const GL, s: Short, t: Short, r: Short) void {
    return self.ptr_glTexCoord3s.?(s, t, r);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord3sv(self: *const GL, v: [*]const [3]Short) void {
    return self.ptr_glTexCoord3sv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord4d(self: *const GL, s: Double, t: Double, r: Double, q: Double) void {
    return self.ptr_glTexCoord4d.?(s, t, r, q);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord4dv(self: *const GL, v: [*]const [4]Double) void {
    return self.ptr_glTexCoord4dv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord4f(self: *const GL, s: Float, t: Float, r: Float, q: Float) void {
    return self.ptr_glTexCoord4f.?(s, t, r, q);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord4fv(self: *const GL, v: [*]const [4]Float) void {
    return self.ptr_glTexCoord4fv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord4i(self: *const GL, s: Int, t: Int, r: Int, q: Int) void {
    return self.ptr_glTexCoord4i.?(s, t, r, q);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord4iv(self: *const GL, v: [*]const [4]Int) void {
    return self.ptr_glTexCoord4iv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord4s(self: *const GL, s: Short, t: Short, r: Short, q: Short) void {
    return self.ptr_glTexCoord4s.?(s, t, r, q);
}
/// - **Available since:** OpenGL 1.0
pub fn texCoord4sv(self: *const GL, v: [*]const [4]Short) void {
    return self.ptr_glTexCoord4sv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex2d(self: *const GL, x: Double, y: Double) void {
    return self.ptr_glVertex2d.?(x, y);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex2dv(self: *const GL, v: [*]const [2]Double) void {
    return self.ptr_glVertex2dv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex2f(self: *const GL, x: Float, y: Float) void {
    return self.ptr_glVertex2f.?(x, y);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex2fv(self: *const GL, v: [*]const [2]Float) void {
    return self.ptr_glVertex2fv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex2i(self: *const GL, x: Int, y: Int) void {
    return self.ptr_glVertex2i.?(x, y);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex2iv(self: *const GL, v: [*]const [2]Int) void {
    return self.ptr_glVertex2iv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex2s(self: *const GL, x: Short, y: Short) void {
    return self.ptr_glVertex2s.?(x, y);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex2sv(self: *const GL, v: [*]const [2]Short) void {
    return self.ptr_glVertex2sv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex3d(self: *const GL, x: Double, y: Double, z: Double) void {
    return self.ptr_glVertex3d.?(x, y, z);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex3dv(self: *const GL, v: [*]const [3]Double) void {
    return self.ptr_glVertex3dv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex3f(self: *const GL, x: Float, y: Float, z: Float) void {
    return self.ptr_glVertex3f.?(x, y, z);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex3fv(self: *const GL, v: [*]const [3]Float) void {
    return self.ptr_glVertex3fv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex3i(self: *const GL, x: Int, y: Int, z: Int) void {
    return self.ptr_glVertex3i.?(x, y, z);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex3iv(self: *const GL, v: [*]const [3]Int) void {
    return self.ptr_glVertex3iv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex3s(self: *const GL, x: Short, y: Short, z: Short) void {
    return self.ptr_glVertex3s.?(x, y, z);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex3sv(self: *const GL, v: [*]const [3]Short) void {
    return self.ptr_glVertex3sv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex4d(self: *const GL, x: Double, y: Double, z: Double, w: Double) void {
    return self.ptr_glVertex4d.?(x, y, z, w);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex4dv(self: *const GL, v: [*]const [4]Double) void {
    return self.ptr_glVertex4dv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex4f(self: *const GL, x: Float, y: Float, z: Float, w: Float) void {
    return self.ptr_glVertex4f.?(x, y, z, w);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex4fv(self: *const GL, v: [*]const [4]Float) void {
    return self.ptr_glVertex4fv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex4i(self: *const GL, x: Int, y: Int, z: Int, w: Int) void {
    return self.ptr_glVertex4i.?(x, y, z, w);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex4iv(self: *const GL, v: [*]const [4]Int) void {
    return self.ptr_glVertex4iv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex4s(self: *const GL, x: Short, y: Short, z: Short, w: Short) void {
    return self.ptr_glVertex4s.?(x, y, z, w);
}
/// - **Available since:** OpenGL 1.0
pub fn vertex4sv(self: *const GL, v: [*]const [4]Short) void {
    return self.ptr_glVertex4sv.?(v);
}
/// - **Available since:** OpenGL 1.0
pub fn clipPlane(self: *const GL, plane: Enum, equation: [*]const Double) void {
    return self.ptr_glClipPlane.?(plane, equation);
}
/// - **Available since:** OpenGL 1.0
pub fn colorMaterial(self: *const GL, face: Enum, mode: Enum) void {
    return self.ptr_glColorMaterial.?(face, mode);
}
/// - **Available since:** OpenGL 1.0
pub fn fogf(self: *const GL, pname: Enum, param: Float) void {
    return self.ptr_glFogf.?(pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn fogfv(self: *const GL, pname: Enum, params: [*]const Float) void {
    return self.ptr_glFogfv.?(pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn fogi(self: *const GL, pname: Enum, param: Int) void {
    return self.ptr_glFogi.?(pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn fogiv(self: *const GL, pname: Enum, params: [*]const Int) void {
    return self.ptr_glFogiv.?(pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn lightf(self: *const GL, light: Enum, pname: Enum, param: Float) void {
    return self.ptr_glLightf.?(light, pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn lightfv(self: *const GL, light: Enum, pname: Enum, params: [*]const Float) void {
    return self.ptr_glLightfv.?(light, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn lighti(self: *const GL, light: Enum, pname: Enum, param: Int) void {
    return self.ptr_glLighti.?(light, pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn lightiv(self: *const GL, light: Enum, pname: Enum, params: [*]const Int) void {
    return self.ptr_glLightiv.?(light, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn lightModelf(self: *const GL, pname: Enum, param: Float) void {
    return self.ptr_glLightModelf.?(pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn lightModelfv(self: *const GL, pname: Enum, params: [*]const Float) void {
    return self.ptr_glLightModelfv.?(pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn lightModeli(self: *const GL, pname: Enum, param: Int) void {
    return self.ptr_glLightModeli.?(pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn lightModeliv(self: *const GL, pname: Enum, params: [*]const Int) void {
    return self.ptr_glLightModeliv.?(pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn lineStipple(self: *const GL, factor: Int, pattern: UShort) void {
    return self.ptr_glLineStipple.?(factor, pattern);
}
/// - **Available since:** OpenGL 1.0
pub fn materialf(self: *const GL, face: Enum, pname: Enum, param: Float) void {
    return self.ptr_glMaterialf.?(face, pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn materialfv(self: *const GL, face: Enum, pname: Enum, params: [*]const Float) void {
    return self.ptr_glMaterialfv.?(face, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn materiali(self: *const GL, face: Enum, pname: Enum, param: Int) void {
    return self.ptr_glMateriali.?(face, pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn materialiv(self: *const GL, face: Enum, pname: Enum, params: [*]const Int) void {
    return self.ptr_glMaterialiv.?(face, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn polygonStipple(self: *const GL, mask: [*]const UByte) void {
    return self.ptr_glPolygonStipple.?(mask);
}
/// - **Available since:** OpenGL 1.0
pub fn shadeModel(self: *const GL, mode: Enum) void {
    return self.ptr_glShadeModel.?(mode);
}
/// - **Available since:** OpenGL 1.0
pub fn texEnvf(self: *const GL, target: Enum, pname: Enum, param: Float) void {
    return self.ptr_glTexEnvf.?(target, pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn texEnvfv(self: *const GL, target: Enum, pname: Enum, params: [*]const Float) void {
    return self.ptr_glTexEnvfv.?(target, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn texEnvi(self: *const GL, target: Enum, pname: Enum, param: Int) void {
    return self.ptr_glTexEnvi.?(target, pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn texEnviv(self: *const GL, target: Enum, pname: Enum, params: [*]const Int) void {
    return self.ptr_glTexEnviv.?(target, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn texGend(self: *const GL, coord: Enum, pname: Enum, param: Double) void {
    return self.ptr_glTexGend.?(coord, pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn texGendv(self: *const GL, coord: Enum, pname: Enum, params: [*]const Double) void {
    return self.ptr_glTexGendv.?(coord, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn texGenf(self: *const GL, coord: Enum, pname: Enum, param: Float) void {
    return self.ptr_glTexGenf.?(coord, pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn texGenfv(self: *const GL, coord: Enum, pname: Enum, params: [*]const Float) void {
    return self.ptr_glTexGenfv.?(coord, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn texGeni(self: *const GL, coord: Enum, pname: Enum, param: Int) void {
    return self.ptr_glTexGeni.?(coord, pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn texGeniv(self: *const GL, coord: Enum, pname: Enum, params: [*]const Int) void {
    return self.ptr_glTexGeniv.?(coord, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn feedbackBuffer(self: *const GL, size: Sizei, @"type": Enum, buffer: [*]Float) void {
    return self.ptr_glFeedbackBuffer.?(size, @"type", buffer);
}
/// - **Available since:** OpenGL 1.0
pub fn selectBuffer(self: *const GL, size: Sizei, buffer: [*]UInt) void {
    return self.ptr_glSelectBuffer.?(size, buffer);
}
/// - **Available since:** OpenGL 1.0
pub fn renderMode(self: *const GL, mode: Enum) Int {
    return self.ptr_glRenderMode.?(mode);
}
/// - **Available since:** OpenGL 1.0
pub fn initNames(self: *const GL) void {
    return self.ptr_glInitNames.?();
}
/// - **Available since:** OpenGL 1.0
pub fn loadName(self: *const GL, name: UInt) void {
    return self.ptr_glLoadName.?(name);
}
/// - **Available since:** OpenGL 1.0
pub fn passThrough(self: *const GL, token: Float) void {
    return self.ptr_glPassThrough.?(token);
}
/// - **Available since:** OpenGL 1.0
pub fn popName(self: *const GL) void {
    return self.ptr_glPopName.?();
}
/// - **Available since:** OpenGL 1.0
pub fn pushName(self: *const GL, name: UInt) void {
    return self.ptr_glPushName.?(name);
}
/// - **Available since:** OpenGL 1.0
pub fn clearAccum(self: *const GL, red: Float, green: Float, blue: Float, alpha: Float) void {
    return self.ptr_glClearAccum.?(red, green, blue, alpha);
}
/// - **Available since:** OpenGL 1.0
pub fn clearIndex(self: *const GL, c: Float) void {
    return self.ptr_glClearIndex.?(c);
}
/// - **Available since:** OpenGL 1.0
pub fn indexMask(self: *const GL, mask: UInt) void {
    return self.ptr_glIndexMask.?(mask);
}
/// - **Available since:** OpenGL 1.0
pub fn accum(self: *const GL, op: Enum, value: Float) void {
    return self.ptr_glAccum.?(op, value);
}
/// - **Available since:** OpenGL 1.0
pub fn popAttrib(self: *const GL) void {
    return self.ptr_glPopAttrib.?();
}
/// - **Available since:** OpenGL 1.0
pub fn pushAttrib(self: *const GL, mask: Bitfield) void {
    return self.ptr_glPushAttrib.?(mask);
}
/// - **Available since:** OpenGL 1.0
pub fn map1d(self: *const GL, target: Enum, @"u1": Double, @"u2": Double, stride: Int, order: Int, points: [*]const Double) void {
    return self.ptr_glMap1d.?(target, @"u1", @"u2", stride, order, points);
}
/// - **Available since:** OpenGL 1.0
pub fn map1f(self: *const GL, target: Enum, @"u1": Float, @"u2": Float, stride: Int, order: Int, points: [*]const Float) void {
    return self.ptr_glMap1f.?(target, @"u1", @"u2", stride, order, points);
}
/// - **Available since:** OpenGL 1.0
pub fn map2d(self: *const GL, target: Enum, @"u1": Double, @"u2": Double, ustride: Int, uorder: Int, v1: Double, v2: Double, vstride: Int, vorder: Int, points: [*]const Double) void {
    return self.ptr_glMap2d.?(target, @"u1", @"u2", ustride, uorder, v1, v2, vstride, vorder, points);
}
/// - **Available since:** OpenGL 1.0
pub fn map2f(self: *const GL, target: Enum, @"u1": Float, @"u2": Float, ustride: Int, uorder: Int, v1: Float, v2: Float, vstride: Int, vorder: Int, points: [*]const Float) void {
    return self.ptr_glMap2f.?(target, @"u1", @"u2", ustride, uorder, v1, v2, vstride, vorder, points);
}
/// - **Available since:** OpenGL 1.0
pub fn mapGrid1d(self: *const GL, un: Int, @"u1": Double, @"u2": Double) void {
    return self.ptr_glMapGrid1d.?(un, @"u1", @"u2");
}
/// - **Available since:** OpenGL 1.0
pub fn mapGrid1f(self: *const GL, un: Int, @"u1": Float, @"u2": Float) void {
    return self.ptr_glMapGrid1f.?(un, @"u1", @"u2");
}
/// - **Available since:** OpenGL 1.0
pub fn mapGrid2d(self: *const GL, un: Int, @"u1": Double, @"u2": Double, vn: Int, v1: Double, v2: Double) void {
    return self.ptr_glMapGrid2d.?(un, @"u1", @"u2", vn, v1, v2);
}
/// - **Available since:** OpenGL 1.0
pub fn mapGrid2f(self: *const GL, un: Int, @"u1": Float, @"u2": Float, vn: Int, v1: Float, v2: Float) void {
    return self.ptr_glMapGrid2f.?(un, @"u1", @"u2", vn, v1, v2);
}
/// - **Available since:** OpenGL 1.0
pub fn evalCoord1d(self: *const GL, u: Double) void {
    return self.ptr_glEvalCoord1d.?(u);
}
/// - **Available since:** OpenGL 1.0
pub fn evalCoord1dv(self: *const GL, u: [*]const Double) void {
    return self.ptr_glEvalCoord1dv.?(u);
}
/// - **Available since:** OpenGL 1.0
pub fn evalCoord1f(self: *const GL, u: Float) void {
    return self.ptr_glEvalCoord1f.?(u);
}
/// - **Available since:** OpenGL 1.0
pub fn evalCoord1fv(self: *const GL, u: [*]const Float) void {
    return self.ptr_glEvalCoord1fv.?(u);
}
/// - **Available since:** OpenGL 1.0
pub fn evalCoord2d(self: *const GL, u: Double, v: Double) void {
    return self.ptr_glEvalCoord2d.?(u, v);
}
/// - **Available since:** OpenGL 1.0
pub fn evalCoord2dv(self: *const GL, u: [*]const Double) void {
    return self.ptr_glEvalCoord2dv.?(u);
}
/// - **Available since:** OpenGL 1.0
pub fn evalCoord2f(self: *const GL, u: Float, v: Float) void {
    return self.ptr_glEvalCoord2f.?(u, v);
}
/// - **Available since:** OpenGL 1.0
pub fn evalCoord2fv(self: *const GL, u: [*]const Float) void {
    return self.ptr_glEvalCoord2fv.?(u);
}
/// - **Available since:** OpenGL 1.0
pub fn evalMesh1(self: *const GL, mode: Enum, @"i1": Int, @"i2": Int) void {
    return self.ptr_glEvalMesh1.?(mode, @"i1", @"i2");
}
/// - **Available since:** OpenGL 1.0
pub fn evalPoint1(self: *const GL, i: Int) void {
    return self.ptr_glEvalPoint1.?(i);
}
/// - **Available since:** OpenGL 1.0
pub fn evalMesh2(self: *const GL, mode: Enum, @"i1": Int, @"i2": Int, j1: Int, j2: Int) void {
    return self.ptr_glEvalMesh2.?(mode, @"i1", @"i2", j1, j2);
}
/// - **Available since:** OpenGL 1.0
pub fn evalPoint2(self: *const GL, i: Int, j: Int) void {
    return self.ptr_glEvalPoint2.?(i, j);
}
/// - **Available since:** OpenGL 1.0
pub fn alphaFunc(self: *const GL, func: Enum, ref: Float) void {
    return self.ptr_glAlphaFunc.?(func, ref);
}
/// - **Available since:** OpenGL 1.0
pub fn pixelZoom(self: *const GL, xfactor: Float, yfactor: Float) void {
    return self.ptr_glPixelZoom.?(xfactor, yfactor);
}
/// - **Available since:** OpenGL 1.0
pub fn pixelTransferf(self: *const GL, pname: Enum, param: Float) void {
    return self.ptr_glPixelTransferf.?(pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn pixelTransferi(self: *const GL, pname: Enum, param: Int) void {
    return self.ptr_glPixelTransferi.?(pname, param);
}
/// - **Available since:** OpenGL 1.0
pub fn pixelMapfv(self: *const GL, map: Enum, mapsize: Sizei, values: [*]const Float) void {
    return self.ptr_glPixelMapfv.?(map, mapsize, values);
}
/// - **Available since:** OpenGL 1.0
pub fn pixelMapuiv(self: *const GL, map: Enum, mapsize: Sizei, values: [*]const UInt) void {
    return self.ptr_glPixelMapuiv.?(map, mapsize, values);
}
/// - **Available since:** OpenGL 1.0
pub fn pixelMapusv(self: *const GL, map: Enum, mapsize: Sizei, values: [*]const UShort) void {
    return self.ptr_glPixelMapusv.?(map, mapsize, values);
}
/// - **Available since:** OpenGL 1.0
pub fn copyPixels(self: *const GL, x: Int, y: Int, width: Sizei, height: Sizei, @"type": Enum) void {
    return self.ptr_glCopyPixels.?(x, y, width, height, @"type");
}
/// - **Available since:** OpenGL 1.0
pub fn drawPixels(self: *const GL, width: Sizei, height: Sizei, format: Enum, @"type": Enum, pixels: ?*const anyopaque) void {
    return self.ptr_glDrawPixels.?(width, height, format, @"type", pixels);
}
/// - **Available since:** OpenGL 1.0
pub fn getClipPlane(self: *const GL, plane: Enum, equation: [*]Double) void {
    return self.ptr_glGetClipPlane.?(plane, equation);
}
/// - **Available since:** OpenGL 1.0
pub fn getLightfv(self: *const GL, light: Enum, pname: Enum, params: [*]Float) void {
    return self.ptr_glGetLightfv.?(light, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn getLightiv(self: *const GL, light: Enum, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetLightiv.?(light, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn getMapdv(self: *const GL, target: Enum, query: Enum, v: [*]Double) void {
    return self.ptr_glGetMapdv.?(target, query, v);
}
/// - **Available since:** OpenGL 1.0
pub fn getMapfv(self: *const GL, target: Enum, query: Enum, v: [*]Float) void {
    return self.ptr_glGetMapfv.?(target, query, v);
}
/// - **Available since:** OpenGL 1.0
pub fn getMapiv(self: *const GL, target: Enum, query: Enum, v: [*]Int) void {
    return self.ptr_glGetMapiv.?(target, query, v);
}
/// - **Available since:** OpenGL 1.0
pub fn getMaterialfv(self: *const GL, face: Enum, pname: Enum, params: [*]Float) void {
    return self.ptr_glGetMaterialfv.?(face, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn getMaterialiv(self: *const GL, face: Enum, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetMaterialiv.?(face, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn getPixelMapfv(self: *const GL, map: Enum, values: [*]Float) void {
    return self.ptr_glGetPixelMapfv.?(map, values);
}
/// - **Available since:** OpenGL 1.0
pub fn getPpixelMapUiv(self: *const GL, map: Enum, values: [*]UInt) void {
    return self.ptr_glGetPpixelMapUiv.?(map, values);
}
/// - **Available since:** OpenGL 1.0
pub fn getPpixelMapUsv(self: *const GL, map: Enum, values: [*]UShort) void {
    return self.ptr_glGetPpixelMapUsv.?(map, values);
}
/// - **Available since:** OpenGL 1.0
pub fn getPolygonStipple(self: *const GL, mask: [*]UByte) void {
    return self.ptr_glGetPolygonStipple.?(mask);
}
/// - **Available since:** OpenGL 1.0
pub fn getTexEnvfv(self: *const GL, target: Enum, pname: Enum, params: [*]Float) void {
    return self.ptr_glGetTexEnvfv.?(target, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn getTexEnviv(self: *const GL, target: Enum, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetTexEnviv.?(target, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn getTexGendv(self: *const GL, coord: Enum, pname: Enum, params: [*]Double) void {
    return self.ptr_glGetTexGendv.?(coord, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn getTexGenfv(self: *const GL, coord: Enum, pname: Enum, params: [*]Float) void {
    return self.ptr_glGetTexGenfv.?(coord, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn getTexGeniv(self: *const GL, coord: Enum, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetTexGeniv.?(coord, pname, params);
}
/// - **Available since:** OpenGL 1.0
pub fn isList(self: *const GL, list: UInt) bool {
    return self.ptr_glIsList.?(list);
}
/// - **Available since:** OpenGL 1.0
pub fn frustrul(self: *const GL, left: Double, right: Double, bottom: Double, top: Double, zNear: Double, zFar: Double) void {
    return self.ptr_glFrustrul.?(left, right, bottom, top, zNear, zFar);
}
/// - **Available since:** OpenGL 1.0
pub fn loadIdentity(self: *const GL) void {
    return self.ptr_glLoadIdentity.?();
}
/// - **Available since:** OpenGL 1.0
pub fn loadMatrixf(self: *const GL, m: [*]const Float) void {
    return self.ptr_glLoadMatrixf.?(m);
}
/// - **Available since:** OpenGL 1.0
pub fn loadMatrixd(self: *const GL, m: [*]const Double) void {
    return self.ptr_glLoadMatrixd.?(m);
}
/// - **Available since:** OpenGL 1.0
pub fn matrixMode(self: *const GL, mode: Enum) void {
    return self.ptr_glMatrixMode.?(mode);
}
/// - **Available since:** OpenGL 1.0
pub fn multMatrixf(self: *const GL, m: [*]const Float) void {
    return self.ptr_glMultMatrixf.?(m);
}
/// - **Available since:** OpenGL 1.0
pub fn multMatrixd(self: *const GL, m: [*]const Double) void {
    return self.ptr_glMultMatrixd.?(m);
}
/// - **Available since:** OpenGL 1.0
pub fn ortho(self: *const GL, left: Double, right: Double, bottom: Double, top: Double, zNear: Double, zFar: Double) void {
    return self.ptr_glOrtho.?(left, right, bottom, top, zNear, zFar);
}
/// - **Available since:** OpenGL 1.0
pub fn popMatrix(self: *const GL) void {
    return self.ptr_glPopMatrix.?();
}
/// - **Available since:** OpenGL 1.0
pub fn pushMatrix(self: *const GL) void {
    return self.ptr_glPushMatrix.?();
}
/// - **Available since:** OpenGL 1.0
pub fn rotated(self: *const GL, ane: Double, x: Double, y: Double, z: Double) void {
    return self.ptr_glRotated.?(ane, x, y, z);
}
/// - **Available since:** OpenGL 1.0
pub fn rotatef(self: *const GL, ane: Float, x: Float, y: Float, z: Float) void {
    return self.ptr_glRotatef.?(ane, x, y, z);
}
/// - **Available since:** OpenGL 1.0
pub fn scaled(self: *const GL, x: Double, y: Double, z: Double) void {
    return self.ptr_glScaled.?(x, y, z);
}
/// - **Available since:** OpenGL 1.0
pub fn scalef(self: *const GL, x: Float, y: Float, z: Float) void {
    return self.ptr_glScalef.?(x, y, z);
}
/// - **Available since:** OpenGL 1.0
pub fn translated(self: *const GL, x: Double, y: Double, z: Double) void {
    return self.ptr_glTranslated.?(x, y, z);
}
/// - **Available since:** OpenGL 1.0
pub fn translatef(self: *const GL, x: Float, y: Float, z: Float) void {
    return self.ptr_glTranslatef.?(x, y, z);
}
//#endregion
//#region OpenGL 1.1
/// - **Available since:** OpenGL 1.1
pub fn drawArrays(self: *const GL, mode: Enum, first: Int, count: Sizei) void {
    return self.ptr_glDrawArrays.?(mode, first, count);
}
/// - **Available since:** OpenGL 1.1
pub fn drawElements(self: *const GL, mode: Enum, count: Sizei, @"type": Enum, indices: usize) void {
    return self.ptr_glDrawElements.?(mode, count, @"type", indices);
}
/// - **Available since:** OpenGL 1.1
pub fn getPointerv(self: *const GL, pname: Enum, params: [*]?*anyopaque) void {
    return self.ptr_glGetPointerv.?(pname, params);
}
/// - **Available since:** OpenGL 1.1
pub fn polygonOffset(self: *const GL, factor: Float, units: Float) void {
    return self.ptr_glPolygonOffset.?(factor, units);
}
/// - **Available since:** OpenGL 1.1
pub fn copyTexImage1D(self: *const GL, target: Enum, level: Int, internalFormat: Enum, x: Int, y: Int, width: Sizei, border: Int) void {
    return self.ptr_glCopyTexImage1D.?(target, level, internalFormat, x, y, width, border);
}
/// - **Available since:** OpenGL 1.1
pub fn copyTexImage2D(self: *const GL, target: Enum, level: Int, internalformat: Enum, x: Int, y: Int, widht: Sizei, height: Sizei, border: Int) void {
    return self.ptr_glCopyTexImage2D.?(target, level, internalformat, x, y, widht, height, border);
}
/// - **Available since:** OpenGL 1.1
pub fn copyTexSubImage1D(self: *const GL, target: Enum, level: Int, internalFormat: Enum, xoffset: Int, x: Int, y: Int, width: Sizei) void {
    return self.ptr_glCopyTexSubImage1D.?(target, level, internalFormat, xoffset, x, y, width);
}
/// - **Available since:** OpenGL 1.1
pub fn copyTexSubImage2D(self: *const GL, target: Enum, level: Int, internalformat: Enum, xoffset: Int, yoffset: Int, x: Int, y: Int, width: Sizei, height: Sizei) void {
    return self.ptr_glCopyTexSubImage2D.?(target, level, internalformat, xoffset, yoffset, x, y, width, height);
}
/// - **Available since:** OpenGL 1.1
pub fn textSubImage1D(self: *const GL, target: Enum, level: Int, xoffset: Int, width: Sizei, format: Enum, @"type": Enum, pixels: ?*const anyopaque) void {
    return self.ptr_glTextSubImage1D.?(target, level, xoffset, width, format, @"type", pixels);
}
/// - **Available since:** OpenGL 1.1
pub fn textSubImage2D(self: *const GL, target: Enum, level: Int, xoffset: Int, yoffset: Int, width: Sizei, height: Sizei, format: Enum, @"type": Enum, pixels: ?*const anyopaque) void {
    return self.ptr_glTextSubImage2D.?(target, level, xoffset, yoffset, width, height, format, @"type", pixels);
}
/// - **Available since:** OpenGL 1.1
pub fn bindTexture(self: *const GL, target: Enum, texture: UInt) void {
    return self.ptr_glBindTexture.?(target, texture);
}
/// - **Available since:** OpenGL 1.1
pub fn deleteTextures(self: *const GL, n: Sizei, textures: [*]const UInt) void {
    return self.ptr_glDeleteTextures.?(n, textures);
}
/// - **Available since:** OpenGL 1.1
pub fn genTextures(self: *const GL, n: Sizei, textures: [*]UInt) void {
    return self.ptr_glGenTextures.?(n, textures);
}
/// - **Available since:** OpenGL 1.1
pub fn isTexture(self: *const GL, texture: UInt) bool {
    return self.ptr_glIsTexture.?(texture);
}
/// - **Available since:** OpenGL 1.1
pub fn arrayElement(self: *const GL, i: Int) void {
    return self.ptr_glArrayElement.?(i);
}
/// - **Available since:** OpenGL 1.1
pub fn colorPointer(self: *const GL, size: Int, @"type": Enum, stride: Sizei, pointer: ?*const anyopaque) void {
    return self.ptr_glColorPointer.?(size, @"type", stride, pointer);
}
/// - **Available since:** OpenGL 1.1
pub fn disableClientState(self: *const GL, array: Enum) void {
    return self.ptr_glDisableClientState.?(array);
}
/// - **Available since:** OpenGL 1.1
pub fn edgeFlagPointer(self: *const GL, stride: Sizei, pointer: ?*const anyopaque) void {
    return self.ptr_glEdgeFlagPointer.?(stride, pointer);
}
/// - **Available since:** OpenGL 1.1
pub fn enableClientState(self: *const GL, array: Enum) void {
    return self.ptr_glEnableClientState.?(array);
}
/// - **Available since:** OpenGL 1.1
pub fn indexPointer(self: *const GL, @"type": Enum, stride: Sizei, pointer: ?*const anyopaque) void {
    return self.ptr_glIndexPointer.?(@"type", stride, pointer);
}
/// - **Available since:** OpenGL 1.1
pub fn interleavedArrays(self: *const GL, format: Enum, stride: Sizei, pointer: ?*const anyopaque) void {
    return self.ptr_glInterleavedArrays.?(format, stride, pointer);
}
/// - **Available since:** OpenGL 1.1
pub fn normalPointer(self: *const GL, @"type": Enum, stride: Sizei, pointer: ?*const anyopaque) void {
    return self.ptr_glNormalPointer.?(@"type", stride, pointer);
}
/// - **Available since:** OpenGL 1.1
pub fn texCoordPointer(self: *const GL, size: Int, @"type": Enum, stride: Sizei, pointer: ?*const anyopaque) void {
    return self.ptr_glTexCoordPointer.?(size, @"type", stride, pointer);
}
/// - **Available since:** OpenGL 1.1
pub fn vertexPointer(self: *const GL, size: Int, @"type": Enum, stride: Sizei, pointer: ?*const anyopaque) void {
    return self.ptr_glVertexPointer.?(size, @"type", stride, pointer);
}
/// - **Available since:** OpenGL 1.1
pub fn areTexturesResident(self: *const GL, n: Sizei, textures: [*]const UInt, residences: [*]bool) bool {
    return self.ptr_glAreTexturesResident.?(n, textures, residences);
}
/// - **Available since:** OpenGL 1.1
pub fn prioritizeTextures(self: *const GL, n: Sizei, textures: [*]const UInt, priorities: [*]const Float) void {
    return self.ptr_glPrioritizeTextures.?(n, textures, priorities);
}
/// - **Available since:** OpenGL 1.1
pub fn indexub(self: *const GL, c: UByte) void {
    return self.ptr_glIndexub.?(c);
}
/// - **Available since:** OpenGL 1.1
pub fn indexubv(self: *const GL, c: [*]const UByte) void {
    return self.ptr_glIndexubv.?(c);
}
/// - **Available since:** OpenGL 1.1
pub fn popClientAttrib(self: *const GL) void {
    return self.ptr_glPopClientAttrib.?();
}
/// - **Available since:** OpenGL 1.1
pub fn pushClientAttrib(self: *const GL, mask: Bitfield) void {
    return self.ptr_glPushClientAttrib.?(mask);
}
//#endregion
//#region OpenGL 1.2
/// - **Available since:** OpenGL 1.2
pub fn drawRangeElements(self: *const GL, mode: Enum, start: UInt, _end: UInt, count: Sizei, @"type": Enum, indices: usize) void {
    return self.ptr_glDrawRangeElements.?(mode, start, _end, count, @"type", indices);
}
/// - **Available since:** OpenGL 1.2
pub fn texImage3D(self: *const GL, target: Enum, level: Int, internalFormat: Int, width: Sizei, height: Sizei, depth: Sizei, border: Int, format: Enum, @"type": Enum, pixels: ?*const anyopaque) void {
    return self.ptr_glTexImage3D.?(target, level, internalFormat, width, height, depth, border, format, @"type", pixels);
}
/// - **Available since:** OpenGL 1.2
pub fn texSubImage3D(self: *const GL, target: Enum, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, width: Sizei, height: Sizei, depth: Sizei, format: Enum, @"type": Enum, pixels: ?*const anyopaque) void {
    return self.ptr_glTexSubImage3D.?(target, level, xoffset, yoffset, zoffset, width, height, depth, format, @"type", pixels);
}
/// - **Available since:** OpenGL 1.2
pub fn copyTexSubImage3D(self: *const GL, target: Enum, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, x: Int, y: Int, width: Sizei, height: Sizei) void {
    return self.ptr_glCopyTexSubImage3D.?(target, level, xoffset, yoffset, zoffset, x, y, width, height);
}
//#endregion
//#region OpenGL 1.3
pub fn activeTexture(self: *const GL, texture: Enum) void {
    return self.ptr_glActiveTexture.?(texture);
}
/// - **Available since:** OpenGL 1.3
pub fn sampleCoverage(self: *const GL, value: Float, invert: bool) void {
    return self.ptr_glSampleCoverage.?(value, invert);
}
/// - **Available since:** OpenGL 1.3
pub fn compressedTexImage3D(self: *const GL, texture: Enum, level: Int, internalFormat: Enum, width: Sizei, height: Sizei, depth: Sizei, border: Int, imageSize: Sizei, data: ?*const anyopaque) void {
    return self.ptr_glCompressedTexImage3D.?(texture, level, internalFormat, width, height, depth, border, imageSize, data);
}
/// - **Available since:** OpenGL 1.3
pub fn compressedTexImage2D(self: *const GL, texture: Enum, level: Int, internalFormat: Enum, width: Sizei, height: Sizei, border: Int, imageSize: Sizei, data: ?*const anyopaque) void {
    return self.ptr_glCompressedTexImage2D.?(texture, level, internalFormat, width, height, border, imageSize, data);
}
/// - **Available since:** OpenGL 1.3
pub fn compressedTexImage1D(self: *const GL, texture: Enum, level: Int, internalFormat: Enum, width: Sizei, border: Int, imageSize: Sizei, data: ?*const anyopaque) void {
    return self.ptr_glCompressedTexImage1D.?(texture, level, internalFormat, width, border, imageSize, data);
}
/// - **Available since:** OpenGL 1.3
pub fn compressedTexSubImage3D(self: *const GL, texture: Enum, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, width: Sizei, height: Sizei, depth: Sizei, format: Enum, imageSize: Sizei, data: ?*const anyopaque) void {
    return self.ptr_glCompressedTexSubImage3D.?(texture, level, xoffset, yoffset, zoffset, width, height, depth, format, imageSize, data);
}
/// - **Available since:** OpenGL 1.3
pub fn compressedTexSubImage2D(self: *const GL, texture: Enum, level: Int, xoffset: Int, yoffset: Int, width: Sizei, height: Sizei, format: Enum, imageSize: Sizei, data: ?*const anyopaque) void {
    return self.ptr_glCompressedTexSubImage2D.?(texture, level, xoffset, yoffset, width, height, format, imageSize, data);
}
/// - **Available since:** OpenGL 1.3
pub fn compressedTexSubImage1D(self: *const GL, texture: Enum, level: Int, xoffset: Int, width: Sizei, format: Enum, imageSize: Sizei, data: ?*const anyopaque) void {
    return self.ptr_glCompressedTexSubImage1D.?(texture, level, xoffset, width, format, imageSize, data);
}
/// - **Available since:** OpenGL 1.3
pub fn getCompressedTexImage(self: *const GL, texture: Enum, level: Int, img: ?*anyopaque) void {
    return self.ptr_glGetCompressedTexImage.?(texture, level, img);
}
/// - **Available since:** OpenGL 1.3
pub fn clientActiveTexture(self: *const GL, texture: Enum) void {
    return self.ptr_glClientActiveTexture.?(texture);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord1d(self: *const GL, texture: Enum, s: Double) void {
    return self.ptr_glMultiTexCoord1d.?(texture, s);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord1dv(self: *const GL, texture: Enum, v: *const Double) void {
    return self.ptr_glMultiTexCoord1dv.?(texture, v);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord1f(self: *const GL, texture: Enum, s: Float) void {
    return self.ptr_glMultiTexCoord1f.?(texture, s);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord1fv(self: *const GL, texture: Enum, v: *const Float) void {
    return self.ptr_glMultiTexCoord1fv.?(texture, v);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord1i(self: *const GL, texture: Enum, s: Int) void {
    return self.ptr_glMultiTexCoord1i.?(texture, s);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord1iv(self: *const GL, texture: Enum, v: *const Int) void {
    return self.ptr_glMultiTexCoord1iv.?(texture, v);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord1s(self: *const GL, texture: Enum, s: Short) void {
    return self.ptr_glMultiTexCoord1s.?(texture, s);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord1sv(self: *const GL, texture: Enum, v: *const Short) void {
    return self.ptr_glMultiTexCoord1sv.?(texture, v);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord2d(self: *const GL, texture: Enum, s: Double, t: Double) void {
    return self.ptr_glMultiTexCoord2d.?(texture, s, t);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord2dv(self: *const GL, texture: Enum, v: *const [2]Double) void {
    return self.ptr_glMultiTexCoord2dv.?(texture, v);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord2f(self: *const GL, texture: Enum, s: Float, t: Float) void {
    return self.ptr_glMultiTexCoord2f.?(texture, s, t);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord2fv(self: *const GL, texture: Enum, v: *const [2]Float) void {
    return self.ptr_glMultiTexCoord2fv.?(texture, v);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord2i(self: *const GL, texture: Enum, s: Int, t: Int) void {
    return self.ptr_glMultiTexCoord2i.?(texture, s, t);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord2iv(self: *const GL, texture: Enum, v: *const [2]Int) void {
    return self.ptr_glMultiTexCoord2iv.?(texture, v);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord2s(self: *const GL, texture: Enum, s: Short, t: Short) void {
    return self.ptr_glMultiTexCoord2s.?(texture, s, t);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord2sv(self: *const GL, texture: Enum, v: *const [2]Short) void {
    return self.ptr_glMultiTexCoord2sv.?(texture, v);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord3d(self: *const GL, texture: Enum, s: Double, t: Double, r: Double) void {
    return self.ptr_glMultiTexCoord3d.?(texture, s, t, r);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord3dv(self: *const GL, texture: Enum, v: *const [3]Double) void {
    return self.ptr_glMultiTexCoord3dv.?(texture, v);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord3f(self: *const GL, texture: Enum, s: Float, t: Float, r: Float) void {
    return self.ptr_glMultiTexCoord3f.?(texture, s, t, r);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord3fv(self: *const GL, texture: Enum, v: *const [3]Float) void {
    return self.ptr_glMultiTexCoord3fv.?(texture, v);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord3i(self: *const GL, texture: Enum, s: Int, t: Int, r: Int) void {
    return self.ptr_glMultiTexCoord3i.?(texture, s, t, r);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord3iv(self: *const GL, texture: Enum, v: *const [3]Int) void {
    return self.ptr_glMultiTexCoord3iv.?(texture, v);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord3s(self: *const GL, texture: Enum, s: Short, t: Short, r: Short) void {
    return self.ptr_glMultiTexCoord3s.?(texture, s, t, r);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord3sv(self: *const GL, texture: Enum, v: *const [3]Short) void {
    return self.ptr_glMultiTexCoord3sv.?(texture, v);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord4d(self: *const GL, texture: Enum, s: Double, t: Double, r: Double, q: Double) void {
    return self.ptr_glMultiTexCoord4d.?(texture, s, t, r, q);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord4dv(self: *const GL, texture: Enum, v: *const [4]Double) void {
    return self.ptr_glMultiTexCoord4dv.?(texture, v);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord4f(self: *const GL, texture: Enum, s: Float, t: Float, r: Float, q: Float) void {
    return self.ptr_glMultiTexCoord4f.?(texture, s, t, r, q);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord4fv(self: *const GL, texture: Enum, v: *const [4]Float) void {
    return self.ptr_glMultiTexCoord4fv.?(texture, v);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord4i(self: *const GL, texture: Enum, s: Int, t: Int, r: Int, q: Int) void {
    return self.ptr_glMultiTexCoord4i.?(texture, s, t, r, q);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord4iv(self: *const GL, texture: Enum, v: *const [4]Int) void {
    return self.ptr_glMultiTexCoord4iv.?(texture, v);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord4s(self: *const GL, texture: Enum, s: Short, t: Short, r: Short, q: Short) void {
    return self.ptr_glMultiTexCoord4s.?(texture, s, t, r, q);
}
/// - **Available since:** OpenGL 1.3
pub fn multiTexCoord4sv(self: *const GL, texture: Enum, v: *const [4]Short) void {
    return self.ptr_glMultiTexCoord4sv.?(texture, v);
}
/// - **Available since:** OpenGL 1.3
pub fn loadTransposeMatrixf(self: *const GL, m: [*]const Float) void {
    return self.ptr_glLoadTransposeMatrixf.?(m);
}
/// - **Available since:** OpenGL 1.3
pub fn loadTransposeMatrixd(self: *const GL, m: [*]const Double) void {
    return self.ptr_glLoadTransposeMatrixd.?(m);
}
/// - **Available since:** OpenGL 1.3
pub fn multTransposeMatrixf(self: *const GL, m: [*]const Float) void {
    return self.ptr_glMultTransposeMatrixf.?(m);
}
/// - **Available since:** OpenGL 1.3
pub fn multTransposeMatrixd(self: *const GL, m: [*]const Double) void {
    return self.ptr_glMultTransposeMatrixd.?(m);
}
//#endregion
//#region OpenGL 1.4
/// - **Available since:** OpenGL 1.4
pub fn blendFuncSeparate(self: *const GL, sfactorRGB: Enum, dfactorRGB: Enum, sfactorAlpha: Enum, dfactorAlpha: Enum) void {
    return self.ptr_glBlendFuncSeparate.?(sfactorRGB, dfactorRGB, sfactorAlpha, dfactorAlpha);
}
/// - **Available since:** OpenGL 1.4
pub fn multiDrawArrays(self: *const GL, mode: Enum, first: [*]const Int, count: [*]const Sizei, drawcount: Sizei) void {
    return self.ptr_glMultiDrawArrays.?(mode, first, count, drawcount);
}
/// - **Available since:** OpenGL 1.4
pub fn multiDrawElements(self: *const GL, mode: Enum, count: [*]const Sizei, @"type": Enum, indices: [*]const usize, drawcount: Sizei) void {
    return self.ptr_glMultiDrawElements.?(mode, count, @"type", indices, drawcount);
}
/// - **Available since:** OpenGL 1.4
pub fn pointParameterf(self: *const GL, pname: Enum, param: Float) void {
    return self.ptr_glPointParameterf.?(pname, param);
}
/// - **Available since:** OpenGL 1.4
pub fn pointParameterfv(self: *const GL, pname: Enum, params: [*]const Float) void {
    return self.ptr_glPointParameterfv.?(pname, params);
}
/// - **Available since:** OpenGL 1.4
pub fn pointParameteri(self: *const GL, pname: Enum, param: Int) void {
    return self.ptr_glPointParameteri.?(pname, param);
}
/// - **Available since:** OpenGL 1.4
pub fn pointParameteriv(self: *const GL, pname: Enum, params: [*]const Int) void {
    return self.ptr_glPointParameteriv.?(pname, params);
}
/// - **Available since:** OpenGL 1.4
pub fn fogCoordf(self: *const GL, coord: Float) void {
    return self.ptr_glFogCoordf.?(coord);
}
/// - **Available since:** OpenGL 1.4
pub fn fogCoordfv(self: *const GL, coord: [*]const Float) void {
    return self.ptr_glFogCoordfv.?(coord);
}
/// - **Available since:** OpenGL 1.4
pub fn fogCoordd(self: *const GL, coord: Double) void {
    return self.ptr_glFogCoordd.?(coord);
}
/// - **Available since:** OpenGL 1.4
pub fn fogCoorddv(self: *const GL, coord: [*]const Double) void {
    return self.ptr_glFogCoorddv.?(coord);
}
/// - **Available since:** OpenGL 1.4
pub fn fogCoordPointer(self: *const GL, @"type": Enum, stride: Sizei, pointer: ?*const anyopaque) void {
    return self.ptr_glFogCoordPointer.?(@"type", stride, pointer);
}
/// - **Available since:** OpenGL 1.4
pub fn secondaryColor3b(self: *const GL, red: Byte, green: Byte, blue: Byte) void {
    return self.ptr_glSecondaryColor3b.?(red, green, blue);
}
/// - **Available since:** OpenGL 1.4
pub fn secondaryColor3bv(self: *const GL, v: *const [3]Byte) void {
    return self.ptr_glSecondaryColor3bv.?(v);
}
/// - **Available since:** OpenGL 1.4
pub fn secondaryColor3d(self: *const GL, red: Double, green: Double, blue: Double) void {
    return self.ptr_glSecondaryColor3d.?(red, green, blue);
}
/// - **Available since:** OpenGL 1.4
pub fn secondaryColor3dv(self: *const GL, v: *const [3]Double) void {
    return self.ptr_glSecondaryColor3dv.?(v);
}
/// - **Available since:** OpenGL 1.4
pub fn secondaryColor3f(self: *const GL, red: Float, green: Float, blue: Float) void {
    return self.ptr_glSecondaryColor3f.?(red, green, blue);
}
/// - **Available since:** OpenGL 1.4
pub fn secondaryColor3fv(self: *const GL, v: *const [3]Float) void {
    return self.ptr_glSecondaryColor3fv.?(v);
}
/// - **Available since:** OpenGL 1.4
pub fn secondaryColor3i(self: *const GL, red: Int, green: Int, blue: Int) void {
    return self.ptr_glSecondaryColor3i.?(red, green, blue);
}
/// - **Available since:** OpenGL 1.4
pub fn secondaryColor3iv(self: *const GL, v: *const [3]Int) void {
    return self.ptr_glSecondaryColor3iv.?(v);
}
/// - **Available since:** OpenGL 1.4
pub fn secondaryColor3s(self: *const GL, red: Short, green: Short, blue: Short) void {
    return self.ptr_glSecondaryColor3s.?(red, green, blue);
}
/// - **Available since:** OpenGL 1.4
pub fn secondaryColor3sv(self: *const GL, v: *const [3]Short) void {
    return self.ptr_glSecondaryColor3sv.?(v);
}
/// - **Available since:** OpenGL 1.4
pub fn secondaryColor3ub(self: *const GL, red: UByte, green: UByte, blue: UByte) void {
    return self.ptr_glSecondaryColor3ub.?(red, green, blue);
}
/// - **Available since:** OpenGL 1.4
pub fn secondaryColor3ubv(self: *const GL, v: *const [3]UByte) void {
    return self.ptr_glSecondaryColor3ubv.?(v);
}
/// - **Available since:** OpenGL 1.4
pub fn secondaryColor3ui(self: *const GL, red: UInt, green: UInt, blue: UInt) void {
    return self.ptr_glSecondaryColor3ui.?(red, green, blue);
}
/// - **Available since:** OpenGL 1.4
pub fn secondaryColor3uiv(self: *const GL, v: *const [3]UInt) void {
    return self.ptr_glSecondaryColor3uiv.?(v);
}
/// - **Available since:** OpenGL 1.4
pub fn secondaryColor3us(self: *const GL, red: UShort, green: UShort, blue: UShort) void {
    return self.ptr_glSecondaryColor3us.?(red, green, blue);
}
/// - **Available since:** OpenGL 1.4
pub fn secondaryColor3usv(self: *const GL, v: *const [3]UShort) void {
    return self.ptr_glSecondaryColor3usv.?(v);
}
/// - **Available since:** OpenGL 1.4
pub fn secondaryColorPointer(self: *const GL, size: Int, @"type": Enum, stride: Sizei, pointer: ?*const anyopaque) void {
    return self.ptr_glSecondaryColorPointer.?(size, @"type", stride, pointer);
}
/// - **Available since:** OpenGL 1.4
pub fn windowPos2d(self: *const GL, x: Double, y: Double) void {
    return self.ptr_glWindowPos2d.?(x, y);
}
/// - **Available since:** OpenGL 1.4
pub fn windowPos2dv(self: *const GL, v: *const [2]Double) void {
    return self.ptr_glWindowPos2dv.?(v);
}
/// - **Available since:** OpenGL 1.4
pub fn windowPos2f(self: *const GL, x: Float, y: Float) void {
    return self.ptr_glWindowPos2f.?(x, y);
}
/// - **Available since:** OpenGL 1.4
pub fn windowPos2fv(self: *const GL, v: *const [2]Float) void {
    return self.ptr_glWindowPos2fv.?(v);
}
/// - **Available since:** OpenGL 1.4
pub fn windowPos2i(self: *const GL, x: Int, y: Int) void {
    return self.ptr_glWindowPos2i.?(x, y);
}
/// - **Available since:** OpenGL 1.4
pub fn windowPos2iv(self: *const GL, v: *const [2]Int) void {
    return self.ptr_glWindowPos2iv.?(v);
}
/// - **Available since:** OpenGL 1.4
pub fn windowPos2s(self: *const GL, x: Short, y: Short) void {
    return self.ptr_glWindowPos2s.?(x, y);
}
/// - **Available since:** OpenGL 1.4
pub fn windowPos2sv(self: *const GL, v: *const [2]Short) void {
    return self.ptr_glWindowPos2sv.?(v);
}
/// - **Available since:** OpenGL 1.4
pub fn windowPos3d(self: *const GL, x: Double, y: Double, z: Double) void {
    return self.ptr_glWindowPos3d.?(x, y, z);
}
/// - **Available since:** OpenGL 1.4
pub fn windowPos3dv(self: *const GL, v: *const [3]Double) void {
    return self.ptr_glWindowPos3dv.?(v);
}
/// - **Available since:** OpenGL 1.4
pub fn windowPos3f(self: *const GL, x: Float, y: Float, z: Float) void {
    return self.ptr_glWindowPos3f.?(x, y, z);
}
/// - **Available since:** OpenGL 1.4
pub fn windowPos3fv(self: *const GL, v: *const [3]Float) void {
    return self.ptr_glWindowPos3fv.?(v);
}
/// - **Available since:** OpenGL 1.4
pub fn windowPos3i(self: *const GL, x: Int, y: Int, z: Int) void {
    return self.ptr_glWindowPos3i.?(x, y, z);
}
/// - **Available since:** OpenGL 1.4
pub fn windowPos3iv(self: *const GL, v: *const [3]Int) void {
    return self.ptr_glWindowPos3iv.?(v);
}
/// - **Available since:** OpenGL 1.4
pub fn windowPos3s(self: *const GL, x: Short, y: Short, z: Short) void {
    return self.ptr_glWindowPos3s.?(x, y, z);
}
/// - **Available since:** OpenGL 1.4
pub fn windowPos3sv(self: *const GL, v: *const [3]Short) void {
    return self.ptr_glWindowPos3sv.?(v);
}
/// - **Available since:** OpenGL 1.4
pub fn blendColor(self: *const GL, red: Float, green: Float, blue: Float, alpha: Float) void {
    return self.ptr_glBlendColor.?(red, green, blue, alpha);
}
/// - **Available since:** OpenGL 1.4
pub fn blendEquation(self: *const GL, mode: Enum) void {
    return self.ptr_glBlendEquation.?(mode);
}
//#endregion
//#region OpenGL 1.5
/// - **Available since:** OpenGL 1.5
pub fn genQueries(self: *const GL, n: Sizei, ids: [*]UInt) void {
    return self.ptr_glGenQueries.?(n, ids);
}
/// - **Available since:** OpenGL 1.5
pub fn deleteQueries(self: *const GL, n: Sizei, ids: [*]const UInt) void {
    return self.ptr_glDeleteQueries.?(n, ids);
}
/// - **Available since:** OpenGL 1.5
pub fn isQuery(self: *const GL, id: UInt) bool {
    return self.ptr_glIsQuery.?(id);
}
/// - **Available since:** OpenGL 1.5
pub fn beginQuery(self: *const GL, target: Enum, id: UInt) void {
    return self.ptr_glBeginQuery.?(target, id);
}
/// - **Available since:** OpenGL 1.5
pub fn endQuery(self: *const GL, target: Enum) void {
    return self.ptr_glEndQuery.?(target);
}
/// - **Available since:** OpenGL 1.5
pub fn getQueryiv(self: *const GL, target: Enum, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetQueryiv.?(target, pname, params);
}
/// - **Available since:** OpenGL 1.5
pub fn getQueryObjectiv(self: *const GL, id: UInt, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetQueryObjectiv.?(id, pname, params);
}
/// - **Available since:** OpenGL 1.5
pub fn getQueryObjectuiv(self: *const GL, id: UInt, pname: Enum, params: [*]UInt) void {
    return self.ptr_glGetQueryObjectuiv.?(id, pname, params);
}
/// - **Available since:** OpenGL 1.5
pub fn bindBuffer(self: *const GL, target: Enum, buffer: UInt) void {
    return self.ptr_glBindBuffer.?(target, buffer);
}
/// - **Available since:** OpenGL 1.5
pub fn deleteBuffers(self: *const GL, n: Sizei, buffers: [*]const UInt) void {
    return self.ptr_glDeleteBuffers.?(n, buffers);
}
/// - **Available since:** OpenGL 1.5
pub fn genBuffers(self: *const GL, n: Sizei, buffers: [*]UInt) void {
    return self.ptr_glGenBuffers.?(n, buffers);
}
/// - **Available since:** OpenGL 1.5
pub fn isBuffer(self: *const GL, buffer: UInt) bool {
    return self.ptr_glIsBuffer.?(buffer);
}
/// - **Available since:** OpenGL 1.5
pub fn bufferData(self: *const GL, target: Enum, size: Sizeiptr, data: ?*const anyopaque, usage: Enum) void {
    return self.ptr_glBufferData.?(target, size, data, usage);
}
/// - **Available since:** OpenGL 1.5
pub fn bufferSubData(self: *const GL, target: Enum, offset: Intptr, size: Sizeiptr, data: ?*const anyopaque) void {
    return self.ptr_glBufferSubData.?(target, offset, size, data);
}
/// - **Available since:** OpenGL 1.5
pub fn getBufferSubData(self: *const GL, target: Enum, offset: Intptr, size: Sizeiptr, data: ?*anyopaque) void {
    return self.ptr_glGetBufferSubData.?(target, offset, size, data);
}
/// - **Available since:** OpenGL 1.5
pub fn mapBuffer(self: *const GL, target: Enum, access: Enum) ?*anyopaque {
    return self.ptr_glMapBuffer.?(target, access);
}
/// - **Available since:** OpenGL 1.5
pub fn unmapBuffer(self: *const GL, target: Enum) bool {
    return self.ptr_glUnmapBuffer.?(target);
}
/// - **Available since:** OpenGL 1.5
pub fn getBufferParameteriv(self: *const GL, target: Enum, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetBufferParameteriv.?(target, pname, params);
}
/// - **Available since:** OpenGL 1.5
pub fn getBufferPointerv(self: *const GL, target: Enum, pname: Enum, params: [*]?*anyopaque) void {
    return self.ptr_glGetBufferPointerv.?(target, pname, params);
}
//#endregion

//#region OpenGL 2.0
/// - **Available since:** OpenGL 2.0
pub fn blendEquationSeparate(self: *const GL, modeRGB: Enum, modeAplha: Enum) void {
    return self.ptr_glBlendEquationSeparate.?(modeRGB, modeAplha);
}
/// - **Available since:** OpenGL 2.0
pub fn drawBuffers(self: *const GL, n: Sizei, bufs: [*]const Enum) void {
    return self.ptr_glDrawBuffers.?(n, bufs);
}
/// - **Available since:** OpenGL 2.0
pub fn stencilOpSeparate(self: *const GL, face: Enum, sfail: Enum, dpfail: Enum, dppass: Enum) void {
    return self.ptr_glStencilOpSeparate.?(face, sfail, dpfail, dppass);
}
/// - **Available since:** OpenGL 2.0
pub fn stencilFuncSeparate(self: *const GL, face: Enum, func: Enum, ref: Int, mask: UInt) void {
    return self.ptr_glStencilFuncSeparate.?(face, func, ref, mask);
}
/// - **Available since:** OpenGL 2.0
pub fn stencilMaskSeparate(self: *const GL, face: Enum, mask: UInt) void {
    return self.ptr_glStencilMaskSeparate.?(face, mask);
}
/// - **Available since:** OpenGL 2.0
pub fn attachShader(self: *const GL, program: UInt, shader: UInt) void {
    return self.ptr_glAttachShader.?(program, shader);
}
/// - **Available since:** OpenGL 2.0
pub fn bindAttribLocation(self: *const GL, program: UInt, _index: UInt, name: [*:0]const Char) void {
    return self.ptr_glBindAttribLocation.?(program, _index, name);
}
/// - **Available since:** OpenGL 2.0
pub fn compileShader(self: *const GL, shader: UInt) void {
    return self.ptr_glCompileShader.?(shader);
}
/// - **Available since:** OpenGL 2.0
pub fn createProgram(self: *const GL) UInt {
    return self.ptr_glCreateProgram.?();
}
/// - **Available since:** OpenGL 2.0
pub fn createShader(self: *const GL, @"type": Enum) UInt {
    return self.ptr_glCreateShader.?(@"type");
}
/// - **Available since:** OpenGL 2.0
pub fn deleteProgram(self: *const GL, program: UInt) void {
    return self.ptr_glDeleteProgram.?(program);
}
/// - **Available since:** OpenGL 2.0
pub fn deleteShader(self: *const GL, shader: UInt) void {
    return self.ptr_glDeleteShader.?(shader);
}
/// - **Available since:** OpenGL 2.0
pub fn detachShader(self: *const GL, program: UInt, shader: UInt) void {
    return self.ptr_glDetachShader.?(program, shader);
}
/// - **Available since:** OpenGL 2.0
pub fn disableVertexAttribArray(self: *const GL, _index: UInt) void {
    return self.ptr_glDisableVertexAttribArray.?(_index);
}
/// - **Available since:** OpenGL 2.0
pub fn enableVertexAttribArray(self: *const GL, _index: UInt) void {
    return self.ptr_glEnableVertexAttribArray.?(_index);
}
/// - **Available since:** OpenGL 2.0
pub fn getActiveAttrib(self: *const GL, program: UInt, _index: UInt, bufSize: Sizei, length: [*]Sizei, size: [*]Int, @"type": [*]Enum, name: [*:0]Char) void {
    return self.ptr_glGetActiveAttrib.?(program, _index, bufSize, length, size, @"type", name);
}
/// - **Available since:** OpenGL 2.0
pub fn getActiveUniform(self: *const GL, program: UInt, _index: UInt, bufSize: Sizei, length: [*]Sizei, size: [*]Int, @"type": [*]Enum, name: [*:0]Char) void {
    return self.ptr_glGetActiveUniform.?(program, _index, bufSize, length, size, @"type", name);
}
/// - **Available since:** OpenGL 2.0
pub fn getAttachedShaders(self: *const GL, program: UInt, maxCount: Sizei, count: ?*Sizei, shaders: [*]UInt) void {
    return self.ptr_glGetAttachedShaders.?(program, maxCount, count, shaders);
}
/// - **Available since:** OpenGL 2.0
pub fn getAttribLocation(self: *const GL, program: UInt, name: [*:0]const Char) Int {
    return self.ptr_glGetAttribLocation.?(program, name);
}
/// - **Available since:** OpenGL 2.0
pub fn getProgramiv(self: *const GL, program: UInt, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetProgramiv.?(program, pname, params);
}
/// - **Available since:** OpenGL 2.0
pub fn getProgramInfoLog(self: *const GL, program: UInt, bufSize: Sizei, length: ?*Sizei, infoLog: [*]Char) void {
    return self.ptr_glGetProgramInfoLog.?(program, bufSize, length, infoLog);
}
/// - **Available since:** OpenGL 2.0
pub fn getShaderiv(self: *const GL, program: UInt, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetShaderiv.?(program, pname, params);
}
/// - **Available since:** OpenGL 2.0
pub fn getShaderInfoLog(self: *const GL, shader: UInt, bufSize: Sizei, length: ?*Sizei, infoLog: [*]Char) void {
    return self.ptr_glGetShaderInfoLog.?(shader, bufSize, length, infoLog);
}
/// - **Available since:** OpenGL 2.0
pub fn getShaderSource(self: *const GL, shader: UInt, bufSize: Sizei, length: ?*Sizei, source: [*]Char) void {
    return self.ptr_glGetShaderSource.?(shader, bufSize, length, source);
}
/// - **Available since:** OpenGL 2.0
pub fn getUniformLocation(self: *const GL, shader: UInt, name: [*:0]const Char) Int {
    return self.ptr_glGetUniformLocation.?(shader, name);
}
/// - **Available since:** OpenGL 2.0
pub fn getUniformfv(self: *const GL, program: UInt, location: Int, params: [*]Float) void {
    return self.ptr_glGetUniformfv.?(program, location, params);
}
/// - **Available since:** OpenGL 2.0
pub fn getUniformiv(self: *const GL, program: UInt, location: Int, params: [*]Int) void {
    return self.ptr_glGetUniformiv.?(program, location, params);
}
/// - **Available since:** OpenGL 2.0
pub fn getVertexAttribdv(self: *const GL, program: UInt, pname: Enum, params: [*]Double) void {
    return self.ptr_glGetVertexAttribdv.?(program, pname, params);
}
/// - **Available since:** OpenGL 2.0
pub fn getVertexAttribfv(self: *const GL, program: UInt, pname: Enum, params: [*]Float) void {
    return self.ptr_glGetVertexAttribfv.?(program, pname, params);
}
/// - **Available since:** OpenGL 2.0
pub fn getVertexAttribiv(self: *const GL, program: UInt, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetVertexAttribiv.?(program, pname, params);
}
/// - **Available since:** OpenGL 2.0
pub fn getVertexAttribPointerv(self: *const GL, _index: UInt, pname: Enum, pointer: [*]?*anyopaque) void {
    return self.ptr_glGetVertexAttribPointerv.?(_index, pname, pointer);
}
/// - **Available since:** OpenGL 2.0
pub fn isProgram(self: *const GL, program: UInt) bool {
    return self.ptr_glIsProgram.?(program);
}
/// - **Available since:** OpenGL 2.0
pub fn isShader(self: *const GL, shader: UInt) bool {
    return self.ptr_glIsShader.?(shader);
}
/// - **Available since:** OpenGL 2.0
pub fn linkProgram(self: *const GL, program: UInt) void {
    return self.ptr_glLinkProgram.?(program);
}
/// - **Available since:** OpenGL 2.0
pub fn shaderSource(self: *const GL, shader: UInt, count: Sizei, string: [*]const [*]const Char, length: ?[*]const Int) void {
    return self.ptr_glShaderSource.?(shader, count, string, length);
}
/// - **Available since:** OpenGL 2.0
pub fn useProgram(self: *const GL, program: UInt) void {
    return self.ptr_glUseProgram.?(program);
}
/// - **Available since:** OpenGL 2.0
pub fn uniform1f(self: *const GL, location: Int, v0: Float) void {
    return self.ptr_glUniform1f.?(location, v0);
}
/// - **Available since:** OpenGL 2.0
pub fn uniform2f(self: *const GL, location: Int, v0: Float, v1: Float) void {
    return self.ptr_glUniform2f.?(location, v0, v1);
}
/// - **Available since:** OpenGL 2.0
pub fn uniform3f(self: *const GL, location: Int, v0: Float, v1: Float, v2: Float) void {
    return self.ptr_glUniform3f.?(location, v0, v1, v2);
}
/// - **Available since:** OpenGL 2.0
pub fn uniform4f(self: *const GL, location: Int, v0: Float, v1: Float, v2: Float, v3: Float) void {
    return self.ptr_glUniform4f.?(location, v0, v1, v2, v3);
}
/// - **Available since:** OpenGL 2.0
pub fn uniform1i(self: *const GL, location: Int, v0: Int) void {
    return self.ptr_glUniform1i.?(location, v0);
}
/// - **Available since:** OpenGL 2.0
pub fn uniform2i(self: *const GL, location: Int, v0: Int, v1: Int) void {
    return self.ptr_glUniform2i.?(location, v0, v1);
}
/// - **Available since:** OpenGL 2.0
pub fn uniform3i(self: *const GL, location: Int, v0: Int, v1: Int, v2: Int) void {
    return self.ptr_glUniform3i.?(location, v0, v1, v2);
}
/// - **Available since:** OpenGL 2.0
pub fn uniform4i(self: *const GL, location: Int, v0: Int, v1: Int, v2: Int, v3: Int) void {
    return self.ptr_glUniform4i.?(location, v0, v1, v2, v3);
}
/// - **Available since:** OpenGL 2.0
pub fn uniform1fv(self: *const GL, location: Int, count: Sizei, value: [*]const Float) void {
    return self.ptr_glUniform1fv.?(location, count, value);
}
/// - **Available since:** OpenGL 2.0
pub fn uniform2fv(self: *const GL, location: Int, count: Sizei, value: [*]const [2]Float) void {
    return self.ptr_glUniform2fv.?(location, count, value);
}
/// - **Available since:** OpenGL 2.0
pub fn uniform3fv(self: *const GL, location: Int, count: Sizei, value: [*]const [3]Float) void {
    return self.ptr_glUniform3fv.?(location, count, value);
}
/// - **Available since:** OpenGL 2.0
pub fn uniform4fv(self: *const GL, location: Int, count: Sizei, value: [*]const [4]Float) void {
    return self.ptr_glUniform4fv.?(location, count, value);
}
/// - **Available since:** OpenGL 2.0
pub fn uniform1iv(self: *const GL, location: Int, count: Sizei, value: [*]const Int) void {
    return self.ptr_glUniform1iv.?(location, count, value);
}
/// - **Available since:** OpenGL 2.0
pub fn uniform2iv(self: *const GL, location: Int, count: Sizei, value: [*]const [2]Int) void {
    return self.ptr_glUniform2iv.?(location, count, value);
}
/// - **Available since:** OpenGL 2.0
pub fn uniform3iv(self: *const GL, location: Int, count: Sizei, value: [*]const [3]Int) void {
    return self.ptr_glUniform3iv.?(location, count, value);
}
/// - **Available since:** OpenGL 2.0
pub fn uniform4iv(self: *const GL, location: Int, count: Sizei, value: [*]const [4]Int) void {
    return self.ptr_glUniform4iv.?(location, count, value);
}
/// - **Available since:** OpenGL 2.0
pub fn uniformMatrix2fv(self: *const GL, location: Int, count: Sizei, transpose: bool, v: [*]const [2 * 2]Float) void {
    return self.ptr_glUniformMatrix2fv.?(location, count, transpose, v);
}
/// - **Available since:** OpenGL 2.0
pub fn uniformMatrix3fv(self: *const GL, location: Int, count: Sizei, transpose: bool, v: [*]const [3 * 3]Float) void {
    return self.ptr_glUniformMatrix3fv.?(location, count, transpose, v);
}
/// - **Available since:** OpenGL 2.0
pub fn uniformMatrix4fv(self: *const GL, location: Int, count: Sizei, transpose: bool, v: [*]const [4 * 4]Float) void {
    return self.ptr_glUniformMatrix4fv.?(location, count, transpose, v);
}
/// - **Available since:** OpenGL 2.0
pub fn validateProgram(self: *const GL, program: UInt) void {
    return self.ptr_glValidateProgram.?(program);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib1d(self: *const GL, _index: UInt, x: Double) void {
    return self.ptr_glVertexAttrib1d.?(_index, x);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib1dv(self: *const GL, _index: UInt, v: *const Double) void {
    return self.ptr_glVertexAttrib1dv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib1f(self: *const GL, _index: UInt, x: Float) void {
    return self.ptr_glVertexAttrib1f.?(_index, x);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib1fv(self: *const GL, _index: UInt, v: *const Float) void {
    return self.ptr_glVertexAttrib1fv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib1s(self: *const GL, _index: UInt, x: Short) void {
    return self.ptr_glVertexAttrib1s.?(_index, x);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib1sv(self: *const GL, _index: UInt, v: *const Short) void {
    return self.ptr_glVertexAttrib1sv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib2d(self: *const GL, _index: UInt, x: Double, y: Double) void {
    return self.ptr_glVertexAttrib2d.?(_index, x, y);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib2dv(self: *const GL, _index: UInt, v: *const [2]Double) void {
    return self.ptr_glVertexAttrib2dv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib2f(self: *const GL, _index: UInt, x: Float, y: Float) void {
    return self.ptr_glVertexAttrib2f.?(_index, x, y);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib2fv(self: *const GL, _index: UInt, v: *const [2]Float) void {
    return self.ptr_glVertexAttrib2fv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib2s(self: *const GL, _index: UInt, x: Short, y: Short) void {
    return self.ptr_glVertexAttrib2s.?(_index, x, y);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib2sv(self: *const GL, _index: UInt, v: *const [2]Short) void {
    return self.ptr_glVertexAttrib2sv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib3d(self: *const GL, _index: UInt, x: Double, y: Double, z: Double) void {
    return self.ptr_glVertexAttrib3d.?(_index, x, y, z);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib3dv(self: *const GL, _index: UInt, v: *const [3]Double) void {
    return self.ptr_glVertexAttrib3dv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib3f(self: *const GL, _index: UInt, x: Float, y: Float, z: Float) void {
    return self.ptr_glVertexAttrib3f.?(_index, x, y, z);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib3fv(self: *const GL, _index: UInt, v: *const [3]Float) void {
    return self.ptr_glVertexAttrib3fv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib3s(self: *const GL, _index: UInt, x: Short, y: Short, z: Short) void {
    return self.ptr_glVertexAttrib3s.?(_index, x, y, z);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib3sv(self: *const GL, _index: UInt, v: *const [3]Short) void {
    return self.ptr_glVertexAttrib3sv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib4Nbv(self: *const GL, _index: UInt, v: *const [4]Byte) void {
    return self.ptr_glVertexAttrib4Nbv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib4Niv(self: *const GL, _index: UInt, v: *const [4]Int) void {
    return self.ptr_glVertexAttrib4Niv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib4Nsv(self: *const GL, _index: UInt, v: *const [4]Short) void {
    return self.ptr_glVertexAttrib4Nsv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib4Nub(self: *const GL, _index: UInt, x: UByte, y: UByte, z: UByte, w: UByte) void {
    return self.ptr_glVertexAttrib4Nub.?(_index, x, y, z, w);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib4Nubv(self: *const GL, _index: UInt, v: *const [4]UByte) void {
    return self.ptr_glVertexAttrib4Nubv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib4Nuiv(self: *const GL, _index: UInt, v: *const [4]UInt) void {
    return self.ptr_glVertexAttrib4Nuiv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib4Nusv(self: *const GL, _index: UInt, v: *const [4]UShort) void {
    return self.ptr_glVertexAttrib4Nusv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib4bv(self: *const GL, _index: UInt, v: *const [4]Byte) void {
    return self.ptr_glVertexAttrib4bv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib4d(self: *const GL, _index: UInt, x: Double, y: Double, z: Double, w: Double) void {
    return self.ptr_glVertexAttrib4d.?(_index, x, y, z, w);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib4dv(self: *const GL, _index: UInt, v: *const [4]Double) void {
    return self.ptr_glVertexAttrib4dv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib4f(self: *const GL, _index: UInt, x: Float, y: Float, z: Float, w: Float) void {
    return self.ptr_glVertexAttrib4f.?(_index, x, y, z, w);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib4fv(self: *const GL, _index: UInt, v: *const [4]Float) void {
    return self.ptr_glVertexAttrib4fv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib4iv(self: *const GL, _index: UInt, v: *const [4]Int) void {
    return self.ptr_glVertexAttrib4iv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib4s(self: *const GL, _index: UInt, x: Short, y: Short, z: Short, w: Short) void {
    return self.ptr_glVertexAttrib4s.?(_index, x, y, z, w);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib4sv(self: *const GL, _index: UInt, v: *const [4]Short) void {
    return self.ptr_glVertexAttrib4sv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib4ubv(self: *const GL, _index: UInt, v: *const [4]UByte) void {
    return self.ptr_glVertexAttrib4ubv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib4uiv(self: *const GL, _index: UInt, v: *const [4]UInt) void {
    return self.ptr_glVertexAttrib4uiv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttrib4usv(self: *const GL, _index: UInt, v: *const [4]UShort) void {
    return self.ptr_glVertexAttrib4usv.?(_index, v);
}
/// - **Available since:** OpenGL 2.0
pub fn vertexAttribPointer(self: *const GL, _index: UInt, size: Int, @"type": Enum, normalized: bool, stride: Sizei, pointer: usize) void {
    return self.ptr_glVertexAttribPointer.?(_index, size, @"type", normalized, stride, pointer);
}
//#endregion
//#region OpenGL 2.1
/// - **Available since:** OpenGL 2.1
pub fn uniformMatrix2x3fv(self: *const GL, location: Int, count: Sizei, transpose: bool, v: *const [2 * 3]Float) void {
    return self.ptr_glUniformMatrix2x3fv.?(location, count, transpose, v);
}
/// - **Available since:** OpenGL 2.1
pub fn uniformMatrix3x2fv(self: *const GL, location: Int, count: Sizei, transpose: bool, v: *const [3 * 2]Float) void {
    return self.ptr_glUniformMatrix3x2fv.?(location, count, transpose, v);
}
/// - **Available since:** OpenGL 2.1
pub fn uniformMatrix2x4fv(self: *const GL, location: Int, count: Sizei, transpose: bool, v: *const [2 * 4]Float) void {
    return self.ptr_glUniformMatrix2x4fv.?(location, count, transpose, v);
}
/// - **Available since:** OpenGL 2.1
pub fn uniformMatrix4x2fv(self: *const GL, location: Int, count: Sizei, transpose: bool, v: *const [4 * 2]Float) void {
    return self.ptr_glUniformMatrix4x2fv.?(location, count, transpose, v);
}
/// - **Available since:** OpenGL 2.1
pub fn uniformMatrix3x4fv(self: *const GL, location: Int, count: Sizei, transpose: bool, v: *const [3 * 4]Float) void {
    return self.ptr_glUniformMatrix3x4fv.?(location, count, transpose, v);
}
/// - **Available since:** OpenGL 2.1
pub fn uniformMatrix4x3fv(self: *const GL, location: Int, count: Sizei, transpose: bool, v: *const [4 * 3]Float) void {
    return self.ptr_glUniformMatrix4x3fv.?(location, count, transpose, v);
}
//#endregion

//#region OpenGL 3.0
/// - **Available since:** OpenGL 3.0
pub fn colorMaski(self: *const GL, _index: UInt, r: bool, g: bool, b: bool, a: bool) void {
    return self.ptr_glColorMaski.?(_index, r, g, b, a);
}
/// - **Available since:** OpenGL 3.0
pub fn getBooleani_v(self: *const GL, target: Enum, _index: UInt, data: [*]bool) void {
    return self.ptr_glGetBooleani_v.?(target, _index, data);
}
/// - **Available since:** OpenGL 3.0
pub fn getIntegeri_v(self: *const GL, target: Enum, _index: UInt, data: [*]Int) void {
    return self.ptr_glGetIntegeri_v.?(target, _index, data);
}
/// - **Available since:** OpenGL 3.0
pub fn enablei(self: *const GL, target: Enum, _index: UInt) void {
    return self.ptr_glEnablei.?(target, _index);
}
/// - **Available since:** OpenGL 3.0
pub fn disablei(self: *const GL, target: Enum, _index: UInt) void {
    return self.ptr_glDisablei.?(target, _index);
}
/// - **Available since:** OpenGL 3.0
pub fn isEnabledi(self: *const GL, target: Enum, _index: UInt) bool {
    return self.ptr_glIsEnabledi.?(target, _index);
}
/// - **Available since:** OpenGL 3.0
pub fn beginTransformFeedback(self: *const GL, primitiveMode: Enum) void {
    return self.ptr_glBeginTransformFeedback.?(primitiveMode);
}
/// - **Available since:** OpenGL 3.0
pub fn endTransformFeedback(self: *const GL) void {
    return self.ptr_glEndTransformFeedback.?();
}
/// - **Available since:** OpenGL 3.0
pub fn bindBufferRange(self: *const GL, target: Enum, _index: UInt, buffer: UInt, offset: Intptr, size: Sizeiptr) void {
    return self.ptr_glBindBufferRange.?(target, _index, buffer, offset, size);
}
/// - **Available since:** OpenGL 3.0
pub fn bindBufferBase(self: *const GL, target: Enum, _index: UInt, buffer: UInt) void {
    return self.ptr_glBindBufferBase.?(target, _index, buffer);
}
/// - **Available since:** OpenGL 3.0
pub fn transformFeedbackVaryings(self: *const GL, program: UInt, count: Sizei, varyings: [*]const [*:0]const Char, bufferMode: Enum) void {
    return self.ptr_glTransformFeedbackVaryings.?(program, count, varyings, bufferMode);
}
/// - **Available since:** OpenGL 3.0
pub fn getTransformFeedbackVarying(self: *const GL, program: UInt, _index: UInt, bufSize: Sizei, length: ?*Sizei, size: ?*Sizei, @"type": *Enum, name: [*:0]Char) void {
    return self.ptr_glGetTransformFeedbackVarying.?(program, _index, bufSize, length, size, @"type", name);
}
/// - **Available since:** OpenGL 3.0
pub fn clampColor(self: *const GL, target: Enum, clamp: Enum) void {
    return self.ptr_glClampColor.?(target, clamp);
}
/// - **Available since:** OpenGL 3.0
pub fn beginConditionalRender(self: *const GL, id: UInt, mode: Enum) void {
    return self.ptr_glBeginConditionalRender.?(id, mode);
}
/// - **Available since:** OpenGL 3.0
pub fn endConditionalRender(self: *const GL) void {
    return self.ptr_glEndConditionalRender.?();
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribIPointer(self: *const GL, _index: UInt, size: Int, @"type": Enum, stride: Sizei, pointer: usize) void {
    return self.ptr_glVertexAttribIPointer.?(_index, size, @"type", stride, pointer);
}
/// - **Available since:** OpenGL 3.0
pub fn getVertexAttribIiv(self: *const GL, _index: UInt, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetVertexAttribIiv.?(_index, pname, params);
}
/// - **Available since:** OpenGL 3.0
pub fn getVertexAttribIuiv(self: *const GL, _index: UInt, pname: Enum, params: [*]UInt) void {
    return self.ptr_glGetVertexAttribIuiv.?(_index, pname, params);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI1i(self: *const GL, _index: UInt, x: Int) void {
    return self.ptr_glVertexAttribI1i.?(_index, x);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI2i(self: *const GL, _index: UInt, x: Int, y: Int) void {
    return self.ptr_glVertexAttribI2i.?(_index, x, y);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI3i(self: *const GL, _index: UInt, x: Int, y: Int, z: Int) void {
    return self.ptr_glVertexAttribI3i.?(_index, x, y, z);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI4i(self: *const GL, _index: UInt, x: Int, y: Int, z: Int, w: Int) void {
    return self.ptr_glVertexAttribI4i.?(_index, x, y, z, w);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI1ui(self: *const GL, _index: UInt, x: UInt) void {
    return self.ptr_glVertexAttribI1ui.?(_index, x);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI2ui(self: *const GL, _index: UInt, x: UInt, y: UInt) void {
    return self.ptr_glVertexAttribI2ui.?(_index, x, y);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI3ui(self: *const GL, _index: UInt, x: UInt, y: UInt, z: UInt) void {
    return self.ptr_glVertexAttribI3ui.?(_index, x, y, z);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI4ui(self: *const GL, _index: UInt, x: UInt, y: UInt, z: UInt, w: UInt) void {
    return self.ptr_glVertexAttribI4ui.?(_index, x, y, z, w);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI1iv(self: *const GL, _index: UInt, v: *const Int) void {
    return self.ptr_glVertexAttribI1iv.?(_index, v);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI2iv(self: *const GL, _index: UInt, v: *const [2]Int) void {
    return self.ptr_glVertexAttribI2iv.?(_index, v);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI3iv(self: *const GL, _index: UInt, v: *const [3]Int) void {
    return self.ptr_glVertexAttribI3iv.?(_index, v);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI4iv(self: *const GL, _index: UInt, v: *const [4]Int) void {
    return self.ptr_glVertexAttribI4iv.?(_index, v);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI1uiv(self: *const GL, _index: UInt, v: *const UInt) void {
    return self.ptr_glVertexAttribI1uiv.?(_index, v);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI2uiv(self: *const GL, _index: UInt, v: *const [2]UInt) void {
    return self.ptr_glVertexAttribI2uiv.?(_index, v);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI3uiv(self: *const GL, _index: UInt, v: *const [3]UInt) void {
    return self.ptr_glVertexAttribI3uiv.?(_index, v);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI4uiv(self: *const GL, _index: UInt, v: *const [4]UInt) void {
    return self.ptr_glVertexAttribI4uiv.?(_index, v);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI4bv(self: *const GL, _index: UInt, v: *const [4]Byte) void {
    return self.ptr_glVertexAttribI4bv.?(_index, v);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI4sv(self: *const GL, _index: UInt, v: *const [4]Short) void {
    return self.ptr_glVertexAttribI4sv.?(_index, v);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI4ubv(self: *const GL, _index: UInt, v: *const [4]UByte) void {
    return self.ptr_glVertexAttribI4ubv.?(_index, v);
}
/// - **Available since:** OpenGL 3.0
pub fn vertexAttribI4usv(self: *const GL, _index: UInt, v: *const [4]UShort) void {
    return self.ptr_glVertexAttribI4usv.?(_index, v);
}
/// - **Available since:** OpenGL 3.0
pub fn getUniformuiv(self: *const GL, program: UInt, location: Int, params: [*]UInt) void {
    return self.ptr_glGetUniformuiv.?(program, location, params);
}
/// - **Available since:** OpenGL 3.0
pub fn bindFragDataLocation(self: *const GL, program: UInt, color: UInt, name: [*:0]const Char) void {
    return self.ptr_glBindFragDataLocation.?(program, color, name);
}
/// - **Available since:** OpenGL 3.0
pub fn getFragDataLocation(self: *const GL, program: UInt, name: [*:0]const Char) Int {
    return self.ptr_glGetFragDataLocation.?(program, name);
}
/// - **Available since:** OpenGL 3.0
pub fn uniform1ui(self: *const GL, location: Int, v0: UInt) void {
    return self.ptr_glUniform1ui.?(location, v0);
}
/// - **Available since:** OpenGL 3.0
pub fn uniform2ui(self: *const GL, location: Int, v0: UInt, v1: UInt) void {
    return self.ptr_glUniform2ui.?(location, v0, v1);
}
/// - **Available since:** OpenGL 3.0
pub fn uniform3ui(self: *const GL, location: Int, v0: UInt, v1: UInt, v2: UInt) void {
    return self.ptr_glUniform3ui.?(location, v0, v1, v2);
}
/// - **Available since:** OpenGL 3.0
pub fn uniform4ui(self: *const GL, location: Int, v0: UInt, v1: UInt, v2: UInt, v3: UInt) void {
    return self.ptr_glUniform4ui.?(location, v0, v1, v2, v3);
}
/// - **Available since:** OpenGL 3.0
pub fn uniform1uiv(self: *const GL, location: Int, count: Sizei, value: *const UInt) void {
    return self.ptr_glUniform1uiv.?(location, count, value);
}
/// - **Available since:** OpenGL 3.0
pub fn uniform2uiv(self: *const GL, location: Int, count: Sizei, value: *const [2]UInt) void {
    return self.ptr_glUniform2uiv.?(location, count, value);
}
/// - **Available since:** OpenGL 3.0
pub fn uniform3uiv(self: *const GL, location: Int, count: Sizei, value: *const [3]UInt) void {
    return self.ptr_glUniform3uiv.?(location, count, value);
}
/// - **Available since:** OpenGL 3.0
pub fn uniform4uiv(self: *const GL, location: Int, count: Sizei, value: *const [4]UInt) void {
    return self.ptr_glUniform4uiv.?(location, count, value);
}
/// - **Available since:** OpenGL 3.0
pub fn texParameterIiv(self: *const GL, target: Enum, pname: Enum, params: [*]const Int) void {
    return self.ptr_glTexParameterIiv.?(target, pname, params);
}
/// - **Available since:** OpenGL 3.0
pub fn texParameterIuiv(self: *const GL, target: Enum, pname: Enum, params: [*]const UInt) void {
    return self.ptr_glTexParameterIuiv.?(target, pname, params);
}
/// - **Available since:** OpenGL 3.0
pub fn getTexParameterIiv(self: *const GL, target: Enum, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetTexParameterIiv.?(target, pname, params);
}
/// - **Available since:** OpenGL 3.0
pub fn getTexParameterIuiv(self: *const GL, target: Enum, pname: Enum, params: [*]UInt) void {
    return self.ptr_glGetTexParameterIuiv.?(target, pname, params);
}
/// - **Available since:** OpenGL 3.0
pub fn clearBufferiv(self: *const GL, buffer: Enum, _drawBuffer: Int, value: [*]const Int) void {
    return self.ptr_glClearBufferiv.?(buffer, _drawBuffer, value);
}
/// - **Available since:** OpenGL 3.0
pub fn clearBufferuiv(self: *const GL, buffer: Enum, _drawBuffer: Int, value: [*]const UInt) void {
    return self.ptr_glClearBufferuiv.?(buffer, _drawBuffer, value);
}
/// - **Available since:** OpenGL 3.0
pub fn clearBufferfv(self: *const GL, buffer: Enum, _drawBuffer: Int, value: [*]const Float) void {
    return self.ptr_glClearBufferfv.?(buffer, _drawBuffer, value);
}
/// - **Available since:** OpenGL 3.0
pub fn clearBufferfi(self: *const GL, buffer: Enum, _drawBuffer: Int, depth: Float, stencil: Int) void {
    return self.ptr_glClearBufferfi.?(buffer, _drawBuffer, depth, stencil);
}
/// - **Available since:** OpenGL 3.0
pub fn getStringi(self: *const GL, buffer: Enum, _index: UInt) [*:0]const Char {
    return self.ptr_glGetStringi.?(buffer, _index);
}
/// - **Available since:** OpenGL 3.0
pub fn isRenderbuffer(self: *const GL, renderbuffer: UInt) bool {
    return self.ptr_glIsRenderbuffer.?(renderbuffer);
}
/// - **Available since:** OpenGL 3.0
pub fn bindRenderbuffer(self: *const GL, target: Enum, renderbuffer: UInt) void {
    return self.ptr_glBindRenderbuffer.?(target, renderbuffer);
}
/// - **Available since:** OpenGL 3.0
pub fn deleteRenderbuffers(self: *const GL, n: Sizei, renderbuffers: [*]const UInt) void {
    return self.ptr_glDeleteRenderbuffers.?(n, renderbuffers);
}
/// - **Available since:** OpenGL 3.0
pub fn genRenderbuffers(self: *const GL, n: Sizei, renderbuffers: [*]UInt) void {
    return self.ptr_glGenRenderbuffers.?(n, renderbuffers);
}
/// - **Available since:** OpenGL 3.0
pub fn renderbufferStorage(self: *const GL, target: Enum, internalFormat: Enum, width: Sizei, height: Sizei) void {
    return self.ptr_glRenderbufferStorage.?(target, internalFormat, width, height);
}
/// - **Available since:** OpenGL 3.0
pub fn getRenderbufferParameteriv(self: *const GL, target: Enum, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetRenderbufferParameteriv.?(target, pname, params);
}
/// - **Available since:** OpenGL 3.0
pub fn isFramebuffer(self: *const GL, framebuffer: UInt) bool {
    return self.ptr_glIsFramebuffer.?(framebuffer);
}
/// - **Available since:** OpenGL 3.0
pub fn bindFramebuffer(self: *const GL, target: Enum, framebuffer: UInt) void {
    return self.ptr_glBindFramebuffer.?(target, framebuffer);
}
/// - **Available since:** OpenGL 3.0
pub fn deleteFramebuffers(self: *const GL, n: Sizei, framebuffers: [*]const UInt) void {
    return self.ptr_glDeleteFramebuffers.?(n, framebuffers);
}
/// - **Available since:** OpenGL 3.0
pub fn genFramebuffers(self: *const GL, n: Sizei, framebuffers: [*]UInt) void {
    return self.ptr_glGenFramebuffers.?(n, framebuffers);
}
/// - **Available since:** OpenGL 3.0
pub fn checkFramebufferStatus(self: *const GL, target: Enum) Enum {
    return self.ptr_glCheckFramebufferStatus.?(target);
}
/// - **Available since:** OpenGL 3.0
pub fn framebufferTexture1D(self: *const GL, target: Enum, attachment: Enum, textarget: Enum, texture: UInt, level: Int) void {
    return self.ptr_glFramebufferTexture1D.?(target, attachment, textarget, texture, level);
}
/// - **Available since:** OpenGL 3.0
pub fn framebufferTexture2D(self: *const GL, target: Enum, attachment: Enum, textarget: Enum, texture: UInt, level: Int) void {
    return self.ptr_glFramebufferTexture2D.?(target, attachment, textarget, texture, level);
}
/// - **Available since:** OpenGL 3.0
pub fn framebufferTexture3D(self: *const GL, target: Enum, attachment: Enum, textarget: Enum, texture: UInt, level: Int, zoffset: Int) void {
    return self.ptr_glFramebufferTexture3D.?(target, attachment, textarget, texture, level, zoffset);
}
/// - **Available since:** OpenGL 3.0
pub fn framebufferRenderbuffer(self: *const GL, target: Enum, attachment: Enum, textarget: Enum, renderbuffer: UInt) void {
    return self.ptr_glFramebufferRenderbuffer.?(target, attachment, textarget, renderbuffer);
}
/// - **Available since:** OpenGL 3.0
pub fn getFramebufferAttachmentParameteriv(self: *const GL, target: Enum, attachment: Enum, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetFramebufferAttachmentParameteriv.?(target, attachment, pname, params);
}
/// - **Available since:** OpenGL 3.0
pub fn generateMipmap(self: *const GL, target: Enum) void {
    return self.ptr_glGenerateMipmap.?(target);
}
/// - **Available since:** OpenGL 3.0
pub fn blitFramebuffer(self: *const GL, srcX0: Int, srcY0: Int, srcX1: Int, srcY1: Int, dstX0: Int, dstY0: Int, dstX1: Int, dstY1: Int, mask: Bitfield, filter: Enum) void {
    return self.ptr_glBlitFramebuffer.?(srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter);
}
/// - **Available since:** OpenGL 3.0
pub fn renderbufferStorageMultisample(self: *const GL, target: Enum, samples: Sizei, internalFormat: Enum, width: Sizei, heught: Sizei) void {
    return self.ptr_glRenderbufferStorageMultisample.?(target, samples, internalFormat, width, heught);
}
/// - **Available since:** OpenGL 3.0
pub fn framebufferTextureLayer(self: *const GL, target: Enum, attachment: Enum, texture: UInt, level: Int, layer: Int) void {
    return self.ptr_glFramebufferTextureLayer.?(target, attachment, texture, level, layer);
}
/// - **Available since:** OpenGL 3.0
pub fn mapBufferRange(self: *const GL, target: Enum, offset: Intptr, length: Sizeiptr, access: Bitfield) ?*anyopaque {
    return self.ptr_glMapBufferRange.?(target, offset, length, access);
}
/// - **Available since:** OpenGL 3.0
pub fn flushMappedBufferRange(self: *const GL, target: Enum, offset: Intptr, length: Sizeiptr) void {
    return self.ptr_glFlushMappedBufferRange.?(target, offset, length);
}
/// - **Available since:** OpenGL 3.0
pub fn bindVertexArray(self: *const GL, array: UInt) void {
    return self.ptr_glBindVertexArray.?(array);
}
/// - **Available since:** OpenGL 3.0
pub fn deleteVertexArrays(self: *const GL, n: Sizei, arrays: [*]const UInt) void {
    return self.ptr_glDeleteVertexArrays.?(n, arrays);
}
/// - **Available since:** OpenGL 3.0
pub fn genVertexArrays(self: *const GL, n: Sizei, arrays: [*]UInt) void {
    return self.ptr_glGenVertexArrays.?(n, arrays);
}
/// - **Available since:** OpenGL 3.0
pub fn isVertexArray(self: *const GL, array: UInt) bool {
    return self.ptr_glIsVertexArray.?(array);
}
//#endregion
//#region OpenGL 3.1
/// - **Available since:** OpenGL 3.1
pub fn drawArraysInstanced(self: *const GL, mode: Enum, first: Int, count: Sizei, instancecount: Sizei) void {
    return self.ptr_glDrawArraysInstanced.?(mode, first, count, instancecount);
}
/// - **Available since:** OpenGL 3.1
pub fn drawElementsInstanced(self: *const GL, mode: Enum, count: Sizei, @"type": Enum, indices: usize, instancecount: Sizei) void {
    return self.ptr_glDrawElementsInstanced.?(mode, count, @"type", indices, instancecount);
}
/// - **Available since:** OpenGL 3.1
pub fn texBuffer(self: *const GL, target: Enum, internalFormat: Enum, buffer: UInt) void {
    return self.ptr_glTexBuffer.?(target, internalFormat, buffer);
}
/// - **Available since:** OpenGL 3.1
pub fn primitiveRestartIndex(self: *const GL, _index: UInt) void {
    return self.ptr_glPrimitiveRestartIndex.?(_index);
}
/// - **Available since:** OpenGL 3.1
pub fn copyBufferSubData(self: *const GL, readTarget: Enum, writeTarget: Enum, readOffset: Intptr, writeOffset: Intptr, size: Sizeiptr) void {
    return self.ptr_glCopyBufferSubData.?(readTarget, writeTarget, readOffset, writeOffset, size);
}
/// - **Available since:** OpenGL 3.1
pub fn getUniformIndices(self: *const GL, program: UInt, uniformCount: Sizei, uniformNames: [*]const [*:0]const Char, uniformIndices: [*]UInt) void {
    return self.ptr_glGetUniformIndices.?(program, uniformCount, uniformNames, uniformIndices);
}
/// - **Available since:** OpenGL 3.1
pub fn getActiveUniformsiv(self: *const GL, program: UInt, uniformCount: Sizei, uniformIndices: [*]const UInt, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetActiveUniformsiv.?(program, uniformCount, uniformIndices, pname, params);
}
/// - **Available since:** OpenGL 3.1
pub fn getActiveUniformName(self: *const GL, program: UInt, uniformIndex: UInt, bufSize: Sizei, length: ?*Sizei, uniformName: [*]Char) void {
    return self.ptr_glGetActiveUniformName.?(program, uniformIndex, bufSize, length, uniformName);
}
/// - **Available since:** OpenGL 3.1
pub fn getUniformBlockIndex(self: *const GL, program: UInt, uniformBlockName: [*:0]const Char) UInt {
    return self.ptr_glGetUniformBlockIndex.?(program, uniformBlockName);
}
/// - **Available since:** OpenGL 3.1
pub fn getActiveUniformBlockiv(self: *const GL, program: UInt, uniformBlockIndex: UInt, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetActiveUniformBlockiv.?(program, uniformBlockIndex, pname, params);
}
/// - **Available since:** OpenGL 3.1
pub fn getActiveUniformBlockName(self: *const GL, program: UInt, uniformBlockIndex: UInt, bufSize: Sizei, length: ?*Sizei, uniformBlockName: [*]Char) void {
    return self.ptr_glGetActiveUniformBlockName.?(program, uniformBlockIndex, bufSize, length, uniformBlockName);
}
/// - **Available since:** OpenGL 3.1
pub fn uniformBlockBinding(self: *const GL, program: UInt, uniformBlockIndex: UInt, _uniformBlockBinding: UInt) void {
    return self.ptr_glUniformBlockBinding.?(program, uniformBlockIndex, _uniformBlockBinding);
}
//#endregion
//#region OpenGL 3.2
/// - **Available since:** OpenGL 3.2
pub fn drawElementsBaseVertex(self: *const GL, mode: Enum, count: Sizei, @"type": Enum, indices: usize, basevertex: Int) void {
    return self.ptr_glDrawElementsBaseVertex.?(mode, count, @"type", indices, basevertex);
}
/// - **Available since:** OpenGL 3.2
pub fn drawRangeElementsBaseVertex(self: *const GL, mode: Enum, start: UInt, _end: UInt, count: Sizei, @"type": Enum, indices: usize, basevertex: Int) void {
    return self.ptr_glDrawRangeElementsBaseVertex.?(mode, start, _end, count, @"type", indices, basevertex);
}
/// - **Available since:** OpenGL 3.2
pub fn drawElementsInstancedBaseVertex(self: *const GL, mode: Enum, count: Sizei, @"type": Enum, indices: usize, instancecount: Sizei, basevertex: Int) void {
    return self.ptr_glDrawElementsInstancedBaseVertex.?(mode, count, @"type", indices, instancecount, basevertex);
}
/// - **Available since:** OpenGL 3.2
pub fn multiDrawElementsBaseVertex(self: *const GL, mode: Enum, count: [*]const Sizei, @"type": Enum, indices: [*]const usize, drawcount: Sizei, basevertex: [*]const Int) void {
    return self.ptr_glMultiDrawElementsBaseVertex.?(mode, count, @"type", indices, drawcount, basevertex);
}
/// - **Available since:** OpenGL 3.2
pub fn provokingVertex(self: *const GL, mode: Enum) void {
    return self.ptr_glProvokingVertex.?(mode);
}
/// - **Available since:** OpenGL 3.2
pub fn fenceSync(self: *const GL, condition: Enum, flags: Bitfield) Sync {
    return self.ptr_glFenceSync.?(condition, flags);
}
/// - **Available since:** OpenGL 3.2
pub fn isSync(self: *const GL, sync: Sync) bool {
    return self.ptr_glIsSync.?(sync);
}
/// - **Available since:** OpenGL 3.2
pub fn deleteSync(self: *const GL, sync: Sync) void {
    return self.ptr_glDeleteSync.?(sync);
}
/// - **Available since:** OpenGL 3.2
pub fn clientWaitSync(self: *const GL, sync: Sync, flags: Bitfield, timeout: UInt64) Enum {
    return self.ptr_glClientWaitSync.?(sync, flags, timeout);
}
/// - **Available since:** OpenGL 3.2
pub fn waitSync(self: *const GL, sync: Sync, flags: Bitfield, timeout: UInt64) void {
    return self.ptr_glWaitSync.?(sync, flags, timeout);
}
/// - **Available since:** OpenGL 3.2
pub fn getInteger64v(self: *const GL, pname: Enum, data: [*]Int64) void {
    return self.ptr_glGetInteger64v.?(pname, data);
}
/// - **Available since:** OpenGL 3.2
pub fn getSynciv(self: *const GL, sync: Sync, pname: Enum, count: Sizei, length: ?*Sizei, values: [*]Int) void {
    return self.ptr_glGetSynciv.?(sync, pname, count, length, values);
}
/// - **Available since:** OpenGL 3.2
pub fn getInteger64i_v(self: *const GL, target: Enum, _index: UInt, data: [*]Int64) void {
    return self.ptr_glGetInteger64i_v.?(target, _index, data);
}
/// - **Available since:** OpenGL 3.2
pub fn getBufferParameteri64v(self: *const GL, target: Enum, pname: Enum, params: [*]Int64) void {
    return self.ptr_glGetBufferParameteri64v.?(target, pname, params);
}
/// - **Available since:** OpenGL 3.2
pub fn framebufferTexture(self: *const GL, target: Enum, attachment: Enum, texture: UInt, level: Int) void {
    return self.ptr_glFramebufferTexture.?(target, attachment, texture, level);
}
/// - **Available since:** OpenGL 3.2
pub fn texImage2DMultisample(self: *const GL, target: Enum, samples: Sizei, internalformat: Enum, width: Sizei, height: Sizei, fixedsamplelocations: bool) void {
    return self.ptr_glTexImage2DMultisample.?(target, samples, internalformat, width, height, fixedsamplelocations);
}
/// - **Available since:** OpenGL 3.2
pub fn texImage3DMultisample(self: *const GL, target: Enum, samples: Sizei, internalformat: Enum, width: Sizei, height: Sizei, depth: Sizei, fixedsamplelocations: bool) void {
    return self.ptr_glTexImage3DMultisample.?(target, samples, internalformat, width, height, depth, fixedsamplelocations);
}
/// - **Available since:** OpenGL 3.2
pub fn getMultisamplefv(self: *const GL, pname: Enum, _index: UInt, val: [*]Float) void {
    return self.ptr_glGetMultisamplefv.?(pname, _index, val);
}
/// - **Available since:** OpenGL 3.2
pub fn sampleMaski(self: *const GL, maskNumber: UInt, mask: Bitfield) void {
    return self.ptr_glSampleMaski.?(maskNumber, mask);
}
//#endregion
//#region OpenGL 3.3
/// - **Available since:** OpenGL 3.3
pub fn bindFragDataLocationIndexed(self: *const GL, program: UInt, colorNumber: UInt, _index: UInt, name: [*:0]const Char) void {
    return self.ptr_glBindFragDataLocationIndexed.?(program, colorNumber, _index, name);
}
/// - **Available since:** OpenGL 3.3
pub fn getFragDataIndex(self: *const GL, program: UInt, name: [*:0]const Char) Int {
    return self.ptr_glGetFragDataIndex.?(program, name);
}
/// - **Available since:** OpenGL 3.3
pub fn genSamplers(self: *const GL, count: Sizei, samplers: [*]UInt) void {
    return self.ptr_glGenSamplers.?(count, samplers);
}
/// - **Available since:** OpenGL 3.3
pub fn deleteSamplers(self: *const GL, count: Sizei, samplers: [*]const UInt) void {
    return self.ptr_glDeleteSamplers.?(count, samplers);
}
/// - **Available since:** OpenGL 3.3
pub fn isSampler(self: *const GL, sampler: UInt) bool {
    return self.ptr_glIsSampler.?(sampler);
}
/// - **Available since:** OpenGL 3.3
pub fn bindSampler(self: *const GL, unit: UInt, sampler: UInt) void {
    return self.ptr_glBindSampler.?(unit, sampler);
}
/// - **Available since:** OpenGL 3.3
pub fn samplerParameteri(self: *const GL, sampler: UInt, pname: Enum, param: Int) void {
    return self.ptr_glSamplerParameteri.?(sampler, pname, param);
}
/// - **Available since:** OpenGL 3.3
pub fn samplerParameteriv(self: *const GL, sampler: UInt, pname: Enum, param: [*]const Int) void {
    return self.ptr_glSamplerParameteriv.?(sampler, pname, param);
}
/// - **Available since:** OpenGL 3.3
pub fn samplerParameterf(self: *const GL, sampler: UInt, pname: Enum, param: Float) void {
    return self.ptr_glSamplerParameterf.?(sampler, pname, param);
}
/// - **Available since:** OpenGL 3.3
pub fn samplerParameterfv(self: *const GL, sampler: UInt, pname: Enum, param: [*]const Float) void {
    return self.ptr_glSamplerParameterfv.?(sampler, pname, param);
}
/// - **Available since:** OpenGL 3.3
pub fn samplerParameterIiv(self: *const GL, sampler: UInt, pname: Enum, param: [*]const Int) void {
    return self.ptr_glSamplerParameterIiv.?(sampler, pname, param);
}
/// - **Available since:** OpenGL 3.3
pub fn samplerParameterIuiv(self: *const GL, sampler: UInt, pname: Enum, param: [*]const UInt) void {
    return self.ptr_glSamplerParameterIuiv.?(sampler, pname, param);
}
/// - **Available since:** OpenGL 3.3
pub fn getSamplerParameteriv(self: *const GL, sampler: UInt, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetSamplerParameteriv.?(sampler, pname, params);
}
/// - **Available since:** OpenGL 3.3
pub fn getSamplerParameterIiv(self: *const GL, sampler: UInt, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetSamplerParameterIiv.?(sampler, pname, params);
}
/// - **Available since:** OpenGL 3.3
pub fn getSamplerParameterfv(self: *const GL, sampler: UInt, pname: Enum, params: [*]Float) void {
    return self.ptr_glGetSamplerParameterfv.?(sampler, pname, params);
}
/// - **Available since:** OpenGL 3.3
pub fn getSamplerParameterIuiv(self: *const GL, sampler: UInt, pname: Enum, params: [*]UInt) void {
    return self.ptr_glGetSamplerParameterIuiv.?(sampler, pname, params);
}
/// - **Available since:** OpenGL 3.3
pub fn queryCounter(self: *const GL, id: UInt, target: Enum) void {
    return self.ptr_glQueryCounter.?(id, target);
}
/// - **Available since:** OpenGL 3.3
pub fn getQueryObjecti64v(self: *const GL, id: UInt, pname: Enum, params: [*]Int64) void {
    return self.ptr_glGetQueryObjecti64v.?(id, pname, params);
}
/// - **Available since:** OpenGL 3.3
pub fn getQueryObjectui64v(self: *const GL, id: UInt, pname: Enum, params: [*]UInt64) void {
    return self.ptr_glGetQueryObjectui64v.?(id, pname, params);
}
/// - **Available since:** OpenGL 3.3
pub fn vertexAttribDivisor(self: *const GL, _index: UInt, divisor: UInt) void {
    return self.ptr_glVertexAttribDivisor.?(_index, divisor);
}
/// - **Available since:** OpenGL 3.3
pub fn vertexAttribP1ui(self: *const GL, _index: UInt, @"type": Enum, normalized: bool, value: UInt) void {
    return self.ptr_glVertexAttribP1ui.?(_index, @"type", normalized, value);
}
/// - **Available since:** OpenGL 3.3
pub fn vertexAttribP1uiv(self: *const GL, _index: UInt, @"type": Enum, normalized: bool, value: *const UInt) void {
    return self.ptr_glVertexAttribP1uiv.?(_index, @"type", normalized, value);
}
/// - **Available since:** OpenGL 3.3
pub fn vertexAttribP2ui(self: *const GL, _index: UInt, @"type": Enum, normalized: bool, value: UInt) void {
    return self.ptr_glVertexAttribP2ui.?(_index, @"type", normalized, value);
}
/// - **Available since:** OpenGL 3.3
pub fn vertexAttribP2uiv(self: *const GL, _index: UInt, @"type": Enum, normalized: bool, value: *const [2]UInt) void {
    return self.ptr_glVertexAttribP2uiv.?(_index, @"type", normalized, value);
}
/// - **Available since:** OpenGL 3.3
pub fn vertexAttribP3ui(self: *const GL, _index: UInt, @"type": Enum, normalized: bool, value: UInt) void {
    return self.ptr_glVertexAttribP3ui.?(_index, @"type", normalized, value);
}
/// - **Available since:** OpenGL 3.3
pub fn vertexAttribP3uiv(self: *const GL, _index: UInt, @"type": Enum, normalized: bool, value: *const [3]UInt) void {
    return self.ptr_glVertexAttribP3uiv.?(_index, @"type", normalized, value);
}
/// - **Available since:** OpenGL 3.3
pub fn vertexAttribP4ui(self: *const GL, _index: UInt, @"type": Enum, normalized: bool, value: UInt) void {
    return self.ptr_glVertexAttribP4ui.?(_index, @"type", normalized, value);
}
/// - **Available since:** OpenGL 3.3
pub fn vertexAttribP4uiv(self: *const GL, _index: UInt, @"type": Enum, normalized: bool, value: *const [4]UInt) void {
    return self.ptr_glVertexAttribP4uiv.?(_index, @"type", normalized, value);
}
/// - **Available since:** OpenGL 3.3
pub fn vertexP2ui(self: *const GL, @"type": Enum, value: UInt) void {
    return self.ptr_glVertexP2ui.?(@"type", value);
}
/// - **Available since:** OpenGL 3.3
pub fn vertexP2uiv(self: *const GL, @"type": Enum, value: *const [2]UInt) void {
    return self.ptr_glVertexP2uiv.?(@"type", value);
}
/// - **Available since:** OpenGL 3.3
pub fn vertexP3ui(self: *const GL, @"type": Enum, value: UInt) void {
    return self.ptr_glVertexP3ui.?(@"type", value);
}
/// - **Available since:** OpenGL 3.3
pub fn vertexP3uiv(self: *const GL, @"type": Enum, value: *const [3]UInt) void {
    return self.ptr_glVertexP3uiv.?(@"type", value);
}
/// - **Available since:** OpenGL 3.3
pub fn vertexP4ui(self: *const GL, @"type": Enum, value: UInt) void {
    return self.ptr_glVertexP4ui.?(@"type", value);
}
/// - **Available since:** OpenGL 3.3
pub fn vertexP4uiv(self: *const GL, @"type": Enum, value: *const [4]UInt) void {
    return self.ptr_glVertexP4uiv.?(@"type", value);
}
/// - **Available since:** OpenGL 3.3
pub fn texCoordP1ui(self: *const GL, @"type": Enum, coords: UInt) void {
    return self.ptr_glTexCoordP1ui.?(@"type", coords);
}
/// - **Available since:** OpenGL 3.3
pub fn texCoordP1uiv(self: *const GL, @"type": Enum, coords: *const UInt) void {
    return self.ptr_glTexCoordP1uiv.?(@"type", coords);
}
/// - **Available since:** OpenGL 3.3
pub fn texCoordP2ui(self: *const GL, @"type": Enum, coords: UInt) void {
    return self.ptr_glTexCoordP2ui.?(@"type", coords);
}
/// - **Available since:** OpenGL 3.3
pub fn texCoordP2uiv(self: *const GL, @"type": Enum, coords: *const [2]UInt) void {
    return self.ptr_glTexCoordP2uiv.?(@"type", coords);
}
/// - **Available since:** OpenGL 3.3
pub fn texCoordP3ui(self: *const GL, @"type": Enum, coords: UInt) void {
    return self.ptr_glTexCoordP3ui.?(@"type", coords);
}
/// - **Available since:** OpenGL 3.3
pub fn texCoordP3uiv(self: *const GL, @"type": Enum, coords: *const [3]UInt) void {
    return self.ptr_glTexCoordP3uiv.?(@"type", coords);
}
/// - **Available since:** OpenGL 3.3
pub fn texCoordP4ui(self: *const GL, @"type": Enum, coords: UInt) void {
    return self.ptr_glTexCoordP4ui.?(@"type", coords);
}
/// - **Available since:** OpenGL 3.3
pub fn texCoordP4uiv(self: *const GL, @"type": Enum, coords: *const [4]UInt) void {
    return self.ptr_glTexCoordP4uiv.?(@"type", coords);
}
/// - **Available since:** OpenGL 3.3
pub fn multiTexCoordP1ui(self: *const GL, texture: Enum, @"type": Enum, coords: UInt) void {
    return self.ptr_glMultiTexCoordP1ui.?(texture, @"type", coords);
}
/// - **Available since:** OpenGL 3.3
pub fn multiTexCoordP1uiv(self: *const GL, texture: Enum, @"type": Enum, coords: *const UInt) void {
    return self.ptr_glMultiTexCoordP1uiv.?(texture, @"type", coords);
}
/// - **Available since:** OpenGL 3.3
pub fn multiTexCoordP2ui(self: *const GL, texture: Enum, @"type": Enum, coords: UInt) void {
    return self.ptr_glMultiTexCoordP2ui.?(texture, @"type", coords);
}
/// - **Available since:** OpenGL 3.3
pub fn multiTexCoordP2uiv(self: *const GL, texture: Enum, @"type": Enum, coords: *const [2]UInt) void {
    return self.ptr_glMultiTexCoordP2uiv.?(texture, @"type", coords);
}
/// - **Available since:** OpenGL 3.3
pub fn multiTexCoordP3ui(self: *const GL, texture: Enum, @"type": Enum, coords: UInt) void {
    return self.ptr_glMultiTexCoordP3ui.?(texture, @"type", coords);
}
/// - **Available since:** OpenGL 3.3
pub fn multiTexCoordP3uiv(self: *const GL, texture: Enum, @"type": Enum, coords: *const [3]UInt) void {
    return self.ptr_glMultiTexCoordP3uiv.?(texture, @"type", coords);
}
/// - **Available since:** OpenGL 3.3
pub fn multiTexCoordP4ui(self: *const GL, texture: Enum, @"type": Enum, coords: UInt) void {
    return self.ptr_glMultiTexCoordP4ui.?(texture, @"type", coords);
}
/// - **Available since:** OpenGL 3.3
pub fn multiTexCoordP4uiv(self: *const GL, texture: Enum, @"type": Enum, coords: *const [4]UInt) void {
    return self.ptr_glMultiTexCoordP4uiv.?(texture, @"type", coords);
}
/// - **Available since:** OpenGL 3.3
pub fn normalP3ui(self: *const GL, @"type": Enum, coords: UInt) void {
    return self.ptr_glNormalP3ui.?(@"type", coords);
}
/// - **Available since:** OpenGL 3.3
pub fn normalP3uiv(self: *const GL, @"type": Enum, coords: *const [3]UInt) void {
    return self.ptr_glNormalP3uiv.?(@"type", coords);
}
/// - **Available since:** OpenGL 3.3
pub fn colorP3ui(self: *const GL, @"type": Enum, color: UInt) void {
    return self.ptr_glColorP3ui.?(@"type", color);
}
/// - **Available since:** OpenGL 3.3
pub fn colorP3uiv(self: *const GL, @"type": Enum, color: *const [3]UInt) void {
    return self.ptr_glColorP3uiv.?(@"type", color);
}
/// - **Available since:** OpenGL 3.3
pub fn colorP4ui(self: *const GL, @"type": Enum, color: UInt) void {
    return self.ptr_glColorP4ui.?(@"type", color);
}
/// - **Available since:** OpenGL 3.3
pub fn colorP4uiv(self: *const GL, @"type": Enum, color: *const [4]UInt) void {
    return self.ptr_glColorP4uiv.?(@"type", color);
}
/// - **Available since:** OpenGL 3.3
pub fn secondaryColorP3ui(self: *const GL, @"type": Enum, color: UInt) void {
    return self.ptr_glSecondaryColorP3ui.?(@"type", color);
}
/// - **Available since:** OpenGL 3.3
pub fn secondaryColorP3uiv(self: *const GL, @"type": Enum, color: *const [3]UInt) void {
    return self.ptr_glSecondaryColorP3uiv.?(@"type", color);
}
//#endregion

//#region OpenGL 4.0
/// - **Available since:** OpenGL 4.0
pub fn minSampleShading(self: *const GL, value: Float) void {
    return self.ptr_glMinSampleShading.?(value);
}
/// - **Available since:** OpenGL 4.0
pub fn blendEquationi(self: *const GL, buf: UInt, mode: Enum) void {
    return self.ptr_glBlendEquationi.?(buf, mode);
}
/// - **Available since:** OpenGL 4.0
pub fn blendEquationSeparatei(self: *const GL, buf: UInt, modeRGB: Enum, modeAlpha: Enum) void {
    return self.ptr_glBlendEquationSeparatei.?(buf, modeRGB, modeAlpha);
}
/// - **Available since:** OpenGL 4.0
pub fn blendFunci(self: *const GL, buf: UInt, src: Enum, dst: Enum) void {
    return self.ptr_glBlendFunci.?(buf, src, dst);
}
/// - **Available since:** OpenGL 4.0
pub fn blendFuncSeparatei(self: *const GL, buf: UInt, srcRGB: Enum, dstRGB: Enum, srcAlpha: Enum, dstAlpha: Enum) void {
    return self.ptr_glBlendFuncSeparatei.?(buf, srcRGB, dstRGB, srcAlpha, dstAlpha);
}
/// - **Available since:** OpenGL 4.0
pub fn drawArraysIndirect(self: *const GL, mode: Enum, indirect: ?*const anyopaque) void {
    return self.ptr_glDrawArraysIndirect.?(mode, indirect);
}
/// - **Available since:** OpenGL 4.0
pub fn drawElementsIndirect(self: *const GL, mode: Enum, @"type": Enum, indirect: ?*const anyopaque) void {
    return self.ptr_glDrawElementsIndirect.?(mode, @"type", indirect);
}
/// - **Available since:** OpenGL 4.0
pub fn uniform1d(self: *const GL, location: Int, x: Double) void {
    return self.ptr_glUniform1d.?(location, x);
}
/// - **Available since:** OpenGL 4.0
pub fn uniform2d(self: *const GL, location: Int, x: Double, y: Double) void {
    return self.ptr_glUniform2d.?(location, x, y);
}
/// - **Available since:** OpenGL 4.0
pub fn uniform3d(self: *const GL, location: Int, x: Double, y: Double, z: Double) void {
    return self.ptr_glUniform3d.?(location, x, y, z);
}
/// - **Available since:** OpenGL 4.0
pub fn uniform4d(self: *const GL, location: Int, x: Double, y: Double, z: Double, w: Double) void {
    return self.ptr_glUniform4d.?(location, x, y, z, w);
}
/// - **Available since:** OpenGL 4.0
pub fn uniform1dv(self: *const GL, location: Int, count: Sizei, value: [*]const Double) void {
    return self.ptr_glUniform1dv.?(location, count, value);
}
/// - **Available since:** OpenGL 4.0
pub fn uniform2dv(self: *const GL, location: Int, count: Sizei, value: [*]const [2]Double) void {
    return self.ptr_glUniform2dv.?(location, count, value);
}
/// - **Available since:** OpenGL 4.0
pub fn uniform3dv(self: *const GL, location: Int, count: Sizei, value: [*]const [3]Double) void {
    return self.ptr_glUniform3dv.?(location, count, value);
}
/// - **Available since:** OpenGL 4.0
pub fn uniform4dv(self: *const GL, location: Int, count: Sizei, value: [*]const [4]Double) void {
    return self.ptr_glUniform4dv.?(location, count, value);
}
/// - **Available since:** OpenGL 4.0
pub fn uniformMatrix2dv(self: *const GL, location: Int, count: Sizei, transpose: bool, value: [*]const [2 * 2]Double) void {
    return self.ptr_glUniformMatrix2dv.?(location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.0
pub fn uniformMatrix3dv(self: *const GL, location: Int, count: Sizei, transpose: bool, value: [*]const [3 * 3]Double) void {
    return self.ptr_glUniformMatrix3dv.?(location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.0
pub fn uniformMatrix4dv(self: *const GL, location: Int, count: Sizei, transpose: bool, value: [*]const [4 * 4]Double) void {
    return self.ptr_glUniformMatrix4dv.?(location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.0
pub fn uniformMatrix2x3dv(self: *const GL, location: Int, count: Sizei, transpose: bool, value: [*]const [2 * 3]Double) void {
    return self.ptr_glUniformMatrix2x3dv.?(location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.0
pub fn uniformMatrix2x4dv(self: *const GL, location: Int, count: Sizei, transpose: bool, value: [*]const [2 * 4]Double) void {
    return self.ptr_glUniformMatrix2x4dv.?(location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.0
pub fn uniformMatrix3x2dv(self: *const GL, location: Int, count: Sizei, transpose: bool, value: [*]const [3 * 2]Double) void {
    return self.ptr_glUniformMatrix3x2dv.?(location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.0
pub fn uniformMatrix3x4dv(self: *const GL, location: Int, count: Sizei, transpose: bool, value: [*]const [3 * 4]Double) void {
    return self.ptr_glUniformMatrix3x4dv.?(location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.0
pub fn uniformMatrix4x2dv(self: *const GL, location: Int, count: Sizei, transpose: bool, value: [*]const [4 * 2]Double) void {
    return self.ptr_glUniformMatrix4x2dv.?(location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.0
pub fn uniformMatrix4x3dv(self: *const GL, location: Int, count: Sizei, transpose: bool, value: [*]const [4 * 3]Double) void {
    return self.ptr_glUniformMatrix4x3dv.?(location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.0
pub fn getUniformdv(self: *const GL, program: UInt, location: Int, params: [*]Double) void {
    return self.ptr_glGetUniformdv.?(program, location, params);
}
/// - **Available since:** OpenGL 4.0
pub fn getSubroutineUniformLocation(self: *const GL, program: UInt, shadertype: Enum, name: [*:0]const Char) Int {
    return self.ptr_glGetSubroutineUniformLocation.?(program, shadertype, name);
}
/// - **Available since:** OpenGL 4.0
pub fn getSubroutineIndex(self: *const GL, program: UInt, shadertype: Enum, name: [*:0]const Char) UInt {
    return self.ptr_glGetSubroutineIndex.?(program, shadertype, name);
}
/// - **Available since:** OpenGL 4.0
pub fn getActiveSubroutineUniformiv(self: *const GL, program: UInt, shadertype: Enum, _index: UInt, pname: Enum, values: [*]Int) void {
    return self.ptr_glGetActiveSubroutineUniformiv.?(program, shadertype, _index, pname, values);
}
/// - **Available since:** OpenGL 4.0
pub fn getActiveSubroutineUniformName(self: *const GL, program: UInt, shadertype: Enum, _index: UInt, bufSize: Sizei, length: ?*Sizei, name: [*]Char) void {
    return self.ptr_glGetActiveSubroutineUniformName.?(program, shadertype, _index, bufSize, length, name);
}
/// - **Available since:** OpenGL 4.0
pub fn getActiveSubroutineName(self: *const GL, program: UInt, shadertype: Enum, _index: UInt, bufSize: Sizei, length: ?*Sizei, name: [*]Char) void {
    return self.ptr_glGetActiveSubroutineName.?(program, shadertype, _index, bufSize, length, name);
}
/// - **Available since:** OpenGL 4.0
pub fn uniformSubroutinesuiv(self: *const GL, shadertype: Enum, count: Sizei, indices: [*]const UInt) void {
    return self.ptr_glUniformSubroutinesuiv.?(shadertype, count, indices);
}
/// - **Available since:** OpenGL 4.0
pub fn getUniformSubroutineuiv(self: *const GL, shadertype: Enum, location: Int, params: [*]UInt) void {
    return self.ptr_glGetUniformSubroutineuiv.?(shadertype, location, params);
}
/// - **Available since:** OpenGL 4.0
pub fn getProgramStageiv(self: *const GL, program: UInt, shadertype: Enum, pname: Enum, values: [*]Int) void {
    return self.ptr_glGetProgramStageiv.?(program, shadertype, pname, values);
}
/// - **Available since:** OpenGL 4.0
pub fn patchParameteri(self: *const GL, pname: Enum, value: Int) void {
    return self.ptr_glPatchParameteri.?(pname, value);
}
/// - **Available since:** OpenGL 4.0
pub fn patchParameterfv(self: *const GL, pname: Enum, values: [*]const Float) void {
    return self.ptr_glPatchParameterfv.?(pname, values);
}
/// - **Available since:** OpenGL 4.0
pub fn bindTransformFeedback(self: *const GL, target: Enum, id: UInt) void {
    return self.ptr_glBindTransformFeedback.?(target, id);
}
/// - **Available since:** OpenGL 4.0
pub fn deleteTransformFeedbacks(self: *const GL, n: Sizei, ids: [*]const UInt) void {
    return self.ptr_glDeleteTransformFeedbacks.?(n, ids);
}
/// - **Available since:** OpenGL 4.0
pub fn genTransformFeedbacks(self: *const GL, n: Sizei, ids: [*]UInt) void {
    return self.ptr_glGenTransformFeedbacks.?(n, ids);
}
/// - **Available since:** OpenGL 4.0
pub fn isTransformFeedback(self: *const GL, id: UInt) bool {
    return self.ptr_glIsTransformFeedback.?(id);
}
/// - **Available since:** OpenGL 4.0
pub fn pauseTransformFeedback(self: *const GL) void {
    return self.ptr_glPauseTransformFeedback.?();
}
/// - **Available since:** OpenGL 4.0
pub fn resumeTransformFeedback(self: *const GL) void {
    return self.ptr_glResumeTransformFeedback.?();
}
/// - **Available since:** OpenGL 4.0
pub fn drawTransformFeedback(self: *const GL, mode: Enum, id: UInt) void {
    return self.ptr_glDrawTransformFeedback.?(mode, id);
}
/// - **Available since:** OpenGL 4.0
pub fn drawTransformFeedbackStream(self: *const GL, mode: Enum, id: UInt, stream: UInt) void {
    return self.ptr_glDrawTransformFeedbackStream.?(mode, id, stream);
}
/// - **Available since:** OpenGL 4.0
pub fn beginQueryIndexed(self: *const GL, target: Enum, _index: UInt, id: UInt) void {
    return self.ptr_glBeginQueryIndexed.?(target, _index, id);
}
/// - **Available since:** OpenGL 4.0
pub fn endQueryIndexed(self: *const GL, target: Enum, _index: UInt) void {
    return self.ptr_glEndQueryIndexed.?(target, _index);
}
/// - **Available since:** OpenGL 4.0
pub fn getQueryIndexediv(self: *const GL, target: Enum, _index: UInt, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetQueryIndexediv.?(target, _index, pname, params);
}
//#endregion
//#region OpenGL 4.1
/// - **Available since:** OpenGL 4.1
pub fn releaseShaderCompiler(self: *const GL) void {
    return self.ptr_glReleaseShaderCompiler.?();
}
/// - **Available since:** OpenGL 4.1
pub fn shaderBinary(self: *const GL, count: Sizei, shaders: [*]const UInt, binaryFormat: Enum, binary: ?*const anyopaque, length: Sizei) void {
    return self.ptr_glShaderBinary.?(count, shaders, binaryFormat, binary, length);
}
/// - **Available since:** OpenGL 4.1
pub fn getShaderPrecisionFormat(self: *const GL, shadertype: Enum, precisiontype: Enum, range: *Int, precision: *Int) void {
    return self.ptr_glGetShaderPrecisionFormat.?(shadertype, precisiontype, range, precision);
}
/// - **Available since:** OpenGL 4.1
pub fn depthRangef(self: *const GL, n: Float, f: Float) void {
    return self.ptr_glDepthRangef.?(n, f);
}
/// - **Available since:** OpenGL 4.1
pub fn clearDepthf(self: *const GL, d: Float) void {
    return self.ptr_glClearDepthf.?(d);
}
/// - **Available since:** OpenGL 4.1
pub fn getProgramBinary(self: *const GL, program: UInt, bufSize: Sizei, length: ?*Sizei, binaryFormat: [*]Enum, binary: ?*anyopaque) void {
    return self.ptr_glGetProgramBinary.?(program, bufSize, length, binaryFormat, binary);
}
/// - **Available since:** OpenGL 4.1
pub fn programBinary(self: *const GL, program: UInt, binaryFormat: Enum, binary: ?*const anyopaque, length: Sizei) void {
    return self.ptr_glProgramBinary.?(program, binaryFormat, binary, length);
}
/// - **Available since:** OpenGL 4.1
pub fn programParameteri(self: *const GL, program: UInt, pname: Enum, value: Int) void {
    return self.ptr_glProgramParameteri.?(program, pname, value);
}
/// - **Available since:** OpenGL 4.1
pub fn useProgramStages(self: *const GL, pipeline: UInt, stages: Bitfield, program: UInt) void {
    return self.ptr_glUseProgramStages.?(pipeline, stages, program);
}
/// - **Available since:** OpenGL 4.1
pub fn activeShaderProgram(self: *const GL, pipeline: UInt, program: UInt) void {
    return self.ptr_glActiveShaderProgram.?(pipeline, program);
}
/// - **Available since:** OpenGL 4.1
pub fn createShaderProgramv(self: *const GL, @"type": Enum, count: Sizei, strings: [*]const [*:0]const Char) UInt {
    return self.ptr_glCreateShaderProgramv.?(@"type", count, strings);
}
/// - **Available since:** OpenGL 4.1
pub fn bindProgramPipeline(self: *const GL, pipeline: UInt) void {
    return self.ptr_glBindProgramPipeline.?(pipeline);
}
/// - **Available since:** OpenGL 4.1
pub fn deleteProgramPipelines(self: *const GL, n: Sizei, pipelines: [*]const UInt) void {
    return self.ptr_glDeleteProgramPipelines.?(n, pipelines);
}
/// - **Available since:** OpenGL 4.1
pub fn genProgramPipelines(self: *const GL, n: Sizei, pipelines: [*]UInt) void {
    return self.ptr_glGenProgramPipelines.?(n, pipelines);
}
/// - **Available since:** OpenGL 4.1
pub fn isProgramPipeline(self: *const GL, pipeline: UInt) bool {
    return self.ptr_glIsProgramPipeline.?(pipeline);
}
/// - **Available since:** OpenGL 4.1
pub fn getProgramPipelineiv(self: *const GL, pipeline: UInt, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetProgramPipelineiv.?(pipeline, pname, params);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform1i(self: *const GL, program: UInt, location: Int, v0: Int) void {
    return self.ptr_glProgramUniform1i.?(program, location, v0);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform1iv(self: *const GL, program: UInt, location: Int, count: Sizei, value: [*]const Int) void {
    return self.ptr_glProgramUniform1iv.?(program, location, count, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform1f(self: *const GL, program: UInt, location: Int, v0: Float) void {
    return self.ptr_glProgramUniform1f.?(program, location, v0);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform1fv(self: *const GL, program: UInt, location: Int, count: Sizei, value: [*]const Float) void {
    return self.ptr_glProgramUniform1fv.?(program, location, count, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform1d(self: *const GL, program: UInt, location: Int, v0: Double) void {
    return self.ptr_glProgramUniform1d.?(program, location, v0);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform1dv(self: *const GL, program: UInt, location: Int, count: Sizei, value: [*]const Double) void {
    return self.ptr_glProgramUniform1dv.?(program, location, count, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform1ui(self: *const GL, program: UInt, location: Int, v0: UInt) void {
    return self.ptr_glProgramUniform1ui.?(program, location, v0);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform1uiv(self: *const GL, program: UInt, location: Int, count: Sizei, value: [*]const UInt) void {
    return self.ptr_glProgramUniform1uiv.?(program, location, count, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform2i(self: *const GL, program: UInt, location: Int, v0: Int, v1: Int) void {
    return self.ptr_glProgramUniform2i.?(program, location, v0, v1);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform2iv(self: *const GL, program: UInt, location: Int, count: Sizei, value: [*]const [2]Int) void {
    return self.ptr_glProgramUniform2iv.?(program, location, count, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform2f(self: *const GL, program: UInt, location: Int, v0: Float, v1: Float) void {
    return self.ptr_glProgramUniform2f.?(program, location, v0, v1);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform2fv(self: *const GL, program: UInt, location: Int, count: Sizei, value: [*]const [2]Float) void {
    return self.ptr_glProgramUniform2fv.?(program, location, count, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform2d(self: *const GL, program: UInt, location: Int, v0: Double, v1: Double) void {
    return self.ptr_glProgramUniform2d.?(program, location, v0, v1);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform2dv(self: *const GL, program: UInt, location: Int, count: Sizei, value: [*]const [2]Double) void {
    return self.ptr_glProgramUniform2dv.?(program, location, count, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform2ui(self: *const GL, program: UInt, location: Int, v0: UInt, v1: UInt) void {
    return self.ptr_glProgramUniform2ui.?(program, location, v0, v1);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform2uiv(self: *const GL, program: UInt, location: Int, count: Sizei, value: [*]const [2]UInt) void {
    return self.ptr_glProgramUniform2uiv.?(program, location, count, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform3i(self: *const GL, program: UInt, location: Int, v0: Int, v1: Int, v2: Int) void {
    return self.ptr_glProgramUniform3i.?(program, location, v0, v1, v2);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform3iv(self: *const GL, program: UInt, location: Int, count: Sizei, value: [*]const [3]Int) void {
    return self.ptr_glProgramUniform3iv.?(program, location, count, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform3f(self: *const GL, program: UInt, location: Int, v0: Float, v1: Float, v2: Float) void {
    return self.ptr_glProgramUniform3f.?(program, location, v0, v1, v2);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform3fv(self: *const GL, program: UInt, location: Int, count: Sizei, value: [*]const [3]Float) void {
    return self.ptr_glProgramUniform3fv.?(program, location, count, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform3d(self: *const GL, program: UInt, location: Int, v0: Double, v1: Double, v2: Double) void {
    return self.ptr_glProgramUniform3d.?(program, location, v0, v1, v2);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform3dv(self: *const GL, program: UInt, location: Int, count: Sizei, value: [*]const [3]Double) void {
    return self.ptr_glProgramUniform3dv.?(program, location, count, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform3ui(self: *const GL, program: UInt, location: Int, v0: UInt, v1: UInt, v2: UInt) void {
    return self.ptr_glProgramUniform3ui.?(program, location, v0, v1, v2);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform3uiv(self: *const GL, program: UInt, location: Int, count: Sizei, value: [*]const [3]UInt) void {
    return self.ptr_glProgramUniform3uiv.?(program, location, count, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform4i(self: *const GL, program: UInt, location: Int, v0: Int, v1: Int, v2: Int, v3: Int) void {
    return self.ptr_glProgramUniform4i.?(program, location, v0, v1, v2, v3);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform4iv(self: *const GL, program: UInt, location: Int, count: Sizei, value: [*]const [4]Int) void {
    return self.ptr_glProgramUniform4iv.?(program, location, count, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform4f(self: *const GL, program: UInt, location: Int, v0: Float, v1: Float, v2: Float, v3: Float) void {
    return self.ptr_glProgramUniform4f.?(program, location, v0, v1, v2, v3);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform4fv(self: *const GL, program: UInt, location: Int, count: Sizei, value: [*]const [4]Float) void {
    return self.ptr_glProgramUniform4fv.?(program, location, count, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform4d(self: *const GL, program: UInt, location: Int, v0: Double, v1: Double, v2: Double, v3: Double) void {
    return self.ptr_glProgramUniform4d.?(program, location, v0, v1, v2, v3);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform4dv(self: *const GL, program: UInt, location: Int, count: Sizei, value: [*]const [4]Double) void {
    return self.ptr_glProgramUniform4dv.?(program, location, count, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform4ui(self: *const GL, program: UInt, location: Int, v0: UInt, v1: UInt, v2: UInt, v3: UInt) void {
    return self.ptr_glProgramUniform4ui.?(program, location, v0, v1, v2, v3);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniform4uiv(self: *const GL, program: UInt, location: Int, count: Sizei, value: [*]const [4]UInt) void {
    return self.ptr_glProgramUniform4uiv.?(program, location, count, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniformMatrix2fv(self: *const GL, program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [2]Float) void {
    return self.ptr_glProgramUniformMatrix2fv.?(program, location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniformMatrix3fv(self: *const GL, program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [3]Float) void {
    return self.ptr_glProgramUniformMatrix3fv.?(program, location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniformMatrix4fv(self: *const GL, program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [4]Float) void {
    return self.ptr_glProgramUniformMatrix4fv.?(program, location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniformMatrix2dv(self: *const GL, program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [2]Double) void {
    return self.ptr_glProgramUniformMatrix2dv.?(program, location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniformMatrix3dv(self: *const GL, program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [3]Double) void {
    return self.ptr_glProgramUniformMatrix3dv.?(program, location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniformMatrix4dv(self: *const GL, program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [4]Double) void {
    return self.ptr_glProgramUniformMatrix4dv.?(program, location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniformMatrix2x3fv(self: *const GL, program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [2 * 3]Float) void {
    return self.ptr_glProgramUniformMatrix2x3fv.?(program, location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniformMatrix3x2fv(self: *const GL, program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [3 * 2]Float) void {
    return self.ptr_glProgramUniformMatrix3x2fv.?(program, location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniformMatrix2x4fv(self: *const GL, program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [2 * 4]Float) void {
    return self.ptr_glProgramUniformMatrix2x4fv.?(program, location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniformMatrix4x2fv(self: *const GL, program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [4 * 2]Float) void {
    return self.ptr_glProgramUniformMatrix4x2fv.?(program, location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniformMatrix3x4fv(self: *const GL, program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [3 * 4]Float) void {
    return self.ptr_glProgramUniformMatrix3x4fv.?(program, location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniformMatrix4x3fv(self: *const GL, program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [4 * 3]Float) void {
    return self.ptr_glProgramUniformMatrix4x3fv.?(program, location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniformMatrix2x3dv(self: *const GL, program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [2 * 3]Double) void {
    return self.ptr_glProgramUniformMatrix2x3dv.?(program, location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniformMatrix3x2dv(self: *const GL, program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [3 * 2]Double) void {
    return self.ptr_glProgramUniformMatrix3x2dv.?(program, location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniformMatrix2x4dv(self: *const GL, program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [2 * 4]Double) void {
    return self.ptr_glProgramUniformMatrix2x4dv.?(program, location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniformMatrix4x2dv(self: *const GL, program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [4 * 2]Double) void {
    return self.ptr_glProgramUniformMatrix4x2dv.?(program, location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniformMatrix3x4dv(self: *const GL, program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [3 * 4]Double) void {
    return self.ptr_glProgramUniformMatrix3x4dv.?(program, location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.1
pub fn programUniformMatrix4x3dv(self: *const GL, program: UInt, location: Int, count: Sizei, transpose: bool, value: [*]const [4 * 3]Double) void {
    return self.ptr_glProgramUniformMatrix4x3dv.?(program, location, count, transpose, value);
}
/// - **Available since:** OpenGL 4.1
pub fn validateProgramPipeline(self: *const GL, pipeline: UInt) void {
    return self.ptr_glValidateProgramPipeline.?(pipeline);
}
/// - **Available since:** OpenGL 4.1
pub fn getProgramPipelineInfoLog(self: *const GL, pipeline: UInt, bufSize: Sizei, length: ?*Sizei, infoLog: [*]Char) void {
    return self.ptr_glGetProgramPipelineInfoLog.?(pipeline, bufSize, length, infoLog);
}
/// - **Available since:** OpenGL 4.1
pub fn vertexAttribL1d(self: *const GL, _index: UInt, x: Double) void {
    return self.ptr_glVertexAttribL1d.?(_index, x);
}
/// - **Available since:** OpenGL 4.1
pub fn vertexAttribL2d(self: *const GL, _index: UInt, x: Double, y: Double) void {
    return self.ptr_glVertexAttribL2d.?(_index, x, y);
}
/// - **Available since:** OpenGL 4.1
pub fn vertexAttribL3d(self: *const GL, _index: UInt, x: Double, y: Double, z: Double) void {
    return self.ptr_glVertexAttribL3d.?(_index, x, y, z);
}
/// - **Available since:** OpenGL 4.1
pub fn vertexAttribL4d(self: *const GL, _index: UInt, x: Double, y: Double, z: Double, w: Double) void {
    return self.ptr_glVertexAttribL4d.?(_index, x, y, z, w);
}
/// - **Available since:** OpenGL 4.1
pub fn vertexAttribL1dv(self: *const GL, _index: UInt, v: *const Double) void {
    return self.ptr_glVertexAttribL1dv.?(_index, v);
}
/// - **Available since:** OpenGL 4.1
pub fn vertexAttribL2dv(self: *const GL, _index: UInt, v: *const [2]Double) void {
    return self.ptr_glVertexAttribL2dv.?(_index, v);
}
/// - **Available since:** OpenGL 4.1
pub fn vertexAttribL3dv(self: *const GL, _index: UInt, v: *const [3]Double) void {
    return self.ptr_glVertexAttribL3dv.?(_index, v);
}
/// - **Available since:** OpenGL 4.1
pub fn vertexAttribL4dv(self: *const GL, _index: UInt, v: *const [4]Double) void {
    return self.ptr_glVertexAttribL4dv.?(_index, v);
}
/// - **Available since:** OpenGL 4.1
pub fn vertexAttribLPointer(self: *const GL, _index: UInt, size: Int, @"type": Enum, stride: Sizei, pointer: usize) void {
    return self.ptr_glVertexAttribLPointer.?(_index, size, @"type", stride, pointer);
}
/// - **Available since:** OpenGL 4.1
pub fn getVertexAttribLdv(self: *const GL, _index: UInt, pname: Enum, params: [*]Double) void {
    return self.ptr_glGetVertexAttribLdv.?(_index, pname, params);
}
/// - **Available since:** OpenGL 4.1
pub fn viewportArrayv(self: *const GL, first: UInt, count: Sizei, v: [*]const [4]Float) void {
    return self.ptr_glViewportArrayv.?(first, count, v);
}
/// - **Available since:** OpenGL 4.1
pub fn viewportIndexedf(self: *const GL, _index: UInt, x: Float, y: Float, w: Float, h: Float) void {
    return self.ptr_glViewportIndexedf.?(_index, x, y, w, h);
}
/// - **Available since:** OpenGL 4.1
pub fn viewportIndexedfv(self: *const GL, _index: UInt, v: [*]const [4]Float) void {
    return self.ptr_glViewportIndexedfv.?(_index, v);
}
/// - **Available since:** OpenGL 4.1
pub fn scissorArrayv(self: *const GL, first: UInt, count: Sizei, v: [*]const [4]Int) void {
    return self.ptr_glScissorArrayv.?(first, count, v);
}
/// - **Available since:** OpenGL 4.1
pub fn scissorIndexed(self: *const GL, _index: UInt, left: Int, bottom: Int, width: Sizei, height: Sizei) void {
    return self.ptr_glScissorIndexed.?(_index, left, bottom, width, height);
}
/// - **Available since:** OpenGL 4.1
pub fn scissorIndexedv(self: *const GL, _index: UInt, v: [*]const [4]Int) void {
    return self.ptr_glScissorIndexedv.?(_index, v);
}
/// - **Available since:** OpenGL 4.1
pub fn depthRangeArrayv(self: *const GL, first: UInt, count: Sizei, v: [*]const [2]Double) void {
    return self.ptr_glDepthRangeArrayv.?(first, count, v);
}
/// - **Available since:** OpenGL 4.1
pub fn depthRangeIndexed(self: *const GL, _index: UInt, n: Double, f: Double) void {
    return self.ptr_glDepthRangeIndexed.?(_index, n, f);
}
/// - **Available since:** OpenGL 4.1
pub fn getFloati_v(self: *const GL, target: Enum, _index: UInt, data: [*]Float) void {
    return self.ptr_glGetFloati_v.?(target, _index, data);
}
/// - **Available since:** OpenGL 4.1
pub fn getDoublei_v(self: *const GL, target: Enum, _index: UInt, data: [*]Double) void {
    return self.ptr_glGetDoublei_v.?(target, _index, data);
}
//#endregion
//#region OpenGL 4.2
/// - **Available since:** OpenGL 4.2
pub fn drawArraysInstancedBaseInstance(self: *const GL, mode: Enum, first: Int, count: Sizei, instancecount: Sizei, baseinstance: UInt) void {
    return self.ptr_glDrawArraysInstancedBaseInstance.?(mode, first, count, instancecount, baseinstance);
}
/// - **Available since:** OpenGL 4.2
pub fn drawElementsInstancedBaseInstance(self: *const GL, mode: Enum, count: Sizei, @"type": Enum, indices: usize, instancecount: Sizei, baseinstance: UInt) void {
    return self.ptr_glDrawElementsInstancedBaseInstance.?(mode, count, @"type", indices, instancecount, baseinstance);
}
/// - **Available since:** OpenGL 4.2
pub fn drawElementsInstancedBaseVertexBaseInstance(self: *const GL, mode: Enum, count: Sizei, @"type": Enum, indices: usize, instancecount: Sizei, basevertex: Int, baseinstance: UInt) void {
    return self.ptr_glDrawElementsInstancedBaseVertexBaseInstance.?(mode, count, @"type", indices, instancecount, basevertex, baseinstance);
}
/// - **Available since:** OpenGL 4.2
pub fn getInternalformativ(self: *const GL, target: Enum, internalformat: Enum, pname: Enum, count: Sizei, params: [*]Int) void {
    return self.ptr_glGetInternalformativ.?(target, internalformat, pname, count, params);
}
/// - **Available since:** OpenGL 4.2
pub fn getActiveAtomicCounterBufferiv(self: *const GL, program: UInt, bufferIndex: UInt, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetActiveAtomicCounterBufferiv.?(program, bufferIndex, pname, params);
}
/// - **Available since:** OpenGL 4.2
pub fn bindImageTexture(self: *const GL, unit: UInt, texture: UInt, level: Int, layered: bool, layer: Int, access: Enum, format: Enum) void {
    return self.ptr_glBindImageTexture.?(unit, texture, level, layered, layer, access, format);
}
/// - **Available since:** OpenGL 4.2
pub fn memoryBarrier(self: *const GL, barriers: Bitfield) void {
    return self.ptr_glMemoryBarrier.?(barriers);
}
/// - **Available since:** OpenGL 4.2
pub fn texStorage1D(self: *const GL, target: Enum, levels: Sizei, internalformat: Enum, width: Sizei) void {
    return self.ptr_glTexStorage1D.?(target, levels, internalformat, width);
}
/// - **Available since:** OpenGL 4.2
pub fn texStorage2D(self: *const GL, target: Enum, levels: Sizei, internalformat: Enum, width: Sizei, height: Sizei) void {
    return self.ptr_glTexStorage2D.?(target, levels, internalformat, width, height);
}
/// - **Available since:** OpenGL 4.2
pub fn texStorage3D(self: *const GL, target: Enum, levels: Sizei, internalformat: Enum, width: Sizei, height: Sizei, depth: Sizei) void {
    return self.ptr_glTexStorage3D.?(target, levels, internalformat, width, height, depth);
}
/// - **Available since:** OpenGL 4.2
pub fn drawTransformFeedbackInstanced(self: *const GL, mode: Enum, id: UInt, instancecount: Sizei) void {
    return self.ptr_glDrawTransformFeedbackInstanced.?(mode, id, instancecount);
}
/// - **Available since:** OpenGL 4.2
pub fn drawTransformFeedbackStreamInstanced(self: *const GL, mode: Enum, id: UInt, stream: UInt, instancecount: Sizei) void {
    return self.ptr_glDrawTransformFeedbackStreamInstanced.?(mode, id, stream, instancecount);
}
//#endregion
//#region OpenGL 4.3
/// - **Available since:** OpenGL 4.3
pub fn clearBufferData(self: *const GL, target: Enum, internalformat: Enum, format: Enum, @"type": Enum, data: ?*const anyopaque) void {
    return self.ptr_glClearBufferData.?(target, internalformat, format, @"type", data);
}
/// - **Available since:** OpenGL 4.3
pub fn clearBufferSubData(self: *const GL, target: Enum, internalformat: Enum, offset: Intptr, size: Sizeiptr, format: Enum, @"type": Enum, data: ?*const anyopaque) void {
    return self.ptr_glClearBufferSubData.?(target, internalformat, offset, size, format, @"type", data);
}
/// - **Available since:** OpenGL 4.3
pub fn dispatchCompute(self: *const GL, num_groups_x: UInt, num_groups_y: UInt, num_groups_z: UInt) void {
    return self.ptr_glDispatchCompute.?(num_groups_x, num_groups_y, num_groups_z);
}
/// - **Available since:** OpenGL 4.3
pub fn dispatchComputeIndirect(self: *const GL, indirect: Intptr) void {
    return self.ptr_glDispatchComputeIndirect.?(indirect);
}
/// - **Available since:** OpenGL 4.3
pub fn copyImageSubData(self: *const GL, srcName: UInt, srcTarget: Enum, srcLevel: Int, srcX: Int, srcY: Int, srcZ: Int, dstName: UInt, dstTarget: Enum, dstLevel: Int, dstX: Int, dstY: Int, dstZ: Int, srcWidth: Sizei, srcHeight: Sizei, srcDepth: Sizei) void {
    return self.ptr_glCopyImageSubData.?(srcName, srcTarget, srcLevel, srcX, srcY, srcZ, dstName, dstTarget, dstLevel, dstX, dstY, dstZ, srcWidth, srcHeight, srcDepth);
}
/// - **Available since:** OpenGL 4.3
pub fn framebufferParameteri(self: *const GL, target: Enum, pname: Enum, param: Int) void {
    return self.ptr_glFramebufferParameteri.?(target, pname, param);
}
/// - **Available since:** OpenGL 4.3
pub fn getFramebufferParameteriv(self: *const GL, target: Enum, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetFramebufferParameteriv.?(target, pname, params);
}
/// - **Available since:** OpenGL 4.3
pub fn getInternalformati64v(self: *const GL, target: Enum, internalformat: Enum, pname: Enum, count: Sizei, params: [*]Int64) void {
    return self.ptr_glGetInternalformati64v.?(target, internalformat, pname, count, params);
}
/// - **Available since:** OpenGL 4.3
pub fn invalidateTexSubImage(self: *const GL, texture: UInt, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, width: Sizei, height: Sizei, depth: Sizei) void {
    return self.ptr_glInvalidateTexSubImage.?(texture, level, xoffset, yoffset, zoffset, width, height, depth);
}
/// - **Available since:** OpenGL 4.3
pub fn invalidateTexImage(self: *const GL, texture: UInt, level: Int) void {
    return self.ptr_glInvalidateTexImage.?(texture, level);
}
/// - **Available since:** OpenGL 4.3
pub fn invalidateBufferSubData(self: *const GL, buffer: UInt, offset: Intptr, length: Sizeiptr) void {
    return self.ptr_glInvalidateBufferSubData.?(buffer, offset, length);
}
/// - **Available since:** OpenGL 4.3
pub fn invalidateBufferData(self: *const GL, buffer: UInt) void {
    return self.ptr_glInvalidateBufferData.?(buffer);
}
/// - **Available since:** OpenGL 4.3
pub fn invalidateFramebuffer(self: *const GL, target: Enum, numAttachments: Sizei, attachments: [*]const Enum) void {
    return self.ptr_glInvalidateFramebuffer.?(target, numAttachments, attachments);
}
/// - **Available since:** OpenGL 4.3
pub fn invalidateSubFramebuffer(self: *const GL, target: Enum, numAttachments: Sizei, attachments: [*]const Enum, x: Int, y: Int, width: Sizei, height: Sizei) void {
    return self.ptr_glInvalidateSubFramebuffer.?(target, numAttachments, attachments, x, y, width, height);
}
/// - **Available since:** OpenGL 4.3
pub fn multiDrawArraysIndirect(self: *const GL, mode: Enum, indirect: ?*const anyopaque, drawcount: Sizei, stride: Sizei) void {
    return self.ptr_glMultiDrawArraysIndirect.?(mode, indirect, drawcount, stride);
}
/// - **Available since:** OpenGL 4.3
pub fn multiDrawElementsIndirect(self: *const GL, mode: Enum, @"type": Enum, indirect: ?*const anyopaque, drawcount: Sizei, stride: Sizei) void {
    return self.ptr_glMultiDrawElementsIndirect.?(mode, @"type", indirect, drawcount, stride);
}
/// - **Available since:** OpenGL 4.3
pub fn getProgramInterfaceiv(self: *const GL, program: UInt, programInterface: Enum, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetProgramInterfaceiv.?(program, programInterface, pname, params);
}
/// - **Available since:** OpenGL 4.3
pub fn getProgramResourceIndex(self: *const GL, program: UInt, programInterface: Enum, name: [*]const Char) UInt {
    return self.ptr_glGetProgramResourceIndex.?(program, programInterface, name);
}
/// - **Available since:** OpenGL 4.3
pub fn getProgramResourceName(self: *const GL, program: UInt, programInterface: Enum, _index: UInt, bufSize: Sizei, length: ?*Sizei, name: [*]Char) void {
    return self.ptr_glGetProgramResourceName.?(program, programInterface, _index, bufSize, length, name);
}
/// - **Available since:** OpenGL 4.3
pub fn getProgramResourceiv(self: *const GL, program: UInt, programInterface: Enum, _index: UInt, propCount: Sizei, props: [*]const Enum, count: Sizei, length: ?*Sizei, params: [*]Int) void {
    return self.ptr_glGetProgramResourceiv.?(program, programInterface, _index, propCount, props, count, length, params);
}
/// - **Available since:** OpenGL 4.3
pub fn getProgramResourceLocation(self: *const GL, program: UInt, programInterface: Enum, name: [*:0]const Char) Int {
    return self.ptr_glGetProgramResourceLocation.?(program, programInterface, name);
}
/// - **Available since:** OpenGL 4.3
pub fn getProgramResourceLocationIndex(self: *const GL, program: UInt, programInterface: Enum, name: [*:0]const Char) Int {
    return self.ptr_glGetProgramResourceLocationIndex.?(program, programInterface, name);
}
/// - **Available since:** OpenGL 4.3
pub fn shaderStorageBlockBinding(self: *const GL, program: UInt, storageBlockIndex: UInt, storageBlockBinding: UInt) void {
    return self.ptr_glShaderStorageBlockBinding.?(program, storageBlockIndex, storageBlockBinding);
}
/// - **Available since:** OpenGL 4.3
pub fn texBufferRange(self: *const GL, target: Enum, internalformat: Enum, buffer: UInt, offset: Intptr, size: Sizeiptr) void {
    return self.ptr_glTexBufferRange.?(target, internalformat, buffer, offset, size);
}
/// - **Available since:** OpenGL 4.3
pub fn texStorage2DMultisample(self: *const GL, target: Enum, samples: Sizei, internalformat: Enum, width: Sizei, height: Sizei, fixedsamplelocations: bool) void {
    return self.ptr_glTexStorage2DMultisample.?(target, samples, internalformat, width, height, fixedsamplelocations);
}
/// - **Available since:** OpenGL 4.3
pub fn texStorage3DMultisample(self: *const GL, target: Enum, samples: Sizei, internalformat: Enum, width: Sizei, height: Sizei, depth: Sizei, fixedsamplelocations: bool) void {
    return self.ptr_glTexStorage3DMultisample.?(target, samples, internalformat, width, height, depth, fixedsamplelocations);
}
/// - **Available since:** OpenGL 4.3
pub fn textureView(self: *const GL, texture: UInt, target: Enum, origtexture: UInt, internalformat: Enum, minlevel: UInt, numlevels: UInt, minlayer: UInt, numlayers: UInt) void {
    return self.ptr_glTextureView.?(texture, target, origtexture, internalformat, minlevel, numlevels, minlayer, numlayers);
}
/// - **Available since:** OpenGL 4.3
pub fn bindVertexBuffer(self: *const GL, bindingindex: UInt, buffer: UInt, offset: Intptr, stride: Sizei) void {
    return self.ptr_glBindVertexBuffer.?(bindingindex, buffer, offset, stride);
}
/// - **Available since:** OpenGL 4.3
pub fn vertexAttribFormat(self: *const GL, attribindex: UInt, size: Int, @"type": Enum, normalized: bool, relativeoffset: UInt) void {
    return self.ptr_glVertexAttribFormat.?(attribindex, size, @"type", normalized, relativeoffset);
}
/// - **Available since:** OpenGL 4.3
pub fn vertexAttribIFormat(self: *const GL, attribindex: UInt, size: Int, @"type": Enum, relativeoffset: UInt) void {
    return self.ptr_glVertexAttribIFormat.?(attribindex, size, @"type", relativeoffset);
}
/// - **Available since:** OpenGL 4.3
pub fn vertexAttribLFormat(self: *const GL, attribindex: UInt, size: Int, @"type": Enum, relativeoffset: UInt) void {
    return self.ptr_glVertexAttribLFormat.?(attribindex, size, @"type", relativeoffset);
}
/// - **Available since:** OpenGL 4.3
pub fn vertexAttribBinding(self: *const GL, attribindex: UInt, bindingindex: UInt) void {
    return self.ptr_glVertexAttribBinding.?(attribindex, bindingindex);
}
/// - **Available since:** OpenGL 4.3
pub fn vertexBindingDivisor(self: *const GL, bindingindex: UInt, divisor: UInt) void {
    return self.ptr_glVertexBindingDivisor.?(bindingindex, divisor);
}
/// - **Available since:** OpenGL 4.3
pub fn debugMessageControl(self: *const GL, source: Enum, @"type": Enum, severity: Enum, count: Sizei, ids: [*]const UInt, enabled: bool) void {
    return self.ptr_glDebugMessageControl.?(source, @"type", severity, count, ids, enabled);
}
/// - **Available since:** OpenGL 4.3
pub fn debugMessageInsert(self: *const GL, source: Enum, @"type": Enum, id: UInt, severity: Enum, length: Sizei, buf: [*]const Char) void {
    return self.ptr_glDebugMessageInsert.?(source, @"type", id, severity, length, buf);
}
/// - **Available since:** OpenGL 4.3
pub fn debugMessageCallback(self: *const GL, callback: DebugProc, userParam: ?*const anyopaque) void {
    return self.ptr_glDebugMessageCallback.?(callback, userParam);
}
/// - **Available since:** OpenGL 4.3
pub fn getDebugMessageLog(self: *const GL, count: UInt, bufSize: Sizei, sources: [*]Enum, types: [*]Enum, ids: [*]UInt, severities: [*]Enum, lengths: [*]Sizei, messageLog: [*]Char) UInt {
    return self.ptr_glGetDebugMessageLog.?(count, bufSize, sources, types, ids, severities, lengths, messageLog);
}
/// - **Available since:** OpenGL 4.3
pub fn pushDebugGroup(self: *const GL, source: Enum, id: UInt, length: Sizei, message: [*:0]const Char) void {
    return self.ptr_glPushDebugGroup.?(source, id, length, message);
}
/// - **Available since:** OpenGL 4.3
pub fn popDebugGroup(self: *const GL) void {
    return self.ptr_glPopDebugGroup.?();
}
/// - **Available since:** OpenGL 4.3
pub fn objectLabel(self: *const GL, identifier: Enum, name: UInt, length: Sizei, label: [*:0]const Char) void {
    return self.ptr_glObjectLabel.?(identifier, name, length, label);
}
/// - **Available since:** OpenGL 4.3
pub fn getObjectLabel(self: *const GL, identifier: Enum, name: UInt, bufSize: Sizei, length: ?*Sizei, label: [*]Char) void {
    return self.ptr_glGetObjectLabel.?(identifier, name, bufSize, length, label);
}
/// - **Available since:** OpenGL 4.3
pub fn objectPtrLabel(self: *const GL, ptr: ?*const anyopaque, length: Sizei, label: [*:0]const Char) void {
    return self.ptr_glObjectPtrLabel.?(ptr, length, label);
}
/// - **Available since:** OpenGL 4.3
pub fn getObjectPtrLabel(self: *const GL, ptr: ?*const anyopaque, bufSize: Sizei, length: [*:0]Sizei, label: [*]Char) void {
    return self.ptr_glGetObjectPtrLabel.?(ptr, bufSize, length, label);
}
//#endregion
//#region OpenGL 4.4
/// - **Available since:** OpenGL 4.4
pub fn bufferStorage(self: *const GL, target: Enum, size: Sizeiptr, data: ?*const anyopaque, flags: Bitfield) void {
    return self.ptr_glBufferStorage.?(target, size, data, flags);
}
/// - **Available since:** OpenGL 4.4
pub fn clearTexImage(self: *const GL, texture: UInt, level: Int, format: Enum, @"type": Enum, data: ?*const anyopaque) void {
    return self.ptr_glClearTexImage.?(texture, level, format, @"type", data);
}
/// - **Available since:** OpenGL 4.4
pub fn clearTexSubImage(self: *const GL, texture: UInt, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, width: Sizei, height: Sizei, depth: Sizei, format: Enum, @"type": Enum, data: ?*const anyopaque) void {
    return self.ptr_glClearTexSubImage.?(texture, level, xoffset, yoffset, zoffset, width, height, depth, format, @"type", data);
}
/// - **Available since:** OpenGL 4.4
pub fn bindBuffersBase(self: *const GL, target: Enum, first: UInt, count: Sizei, buffers: [*]const UInt) void {
    return self.ptr_glBindBuffersBase.?(target, first, count, buffers);
}
/// - **Available since:** OpenGL 4.4
pub fn bindBuffersRange(self: *const GL, target: Enum, first: UInt, count: Sizei, buffers: [*]const UInt, offsets: [*]const Intptr, sizes: [*]const Sizeiptr) void {
    return self.ptr_glBindBuffersRange.?(target, first, count, buffers, offsets, sizes);
}
/// - **Available since:** OpenGL 4.4
pub fn bindTextures(self: *const GL, first: UInt, count: Sizei, textures: [*]const UInt) void {
    return self.ptr_glBindTextures.?(first, count, textures);
}
/// - **Available since:** OpenGL 4.4
pub fn bindSamplers(self: *const GL, first: UInt, count: Sizei, samplers: [*]const UInt) void {
    return self.ptr_glBindSamplers.?(first, count, samplers);
}
/// - **Available since:** OpenGL 4.4
pub fn bindImageTextures(self: *const GL, first: UInt, count: Sizei, textures: [*]const UInt) void {
    return self.ptr_glBindImageTextures.?(first, count, textures);
}
/// - **Available since:** OpenGL 4.4
pub fn bindVertexBuffers(self: *const GL, first: UInt, count: Sizei, buffers: [*]const UInt, offsets: [*]const Intptr, strides: [*]const Sizei) void {
    return self.ptr_glBindVertexBuffers.?(first, count, buffers, offsets, strides);
}
//#endregion
//#region OpenGL 4.5
/// - **Available since:** OpenGL 4.5
pub fn clipControl(self: *const GL, origin: Enum, depth: Enum) void {
    return self.ptr_glClipControl.?(origin, depth);
}
/// - **Available since:** OpenGL 4.5
pub fn createTransformFeedbacks(self: *const GL, n: Sizei, ids: [*]UInt) void {
    return self.ptr_glCreateTransformFeedbacks.?(n, ids);
}
/// - **Available since:** OpenGL 4.5
pub fn transformFeedbackBufferBase(self: *const GL, xfb: UInt, _index: UInt, buffer: UInt) void {
    return self.ptr_glTransformFeedbackBufferBase.?(xfb, _index, buffer);
}
/// - **Available since:** OpenGL 4.5
pub fn transformFeedbackBufferRange(self: *const GL, xfb: UInt, _index: UInt, buffer: UInt, offset: Intptr, size: Sizeiptr) void {
    return self.ptr_glTransformFeedbackBufferRange.?(xfb, _index, buffer, offset, size);
}
/// - **Available since:** OpenGL 4.5
pub fn getTransformFeedbackiv(self: *const GL, xfb: UInt, pname: Enum, param: [*]Int) void {
    return self.ptr_glGetTransformFeedbackiv.?(xfb, pname, param);
}
/// - **Available since:** OpenGL 4.5
pub fn getTransformFeedbacki_v(self: *const GL, xfb: UInt, pname: Enum, _index: UInt, param: [*]Int) void {
    return self.ptr_glGetTransformFeedbacki_v.?(xfb, pname, _index, param);
}
/// - **Available since:** OpenGL 4.5
pub fn getTransformFeedbacki64_v(self: *const GL, xfb: UInt, pname: Enum, _index: UInt, param: [*]Int64) void {
    return self.ptr_glGetTransformFeedbacki64_v.?(xfb, pname, _index, param);
}
/// - **Available since:** OpenGL 4.5
pub fn createBuffers(self: *const GL, n: Sizei, buffers: [*]UInt) void {
    return self.ptr_glCreateBuffers.?(n, buffers);
}
/// - **Available since:** OpenGL 4.5
pub fn namedBufferStorage(self: *const GL, buffer: UInt, size: Sizeiptr, data: ?*const anyopaque, flags: Bitfield) void {
    return self.ptr_glNamedBufferStorage.?(buffer, size, data, flags);
}
/// - **Available since:** OpenGL 4.5
pub fn namedBufferData(self: *const GL, buffer: UInt, size: Sizeiptr, data: ?*const anyopaque, usage: Enum) void {
    return self.ptr_glNamedBufferData.?(buffer, size, data, usage);
}
/// - **Available since:** OpenGL 4.5
pub fn namedBufferSubData(self: *const GL, buffer: UInt, offset: Intptr, size: Sizeiptr, data: ?*const anyopaque) void {
    return self.ptr_glNamedBufferSubData.?(buffer, offset, size, data);
}
/// - **Available since:** OpenGL 4.5
pub fn copyNamedBufferSubData(self: *const GL, _readBuffer: UInt, writeBuffer: UInt, readOffset: Intptr, writeOffset: Intptr, size: Sizeiptr) void {
    return self.ptr_glCopyNamedBufferSubData.?(_readBuffer, writeBuffer, readOffset, writeOffset, size);
}
/// - **Available since:** OpenGL 4.5
pub fn clearNamedBufferData(self: *const GL, buffer: UInt, internalformat: Enum, format: Enum, @"type": Enum, data: ?*const anyopaque) void {
    return self.ptr_glClearNamedBufferData.?(buffer, internalformat, format, @"type", data);
}
/// - **Available since:** OpenGL 4.5
pub fn clearNamedBufferSubData(self: *const GL, buffer: UInt, internalformat: Enum, offset: Intptr, size: Sizeiptr, format: Enum, @"type": Enum, data: ?*const anyopaque) void {
    return self.ptr_glClearNamedBufferSubData.?(buffer, internalformat, offset, size, format, @"type", data);
}
/// - **Available since:** OpenGL 4.5
pub fn mapNamedBuffer(self: *const GL, buffer: UInt, access: Enum) ?*anyopaque {
    return self.ptr_glMapNamedBuffer.?(buffer, access);
}
/// - **Available since:** OpenGL 4.5
pub fn mapNamedBufferRange(self: *const GL, buffer: UInt, offset: Intptr, length: Sizeiptr, access: Bitfield) ?*anyopaque {
    return self.ptr_glMapNamedBufferRange.?(buffer, offset, length, access);
}
/// - **Available since:** OpenGL 4.5
pub fn unmapNamedBuffer(self: *const GL, buffer: UInt) bool {
    return self.ptr_glUnmapNamedBuffer.?(buffer);
}
/// - **Available since:** OpenGL 4.5
pub fn flushMappedNamedBufferRange(self: *const GL, buffer: UInt, offset: Intptr, length: Sizeiptr) void {
    return self.ptr_glFlushMappedNamedBufferRange.?(buffer, offset, length);
}
/// - **Available since:** OpenGL 4.5
pub fn getNamedBufferParameteriv(self: *const GL, buffer: UInt, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetNamedBufferParameteriv.?(buffer, pname, params);
}
/// - **Available since:** OpenGL 4.5
pub fn getNamedBufferParameteri64v(self: *const GL, buffer: UInt, pname: Enum, params: [*]Int64) void {
    return self.ptr_glGetNamedBufferParameteri64v.?(buffer, pname, params);
}
/// - **Available since:** OpenGL 4.5
pub fn getNamedBufferPointerv(self: *const GL, buffer: UInt, pname: Enum, params: [*]?*anyopaque) void {
    return self.ptr_glGetNamedBufferPointerv.?(buffer, pname, params);
}
/// - **Available since:** OpenGL 4.5
pub fn getNamedBufferSubData(self: *const GL, buffer: UInt, offset: Intptr, size: Sizeiptr, data: ?*anyopaque) void {
    return self.ptr_glGetNamedBufferSubData.?(buffer, offset, size, data);
}
/// - **Available since:** OpenGL 4.5
pub fn createFramebuffers(self: *const GL, n: Sizei, framebuffers: [*]UInt) void {
    return self.ptr_glCreateFramebuffers.?(n, framebuffers);
}
/// - **Available since:** OpenGL 4.5
pub fn namedFramebufferRenderbuffer(self: *const GL, framebuffer: UInt, attachment: Enum, renderbuffertarget: Enum, renderbuffer: UInt) void {
    return self.ptr_glNamedFramebufferRenderbuffer.?(framebuffer, attachment, renderbuffertarget, renderbuffer);
}
/// - **Available since:** OpenGL 4.5
pub fn namedFramebufferParameteri(self: *const GL, framebuffer: UInt, pname: Enum, param: Int) void {
    return self.ptr_glNamedFramebufferParameteri.?(framebuffer, pname, param);
}
/// - **Available since:** OpenGL 4.5
pub fn namedFramebufferTexture(self: *const GL, framebuffer: UInt, attachment: Enum, texture: UInt, level: Int) void {
    return self.ptr_glNamedFramebufferTexture.?(framebuffer, attachment, texture, level);
}
/// - **Available since:** OpenGL 4.5
pub fn namedFramebufferTextureLayer(self: *const GL, framebuffer: UInt, attachment: Enum, texture: UInt, level: Int, layer: Int) void {
    return self.ptr_glNamedFramebufferTextureLayer.?(framebuffer, attachment, texture, level, layer);
}
/// - **Available since:** OpenGL 4.5
pub fn namedFramebufferDrawBuffer(self: *const GL, framebuffer: UInt, buf: Enum) void {
    return self.ptr_glNamedFramebufferDrawBuffer.?(framebuffer, buf);
}
/// - **Available since:** OpenGL 4.5
pub fn namedFramebufferDrawBuffers(self: *const GL, framebuffer: UInt, n: Sizei, bufs: [*]const Enum) void {
    return self.ptr_glNamedFramebufferDrawBuffers.?(framebuffer, n, bufs);
}
/// - **Available since:** OpenGL 4.5
pub fn namedFramebufferReadBuffer(self: *const GL, framebuffer: UInt, src: Enum) void {
    return self.ptr_glNamedFramebufferReadBuffer.?(framebuffer, src);
}
/// - **Available since:** OpenGL 4.5
pub fn invalidateNamedFramebufferData(self: *const GL, framebuffer: UInt, numAttachments: Sizei, attachments: [*]const Enum) void {
    return self.ptr_glInvalidateNamedFramebufferData.?(framebuffer, numAttachments, attachments);
}
/// - **Available since:** OpenGL 4.5
pub fn invalidateNamedFramebufferSubData(self: *const GL, framebuffer: UInt, numAttachments: Sizei, attachments: [*]const Enum, x: Int, y: Int, width: Sizei, height: Sizei) void {
    return self.ptr_glInvalidateNamedFramebufferSubData.?(framebuffer, numAttachments, attachments, x, y, width, height);
}
/// - **Available since:** OpenGL 4.5
pub fn clearNamedFramebufferiv(self: *const GL, framebuffer: UInt, buffer: Enum, drawbuffer: Int, value: [*]const Int) void {
    return self.ptr_glClearNamedFramebufferiv.?(framebuffer, buffer, drawbuffer, value);
}
/// - **Available since:** OpenGL 4.5
pub fn clearNamedFramebufferuiv(self: *const GL, framebuffer: UInt, buffer: Enum, drawbuffer: Int, value: [*]const UInt) void {
    return self.ptr_glClearNamedFramebufferuiv.?(framebuffer, buffer, drawbuffer, value);
}
/// - **Available since:** OpenGL 4.5
pub fn clearNamedFramebufferfv(self: *const GL, framebuffer: UInt, buffer: Enum, drawbuffer: Int, value: [*]const Float) void {
    return self.ptr_glClearNamedFramebufferfv.?(framebuffer, buffer, drawbuffer, value);
}
/// - **Available since:** OpenGL 4.5
pub fn clearNamedFramebufferfi(self: *const GL, framebuffer: UInt, buffer: Enum, drawbuffer: Int, depth: Float, stencil: Int) void {
    return self.ptr_glClearNamedFramebufferfi.?(framebuffer, buffer, drawbuffer, depth, stencil);
}
/// - **Available since:** OpenGL 4.5
pub fn blitNamedFramebuffer(self: *const GL, readFramebuffer: UInt, drawFramebuffer: UInt, srcX0: Int, srcY0: Int, srcX1: Int, srcY1: Int, dstX0: Int, dstY0: Int, dstX1: Int, dstY1: Int, mask: Bitfield, filter: Enum) void {
    return self.ptr_glBlitNamedFramebuffer.?(readFramebuffer, drawFramebuffer, srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter);
}
/// - **Available since:** OpenGL 4.5
pub fn checkNamedFramebufferStatus(self: *const GL, framebuffer: UInt, target: Enum) Enum {
    return self.ptr_glCheckNamedFramebufferStatus.?(framebuffer, target);
}
/// - **Available since:** OpenGL 4.5
pub fn getNamedFramebufferParameteriv(self: *const GL, framebuffer: UInt, pname: Enum, param: [*]Int) void {
    return self.ptr_glGetNamedFramebufferParameteriv.?(framebuffer, pname, param);
}
/// - **Available since:** OpenGL 4.5
pub fn getNamedFramebufferAttachmentParameteriv(self: *const GL, framebuffer: UInt, attachment: Enum, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetNamedFramebufferAttachmentParameteriv.?(framebuffer, attachment, pname, params);
}
/// - **Available since:** OpenGL 4.5
pub fn createRenderbuffers(self: *const GL, n: Sizei, renderbuffers: [*]UInt) void {
    return self.ptr_glCreateRenderbuffers.?(n, renderbuffers);
}
/// - **Available since:** OpenGL 4.5
pub fn namedRenderbufferStorage(self: *const GL, renderbuffer: UInt, internalformat: Enum, width: Sizei, height: Sizei) void {
    return self.ptr_glNamedRenderbufferStorage.?(renderbuffer, internalformat, width, height);
}
/// - **Available since:** OpenGL 4.5
pub fn namedRenderbufferStorageMultisample(self: *const GL, renderbuffer: UInt, samples: Sizei, internalformat: Enum, width: Sizei, height: Sizei) void {
    return self.ptr_glNamedRenderbufferStorageMultisample.?(renderbuffer, samples, internalformat, width, height);
}
/// - **Available since:** OpenGL 4.5
pub fn getNamedRenderbufferParameteriv(self: *const GL, renderbuffer: UInt, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetNamedRenderbufferParameteriv.?(renderbuffer, pname, params);
}
/// - **Available since:** OpenGL 4.5
pub fn createTextures(self: *const GL, target: Enum, n: Sizei, textures: [*]UInt) void {
    return self.ptr_glCreateTextures.?(target, n, textures);
}
/// - **Available since:** OpenGL 4.5
pub fn textureBuffer(self: *const GL, texture: UInt, internalformat: Enum, buffer: UInt) void {
    return self.ptr_glTextureBuffer.?(texture, internalformat, buffer);
}
/// - **Available since:** OpenGL 4.5
pub fn textureBufferRange(self: *const GL, texture: UInt, internalformat: Enum, buffer: UInt, offset: Intptr, size: Sizeiptr) void {
    return self.ptr_glTextureBufferRange.?(texture, internalformat, buffer, offset, size);
}
/// - **Available since:** OpenGL 4.5
pub fn textureStorage1D(self: *const GL, texture: UInt, levels: Sizei, internalformat: Enum, width: Sizei) void {
    return self.ptr_glTextureStorage1D.?(texture, levels, internalformat, width);
}
/// - **Available since:** OpenGL 4.5
pub fn textureStorage2D(self: *const GL, texture: UInt, levels: Sizei, internalformat: Enum, width: Sizei, height: Sizei) void {
    return self.ptr_glTextureStorage2D.?(texture, levels, internalformat, width, height);
}
/// - **Available since:** OpenGL 4.5
pub fn textureStorage3D(self: *const GL, texture: UInt, levels: Sizei, internalformat: Enum, width: Sizei, height: Sizei, depth: Sizei) void {
    return self.ptr_glTextureStorage3D.?(texture, levels, internalformat, width, height, depth);
}
/// - **Available since:** OpenGL 4.5
pub fn textureStorage2DMultisample(self: *const GL, texture: UInt, samples: Sizei, internalformat: Enum, width: Sizei, height: Sizei, fixedsamplelocations: bool) void {
    return self.ptr_glTextureStorage2DMultisample.?(texture, samples, internalformat, width, height, fixedsamplelocations);
}
/// - **Available since:** OpenGL 4.5
pub fn textureStorage3DMultisample(self: *const GL, texture: UInt, samples: Sizei, internalformat: Enum, width: Sizei, height: Sizei, depth: Sizei, fixedsamplelocations: bool) void {
    return self.ptr_glTextureStorage3DMultisample.?(texture, samples, internalformat, width, height, depth, fixedsamplelocations);
}
/// - **Available since:** OpenGL 4.5
pub fn textureSubImage1D(self: *const GL, texture: UInt, level: Int, xoffset: Int, width: Sizei, format: Enum, @"type": Enum, pixels: ?*const anyopaque) void {
    return self.ptr_glTextureSubImage1D.?(texture, level, xoffset, width, format, @"type", pixels);
}
/// - **Available since:** OpenGL 4.5
pub fn textureSubImage2D(self: *const GL, texture: UInt, level: Int, xoffset: Int, yoffset: Int, width: Sizei, height: Sizei, format: Enum, @"type": Enum, pixels: ?*const anyopaque) void {
    return self.ptr_glTextureSubImage2D.?(texture, level, xoffset, yoffset, width, height, format, @"type", pixels);
}
/// - **Available since:** OpenGL 4.5
pub fn textureSubImage3D(self: *const GL, texture: UInt, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, width: Sizei, height: Sizei, depth: Sizei, format: Enum, @"type": Enum, pixels: ?*const anyopaque) void {
    return self.ptr_glTextureSubImage3D.?(texture, level, xoffset, yoffset, zoffset, width, height, depth, format, @"type", pixels);
}
/// - **Available since:** OpenGL 4.5
pub fn compressedTextureSubImage1D(self: *const GL, texture: UInt, level: Int, xoffset: Int, width: Sizei, format: Enum, imageSize: Sizei, data: ?*const anyopaque) void {
    return self.ptr_glCompressedTextureSubImage1D.?(texture, level, xoffset, width, format, imageSize, data);
}
/// - **Available since:** OpenGL 4.5
pub fn compressedTextureSubImage2D(self: *const GL, texture: UInt, level: Int, xoffset: Int, yoffset: Int, width: Sizei, height: Sizei, format: Enum, imageSize: Sizei, data: ?*const anyopaque) void {
    return self.ptr_glCompressedTextureSubImage2D.?(texture, level, xoffset, yoffset, width, height, format, imageSize, data);
}
/// - **Available since:** OpenGL 4.5
pub fn compressedTextureSubImage3D(self: *const GL, texture: UInt, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, width: Sizei, height: Sizei, depth: Sizei, format: Enum, imageSize: Sizei, data: ?*const anyopaque) void {
    return self.ptr_glCompressedTextureSubImage3D.?(texture, level, xoffset, yoffset, zoffset, width, height, depth, format, imageSize, data);
}
/// - **Available since:** OpenGL 4.5
pub fn copyTextureSubImage1D(self: *const GL, texture: UInt, level: Int, xoffset: Int, x: Int, y: Int, width: Sizei) void {
    return self.ptr_glCopyTextureSubImage1D.?(texture, level, xoffset, x, y, width);
}
/// - **Available since:** OpenGL 4.5
pub fn copyTextureSubImage2D(self: *const GL, texture: UInt, level: Int, xoffset: Int, yoffset: Int, x: Int, y: Int, width: Sizei, height: Sizei) void {
    return self.ptr_glCopyTextureSubImage2D.?(texture, level, xoffset, yoffset, x, y, width, height);
}
/// - **Available since:** OpenGL 4.5
pub fn copyTextureSubImage3D(self: *const GL, texture: UInt, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, x: Int, y: Int, width: Sizei, height: Sizei) void {
    return self.ptr_glCopyTextureSubImage3D.?(texture, level, xoffset, yoffset, zoffset, x, y, width, height);
}
/// - **Available since:** OpenGL 4.5
pub fn textureParameterf(self: *const GL, texture: UInt, pname: Enum, param: Float) void {
    return self.ptr_glTextureParameterf.?(texture, pname, param);
}
/// - **Available since:** OpenGL 4.5
pub fn textureParameterfv(self: *const GL, texture: UInt, pname: Enum, param: [*]const Float) void {
    return self.ptr_glTextureParameterfv.?(texture, pname, param);
}
/// - **Available since:** OpenGL 4.5
pub fn textureParameteri(self: *const GL, texture: UInt, pname: Enum, param: Int) void {
    return self.ptr_glTextureParameteri.?(texture, pname, param);
}
/// - **Available since:** OpenGL 4.5
pub fn textureParameterIiv(self: *const GL, texture: UInt, pname: Enum, params: [*]const Int) void {
    return self.ptr_glTextureParameterIiv.?(texture, pname, params);
}
/// - **Available since:** OpenGL 4.5
pub fn textureParameterIuiv(self: *const GL, texture: UInt, pname: Enum, params: [*]const UInt) void {
    return self.ptr_glTextureParameterIuiv.?(texture, pname, params);
}
/// - **Available since:** OpenGL 4.5
pub fn textureParameteriv(self: *const GL, texture: UInt, pname: Enum, param: [*]const Int) void {
    return self.ptr_glTextureParameteriv.?(texture, pname, param);
}
/// - **Available since:** OpenGL 4.5
pub fn generateTextureMipmap(self: *const GL, texture: UInt) void {
    return self.ptr_glGenerateTextureMipmap.?(texture);
}
/// - **Available since:** OpenGL 4.5
pub fn bindTextureUnit(self: *const GL, unit: UInt, texture: UInt) void {
    return self.ptr_glBindTextureUnit.?(unit, texture);
}
/// - **Available since:** OpenGL 4.5
pub fn getTextureImage(self: *const GL, texture: UInt, level: Int, format: Enum, @"type": Enum, bufSize: Sizei, pixels: ?*anyopaque) void {
    return self.ptr_glGetTextureImage.?(texture, level, format, @"type", bufSize, pixels);
}
/// - **Available since:** OpenGL 4.5
pub fn getCompressedTextureImage(self: *const GL, texture: UInt, level: Int, bufSize: Sizei, pixels: ?*anyopaque) void {
    return self.ptr_glGetCompressedTextureImage.?(texture, level, bufSize, pixels);
}
/// - **Available since:** OpenGL 4.5
pub fn getTextureLevelParameterfv(self: *const GL, texture: UInt, level: Int, pname: Enum, params: [*]Float) void {
    return self.ptr_glGetTextureLevelParameterfv.?(texture, level, pname, params);
}
/// - **Available since:** OpenGL 4.5
pub fn getTextureLevelParameteriv(self: *const GL, texture: UInt, level: Int, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetTextureLevelParameteriv.?(texture, level, pname, params);
}
/// - **Available since:** OpenGL 4.5
pub fn getTextureParameterfv(self: *const GL, texture: UInt, pname: Enum, params: [*]Float) void {
    return self.ptr_glGetTextureParameterfv.?(texture, pname, params);
}
/// - **Available since:** OpenGL 4.5
pub fn getTextureParameterIiv(self: *const GL, texture: UInt, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetTextureParameterIiv.?(texture, pname, params);
}
/// - **Available since:** OpenGL 4.5
pub fn getTextureParameterIuiv(self: *const GL, texture: UInt, pname: Enum, params: [*]UInt) void {
    return self.ptr_glGetTextureParameterIuiv.?(texture, pname, params);
}
/// - **Available since:** OpenGL 4.5
pub fn getTextureParameteriv(self: *const GL, texture: UInt, pname: Enum, params: [*]Int) void {
    return self.ptr_glGetTextureParameteriv.?(texture, pname, params);
}
/// - **Available since:** OpenGL 4.5
pub fn createVertexArrays(self: *const GL, n: Sizei, arrays: [*]UInt) void {
    return self.ptr_glCreateVertexArrays.?(n, arrays);
}
/// - **Available since:** OpenGL 4.5
pub fn disableVertexArrayAttrib(self: *const GL, vaobj: UInt, _index: UInt) void {
    return self.ptr_glDisableVertexArrayAttrib.?(vaobj, _index);
}
/// - **Available since:** OpenGL 4.5
pub fn enableVertexArrayAttrib(self: *const GL, vaobj: UInt, _index: UInt) void {
    return self.ptr_glEnableVertexArrayAttrib.?(vaobj, _index);
}
/// - **Available since:** OpenGL 4.5
pub fn vertexArrayElementBuffer(self: *const GL, vaobj: UInt, buffer: UInt) void {
    return self.ptr_glVertexArrayElementBuffer.?(vaobj, buffer);
}
/// - **Available since:** OpenGL 4.5
pub fn vertexArrayVertexBuffer(self: *const GL, vaobj: UInt, bindingindex: UInt, buffer: UInt, offset: Intptr, stride: Sizei) void {
    return self.ptr_glVertexArrayVertexBuffer.?(vaobj, bindingindex, buffer, offset, stride);
}
/// - **Available since:** OpenGL 4.5
pub fn vertexArrayVertexBuffers(self: *const GL, vaobj: UInt, first: UInt, count: Sizei, buffers: [*]const UInt, offsets: [*]const Intptr, strides: [*]const Sizei) void {
    return self.ptr_glVertexArrayVertexBuffers.?(vaobj, first, count, buffers, offsets, strides);
}
/// - **Available since:** OpenGL 4.5
pub fn vertexArrayAttribBinding(self: *const GL, vaobj: UInt, attribindex: UInt, bindingindex: UInt) void {
    return self.ptr_glVertexArrayAttribBinding.?(vaobj, attribindex, bindingindex);
}
/// - **Available since:** OpenGL 4.5
pub fn vertexArrayAttribFormat(self: *const GL, vaobj: UInt, attribindex: UInt, size: Int, @"type": Enum, normalized: bool, relativeoffset: UInt) void {
    return self.ptr_glVertexArrayAttribFormat.?(vaobj, attribindex, size, @"type", normalized, relativeoffset);
}
/// - **Available since:** OpenGL 4.5
pub fn vertexArrayAttribIFormat(self: *const GL, vaobj: UInt, attribindex: UInt, size: Int, @"type": Enum, relativeoffset: UInt) void {
    return self.ptr_glVertexArrayAttribIFormat.?(vaobj, attribindex, size, @"type", relativeoffset);
}
/// - **Available since:** OpenGL 4.5
pub fn vertexArrayAttribLFormat(self: *const GL, vaobj: UInt, attribindex: UInt, size: Int, @"type": Enum, relativeoffset: UInt) void {
    return self.ptr_glVertexArrayAttribLFormat.?(vaobj, attribindex, size, @"type", relativeoffset);
}
/// - **Available since:** OpenGL 4.5
pub fn vertexArrayBindingDivisor(self: *const GL, vaobj: UInt, bindingindex: UInt, divisor: UInt) void {
    return self.ptr_glVertexArrayBindingDivisor.?(vaobj, bindingindex, divisor);
}
/// - **Available since:** OpenGL 4.5
pub fn getVertexArrayiv(self: *const GL, vaobj: UInt, pname: Enum, param: [*]Int) void {
    return self.ptr_glGetVertexArrayiv.?(vaobj, pname, param);
}
/// - **Available since:** OpenGL 4.5
pub fn getVertexArrayIndexediv(self: *const GL, vaobj: UInt, _index: UInt, pname: Enum, param: [*]Int) void {
    return self.ptr_glGetVertexArrayIndexediv.?(vaobj, _index, pname, param);
}
/// - **Available since:** OpenGL 4.5
pub fn getVertexArrayIndexed64iv(self: *const GL, vaobj: UInt, _index: UInt, pname: Enum, param: [*]Int64) void {
    return self.ptr_glGetVertexArrayIndexed64iv.?(vaobj, _index, pname, param);
}
/// - **Available since:** OpenGL 4.5
pub fn createSamplers(self: *const GL, n: Sizei, samplers: [*]UInt) void {
    return self.ptr_glCreateSamplers.?(n, samplers);
}
/// - **Available since:** OpenGL 4.5
pub fn createProgramPipelines(self: *const GL, n: Sizei, pipelines: [*]UInt) void {
    return self.ptr_glCreateProgramPipelines.?(n, pipelines);
}
/// - **Available since:** OpenGL 4.5
pub fn createQueries(self: *const GL, target: Enum, n: Sizei, ids: [*]UInt) void {
    return self.ptr_glCreateQueries.?(target, n, ids);
}
/// - **Available since:** OpenGL 4.5
pub fn getQueryBufferObjecti64v(self: *const GL, id: UInt, buffer: UInt, pname: Enum, offset: Intptr) void {
    return self.ptr_glGetQueryBufferObjecti64v.?(id, buffer, pname, offset);
}
/// - **Available since:** OpenGL 4.5
pub fn getQueryBufferObjectiv(self: *const GL, id: UInt, buffer: UInt, pname: Enum, offset: Intptr) void {
    return self.ptr_glGetQueryBufferObjectiv.?(id, buffer, pname, offset);
}
/// - **Available since:** OpenGL 4.5
pub fn getQueryBufferObjectui64v(self: *const GL, id: UInt, buffer: UInt, pname: Enum, offset: Intptr) void {
    return self.ptr_glGetQueryBufferObjectui64v.?(id, buffer, pname, offset);
}
/// - **Available since:** OpenGL 4.5
pub fn getQueryBufferObjectuiv(self: *const GL, id: UInt, buffer: UInt, pname: Enum, offset: Intptr) void {
    return self.ptr_glGetQueryBufferObjectuiv.?(id, buffer, pname, offset);
}
/// - **Available since:** OpenGL 4.5
pub fn memoryBarrierByRegion(self: *const GL, barriers: Bitfield) void {
    return self.ptr_glMemoryBarrierByRegion.?(barriers);
}
/// - **Available since:** OpenGL 4.5
pub fn getTextureSubImage(self: *const GL, texture: UInt, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, width: Sizei, height: Sizei, depth: Sizei, format: Enum, @"type": Enum, bufSize: Sizei, pixels: ?*anyopaque) void {
    return self.ptr_glGetTextureSubImage.?(texture, level, xoffset, yoffset, zoffset, width, height, depth, format, @"type", bufSize, pixels);
}
/// - **Available since:** OpenGL 4.5
pub fn getCompressedTextureSubImage(self: *const GL, texture: UInt, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, width: Sizei, height: Sizei, depth: Sizei, bufSize: Sizei, pixels: ?*anyopaque) void {
    return self.ptr_glGetCompressedTextureSubImage.?(texture, level, xoffset, yoffset, zoffset, width, height, depth, bufSize, pixels);
}
/// - **Available since:** OpenGL 4.5
pub fn getGraphicsResetStatus(self: *const GL) Enum {
    return self.ptr_glGetGraphicsResetStatus.?();
}
/// - **Available since:** OpenGL 4.5
pub fn getnCompressedTexImage(self: *const GL, target: Enum, lod: Int, bufSize: Sizei, pixels: ?*anyopaque) void {
    return self.ptr_glGetnCompressedTexImage.?(target, lod, bufSize, pixels);
}
/// - **Available since:** OpenGL 4.5
pub fn getnTexImage(self: *const GL, target: Enum, level: Int, format: Enum, @"type": Enum, bufSize: Sizei, pixels: ?*anyopaque) void {
    return self.ptr_glGetnTexImage.?(target, level, format, @"type", bufSize, pixels);
}
/// - **Available since:** OpenGL 4.5
pub fn getnUniformdv(self: *const GL, program: UInt, location: Int, bufSize: Sizei, params: [*]Double) void {
    return self.ptr_glGetnUniformdv.?(program, location, bufSize, params);
}
/// - **Available since:** OpenGL 4.5
pub fn getnUniformfv(self: *const GL, program: UInt, location: Int, bufSize: Sizei, params: [*]Float) void {
    return self.ptr_glGetnUniformfv.?(program, location, bufSize, params);
}
/// - **Available since:** OpenGL 4.5
pub fn getnUniformiv(self: *const GL, program: UInt, location: Int, bufSize: Sizei, params: [*]Int) void {
    return self.ptr_glGetnUniformiv.?(program, location, bufSize, params);
}
/// - **Available since:** OpenGL 4.5
pub fn getnUniformuiv(self: *const GL, program: UInt, location: Int, bufSize: Sizei, params: [*]UInt) void {
    return self.ptr_glGetnUniformuiv.?(program, location, bufSize, params);
}
/// - **Available since:** OpenGL 4.5
pub fn readnPixels(self: *const GL, x: Int, y: Int, width: Sizei, height: Sizei, format: Enum, @"type": Enum, bufSize: Sizei, data: ?*anyopaque) void {
    return self.ptr_glReadnPixels.?(x, y, width, height, format, @"type", bufSize, data);
}
/// - **Available since:** OpenGL 4.5
pub fn getnMapdv(self: *const GL, target: Enum, query: Enum, bufSize: Sizei, v: [*]Double) void {
    return self.ptr_glGetnMapdv.?(target, query, bufSize, v);
}
/// - **Available since:** OpenGL 4.5
pub fn getnMapfv(self: *const GL, target: Enum, query: Enum, bufSize: Sizei, v: [*]Float) void {
    return self.ptr_glGetnMapfv.?(target, query, bufSize, v);
}
/// - **Available since:** OpenGL 4.5
pub fn getnMapiv(self: *const GL, target: Enum, query: Enum, bufSize: Sizei, v: [*]Int) void {
    return self.ptr_glGetnMapiv.?(target, query, bufSize, v);
}
/// - **Available since:** OpenGL 4.5
pub fn getnPixelMapfv(self: *const GL, map: Enum, bufSize: Sizei, values: [*]Float) void {
    return self.ptr_glGetnPixelMapfv.?(map, bufSize, values);
}
/// - **Available since:** OpenGL 4.5
pub fn getnPixelMapuiv(self: *const GL, map: Enum, bufSize: Sizei, values: [*]UInt) void {
    return self.ptr_glGetnPixelMapuiv.?(map, bufSize, values);
}
/// - **Available since:** OpenGL 4.5
pub fn getnPixelMapusv(self: *const GL, map: Enum, bufSize: Sizei, values: [*]UShort) void {
    return self.ptr_glGetnPixelMapusv.?(map, bufSize, values);
}
/// - **Available since:** OpenGL 4.5
pub fn getnPolygonStipple(self: *const GL, bufSize: Sizei, pattern: [*]UByte) void {
    return self.ptr_glGetnPolygonStipple.?(bufSize, pattern);
}
/// - **Available since:** OpenGL 4.5
pub fn getnColorTable(self: *const GL, target: Enum, format: Enum, @"type": Enum, bufSize: Sizei, table: ?*anyopaque) void {
    return self.ptr_glGetnColorTable.?(target, format, @"type", bufSize, table);
}
/// - **Available since:** OpenGL 4.5
pub fn getnConvolutionFilter(self: *const GL, target: Enum, format: Enum, @"type": Enum, bufSize: Sizei, image: ?*anyopaque) void {
    return self.ptr_glGetnConvolutionFilter.?(target, format, @"type", bufSize, image);
}
/// - **Available since:** OpenGL 4.5
pub fn getnSeparableFilter(self: *const GL, target: Enum, format: Enum, @"type": Enum, rowBufSize: Sizei, row: ?*anyopaque, columnBufSize: Sizei, column: ?*anyopaque, span: ?*anyopaque) void {
    return self.ptr_glGetnSeparableFilter.?(target, format, @"type", rowBufSize, row, columnBufSize, column, span);
}
/// - **Available since:** OpenGL 4.5
pub fn getnHistogram(self: *const GL, target: Enum, reset: bool, format: Enum, @"type": Enum, bufSize: Sizei, values: ?*anyopaque) void {
    return self.ptr_glGetnHistogram.?(target, reset, format, @"type", bufSize, values);
}
/// - **Available since:** OpenGL 4.5
pub fn getnMinmax(self: *const GL, target: Enum, reset: bool, format: Enum, @"type": Enum, bufSize: Sizei, values: ?*anyopaque) void {
    return self.ptr_glGetnMinmax.?(target, reset, format, @"type", bufSize, values);
}
/// - **Available since:** OpenGL 4.5
pub fn textureBarrier(self: *const GL) void {
    return self.ptr_glTextureBarrier.?();
}
//#endregion
//#region OpenGL 4.6
/// - **Available since:** OpenGL 4.6
pub fn specializeShader(self: *const GL, shader: UInt, pEntryPoint: [*:0]const Char, numSpecializationConstants: UInt, pConstantIndex: [*]const UInt, pConstantValue: [*]const UInt) void {
    return self.ptr_glSpecializeShader.?(shader, pEntryPoint, numSpecializationConstants, pConstantIndex, pConstantValue);
}
/// - **Available since:** OpenGL 4.6
pub fn multiDrawArraysIndirectCount(self: *const GL, mode: Enum, indirect: ?*const anyopaque, drawcount: Intptr, maxdrawcount: Sizei, stride: Sizei) void {
    return self.ptr_glMultiDrawArraysIndirectCount.?(mode, indirect, drawcount, maxdrawcount, stride);
}
/// - **Available since:** OpenGL 4.6
pub fn multiDrawElementsIndirectCount(self: *const GL, mode: Enum, @"type": Enum, indirect: ?*const anyopaque, drawcount: Intptr, maxdrawcount: Sizei, stride: Sizei) void {
    return self.ptr_glMultiDrawElementsIndirectCount.?(mode, @"type", indirect, drawcount, maxdrawcount, stride);
}
/// - **Available since:** OpenGL 4.6
pub fn polygonOffsetClamp(self: *const GL, factor: Float, units: Float, clamp: Float) void {
    return self.ptr_glPolygonOffsetClamp.?(factor, units, clamp);
}
//#endregion
//#endregion functions
//#endregion struct
