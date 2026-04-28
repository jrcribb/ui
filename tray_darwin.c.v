module ui

import macos

$if macos {
	#flag -framework Cocoa
}

pub type TrayActionFn = fn (voidptr)

@[params]
pub struct TrayParams {
pub:
	title      string       = 'CX'
	user_data  voidptr      = unsafe { nil }
	on_open    TrayActionFn = unsafe { nil }
	on_refresh TrayActionFn = unsafe { nil }
	on_quit    TrayActionFn = unsafe { nil }
}

const tray_status_item_length = -1.0
const tray_event_right_mouse_up = i64(4)
const tray_event_mask_left_mouse_up = u64(1 << 2)
const tray_event_mask_right_mouse_up = u64(1 << 4)
const tray_modifier_control = u64(1 << 18)
const tray_activation_policy_accessory = u64(1)
const tray_target_class_name = 'VUITrayTarget'

const tray_state_singleton = &TrayState{}

@[heap]
struct TrayState {
mut:
	status_item macos.Id
	target      macos.Id
	menu        macos.Id
	on_open     TrayActionFn = unsafe { TrayActionFn(nil) }
	on_refresh  TrayActionFn = unsafe { TrayActionFn(nil) }
	on_quit     TrayActionFn = unsafe { TrayActionFn(nil) }
	user_data   voidptr      = unsafe { nil }
}

fn tray_state() &TrayState {
	return unsafe { &TrayState(tray_state_singleton) }
}

fn tray_title_nsstring(title string) macos.Id {
	if title.len == 0 {
		return macos.nsstring('CX')
	}
	return macos.nsstring(title)
}

fn tray_current_app() macos.Id {
	return macos.msg_id(macos.get_class('NSApplication'), 'sharedApplication')
}

fn tray_fire_open(self macos.Id, _cmd macos.Sel, sender macos.Id) {
	_ = self
	_ = _cmd
	_ = sender
	state := tray_state()
	if state.on_open != unsafe { TrayActionFn(nil) } {
		state.on_open(state.user_data)
	}
}

fn tray_fire_refresh(self macos.Id, _cmd macos.Sel, sender macos.Id) {
	_ = self
	_ = _cmd
	_ = sender
	state := tray_state()
	if state.on_refresh != unsafe { TrayActionFn(nil) } {
		state.on_refresh(state.user_data)
	}
}

fn tray_fire_quit(self macos.Id, _cmd macos.Sel, sender macos.Id) {
	_ = self
	_ = _cmd
	_ = sender
	state := tray_state()
	if state.on_quit != unsafe { TrayActionFn(nil) } {
		state.on_quit(state.user_data)
	}
}

fn tray_status_click(self macos.Id, _cmd macos.Sel, sender macos.Id) {
	_ = self
	_ = _cmd
	state := tray_state()
	app := tray_current_app()
	event := macos.msg_id(app, 'currentEvent')
	if event != unsafe { nil } {
		event_type := macos.msg_i64(event, 'type')
		modifier_flags := macos.msg_u64(event, 'modifierFlags')
		if event_type == tray_event_right_mouse_up || (modifier_flags & tray_modifier_control) != 0 {
			if state.menu != unsafe { nil } {
				view := macos.msg_id(sender, 'superview')
				C.macos_objc_msg_void3(macos.get_class('NSMenu'),
					macos.sel('popUpContextMenu:withEvent:forView:'), state.menu, event, view)
			}
			return
		}
	}
	if state.on_open != unsafe { TrayActionFn(nil) } {
		state.on_open(state.user_data)
	}
}

fn ensure_tray_target_class() macos.Class {
	existing := macos.get_class(tray_target_class_name)
	if existing != unsafe { nil } {
		return macos.Class(existing)
	}
	cls := C.macos_objc_allocate_class_pair(macos.Class(macos.get_class('NSObject')),
		&char(tray_target_class_name.str), 0)
	assert cls != unsafe { nil }
	assert C.macos_class_add_method(cls, macos.sel('openAction:'), voidptr(tray_fire_open), c'v@:@')
	assert C.macos_class_add_method(cls, macos.sel('refreshAction:'), voidptr(tray_fire_refresh),
		c'v@:@')
	assert C.macos_class_add_method(cls, macos.sel('quitAction:'), voidptr(tray_fire_quit), c'v@:@')
	assert C.macos_class_add_method(cls, macos.sel('statusClick:'), voidptr(tray_status_click),
		c'v@:@')
	C.macos_objc_register_class_pair(cls)
	return cls
}

fn build_tray_menu(target macos.Id) macos.Id {
	menu := C.macos_objc_msg_id1(macos.alloc('NSMenu'), macos.sel('initWithTitle:'),
		macos.nsstring('V UI Tray'))
	open_item := C.macos_objc_msg_id3(macos.alloc('NSMenuItem'),
		macos.sel('initWithTitle:action:keyEquivalent:'), macos.nsstring('Open'),
		macos.sel('openAction:'), macos.nsstring(''))
	C.macos_objc_msg_void1(open_item, macos.sel('setTarget:'), target)
	C.macos_objc_msg_void1(menu, macos.sel('addItem:'), open_item)

	refresh_item := C.macos_objc_msg_id3(macos.alloc('NSMenuItem'),
		macos.sel('initWithTitle:action:keyEquivalent:'), macos.nsstring('Refresh'),
		macos.sel('refreshAction:'), macos.nsstring(''))
	C.macos_objc_msg_void1(refresh_item, macos.sel('setTarget:'), target)
	C.macos_objc_msg_void1(menu, macos.sel('addItem:'), refresh_item)

	separator := macos.msg_id(macos.get_class('NSMenuItem'), 'separatorItem')
	C.macos_objc_msg_void1(menu, macos.sel('addItem:'), separator)

	quit_item := C.macos_objc_msg_id3(macos.alloc('NSMenuItem'),
		macos.sel('initWithTitle:action:keyEquivalent:'), macos.nsstring('Quit'),
		macos.sel('quitAction:'), macos.nsstring(''))
	C.macos_objc_msg_void1(quit_item, macos.sel('setTarget:'), target)
	C.macos_objc_msg_void1(menu, macos.sel('addItem:'), quit_item)

	return menu
}

pub fn tray_init(c TrayParams) {
	$if macos {
		mut state := tray_state()
		state.user_data = c.user_data
		state.on_open = c.on_open
		state.on_refresh = c.on_refresh
		state.on_quit = c.on_quit

		app := tray_current_app()
		C.macos_objc_msg_void1(app, macos.sel('setActivationPolicy:'),
			voidptr(tray_activation_policy_accessory))

		if state.target == unsafe { nil } {
			cls := ensure_tray_target_class()
			state.target = macos.msg_id(macos.Id(cls), 'new')
		}
		if state.status_item == unsafe { nil } {
			status_bar := macos.msg_id(macos.get_class('NSStatusBar'), 'systemStatusBar')
			state.status_item = C.macos_objc_msg_id_f64(status_bar,
				macos.sel('statusItemWithLength:'), tray_status_item_length)
		}
		button := macos.msg_id(state.status_item, 'button')
		if button != unsafe { nil } {
			C.macos_objc_msg_void1(button, macos.sel('setTitle:'), tray_title_nsstring(c.title))
			C.macos_objc_msg_void1(button, macos.sel('setTarget:'), state.target)
			C.macos_objc_msg_void1(button, macos.sel('setAction:'), macos.sel('statusClick:'))
			C.macos_objc_msg_void1(button, macos.sel('sendActionOn:'),
				voidptr(tray_event_mask_left_mouse_up | tray_event_mask_right_mouse_up))
		}
		state.menu = build_tray_menu(state.target)
	} $else {
		_ = c
	}
}

pub fn tray_set_title(title string) {
	$if macos {
		mut state := tray_state()
		if state.status_item == unsafe { nil } {
			return
		}
		button := macos.msg_id(state.status_item, 'button')
		if button == unsafe { nil } {
			return
		}
		C.macos_objc_msg_void1(button, macos.sel('setTitle:'), tray_title_nsstring(title))
	} $else {
		_ = title
	}
}
