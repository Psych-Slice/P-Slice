package backend;

import lime.app.Application;
import lime.system.Display;
import lime.system.System;

import flixel.util.FlxColor;

#if (cpp && windows)
@:buildXml('
<target id="haxe">
	<lib name="dwmapi.lib" if="windows"/>
	<lib name="gdi32.lib" if="windows"/>
</target>
')
@:cppFileCode('
#include <windows.h>
#include <dwmapi.h>
#include <winuser.h>
#include <wingdi.h>

#define attributeDarkMode 20
#define attributeDarkModeFallback 19

#define attributeCaptionColor 34
#define attributeTextColor 35
#define attributeBorderColor 36

struct HandleData {
	DWORD pid = 0;
	HWND handle = 0;
};

BOOL CALLBACK findByPID(HWND handle, LPARAM lParam) {
	DWORD targetPID = ((HandleData*)lParam)->pid;
	DWORD curPID = 0;

	GetWindowThreadProcessId(handle, &curPID);
	if (targetPID != curPID || GetWindow(handle, GW_OWNER) != (HWND)0 || !IsWindowVisible(handle)) {
		return TRUE;
	}

	((HandleData*)lParam)->handle = handle;
	return FALSE;
}

HWND curHandle = 0;
void getHandle() {
	if (curHandle == (HWND)0) {
		HandleData data;
		data.pid = GetCurrentProcessId();
		EnumWindows(findByPID, (LPARAM)&data);
		curHandle = data.handle;
	}
}
')
#end
class Native
{
	public static function __init__():Void
	{
		registerDPIAware();
	}

	public static function buildSystemInfo():String
	{
		var fullContents = 'System timestamp: ${DateUtil.generateTimestamp()}\n';
		var driverInfo = FlxG?.stage?.context3D?.driverInfo ?? 'N/A';
		fullContents += 'Driver info: ${driverInfo}\n';
		#if sys
		fullContents += 'Platform: ${Sys.systemName()}\n';
		#end

		fullContents += '\n';

		fullContents += '=====================\n';

		fullContents += '\n';

		#if cpp
		fullContents += 'HXCPP-Immix:';
		fullContents += '\n- Memory Used: ${cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE)} bytes';
		fullContents += '\n- Memory Reserved: ${cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_RESERVED)} bytes';
		fullContents += '\n- Memory Current Pool: ${cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_CURRENT)} bytes';
		fullContents += '\n- Memory Large Pool: ${cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_LARGE)} bytes';
		fullContents += '\n- HXCPP Debugger: ${#if HXCPP_DEBUGGER 'Enabled' #else 'Disabled' #end}';
		fullContents += '\n- HXCPP Exp Generational Mode: ${#if HXCPP_GC_GENERATIONAL 'Enabled' #else 'Disabled' #end}';
		fullContents += '\n- HXCPP Exp Moving GC: ${#if HXCPP_GC_MOVING 'Enabled' #else 'Disabled' #end}';
		fullContents += '\n- HXCPP Exp Moving GC: ${#if HXCPP_GC_DYNAMIC_SIZE 'Enabled' #else 'Disabled' #end}';
		fullContents += '\n- HXCPP Exp Moving GC: ${#if HXCPP_GC_BIG_BLOCKS 'Enabled' #else 'Disabled' #end}';
		fullContents += '\n- HXCPP Debug Link: ${#if HXCPP_DEBUG_LINK 'Enabled' #else 'Disabled' #end}';
		fullContents += '\n- HXCPP Stack Trace: ${#if HXCPP_STACK_TRACE 'Enabled' #else 'Disabled' #end}';
		fullContents += '\n- HXCPP Stack Trace Line Numbers: ${#if HXCPP_STACK_LINE 'Enabled' #else 'Disabled' #end}';
		fullContents += '\n- HXCPP Pointer Validation: ${#if HXCPP_CHECK_POINTER 'Enabled' #else 'Disabled' #end}';
		fullContents += '\n- HXCPP Profiler: ${#if HXCPP_PROFILER 'Enabled' #else 'Disabled' #end}';
		fullContents += '\n- HXCPP Local Telemetry: ${#if HXCPP_TELEMETRY 'Enabled' #else 'Disabled' #end}';
		fullContents += '\n- HXCPP C++11: ${#if HXCPP_CPP11 'Enabled' #else 'Disabled' #end}';
		fullContents += '\n- Source Annotation: ${#if annotate_source 'Enabled' #else 'Disabled' #end}';
		#else
		var result:String = 'Unknown GC';
		#end
		return fullContents;
	}

	public static function registerDPIAware():Void
	{
		#if (cpp && windows)
		// DPI Scaling fix for windows 
		// this shouldn't be needed for other systems
		// Credit to YoshiCrafter29 for finding this function
		untyped __cpp__('
			SetProcessDPIAware();	
			#ifdef DPI_AWARENESS_CONTEXT
			SetProcessDpiAwarenessContext(
				#ifdef DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2
				DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2
				#else
				DPI_AWARENESS_CONTEXT_SYSTEM_AWARE
				#endif
			);
			#endif
		');
		#end
	}

	private static var fixedScaling:Bool = false;
	public static function fixScaling():Void
	{
		if (fixedScaling) return;
		fixedScaling = true;

		#if (cpp && windows)
		trace("running haxe code for scale fix");
		final display:Null<Display> = System.getDisplay(0);
		if (display != null)
		{
			final dpiScale:Float = display.dpi / 96;
			@:privateAccess Application.current.window.width = Std.int(Main.game.width * dpiScale);
			@:privateAccess Application.current.window.height = Std.int(Main.game.height * dpiScale);

			Application.current.window.x = Std.int((Application.current.window.display.bounds.width - Application.current.window.width) / 2);
			Application.current.window.y = Std.int((Application.current.window.display.bounds.height - Application.current.window.height) / 2);
		}
		trace("running cpp code for scale fix");
		untyped __cpp__('
			getHandle();
			if (curHandle != (HWND)0) {
				HDC curHDC = GetDC(curHandle);
				RECT curRect;
				GetClientRect(curHandle, &curRect);
				FillRect(curHDC, &curRect, (HBRUSH)GetStockObject(BLACK_BRUSH));
				ReleaseDC(curHandle, curHDC);
			}
		');
		#end
		trace("done fixing scale issue");
	}
}