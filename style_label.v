module ui

import gg
import x.json2

pub struct LabelStyle {
pub mut:
	text_font_name      string = 'system'
	text_color          gg.Color
	text_size           int                 = 16
	text_align          TextHorizontalAlign = .left
	text_vertical_align TextVerticalAlign   = .top
}

pub struct LabelStyleParams {
	WidgetTextStyleParams
pub mut:
	style string = no_style
}

pub fn (ls LabelStyle) to_json_any() json2.Any {
	mut obj := map[string]json2.Any{}
	obj['text_font_name'] = ls.text_font_name
	obj['text_color'] = hex_color(ls.text_color)
	obj['text_size'] = ls.text_size
	obj['text_align'] = int(ls.text_align)
	obj['text_vertical_align'] = int(ls.text_vertical_align)
	return obj
}

pub fn (mut ls LabelStyle) from_json(a json2.Any) {
	m := a.as_map()
	ls.text_font_name = (m['text_font_name'] or { json2.Any('') }).str()
	ls.text_color = HexColor((m['text_color'] or { json2.Any('') }).str()).color()
	ls.text_size = (m['text_size'] or { json2.Any(0) }).int()
	ls.text_align = unsafe { TextHorizontalAlign((m['text_align'] or { json2.Any(0) }).int()) }
	ls.text_vertical_align = unsafe { TextVerticalAlign((m['text_vertical_align'] or { json2.Any(0) }).int()) }
}

pub fn (mut l Label) load_style() {
	// println("btn load style $rect.theme_style")
	mut style := if l.theme_style == '' { l.ui.window.theme_style } else { l.theme_style }
	if l.style_params.style != no_style {
		style = l.style_params.style
	}
	l.update_theme_style(style)
	// forced overload default style
	l.update_style(l.style_params)
}

pub fn (mut l Label) update_theme_style(theme string) {
	// println("update_style <$p.style>")
	style := if theme == '' { 'default' } else { theme }
	if style != no_style && style in l.ui.styles {
		ls := l.ui.styles[style].label
		l.theme_style = theme
		mut dtw := DrawTextWidget(l)
		dtw.update_theme_style(ls)
	}
}

pub fn (mut l Label) update_style(p LabelStyleParams) {
	mut dtw := DrawTextWidget(l)
	dtw.update_theme_style_params(p)
}
