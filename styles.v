module ui

import gg
import os
import x.json2

// define style outside Widget definition
// all styles would be collected inside one map attached to ui

pub const no_style = '_no_style_'
pub const no_color = gg.Color{0, 0, 0, 0}
pub const transparent = gg.Color{0, 0, 0, 1}

pub struct Style {
pub mut:
	win    WindowStyle
	btn    ButtonStyle
	pgbar  ProgressBarStyle
	cl     CanvasLayoutStyle
	stack  StackStyle
	tb     TextBoxStyle
	lb     ListBoxStyle
	cb     CheckBoxStyle
	radio  RadioStyle
	rect   RectangleStyle
	slider SliderStyle
	dd     DropdownStyle
	menu   MenuStyle
	label  LabelStyle
}

pub fn (s Style) to_json_any() json2.Any {
	mut obj := map[string]json2.Any{}
	obj['window'] = s.win.to_json_any()
	obj['button'] = s.btn.to_json_any()
	obj['progressbar'] = s.pgbar.to_json_any()
	obj['slider'] = s.slider.to_json_any()
	obj['dropdown'] = s.dd.to_json_any()
	obj['checkbox'] = s.cb.to_json_any()
	obj['radio'] = s.radio.to_json_any()
	obj['rectangle'] = s.rect.to_json_any()
	obj['menu'] = s.menu.to_json_any()
	obj['canvaslayout'] = s.cl.to_json_any()
	obj['stack'] = s.stack.to_json_any()
	obj['textbox'] = s.tb.to_json_any()
	obj['listbox'] = s.lb.to_json_any()
	obj['label'] = s.label.to_json_any()
	return obj
}

pub fn parse_style_json_file(path string) Style {
	text := os.read_file(path) or {
		eprintln('UI: using the default UI style, since the .json file `${path}` could not be read: ${err}')
		return default_style()
	}
	doc := json2.decode[json2.Any](text) or {
		eprintln('UI: using the default UI style, since the .json file `${path}` was invalid. JSON parse error: ${err}')
		return default_style()
	}
	m := doc.as_map()
	mut s := Style{}
	s.win.from_json(m['window'] or { json2.Any(map[string]json2.Any{}) })
	s.btn.from_json(m['button'] or { json2.Any(map[string]json2.Any{}) })
	s.pgbar.from_json(m['progressbar'] or { json2.Any(map[string]json2.Any{}) })
	s.slider.from_json(m['slider'] or { json2.Any(map[string]json2.Any{}) })
	s.dd.from_json(m['dropdown'] or { json2.Any(map[string]json2.Any{}) })
	s.cb.from_json(m['checkbox'] or { json2.Any(map[string]json2.Any{}) })
	s.radio.from_json(m['radio'] or { json2.Any(map[string]json2.Any{}) })
	s.rect.from_json(m['rectangle'] or { json2.Any(map[string]json2.Any{}) })
	s.menu.from_json(m['menu'] or { json2.Any(map[string]json2.Any{}) })
	s.cl.from_json(m['canvaslayout'] or { json2.Any(map[string]json2.Any{}) })
	s.stack.from_json(m['stack'] or { json2.Any(map[string]json2.Any{}) })
	s.tb.from_json(m['textbox'] or { json2.Any(map[string]json2.Any{}) })
	s.lb.from_json(m['listbox'] or { json2.Any(map[string]json2.Any{}) })
	s.label.from_json(m['label'] or { json2.Any(map[string]json2.Any{}) })
	return s
}

pub fn (s Style) as_json_file(path string) {
	text := json2.encode(s.to_json_any(), prettify: true)
	os.write_file(path, text) or { panic(err) }
}

pub fn style_json_file(style_id string) string {
	return os.join_path(settings_styles_dir, 'style_${style_id}.json')
}

// load styles

pub fn (mut gui UI) load_styles() {
	// ensure some theme styles are predefined
	$if no_load_styles ? {
		gui.styles['default'] = default_style()
		return
	}
	create_theme_styles()
	for style_id in ['default', 'red', 'blue'] {
		gui.load_style_from_file(style_id)
	}
}

pub fn (mut gui UI) load_style_from_file(style_id string) {
	style := parse_style_json_file(style_json_file(style_id))
	// println("$style_id: $style")
	gui.styles[style_id] = style
}

// predefined style

fn create_theme_styles() {
	if !os.exists(settings_styles_dir) {
		os.mkdir_all(settings_styles_dir) or { panic(err) }
	}
	if !os.exists(style_json_file('default')) {
		create_default_style_file()
	}
	if !os.exists(style_json_file('red')) {
		create_red_style_file()
	}
	if !os.exists(style_json_file('blue')) {
		create_blue_style_file()
	}
}

pub fn default_style() Style {
	// "" means default
	return Style{
		// window
		win: WindowStyle{
			bg_color: default_window_color
		}
		// button
		btn: ButtonStyle{
			radius:           .1
			border_color:     button_border_color
			bg_color:         gg.white
			bg_color_pressed: gg.rgb(119, 119, 119)
			bg_color_hover:   gg.rgb(219, 219, 219)
		}
		// progressbar
		pgbar: ProgressBarStyle{
			color:           gg.rgb(87, 153, 245)
			border_color:    gg.rgb(76, 133, 213)
			bg_color:        gg.rgb(219, 219, 219)
			bg_border_color: gg.rgb(191, 191, 191)
		}
	}
}

pub fn create_default_style_file() {
	default_style().as_json_file(style_json_file('default'))
}

pub fn blue_style() Style {
	return Style{
		// win
		win: WindowStyle{
			bg_color: gg.blue
		}
		// button
		btn: ButtonStyle{
			radius:           .3
			border_color:     button_border_color
			bg_color:         gg.light_blue
			bg_color_pressed: gg.rgb(0, 0, 119)
			bg_color_hover:   gg.rgb(0, 0, 219)
		}
		// progressbar
		pgbar: ProgressBarStyle{
			color:           gg.rgb(87, 153, 245)
			border_color:    gg.rgb(76, 133, 213)
			bg_color:        gg.rgb(219, 219, 219)
			bg_border_color: gg.rgb(191, 191, 191)
		}
		// canvas layout
		cl: CanvasLayoutStyle{
			bg_color: transparent // gg.rgb(220, 220, 255)
		}
		// stack
		stack: StackStyle{
			bg_color: transparent // gg.rgb(220, 220, 255)
		}
	}
}

pub fn create_blue_style_file() {
	blue_style().as_json_file(os.join_path(settings_styles_dir, 'style_blue.json'))
}

pub fn red_style() Style {
	return Style{
		// win
		win: WindowStyle{
			bg_color: gg.red
		}
		// button
		btn: ButtonStyle{
			radius:           .3
			border_color:     button_border_color
			bg_color:         gg.light_red
			bg_color_pressed: gg.rgb(119, 0, 0)
			bg_color_hover:   gg.rgb(219, 0, 0)
			text_color:       gg.red
		}
		// progressbar
		pgbar: ProgressBarStyle{
			color:           gg.rgb(245, 153, 87)
			border_color:    gg.rgb(213, 133, 76)
			bg_color:        gg.rgb(219, 219, 219)
			bg_border_color: gg.rgb(191, 191, 191)
		}
		// slider
		slider: SliderStyle{
			thumb_color: gg.rgb(245, 153, 87)
		}
		// canvas layout
		cl: CanvasLayoutStyle{
			bg_color: transparent // gg.rgb(255, 220, 220)
		}
		// stack
		stack: StackStyle{
			bg_color: transparent // gg.rgb(255, 220, 220)
		}
	}
}

pub fn create_red_style_file() {
	red_style().as_json_file(os.join_path(settings_styles_dir, 'style_red.json'))
}

// parent style

pub fn (l Layout) bg_color() gg.Color {
	mut col := no_color
	if l is Stack {
		col = l.style.bg_color
		if col in [no_color, transparent] {
			return l.parent.bg_color()
		}
	} else if l is CanvasLayout {
		col = l.style.bg_color
		if col in [no_color, transparent] {
			return l.parent.bg_color()
		}
	} else if l is Window {
		col = l.bg_color
	}
	return col
}

// add shortcut
pub fn (mut window Window) add_shortcut_theme() {
	mut sc := Shortcutable(window)
	sc.add_shortcut('ctrl + t', fn (mut w Window) {
		themes := ['default', 'red', 'blue']
		for i, theme in themes {
			if w.theme_style == theme {
				w.theme_style = themes[if i + 1 == themes.len { 0 } else { i + 1 }]
				break
			}
		}
		mut l := Layout(w)
		l.update_theme_style(w.theme_style)
	})
}
