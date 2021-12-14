const c = @cImport({
    @cInclude("SDL2/SDL.h");
});
const std = @import("std");
const math = @import("std").math;
const rand = @import("std").rand;

const WINDOW_WIDTH: i32 = 1024;
const WINDOW_HEIGHT: i32 = 768;

const RndGen = rand.DefaultPrng;

const Star = struct {
    x: f32,
    y: f32,
    delta: f32,
    m: f32,
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
        };
    }
    pub fn init2(x: f32, y: f32) Star {
        var delta: f32 = (@intToFloat(f32, WINDOW_HEIGHT / 2) - y) / (@intToFloat(f32, WINDOW_WIDTH / 2) - x);
        return Star{
            .x = x,
            .y = y,
            .delta = delta,
            .m = y - x * delta,
            .r = 0xff,
            .g = 0xff,
            .b = 0xff,
        };
    }
};

pub fn main() anyerror!void {
    var rnd = rand.DefaultPrng.init(42);
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
    var pos_x: i32 = 0;
    var pos_y: i32 = WINDOW_HEIGHT / 2;
    var star = Star.init2(@intToFloat(f32, WINDOW_WIDTH / 2) + 10.0, @intToFloat(f32, WINDOW_HEIGHT / 2) + 10.0);
    std.debug.print("-> {d}\n", .{star});

    while (!quit) {
        _ = c.SDL_SetRenderDrawColor(renderer, 0x00, 0x00, 0x00, 0x00);
        _ = c.SDL_RenderClear(renderer);
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.@"type") {
                c.SDL_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }

        _ = c.SDL_SetRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0x00);

        if (star.x < WINDOW_WIDTH / 2) {
            star.x -= 1.5;
        } else {
            star.x += 1.5;
        }
        star.y = star.x * star.delta + star.m;
        _ = c.SDL_RenderDrawPoint(renderer, @floatToInt(i32, star.x), @floatToInt(i32, star.y));
        if (star.x < 0 or star.x > WINDOW_WIDTH) {
            star = Star.init2(rnd.random.float(f32) * @intToFloat(f32, WINDOW_WIDTH), rnd.random.float(f32) * @intToFloat(f32, WINDOW_HEIGHT));
        } else if (star.y < 0 or star.y > WINDOW_HEIGHT) {
            star = Star.init2(rnd.random.float(f32) * @intToFloat(f32, WINDOW_WIDTH), rnd.random.float(f32) * @intToFloat(f32, WINDOW_HEIGHT));
        }

        //_ = c.SDL_RenderCopy(renderer, zig_texture, null, null);
        c.SDL_RenderPresent(renderer);

        c.SDL_Delay(30);
    }
}
