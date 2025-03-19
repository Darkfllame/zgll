pub const Bitfield = enum(u32) {
    _,

    pub fn bitOr(a: Bitfield, b: Bitfield) Bitfield {
        return @enumFromInt(@intFromEnum(a) | @intFromEnum(b));
    }

    pub const DEPTH_BUFFER_BIT: Bitfield = @enumFromInt(0x00000100);
    pub const STENCIL_BUFFER_BIT: Bitfield = @enumFromInt(0x00000400);
    pub const COLOR_BUFFER_BIT: Bitfield = @enumFromInt(0x00004000);
    pub const CURRENT_BIT: Bitfield = @enumFromInt(0x00000001);
    pub const POINT_BIT: Bitfield = @enumFromInt(0x00000002);
    pub const LINE_BIT: Bitfield = @enumFromInt(0x00000004);
    pub const POLYGON_BIT: Bitfield = @enumFromInt(0x00000008);
    pub const POLYGON_STIPPLE_BIT: Bitfield = @enumFromInt(0x00000010);
    pub const PIXEL_MODE_BIT: Bitfield = @enumFromInt(0x00000020);
    pub const LIGHTING_BIT: Bitfield = @enumFromInt(0x00000040);
    pub const FOG_BIT: Bitfield = @enumFromInt(0x00000080);
    pub const ACCUM_BUFFER_BIT: Bitfield = @enumFromInt(0x00000200);
    pub const VIEWPORT_BIT: Bitfield = @enumFromInt(0x00000800);
    pub const TRANSFORM_BIT: Bitfield = @enumFromInt(0x00001000);
    pub const ENABLE_BIT: Bitfield = @enumFromInt(0x00002000);
    pub const HINT_BIT: Bitfield = @enumFromInt(0x00008000);
    pub const EVAL_BIT: Bitfield = @enumFromInt(0x00010000);
    pub const LIST_BIT: Bitfield = @enumFromInt(0x00020000);
    pub const TEXTURE_BIT: Bitfield = @enumFromInt(0x00040000);
    pub const SCISSOR_BIT: Bitfield = @enumFromInt(0x00080000);
    pub const CLIENT_PIXEL_STORE_BIT: Bitfield = @enumFromInt(0x00000001);
    pub const CLIENT_VERTEX_ARRAY_BIT: Bitfield = @enumFromInt(0x00000002);
    pub const MULTISAMPLE_BIT: Bitfield = @enumFromInt(0x20000000);
    pub const CONTEXT_FLAG_FORWARD_COMPATIBLE_BIT: Bitfield = @enumFromInt(0x00000001);
    pub const MAP_READ_BIT: Bitfield = @enumFromInt(0x0001);
    pub const MAP_WRITE_BIT: Bitfield = @enumFromInt(0x0002);
    pub const MAP_INVALIDATE_RANGE_BIT: Bitfield = @enumFromInt(0x0004);
    pub const MAP_INVALIDATE_BUFFER_BIT: Bitfield = @enumFromInt(0x0008);
    pub const MAP_FLUSH_EXPLICIT_BIT: Bitfield = @enumFromInt(0x0010);
    pub const MAP_UNSYNCHRONIZED_BIT: Bitfield = @enumFromInt(0x0020);
    pub const CONTEXT_CORE_PROFILE_BIT: Bitfield = @enumFromInt(0x00000001);
    pub const CONTEXT_COMPATIBILITY_PROFILE_BIT: Bitfield = @enumFromInt(0x00000002);
    pub const SYNC_FLUSH_COMMANDS_BIT: Bitfield = @enumFromInt(0x00000001);
    pub const VERTEX_SHADER_BIT: Bitfield = @enumFromInt(0x00000001);
    pub const FRAGMENT_SHADER_BIT: Bitfield = @enumFromInt(0x00000002);
    pub const GEOMETRY_SHADER_BIT: Bitfield = @enumFromInt(0x00000004);
    pub const TESS_CONTROL_SHADER_BIT: Bitfield = @enumFromInt(0x00000008);
    pub const TESS_EVALUATION_SHADER_BIT: Bitfield = @enumFromInt(0x00000010);
    pub const VERTEX_ATTRIB_ARRAY_BARRIER_BIT: Bitfield = @enumFromInt(0x00000001);
    pub const ELEMENT_ARRAY_BARRIER_BIT: Bitfield = @enumFromInt(0x00000002);
    pub const UNIFORM_BARRIER_BIT: Bitfield = @enumFromInt(0x00000004);
    pub const TEXTURE_FETCH_BARRIER_BIT: Bitfield = @enumFromInt(0x00000008);
    pub const SHADER_IMAGE_ACCESS_BARRIER_BIT: Bitfield = @enumFromInt(0x00000020);
    pub const COMMAND_BARRIER_BIT: Bitfield = @enumFromInt(0x00000040);
    pub const PIXEL_BUFFER_BARRIER_BIT: Bitfield = @enumFromInt(0x00000080);
    pub const TEXTURE_UPDATE_BARRIER_BIT: Bitfield = @enumFromInt(0x00000100);
    pub const BUFFER_UPDATE_BARRIER_BIT: Bitfield = @enumFromInt(0x00000200);
    pub const FRAMEBUFFER_BARRIER_BIT: Bitfield = @enumFromInt(0x00000400);
    pub const TRANSFORM_FEEDBACK_BARRIER_BIT: Bitfield = @enumFromInt(0x00000800);
    pub const ATOMIC_COUNTER_BARRIER_BIT: Bitfield = @enumFromInt(0x00001000);
    pub const COMPUTE_SHADER_BIT: Bitfield = @enumFromInt(0x00000020);
    pub const CONTEXT_FLAG_DEBUG_BIT: Bitfield = @enumFromInt(0x00000002);
    pub const SHADER_STORAGE_BARRIER_BIT: Bitfield = @enumFromInt(0x00002000);
    pub const MAP_PERSISTENT_BIT: Bitfield = @enumFromInt(0x0040);
    pub const MAP_COHERENT_BIT: Bitfield = @enumFromInt(0x0080);
    pub const DYNAMIC_STORAGE_BIT: Bitfield = @enumFromInt(0x0100);
    pub const CLIENT_STORAGE_BIT: Bitfield = @enumFromInt(0x0200);
    pub const CLIENT_MAPPED_BUFFER_BARRIER_BIT: Bitfield = @enumFromInt(0x00004000);
    pub const QUERY_BUFFER_BARRIER_BIT: Bitfield = @enumFromInt(0x00008000);
    pub const CONTEXT_FLAG_ROBUST_ACCESS_BIT: Bitfield = @enumFromInt(0x00000004);
    pub const CONTEXT_FLAG_NO_ERROR_BIT: Bitfield = @enumFromInt(0x00000008);
};
