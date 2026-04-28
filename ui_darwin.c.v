// Copyright (c) 2020-2022 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file.
module ui

import macos
import sokol.sapp

#flag darwin -framework Cocoa

const ns_event_mask_any = u64(0xffffffffffffffff)
const ns_window_title_visible = u64(0)
const ns_window_title_hidden = u64(1)
const ns_window_style_full_size_content_view = u64(1 << 15)
const ns_window_close_button = u64(0)
const ns_window_miniaturize_button = u64(1)
const ns_window_zoom_button = u64(2)

fn current_app() macos.Id {
	return macos.msg_id(macos.get_class('NSApplication'), 'sharedApplication')
}

pub fn message_box(s string) {
	alert := macos.new('NSAlert')
	C.macos_objc_msg_void1(alert, macos.sel('setMessageText:'), macos.nsstring(s))
	_ = C.macos_objc_msg_i64(alert, macos.sel('runModal'))
}

pub fn notify(title string, msg string) {
	notification := macos.new('NSUserNotification')
	C.macos_objc_msg_void1(notification, macos.sel('setTitle:'), macos.nsstring(title))
	C.macos_objc_msg_void1(notification, macos.sel('setInformativeText:'), macos.nsstring(msg))
	notif_center := macos.msg_id(macos.get_class('NSUserNotificationCenter'),
		'defaultUserNotificationCenter')
	C.macos_objc_msg_void1(notif_center, macos.sel('deliverNotification:'), notification)
}

pub fn bundle_path() string {
	bundle := macos.msg_id(macos.get_class('NSBundle'), 'mainBundle')
	path := macos.msg_id(bundle, 'bundlePath')
	return macos.utf8_string(path)
}

pub fn wait_events() {
	app := current_app()
	distant_future := macos.msg_id(macos.get_class('NSDate'), 'distantFuture')
	mode := macos.nsstring(macos.run_loop_default_mode)
	event := C.macos_objc_msg_id4(app,
		macos.sel('nextEventMatchingMask:untilDate:inMode:dequeue:'), voidptr(ns_event_mask_any),
		distant_future, mode, voidptr(1))
	if event != unsafe { nil } {
		C.macos_objc_msg_void1(app, macos.sel('sendEvent:'), event)
	}
}

fn minimize_window(window voidptr) {
	C.macos_objc_msg_void1(macos.Id(window), macos.sel('performMiniaturize:'), unsafe { nil })
}

fn deminimize_window(window voidptr) {
	C.macos_objc_msg_void1(macos.Id(window), macos.sel('deminiaturize:'), unsafe { nil })
}

fn focus_window(window voidptr) {
	app := current_app()
	C.macos_objc_msg_void1(app, macos.sel('activateIgnoringOtherApps:'), voidptr(1))
	C.macos_objc_msg_void1(macos.Id(window), macos.sel('makeKeyAndOrderFront:'), unsafe { nil })
}

fn hide_window(window voidptr) {
	win := macos.Id(window)
	if win == unsafe { nil } {
		return
	}
	C.macos_objc_msg_void1(win, macos.sel('setIgnoresMouseEvents:'), voidptr(1))
	C.macos_objc_msg_void_f64(win, macos.sel('setAlphaValue:'), 0.0)
	frame := macos.msg_rect(win, 'frame')
	offscreen := macos.rect(-100000.0, -100000.0, frame.width, frame.height)
	C.macos_objc_msg_void_rect_bool_bool(win, macos.sel('setFrame:display:animate:'), offscreen,
		true, false)
	C.macos_objc_msg_void1(win, macos.sel('orderFront:'), unsafe { nil })
}

fn show_window_top_right(window voidptr, width int, height int, margin int) {
	win := macos.Id(window)
	if win == unsafe { nil } {
		return
	}
	mut screen := macos.msg_id(win, 'screen')
	if screen == unsafe { nil } {
		screen = macos.msg_id(macos.get_class('NSScreen'), 'mainScreen')
	}
	if screen == unsafe { nil } {
		return
	}
	visible := macos.msg_rect(screen, 'visibleFrame')
	current := macos.msg_rect(win, 'frame')
	popup_w := if width > 0 { f64(width) } else { current.width }
	popup_h := if height > 0 { f64(height) } else { current.height }
	inset := if margin >= 0 { f64(margin) } else { 10.0 }
	x := (visible.x + visible.width) - popup_w - inset
	y := (visible.y + visible.height) - popup_h - inset
	frame := macos.rect(x, y, popup_w, popup_h)
	C.macos_objc_msg_void1(win, macos.sel('setIgnoresMouseEvents:'), unsafe { nil })
	C.macos_objc_msg_void_f64(win, macos.sel('setAlphaValue:'), 1.0)
	C.macos_objc_msg_void_rect_bool_bool(win, macos.sel('setFrame:display:animate:'), frame, true,
		false)
	app := current_app()
	C.macos_objc_msg_void1(app, macos.sel('activateIgnoringOtherApps:'), voidptr(1))
	C.macos_objc_msg_void1(win, macos.sel('makeKeyAndOrderFront:'), unsafe { nil })
}

fn set_window_chrome(window voidptr, visible bool) {
	win := macos.Id(window)
	if win == unsafe { nil } {
		return
	}
	if visible {
		C.macos_objc_msg_void1(win, macos.sel('setTitleVisibility:'),
			voidptr(ns_window_title_visible))
		C.macos_objc_msg_void1(win, macos.sel('setTitlebarAppearsTransparent:'), unsafe { nil })
		C.macos_objc_msg_void1(win, macos.sel('setHasShadow:'), voidptr(1))
		C.macos_objc_msg_void1(win, macos.sel('setOpaque:'), voidptr(1))
		for button_kind in [ns_window_close_button, ns_window_miniaturize_button,
			ns_window_zoom_button] {
			button := C.macos_objc_msg_id_u64(win, macos.sel('standardWindowButton:'), button_kind)
			C.macos_objc_msg_void1(button, macos.sel('setHidden:'), unsafe { nil })
		}
		return
	}
	C.macos_objc_msg_void1(win, macos.sel('setTitleVisibility:'), voidptr(ns_window_title_hidden))
	C.macos_objc_msg_void1(win, macos.sel('setTitlebarAppearsTransparent:'), voidptr(1))
	C.macos_objc_msg_void1(win, macos.sel('setMovableByWindowBackground:'), voidptr(1))
	C.macos_objc_msg_void1(win, macos.sel('setHasShadow:'), unsafe { nil })
	C.macos_objc_msg_void1(win, macos.sel('setOpaque:'), unsafe { nil })
	for button_kind in [ns_window_close_button, ns_window_miniaturize_button, ns_window_zoom_button] {
		button := C.macos_objc_msg_id_u64(win, macos.sel('standardWindowButton:'), button_kind)
		C.macos_objc_msg_void1(button, macos.sel('setHidden:'), voidptr(1))
	}
	mask := macos.msg_u64(win, 'styleMask')
	C.macos_objc_msg_void_u64(win, macos.sel('setStyleMask:'),
		mask | ns_window_style_full_size_content_view)
}

pub fn (w &Window) hide_popup() {
	$if macos {
		_ = w
		x := sapp.macos_get_window()
		hide_window(x)
	}
}

pub fn (w &Window) show_popup_top_right(width int, height int, margin int) {
	$if macos {
		x := sapp.macos_get_window()
		show_window_top_right(x, width, height, margin)
	}
}

pub fn (w &Window) set_chrome_visible(visible bool) {
	$if macos {
		x := sapp.macos_get_window()
		set_window_chrome(x, visible)
	}
}
