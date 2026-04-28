module ui

import gg
import x.json2

// ListBox

pub struct ListBoxShapeStyle {
pub mut:
	radius           f32
	border_color     gg.Color = gg.gray
	bg_color         gg.Color = gg.white
	bg_color_pressed gg.Color = gg.light_blue
	bg_color_hover   gg.Color = gg.light_gray
}

pub struct ListBoxStyle {
	ListBoxShapeStyle // text_style TextStyle
pub mut:
	text_font_name      string = 'system'
	text_color          gg.Color
	text_size           int                 = 16
	text_align          TextHorizontalAlign = .left
	text_vertical_align TextVerticalAlign   = .top
}

@[params]
pub struct ListBoxStyleParams {
	WidgetTextStyleParams
pub mut:
	style            string = no_style
	radius           f32
	border_color     gg.Color = no_color
	bg_color         gg.Color = no_color
	bg_color_pressed gg.Color = no_color
	bg_color_hover   gg.Color = no_color
}

pub fn listbox_style(p ListBoxStyleParams) ListBoxStyleParams {
	return p
}

pub fn (lbs ListBoxStyle) to_json_any() json2.Any {
	mut obj := map[string]json2.Any{}
	obj['radius'] = lbs.radius
	obj['border_color'] = hex_color(lbs.border_color)
	obj['bg_color'] = hex_color(lbs.bg_color)
	obj['bg_color_pressed'] = hex_color(lbs.bg_color_hover)
	obj['bg_color_hover'] = hex_color(lbs.bg_color_pressed)
	obj['text_font_name'] = lbs.text_font_name
	obj['text_color'] = hex_color(lbs.text_color)
	obj['text_size'] = lbs.text_size
	obj['text_align'] = int(lbs.text_align)
	obj['text_vertical_align'] = int(lbs.text_vertical_align)
	return obj
}

pub fn (mut lbs ListBoxStyle) from_json(a json2.Any) {
	m := a.as_map()
	lbs.radius = (m['radius'] or { json2.Any(0) }).f32()
	lbs.border_color = HexColor((m['border_color'] or { json2.Any('') }).str()).color()
	lbs.bg_color = HexColor((m['bg_color'] or { json2.Any('') }).str()).color()
	lbs.bg_color_hover = HexColor((m['bg_color_pressed'] or { json2.Any('') }).str()).color()
	lbs.bg_color_pressed = HexColor((m['bg_color_hover'] or { json2.Any('') }).str()).color()
	lbs.text_font_name = (m['text_font_name'] or { json2.Any('') }).str()
	lbs.text_color = HexColor((m['text_color'] or { json2.Any('') }).str()).color()
	lbs.text_size = (m['text_size'] or { json2.Any(0) }).int()
	lbs.text_align = unsafe { TextHorizontalAlign((m['text_align'] or { json2.Any(0) }).int()) }
	lbs.text_vertical_align = unsafe { TextVerticalAlign((m['text_vertical_align'] or { json2.Any(0) }).int()) }
}

pub fn (mut lb ListBox) load_style() {
	// println("btn load style $lb.theme_style")
	mut style := if lb.theme_style == '' { lb.ui.window.theme_style } else { lb.theme_style }
	if lb.style_params.style != no_style {
		style = lb.style_params.style
	}
	lb.update_theme_style(style)
	// forced overload default style
	lb.update_style(lb.style_params)
}

pub fn (mut lb ListBox) update_theme_style(theme string) {
	// println("update_style <$p.style>")
	style := if theme == '' { 'default' } else { theme }
	if style != no_style && style in lb.ui.styles {
		lbs := lb.ui.styles[style].lb
		lb.theme_style = theme
		lb.update_shape_theme_style(lbs)
		mut dtw := DrawTextWidget(lb)
		dtw.update_theme_style(lbs)
	}
}

pub fn (mut lb ListBox) update_style(p ListBoxStyleParams) {
	lb.update_shape_style(p)
	mut dtw := DrawTextWidget(lb)
	dtw.update_theme_style_params(p)
}

fn (mut lb ListBox) update_shape_theme_style(lbs ListBoxStyle) {
	lb.style.radius = lbs.radius
	lb.style.border_color = lbs.border_color
	lb.style.bg_color = lbs.bg_color
	lb.style.bg_color_pressed = lbs.bg_color_pressed
	lb.style.bg_color_hover = lbs.bg_color_hover
}

fn (mut lb ListBox) update_shape_style(p ListBoxStyleParams) {
	if p.radius > 0 {
		lb.style.radius = p.radius
	}
	if p.border_color != no_color {
		lb.style.border_color = p.border_color
	}
	if p.bg_color != no_color {
		lb.style.bg_color = p.bg_color
	}
	if p.bg_color_pressed != no_color {
		lb.style.bg_color_pressed = p.bg_color_pressed
	}
	if p.bg_color_hover != no_color {
		lb.style.bg_color_hover = p.bg_color_hover
	}
}

fn (mut lb ListBox) update_style_params(p ListBoxStyleParams) {
	if p.radius > 0 {
		lb.style_params.radius = p.radius
	}
	if p.border_color != no_color {
		lb.style_params.border_color = p.border_color
	}
	if p.bg_color != no_color {
		lb.style_params.bg_color = p.bg_color
	}
	if p.bg_color_pressed != no_color {
		lb.style_params.bg_color_pressed = p.bg_color_pressed
	}
	if p.bg_color_hover != no_color {
		lb.style_params.bg_color_hover = p.bg_color_hover
	}
	mut dtw := DrawTextWidget(lb)
	dtw.update_theme_style_params(p)
}
