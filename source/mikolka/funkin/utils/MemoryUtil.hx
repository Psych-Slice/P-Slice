package mikolka.funkin.utils;

/**
 * Utilities for working with the garbage collector.
 *
 * HXCPP is built on Immix.
 * HTML5 builds use the browser's built-in mark-and-sweep and JS has no APIs to interact with it.
 * @see https://www.cs.cornell.edu/courses/cs6120/2019fa/blog/immix/
 * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Memory_management
 * @see https://betterprogramming.pub/deep-dive-into-garbage-collection-in-javascript-6881610239a
 * @see https://github.com/HaxeFoundation/hxcpp/blob/master/docs/build_xml/Defines.md
 * @see cpp.vm.Gc
 */
class MemoryUtil
{
  public static function buildGCInfo():String
  {
    #if cpp
    var result:String = 'HXCPP-Immix:';
    result += '\n- Memory Used: ${cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_USAGE)} bytes';
    result += '\n- Memory Reserved: ${cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_RESERVED)} bytes';
    result += '\n- Memory Current Pool: ${cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_CURRENT)} bytes';
    result += '\n- Memory Large Pool: ${cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_LARGE)} bytes';
    result += '\n- HXCPP Debugger: ${#if HXCPP_DEBUGGER 'Enabled' #else 'Disabled' #end}';
    result += '\n- HXCPP Exp Generational Mode: ${#if HXCPP_GC_GENERATIONAL 'Enabled' #else 'Disabled' #end}';
    result += '\n- HXCPP Exp Moving GC: ${#if HXCPP_GC_MOVING 'Enabled' #else 'Disabled' #end}';
    result += '\n- HXCPP Exp Moving GC: ${#if HXCPP_GC_DYNAMIC_SIZE 'Enabled' #else 'Disabled' #end}';
    result += '\n- HXCPP Exp Moving GC: ${#if HXCPP_GC_BIG_BLOCKS 'Enabled' #else 'Disabled' #end}';
    result += '\n- HXCPP Debug Link: ${#if HXCPP_DEBUG_LINK 'Enabled' #else 'Disabled' #end}';
    result += '\n- HXCPP Stack Trace: ${#if HXCPP_STACK_TRACE 'Enabled' #else 'Disabled' #end}';
    result += '\n- HXCPP Stack Trace Line Numbers: ${#if HXCPP_STACK_LINE 'Enabled' #else 'Disabled' #end}';
    result += '\n- HXCPP Pointer Validation: ${#if HXCPP_CHECK_POINTER 'Enabled' #else 'Disabled' #end}';
    result += '\n- HXCPP Profiler: ${#if HXCPP_PROFILER 'Enabled' #else 'Disabled' #end}';
    result += '\n- HXCPP Local Telemetry: ${#if HXCPP_TELEMETRY 'Enabled' #else 'Disabled' #end}';
    result += '\n- HXCPP C++11: ${#if HXCPP_CPP11 'Enabled' #else 'Disabled' #end}';
    result += '\n- Source Annotation: ${#if annotate_source 'Enabled' #else 'Disabled' #end}';
    #elseif js
    var result:String = 'JS-MNS:';
    result += '\n- Memory Used: ${getMemoryUsed()} bytes';
    #else
    var result:String = 'Unknown GC';
    #end

    return result;
  }


  public static function supportsTaskMem():Bool
  {
    #if ((cpp && (windows || ios || macos)) || linux || android)
    return true;
    #else
    return false;
    #end
  }

  public static function getTaskMemory():Float
  {
    #if (windows && cpp)
    return external.windows.WinAPI.getProcessMemoryWorkingSetSize();
    #elseif ((ios || macos) && cpp)
    return external.apple.MemoryUtil.getCurrentProcessRss();
    #elseif (linux || android)
    try
    {
      #if cpp
      final input:sys.io.FileInput = sys.io.File.read('/proc/${cpp.NativeSys.sys_get_pid()}/status', false);
      #else
      final input:sys.io.FileInput = sys.io.File.read('/proc/self/status', false);
      #end

      final regex:EReg = ~/^VmRSS:\s+(\d+)\s+kB/m;
      var line:String;
      do
      {
        if (input.eof())
        {
          input.close();
          return 0.0;
        }
        line = input.readLine();
      }
      while (!regex.match(line));

      input.close();

      final kb:Float = Std.parseFloat(regex.matched(1));

      if (kb != Math.NaN)
      {
        return kb * 1024.0;
      }
    }
    catch (e:Dynamic) {}
    #end

    return 0.0;
  }

  /**
   * Calculate the total memory usage of the program, in bytes.
   * @return Int
   */
  public static function getMemoryUsed():Int
  {
    #if cpp
    // There is also Gc.MEM_INFO_RESERVED, MEM_INFO_CURRENT, and MEM_INFO_LARGE.
    return cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_USAGE);
    #else
    return openfl.system.System.totalMemory;
    #end
  }

    public static function getGCMemory():Float
  {
    #if LEGACY_PSYCH
    return openfl.system.System.totalMemory;
    #else
    return openfl.system.System.totalMemoryNumber;
    #end
  }
}
