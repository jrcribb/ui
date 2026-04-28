module ui

import gg
import x.json2

// Radio

pub struct RadioShapeStyle {
pub mut:
	radio_mode   string = 'radio' // or "radio_white" and maybe one day "square" and "square_white"
	border_color gg.Color
	bg_color     gg.Color = gg.white
}

pub struct RadioStyle {
	RadioShapeStyle // text_style TextStyle
pub mut:
	text_font_name      string = 'system'
	text_color          gg.Color
	text_size           int                 = 16
	text_align          TextHorizontalAlign = .left
	text_vertical_align TextVerticalAlign   = .top
}

@[params]
pub struct RadioStyleParams {
	WidgetTextStyleParams
pub mut:
	style        string   = no_style
	border_color gg.Color = no_color
	bg_color     gg.Color = no_color
	radio_mode   string
}

pub fn radio_style(p RadioStyleParams) RadioStyleParams {
	return p
}

pub fn (rs RadioStyle) to_json_any() json2.Any {
	mut obj := map[string]json2.Any{}
	obj['border_color'] = hex_color(rs.border_color)
	obj['bg_color'] = hex_color(rs.bg_color)
	obj['radio_mode'] = rs.radio_mode
	obj['text_font_name'] = rs.text_font_name
	obj['text_color'] = hex_color(rs.text_color)
	obj['text_size'] = rs.text_size
	obj['text_align'] = int(rs.text_align)
	obj['text_vertical_align'] = int(rs.text_vertical_align)
	return obj
}

pub fn (mut rs RadioStyle) from_json(a json2.Any) {
	m := a.as_map()
	rs.border_color = HexColor((m['border_color'] or { json2.Any('') }).str()).color()
	rs.bg_color = HexColor((m['bg_color'] or { json2.Any('') }).str()).color()
	rs.radio_mode = (m['radio_mode'] or { json2.Any('') }).str()
	rs.text_font_name = (m['text_font_name'] or { json2.Any('') }).str()
	rs.text_color = HexColor((m['text_color'] or { json2.Any('') }).str()).color()
	rs.text_size = (m['text_size'] or { json2.Any(0) }).int()
	rs.text_align = unsafe { TextHorizontalAlign((m['text_align'] or { json2.Any(0) }).int()) }
	rs.text_vertical_align = unsafe { TextVerticalAlign((m['text_vertical_align'] or { json2.Any(0) }).int()) }
}

pub fn (mut r Radio) load_style() {
	// println("btn load style $r.theme_style")
	mut style := if r.theme_style == '' { r.ui.window.theme_style } else { r.theme_style }
	if r.style_params.style != no_style {
		style = r.style_params.style
	}
	r.update_theme_style(style)
	// forced overload default style
	r.update_style(r.style_params)
	r.ui.radio_selected_image = r.ui.img(r.style.radio_mode + '_selected')
}

pub fn (mut r Radio) update_theme_style(theme string) {
	// println("update_style <$p.style>")
	style := if theme == '' { 'default' } else { theme }
	if style != no_style && style in r.ui.styles {
		rs := r.ui.styles[style].radio
		r.theme_style = theme
		r.update_shape_theme_style(rs)
		mut dtw := DrawTextWidget(r)
		dtw.update_theme_style(rs)
	}
}

pub fn (mut r Radio) update_style(p RadioStyleParams) {
	r.update_shape_style(p)
	mut dtw := DrawTextWidget(r)
	dtw.update_theme_style_params(p)
}

fn (mut r Radio) update_shape_theme_style(rs RadioStyle) {
	r.style.border_color = rs.border_color
	r.style.bg_color = rs.bg_color
	r.style.radio_mode = rs.radio_mode
}

fn (mut r Radio) update_shape_style(p RadioStyleParams) {
	if p.border_color != no_color {
		r.style.border_color = p.border_color
	}
	if p.bg_color != no_color {
		r.style.bg_color = p.bg_color
	}
	if p.radio_mode != '' {
		r.style.radio_mode = p.radio_mode
	}
}

fn (mut r Radio) update_style_params(p RadioStyleParams) {
	if p.border_color != no_color {
		r.style_params.border_color = p.border_color
	}
	if p.bg_color != no_color {
		r.style_params.bg_color = p.bg_color
	}
	if p.radio_mode != '' {
		r.style_params.radio_mode = p.radio_mode
	}
	mut dtw := DrawTextWidget(r)
	dtw.update_theme_style_params(p)
}
