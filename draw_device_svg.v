module ui

import gg

// Note: libvg-based SVG rendering is temporarily stubbed out
// due to V compiler submodule resolution issue with src/ layout.
// Restore full implementation when `import ui.libvg` works again.

struct DrawDeviceSVG {
mut:
	id string   = 'dd_svg'
	ts voidptr  = unsafe { nil }
pub mut:
	s voidptr = unsafe { nil }
}

@[params]
struct DrawDeviceSVGParams {
pub:
	id string = 'dd_svg'
}

// TODO: documentation
pub fn draw_device_svg(p DrawDeviceSVGParams) &DrawDeviceSVG {
	return &DrawDeviceSVG{
		id: p.id
	}
}

// screenshot method for SVG device
@[manualfree]
pub fn (mut d DrawDeviceSVG) screenshot_window(filename string, mut w Window) {
	// stubbed: requires ui.libvg
}

// methods

// TODO: documentation
pub fn (d &DrawDeviceSVG) begin(win_bg_color gg.Color) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) end() {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) save(filepath string) {
}

// interface DrawDevice

// TODO: documentation
pub fn (d DrawDeviceSVG) set_bg_color(color gg.Color) {}

// TODO: documentation
pub fn (d &DrawDeviceSVG) has_text_style() bool {
	return true
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) set_text_style(font_name string, font_path string, size int, color gg.Color, align int, vertical_align int) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_text(x int, y int, text string, cfg gg.TextCfg) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_text_default(x int, y int, text string) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_text_def(x int, y int, text string) {}

// TODO: documentation
pub fn (d &DrawDeviceSVG) set_text_cfg(c gg.TextCfg) {}

// TODO: documentation
pub fn (d &DrawDeviceSVG) text_size(s string) (int, int) {
	return 0, 0
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) text_width(s string) int {
	return 0
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) text_height(s string) int {
	return 0
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) reset_clipping() {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) set_clipping(rect Rect) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) get_clipping() Rect {
	return Rect{0, 0, int(max_i32), int(max_i32)}
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_pixel(x f32, y f32, color gg.Color, params gg.DrawPixelConfig) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_pixels(points []f32, color gg.Color, params gg.DrawPixelConfig) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_image(x f32, y f32, width f32, height f32, img &gg.Image) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_triangle_empty(x f32, y f32, x2 f32, y2 f32, x3 f32, y3 f32, color gg.Color) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_triangle_filled(x f32, y f32, x2 f32, y2 f32, x3 f32, y3 f32, color gg.Color) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_rect_empty(x f32, y f32, w f32, h f32, color gg.Color) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_rect_filled(x f32, y f32, w f32, h f32, color gg.Color) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_rounded_rect_filled(x f32, y f32, w f32, h f32, radius f32, color gg.Color) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_rounded_rect_empty(x f32, y f32, w f32, h f32, radius f32, color gg.Color) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_circle_line(x f32, y f32, r int, segments int, color gg.Color) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_circle_empty(x f32, y f32, r f32, color gg.Color) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_circle_filled(x f32, y f32, r f32, color gg.Color) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_slice_empty(x f32, y f32, r f32, start_angle f32, end_angle f32, segments int, color gg.Color) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_slice_filled(x f32, y f32, r f32, start_angle f32, end_angle f32, segments int, color gg.Color) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_arc_empty(x f32, y f32, radius f32, thickness f32, start_angle f32, end_angle f32, segments int, color gg.Color) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_arc_filled(x f32, y f32, radius f32, thickness f32, start_angle f32, end_angle f32, segments int, color gg.Color) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_arc_line(x f32, y f32, radius f32, start_angle f32, end_angle f32, segments int, color gg.Color) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_line(x f32, y f32, x2 f32, y2 f32, color gg.Color) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_convex_poly(points []f32, color gg.Color) {
}

// TODO: documentation
pub fn (d &DrawDeviceSVG) draw_poly_empty(points []f32, color gg.Color) {
}
