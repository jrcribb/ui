module ui

import gg
import x.json2

// Dropdown

pub struct DropdownShapeStyle {
pub mut:
	bg_color     gg.Color = gg.rgb(240, 240, 240)
	border_color gg.Color = gg.rgb(223, 223, 223)
	focus_color  gg.Color = gg.rgb(50, 50, 50)
	drawer_color gg.Color = gg.rgb(255, 255, 255)
}

struct DropdownStyle {
	DropdownShapeStyle
pub mut:
	text_font_name      string = 'system'
	text_color          gg.Color
	text_size           int                 = 16
	text_align          TextHorizontalAlign = .left
	text_vertical_align TextVerticalAlign   = .top
}

@[params]
pub struct DropdownStyleParams {
	WidgetTextStyleParams
pub mut:
	style        string   = no_style
	bg_color     gg.Color = no_color
	border_color gg.Color = no_color
	focus_color  gg.Color = no_color
	drawer_color gg.Color = no_color
}

pub fn dropdown_style(p DropdownStyleParams) DropdownStyleParams {
	return p
}

pub fn (dds DropdownStyle) to_json_any() json2.Any {
	mut obj := map[string]json2.Any{}
	obj['bg_color'] = hex_color(dds.bg_color)
	obj['border_color'] = hex_color(dds.border_color)
	obj['focus_color'] = hex_color(dds.focus_color)
	obj['drawer_color'] = hex_color(dds.drawer_color)
	return obj
}

pub fn (mut dds DropdownStyle) from_json(a json2.Any) {
	m := a.as_map()
	dds.bg_color = HexColor((m['bg_color'] or { json2.Any('') }).str()).color()
	dds.border_color = HexColor((m['border_color'] or { json2.Any('') }).str()).color()
	dds.focus_color = HexColor((m['focus_color'] or { json2.Any('') }).str()).color()
	dds.drawer_color = HexColor((m['drawer_color'] or { json2.Any('') }).str()).color()
}

fn (mut dd Dropdown) load_style() {
	// println("pgbar load style $dd.theme_style")
	mut style := if dd.theme_style == '' { dd.ui.window.theme_style } else { dd.theme_style }
	if dd.style_params.style != no_style {
		style = dd.style_params.style
	}
	dd.update_theme_style(style)
	// forced overload default style
	dd.update_style(dd.style_params)
}

pub fn (mut dd Dropdown) update_theme_style(theme string) {
	// println("update_style <$p.style>")
	style := if theme == '' { 'default' } else { theme }
	if style != no_style && style in dd.ui.styles {
		dds := dd.ui.styles[style].dd
		dd.theme_style = theme
		dd.update_shape_theme_style(dds)
		mut dtw := DrawTextWidget(dd)
		dtw.update_theme_style(dds)
	}
}

pub fn (mut dd Dropdown) update_style(p DropdownStyleParams) {
	// println("update_style <$p.style>")
	dd.update_shape_style(p)
	mut dtw := DrawTextWidget(dd)
	dtw.update_theme_style_params(p)
}

fn (mut dd Dropdown) update_shape_theme_style(dds DropdownStyle) {
	dd.style.bg_color = dds.bg_color
	dd.style.border_color = dds.border_color
	dd.style.focus_color = dds.focus_color
	dd.style.drawer_color = dds.drawer_color
}

pub fn (mut dd Dropdown) update_shape_style(p DropdownStyleParams) {
	if p.bg_color != no_color {
		dd.style.bg_color = p.bg_color
	}
	if p.border_color != no_color {
		dd.style.border_color = p.border_color
	}
	if p.focus_color != no_color {
		dd.style.focus_color = p.focus_color
	}
	if p.drawer_color != no_color {
		dd.style.drawer_color = p.drawer_color
	}
}

pub fn (mut dd Dropdown) update_style_params(p DropdownStyleParams) {
	if p.bg_color != no_color {
		dd.style_params.bg_color = p.bg_color
	}
	if p.border_color != no_color {
		dd.style_params.border_color = p.border_color
	}
	if p.focus_color != no_color {
		dd.style_params.focus_color = p.focus_color
	}
	if p.drawer_color != no_color {
		dd.style_params.drawer_color = p.drawer_color
	}
	mut dtw := DrawTextWidget(dd)
	dtw.update_theme_style_params(p)
}
