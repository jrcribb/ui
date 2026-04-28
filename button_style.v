module ui

import gg
import x.json2

// Button

pub struct ButtonShapeStyle {
pub mut:
	radius           f32
	border_color     gg.Color
	bg_color         gg.Color
	bg_color_pressed gg.Color
	bg_color_hover   gg.Color
}

pub struct ButtonStyle {
	ButtonShapeStyle
pub mut:
	text_font_name      string = 'system'
	text_color          gg.Color
	text_size           int                 = 16
	text_align          TextHorizontalAlign = .center
	text_vertical_align TextVerticalAlign   = .middle
}

@[params]
pub struct ButtonStyleParams {
	WidgetTextStyleParams
pub mut:
	style            string   = no_style
	radius           f32      = -1
	border_color     gg.Color = no_color
	bg_color         gg.Color = no_color
	bg_color_pressed gg.Color = no_color
	bg_color_hover   gg.Color = no_color
}

pub fn button_style(p ButtonStyleParams) ButtonStyleParams {
	return p
}

pub fn (bs ButtonStyle) to_json_any() json2.Any {
	mut obj := map[string]json2.Any{}
	obj['radius'] = bs.radius
	obj['border_color'] = hex_color(bs.border_color)
	obj['bg_color'] = hex_color(bs.bg_color)
	obj['bg_color_pressed'] = hex_color(bs.bg_color_hover)
	obj['bg_color_hover'] = hex_color(bs.bg_color_pressed)
	obj['text_font_name'] = bs.text_font_name
	obj['text_color'] = hex_color(bs.text_color)
	obj['text_size'] = bs.text_size
	obj['text_align'] = int(bs.text_align)
	obj['text_vertical_align'] = int(bs.text_vertical_align)
	return obj
}

pub fn (mut bs ButtonStyle) from_json(a json2.Any) {
	m := a.as_map()
	bs.radius = (m['radius'] or { json2.Any(0) }).f32()
	bs.border_color = HexColor((m['border_color'] or { json2.Any('') }).str()).color()
	bs.bg_color = HexColor((m['bg_color'] or { json2.Any('') }).str()).color()
	bs.bg_color_hover = HexColor((m['bg_color_pressed'] or { json2.Any('') }).str()).color()
	bs.bg_color_pressed = HexColor((m['bg_color_hover'] or { json2.Any('') }).str()).color()
	bs.text_font_name = (m['text_font_name'] or { json2.Any('') }).str()
	bs.text_color = HexColor((m['text_color'] or { json2.Any('') }).str()).color()
	bs.text_size = (m['text_size'] or { json2.Any(0) }).int()
	bs.text_align = unsafe { TextHorizontalAlign((m['text_align'] or { json2.Any(0) }).int()) }
	bs.text_vertical_align = unsafe { TextVerticalAlign((m['text_vertical_align'] or { json2.Any(0) }).int()) }
}

pub fn (mut b Button) load_style() {
	// println("btn load style $b.theme_style")
	mut style := if b.theme_style == '' { b.ui.window.theme_style } else { b.theme_style }
	if b.style_params.style != no_style {
		style = b.style_params.style
	}
	b.update_theme_style(style)
	// forced overload default style
	b.update_style(b.style_params)
}

pub fn (mut b Button) update_theme_style(theme string) {
	// println("update_style <$p.style>")
	style := if theme == '' { 'default' } else { theme }
	if style != no_style && style in b.ui.styles {
		bs := b.ui.styles[style].btn
		b.theme_style = theme
		b.update_shape_theme_style(bs)
		mut dtw := DrawTextWidget(b)
		dtw.update_theme_style(bs)
	}
}

pub fn (mut b Button) update_style(p ButtonStyleParams) {
	// println("update_style <$p.style>")
	b.update_shape_style(p)
	mut dtw := DrawTextWidget(b)
	dtw.update_theme_style_params(p)
}

fn (mut b Button) update_shape_theme_style(bs ButtonStyle) {
	b.style.radius = bs.radius
	b.style.border_color = bs.border_color
	b.style.bg_color = bs.bg_color
	b.style.bg_color_pressed = bs.bg_color_pressed
	b.style.bg_color_hover = bs.bg_color_hover
}

fn (mut b Button) update_shape_style(p ButtonStyleParams) {
	if p.radius >= 0 {
		b.style.radius = p.radius
	}
	if p.border_color != no_color {
		b.style.border_color = p.border_color
	}
	if p.bg_color != no_color {
		b.style.bg_color = p.bg_color
	}
	if p.bg_color_pressed != no_color {
		b.style.bg_color_pressed = p.bg_color_pressed
	}
	if p.bg_color_hover != no_color {
		b.style.bg_color_hover = p.bg_color_hover
	}
}

// update style_params
pub fn (mut b Button) update_style_params(p ButtonStyleParams) {
	if p.radius >= 0 {
		b.style_params.radius = p.radius
	}
	if p.border_color != no_color {
		b.style_params.border_color = p.border_color
	}
	if p.bg_color != no_color {
		b.style_params.bg_color = p.bg_color
	}
	if p.bg_color_pressed != no_color {
		b.style.bg_color_pressed = p.bg_color_pressed
	}
	if p.bg_color_hover != no_color {
		b.style.bg_color_hover = p.bg_color_hover
	}
	mut dtw := DrawTextWidget(b)
	dtw.update_theme_style_params(p)
}
