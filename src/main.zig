const windows = std.os.windows;
const builtin = @import("builtin");
const native_os = builtin.os.tag;

const c = @cImport({
    if (native_os == .windows) {
        @cInclude("SDL.h");
    } else {
        @cInclude("SDL2/SDL.h");
    }
});
const std = @import("std");
const math = @import("std").math;
const rand = @import("std").Random;

const WINDOW_WIDTH: i32 = 1024;
const WINDOW_HEIGHT: i32 = 768;

const RndGen = rand.DefaultPrng;

const Star = struct {
    x: f32,
    y: f32,
    delta: f32,
    m: f32,
    age: u8,
    r: u8,
    g: u8,
    b: u8,

    pub fn init3(x: f32, y: f32, delta: f32) Star {
        return Star{
            .x = x,
            .y = y,
            .delta = delta,
            .m = y - delta * x,
            .r = 0xff,
            .g = 0xff,
            .b = 0xff,
            .age = 0xf0,
        };
    }
    pub fn init2(x: f32, y: f32) Star {
        const delta: f32 = (@as(f32, @floatFromInt(WINDOW_HEIGHT / 2)) - y) / (@as(f32, @floatFromInt(WINDOW_WIDTH / 2)) - x);
        return Star{
            .x = x,
            .y = y,
            .delta = delta,
            .m = y - x * delta,
            .r = 0xff,
            .g = 0xff,
            .b = 0xff,
            .age = 0xf0,
        };
    }
};

pub fn main() anyerror!void {
    var prnd = rand.DefaultPrng.init(42);
    const random = prnd.random();

    std.log.info("A small sdl test.", .{});

    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const screen = c.SDL_CreateWindow("My Game Window", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, WINDOW_WIDTH, WINDOW_HEIGHT, c.SDL_RENDERER_PRESENTVSYNC | c.SDL_RENDERER_ACCELERATED) orelse
        {
            c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
            return error.SDLInitializationFailed;
        };
    defer c.SDL_DestroyWindow(screen);

    const renderer = c.SDL_CreateRenderer(screen, -1, 0) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    _ = c.SDL_RenderClear(renderer);
    _ = c.SDL_RenderPresent(renderer);
    var quit = false;
    //   var _pos_x: i32 = 0;
    //   var _pos_y: i32 = WINDOW_HEIGHT / 2;

    //var star = Star.init2(@floatFromInt(f32, WINDOW_WIDTH / 2) + 10.0, @floatFromInt(f32, WINDOW_HEIGHT / 2) + 10.0);
    var stars: [500]Star = undefined;

    for (&stars) |*st| {
        st.* = Star.init2(random.float(f32) * @as(f32, @floatFromInt(WINDOW_WIDTH)), random.float(f32) * @as(f32, @floatFromInt(WINDOW_HEIGHT)));
    }
    //std.debug.print("-> {d}\n", .{star});

    while (!quit) {
        _ = c.SDL_SetRenderDrawColor(renderer, 0x00, 0x00, 0x00, 0x00);
        _ = c.SDL_RenderClear(renderer);
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }

        for (&stars) |*star| {
            _ = c.SDL_SetRenderDrawColor(renderer, star.r - star.age, star.g - star.age, star.b - star.age, 0x00);
            if (star.age > 0x2) {
                star.age -= 0x2;
            }
            if (star.x < WINDOW_WIDTH / 2) {
                star.x -= math.clamp(1 / @abs(star.delta), 0.1, 1); //1.0;
            } else {
                star.x += math.clamp(1 / @abs(star.delta), 0.1, 1); //1.0;
            }
            star.y = star.x * star.delta + star.m;
            _ = c.SDL_RenderDrawPoint(renderer, @as(i32, @intFromFloat(star.x)), @as(i32, @intFromFloat(star.y)));
            if (star.x < 0 or star.x > WINDOW_WIDTH) {
                star.* = Star.init2(random.float(f32) * @as(f32, @floatFromInt(WINDOW_WIDTH)), random.float(f32) * @as(f32, @floatFromInt(WINDOW_HEIGHT)));
            } else if (star.y < 0 or star.y > WINDOW_HEIGHT) {
                star.* = Star.init2(random.float(f32) * @as(f32, @floatFromInt(WINDOW_WIDTH)), random.float(f32) * @as(f32, @floatFromInt(WINDOW_HEIGHT)));
            }
        }
        //_ = c.SDL_RenderCopy(renderer, zig_texture, null, null);
        c.SDL_RenderPresent(renderer);

        c.SDL_Delay(17);
    }
}
