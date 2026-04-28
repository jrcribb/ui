module webview

import json
import macos

#flag darwin -framework Cocoa
#flag darwin -framework WebKit

const (
	darwin_webview_user_agent                 = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 14_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.4 Safari/605.1.15'
	darwin_webview_activation_policy_regular  = u64(0)
	darwin_webview_window_style_mask          = u64((1 << 0) | (1 << 1) | (1 << 2) | (1 << 3))
	darwin_webview_backing_store_buffered     = u64(2)
	darwin_webview_user_script_document_start = u64(0)
	darwin_navigation_delegate_class_name     = 'VUIWKNavigationDelegate'
	darwin_script_handler_class_name          = 'VUIWKScriptHandler'
)

const darwin_webview_state_singleton = &DarwinWebViewState{}

@[heap]
struct DarwinWebViewState {
mut:
	window              macos.Id
	webview             macos.Id
	navigation_delegate macos.Id
	script_handler      macos.Id
	js_val              string
	cookie_val          string
}

fn darwin_webview_state() &DarwinWebViewState {
	return unsafe { &DarwinWebViewState(darwin_webview_state_singleton) }
}

fn darwin_webview_finished_navigation(self macos.Id, _cmd macos.Sel, web_view macos.Id, navigation macos.Id) {
	_ = self
	_ = _cmd
	_ = web_view
	_ = navigation
}

fn darwin_webview_received_script_message(self macos.Id, _cmd macos.Sel, user_content_controller macos.Id, message macos.Id) {
	_ = self
	_ = _cmd
	_ = user_content_controller
	mut state := darwin_webview_state()
	body := macos.msg_id(message, 'body')
	state.js_val = macos.description_string(body)
}

fn ensure_navigation_delegate_class() macos.Class {
	existing := macos.get_class(darwin_navigation_delegate_class_name)
	if existing != unsafe { nil } {
		return macos.Class(existing)
	}
	cls := C.macos_objc_allocate_class_pair(macos.Class(macos.get_class('NSObject')), &char(darwin_navigation_delegate_class_name.str), 0)
	assert cls != unsafe { nil }
	protocol := macos.get_protocol('WKNavigationDelegate')
	if protocol != unsafe { nil } {
		C.macos_class_add_protocol(cls, protocol)
	}
	assert C.macos_class_add_method(cls, macos.sel('webView:didFinishNavigation:'), voidptr(darwin_webview_finished_navigation), c'v@:@@')
	C.macos_objc_register_class_pair(cls)
	return cls
}

fn ensure_script_handler_class() macos.Class {
	existing := macos.get_class(darwin_script_handler_class_name)
	if existing != unsafe { nil } {
		return macos.Class(existing)
	}
	cls := C.macos_objc_allocate_class_pair(macos.Class(macos.get_class('NSObject')), &char(darwin_script_handler_class_name.str), 0)
	assert cls != unsafe { nil }
	protocol := macos.get_protocol('WKScriptMessageHandler')
	if protocol != unsafe { nil } {
		C.macos_class_add_protocol(cls, protocol)
	}
	assert C.macos_class_add_method(cls, macos.sel('userContentController:didReceiveScriptMessage:'), voidptr(darwin_webview_received_script_message), c'v@:@@')
	C.macos_objc_register_class_pair(cls)
	return cls
}

fn current_app() macos.Id {
	return macos.msg_id(macos.get_class('NSApplication'), 'sharedApplication')
}

fn user_content_controller_for_config(config macos.Id) macos.Id {
	mut controller := macos.msg_id(config, 'userContentController')
	if controller != unsafe { nil } {
		return controller
	}
	controller = macos.new('WKUserContentController')
	C.macos_objc_msg_void1(config, macos.sel('setUserContentController:'), controller)
	return controller
}

fn build_eval_bridge_script(js string) string {
	encoded_js := json.encode(js)
	return '(function(){try{var __vui_result = eval(${encoded_js});window.webkit.messageHandlers.vui.postMessage(__vui_result == null ? "" : String(__vui_result));}catch(e){window.webkit.messageHandlers.vui.postMessage(String(e));}})();'
}

pub fn new_darwin_web_view(url string, title string, js_on_init string) voidptr {
	mut state := darwin_webview_state()
	app := current_app()
	C.macos_objc_msg_void1(app, macos.sel('setActivationPolicy:'), voidptr(darwin_webview_activation_policy_regular))

	prefs := macos.new('WKPreferences')
	config := macos.new('WKWebViewConfiguration')
	C.macos_objc_msg_void1(config, macos.sel('setPreferences:'), prefs)
	controller := user_content_controller_for_config(config)

	frame := macos.rect(0, 0, 950, 800)
	web_view := C.macos_objc_msg_id_rect_obj(macos.alloc('WKWebView'), macos.sel('initWithFrame:configuration:'),
		frame, config)
	C.macos_objc_msg_void1(web_view, macos.sel('setCustomUserAgent:'), macos.nsstring(darwin_webview_user_agent))

	window_rect := macos.rect(0, 0, 1000, 800)
	window := C.macos_objc_msg_id_rect_u64_u64_bool(macos.alloc('NSWindow'),
		macos.sel('initWithContentRect:styleMask:backing:defer:'), window_rect,
		darwin_webview_window_style_mask, darwin_webview_backing_store_buffered, false)
	C.macos_objc_msg_void1(window, macos.sel('setTitle:'), macos.nsstring(title))
	C.macos_objc_msg_void1(window, macos.sel('setReleasedWhenClosed:'), voidptr(0))

	navigation_delegate_cls := ensure_navigation_delegate_class()
	state.navigation_delegate = macos.msg_id(macos.Id(navigation_delegate_cls), 'new')
	C.macos_objc_msg_void1(web_view, macos.sel('setNavigationDelegate:'), state.navigation_delegate)

	script_handler_cls := ensure_script_handler_class()
	state.script_handler = macos.msg_id(macos.Id(script_handler_cls), 'new')
	C.macos_objc_msg_void2(controller, macos.sel('addScriptMessageHandler:name:'), state.script_handler,
		macos.nsstring('vui'))

	if js_on_init.len > 0 {
		user_script := C.macos_objc_msg_id3(macos.alloc('WKUserScript'),
			macos.sel('initWithSource:injectionTime:forMainFrameOnly:'), macos.nsstring(js_on_init),
			voidptr(darwin_webview_user_script_document_start), voidptr(0))
		C.macos_objc_msg_void1(controller, macos.sel('addUserScript:'), user_script)
	}

	nsurl := C.macos_objc_msg_id1(macos.get_class('NSURL'), macos.sel('URLWithString:'), macos.nsstring(url))
	request := C.macos_objc_msg_id1(macos.get_class('NSURLRequest'), macos.sel('requestWithURL:'), nsurl)
	C.macos_objc_msg_void1(web_view, macos.sel('loadRequest:'), request)
	C.macos_objc_msg_void1(window, macos.sel('setContentView:'), web_view)
	C.macos_objc_msg_void1(window, macos.sel('makeKeyAndOrderFront:'), unsafe { nil })

	state.window = window
	state.webview = web_view
	state.js_val = ''
	state.cookie_val = ''
	return web_view
}

pub fn darwin_webview_eval_js(obj voidptr, js string) {
	web_view := macos.Id(obj)
	if web_view == unsafe { nil } {
		return
	}
	C.macos_objc_msg_void2(web_view, macos.sel('evaluateJavaScript:completionHandler:'),
		macos.nsstring(build_eval_bridge_script(js)), unsafe { nil })
}

pub fn darwin_webview_load(obj voidptr, url string) {
	web_view := macos.Id(obj)
	if web_view == unsafe { nil } {
		return
	}
	nsurl := C.macos_objc_msg_id1(macos.get_class('NSURL'), macos.sel('URLWithString:'), macos.nsstring(url))
	request := C.macos_objc_msg_id1(macos.get_class('NSURLRequest'), macos.sel('requestWithURL:'), nsurl)
	C.macos_objc_msg_void1(web_view, macos.sel('loadRequest:'), request)
}

pub fn darwin_delete_all_cookies2(obj voidptr) {
	web_view := macos.Id(obj)
	if web_view == unsafe { nil } {
		return
	}
	config := macos.msg_id(web_view, 'configuration')
	data_store := macos.msg_id(config, 'websiteDataStore')
	types := macos.msg_id(macos.get_class('WKWebsiteDataStore'), 'allWebsiteDataTypes')
	date_from := macos.msg_id(macos.get_class('NSDate'), 'distantPast')
	C.macos_objc_msg_void3(data_store, macos.sel('removeDataOfTypes:modifiedSince:completionHandler:'),
		types, date_from, unsafe { nil })
}

pub fn darwin_webview_close() {
	mut state := darwin_webview_state()
	if state.window == unsafe { nil } {
		return
	}
	C.macos_objc_msg_void0(state.window, macos.sel('close'))
	state.window = unsafe { nil }
	state.webview = unsafe { nil }
	state.navigation_delegate = unsafe { nil }
	state.script_handler = unsafe { nil }
}

pub fn darwin_delete_all_cookies() {
	data_store := macos.msg_id(macos.get_class('WKWebsiteDataStore'), 'defaultDataStore')
	types := macos.msg_id(macos.get_class('WKWebsiteDataStore'), 'allWebsiteDataTypes')
	date_from := macos.msg_id(macos.get_class('NSDate'), 'distantPast')
	C.macos_objc_msg_void3(data_store, macos.sel('removeDataOfTypes:modifiedSince:completionHandler:'),
		types, date_from, unsafe { nil })
}

pub fn darwin_get_webview_js_val() string {
	return darwin_webview_state().js_val
}

pub fn darwin_get_webview_cookie_val() string {
	return darwin_webview_state().cookie_val
}

pub fn (w &WebView) eval_js(s string) {
	darwin_webview_eval_js(w.obj, s)
}

pub fn (w &WebView) load(url string) {
	darwin_webview_load(w.obj, url)
}

pub fn delete_all_cookies() {
	darwin_delete_all_cookies()
}

pub fn (w &WebView) delete_all_cookies() {
	darwin_delete_all_cookies2(w.obj)
}