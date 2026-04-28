module ui

import gg
import x.json2

// Menu

pub struct MenuShapeStyle {
pub mut:
	border_color   gg.Color = menu_border_color
	bar_color      gg.Color = menu_bar_color
	bg_color       gg.Color = menu_bg_color
	bg_color_hover gg.Color = menu_bg_color_hover
}

pub struct MenuStyle {
	MenuShapeStyle // text_style TextStyle
pub mut:
	text_font_name      string = 'system'
	text_color          gg.Color
	text_size           int                 = 16
	text_align          TextHorizontalAlign = .left
	text_vertical_align TextVerticalAlign   = .top
}

@[params]
pub struct MenuStyleParams {
	WidgetTextStyleParams
mut:
	style          string   = no_style
	border_color   gg.Color = no_color
	bar_color      gg.Color = no_color
	bg_color       gg.Color = no_color
	bg_color_hover gg.Color = no_color
}

pub fn menu_style(p MenuStyleParams) MenuStyleParams {
	return p
}

pub fn (ms MenuStyle) to_json_any() json2.Any {
	mut obj := map[string]json2.Any{}
	obj['border_color'] = hex_color(ms.border_color)
	obj['bar_color'] = hex_color(ms.bar_color)
	obj['bg_color'] = hex_color(ms.bg_color)
	obj['bg_color_hover'] = hex_color(ms.bg_color_hover)
	obj['text_font_name'] = ms.text_font_name
	obj['text_color'] = hex_color(ms.text_color)
	obj['text_size'] = ms.text_size
	obj['text_align'] = int(ms.text_align)
	obj['text_vertical_align'] = int(ms.text_vertical_align)
	return obj
}

pub fn (mut ms MenuStyle) from_json(a json2.Any) {
	m := a.as_map()
	ms.border_color = HexColor((m['border_color'] or { json2.Any('') }).str()).color()
	ms.bar_color = HexColor((m['bar_color'] or { json2.Any('') }).str()).color()
	ms.bg_color = HexColor((m['bg_color'] or { json2.Any('') }).str()).color()
	ms.bg_color_hover = HexColor((m['bg_color_hover'] or { json2.Any('') }).str()).color()
	ms.text_font_name = (m['text_font_name'] or { json2.Any('') }).str()
	ms.text_color = HexColor((m['text_color'] or { json2.Any('') }).str()).color()
	ms.text_size = (m['text_size'] or { json2.Any(0) }).int()
	ms.text_align = unsafe { TextHorizontalAlign((m['text_align'] or { json2.Any(0) }).int()) }
	ms.text_vertical_align = unsafe { TextVerticalAlign((m['text_vertical_align'] or { json2.Any(0) }).int()) }
}

pub fn (mut m Menu) load_style() {
	// println("btn load style $m.theme_style")
	mut style := if m.theme_style == '' { m.ui.window.theme_style } else { m.theme_style }
	if m.style_params.style != no_style {
		style = m.style_params.style
	}
	m.update_theme_style(style)
	// forced overload default style
	m.update_style(m.style_params)
}

pub fn (mut m Menu) update_theme_style(theme string) {
	// println("update_style $m.id")
	style := if theme == '' { 'default' } else { theme }
	if style != no_style && style in m.ui.styles {
		ms := m.ui.styles[style].menu
		m.theme_style = theme
		m.update_shape_theme_style(ms)
		mut dtw := DrawTextWidget(m)
		dtw.update_theme_style(ms)
	}
}

pub fn (mut m Menu) update_style(p MenuStyleParams) {
	m.update_shape_style(p)
	mut dtw := DrawTextWidget(m)
	dtw.update_theme_style_params(p)
}

fn (mut m Menu) update_shape_theme_style(ms MenuStyle) {
	m.style.border_color = ms.border_color
	m.style.bar_color = ms.bar_color
	m.style.bg_color = ms.bg_color
	m.style.bg_color_hover = ms.bg_color_hover
}

fn (mut m Menu) update_shape_style(p MenuStyleParams) {
	if p.border_color != no_color {
		m.style.border_color = p.border_color
	}
	if p.bar_color != no_color {
		m.style.bar_color = p.bar_color
	}
	if p.bg_color != no_color {
		m.style.bg_color = p.bg_color
	}
	if p.bg_color_hover != no_color {
		m.style.bg_color_hover = p.bg_color_hover
	}
}

fn (mut m Menu) update_style_params(p MenuStyleParams) {
	if p.border_color != no_color {
		m.style_params.border_color = p.border_color
	}
	if p.bar_color != no_color {
		m.style_params.bar_color = p.bar_color
	}
	if p.bg_color != no_color {
		m.style_params.bg_color = p.bg_color
	}
	if p.bg_color_hover != no_color {
		m.style_params.bg_color_hover = p.bg_color_hover
	}
	mut dtw := DrawTextWidget(m)
	dtw.update_theme_style_params(p)
}
