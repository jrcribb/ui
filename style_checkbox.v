module ui

import gg
import x.json2

// CheckBox

pub struct CheckBoxShapeStyle {
pub mut:
	check_mode   string   = 'check' // or "check_white" and maybe one day "square" and "square_white"
	border_color gg.Color = cb_border_color
	bg_color     gg.Color = gg.white
}

pub struct CheckBoxStyle {
	CheckBoxShapeStyle // text_style TextStyle
pub mut:
	text_font_name      string = 'system'
	text_color          gg.Color
	text_size           int                 = 16
	text_align          TextHorizontalAlign = .left
	text_vertical_align TextVerticalAlign   = .top
}

@[params]
pub struct CheckBoxStyleParams {
	WidgetTextStyleParams
pub mut:
	style        string   = no_style
	border_color gg.Color = no_color
	bg_color     gg.Color = no_color
	check_mode   string
}

pub fn checkbox_style(p CheckBoxStyleParams) CheckBoxStyleParams {
	return p
}

pub fn (cbs CheckBoxStyle) to_json_any() json2.Any {
	mut obj := map[string]json2.Any{}
	obj['border_color'] = hex_color(cbs.border_color)
	obj['bg_color'] = hex_color(cbs.bg_color)
	obj['check_mode'] = cbs.check_mode
	obj['text_font_name'] = cbs.text_font_name
	obj['text_color'] = hex_color(cbs.text_color)
	obj['text_size'] = cbs.text_size
	obj['text_align'] = int(cbs.text_align)
	obj['text_vertical_align'] = int(cbs.text_vertical_align)
	return obj
}

pub fn (mut cbs CheckBoxStyle) from_json(a json2.Any) {
	m := a.as_map()
	cbs.border_color = HexColor((m['border_color'] or { json2.Any('') }).str()).color()
	cbs.bg_color = HexColor((m['bg_color'] or { json2.Any('') }).str()).color()
	cbs.check_mode = (m['check_mode'] or { json2.Any('') }).str()
	cbs.text_font_name = (m['text_font_name'] or { json2.Any('') }).str()
	cbs.text_color = HexColor((m['text_color'] or { json2.Any('') }).str()).color()
	cbs.text_size = (m['text_size'] or { json2.Any(0) }).int()
	cbs.text_align = unsafe { TextHorizontalAlign((m['text_align'] or { json2.Any(0) }).int()) }
	cbs.text_vertical_align = unsafe { TextVerticalAlign((m['text_vertical_align'] or { json2.Any(0) }).int()) }
}

pub fn (mut cb CheckBox) load_style() {
	// println("btn load style $cb.theme_style")
	mut style := if cb.theme_style == '' { cb.ui.window.theme_style } else { cb.theme_style }
	if cb.style_params.style != no_style {
		style = cb.style_params.style
	}
	cb.update_theme_style(style)
	// forced overload default style
	cb.update_style(cb.style_params)
	cb.ui.cb_image = cb.ui.img(cb.style.check_mode)
}

pub fn (mut cb CheckBox) update_theme_style(theme string) {
	// println("update_style <$p.style>")
	style := if theme == '' { 'default' } else { theme }
	if style != no_style && style in cb.ui.styles {
		cbs := cb.ui.styles[style].cb
		cb.theme_style = theme
		cb.update_shape_theme_style(cbs)
		mut dtw := DrawTextWidget(cb)
		dtw.update_theme_style(cbs)
	}
}

pub fn (mut cb CheckBox) update_style(p CheckBoxStyleParams) {
	cb.update_shape_style(p)
	mut dtw := DrawTextWidget(cb)
	dtw.update_theme_style_params(p)
}

fn (mut cb CheckBox) update_shape_theme_style(cbs CheckBoxStyle) {
	cb.style.border_color = cbs.border_color
	cb.style.bg_color = cbs.bg_color
	cb.style.check_mode = cbs.check_mode
}

fn (mut cb CheckBox) update_shape_style(p CheckBoxStyleParams) {
	if p.border_color != no_color {
		cb.style.border_color = p.border_color
	}
	if p.bg_color != no_color {
		cb.style.bg_color = p.bg_color
	}
	if p.check_mode != '' {
		cb.style.check_mode = p.check_mode
	}
}

fn (mut cb CheckBox) update_style_params(p CheckBoxStyleParams) {
	if p.border_color != no_color {
		cb.style_params.border_color = p.border_color
	}
	if p.bg_color != no_color {
		cb.style_params.bg_color = p.bg_color
	}
	if p.check_mode != '' {
		cb.style_params.check_mode = p.check_mode
	}
	mut dtw := DrawTextWidget(cb)
	dtw.update_theme_style_params(p)
}
