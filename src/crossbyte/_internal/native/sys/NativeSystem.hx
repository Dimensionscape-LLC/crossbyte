package crossbyte._internal.native.sys;

/**
 * ...
 * @author Christopher Speciale
 */
@:cppInclude("Windows.h")
@:cppInclude("Winbase.h")

class NativeSystem
{

	private static function getCpuCores():Int
	{
		untyped __cpp__ ("
			HANDLE hProcess = GetCurrentProcess();
			SYSTEM_INFO systemInfo;
			GetSystemInfo(&systemInfo);
		");

		return untyped __cpp__("systemInfo.dwNumberOfProcessors;");
	};

	private static function getCpuAffinities():Array<Bool>
	{
		untyped __cpp__
		("
			HANDLE hProcess = GetCurrentProcess();

			DWORD_PTR processAffinityMask;
			DWORD_PTR systemAffinityMask;

			BOOL success = GetProcessAffinityMask(hProcess, &processAffinityMask, &systemAffinityMask);
		");

		if (!untyped __cpp__ ("success"))
		{
			return [];
		}
		//TODO: only get hProcess once for all functions and cache it
		untyped __cpp__	("Array<BOOL> affinity = Array_obj<BOOL>::__new(0);");

		var numCores:Int = getCpuCores();
		for (i in 0...numCores)
		{
			untyped __cpp__
			("
				DWORD bit = 1 << i;
				BOOL isSet = (processAffinityMask & bit) != 0;

				affinity[i] = isSet;
			");
		}

		return untyped __cpp__ ("affinity");
	}
	
	private static function getCpuAffinity(cpuIndex:Int):Bool{
		 untyped __cpp__
		 ("
			HANDLE hProcess = GetCurrentProcess();
			DWORD_PTR processAffinityMask;
			DWORD_PTR systemAffinityMask;

			BOOL success = GetProcessAffinityMask(hProcess, &processAffinityMask, &systemAffinityMask);
        ");
	
		//TODO: throw an error if success is false instead
		if (!untyped __cpp__("success")) {
			return false;
		}

		untyped __cpp__
		("
			DWORD bit = 1 << cpuIndex;
			BOOL isSet = (processAffinityMask & bit) != 0;
        ");

    return untyped __cpp__("isSet");
	}
	
	private static function setCpuAffinity(cpuIndex:Int, value:Bool):Bool{

        untyped __cpp__
		("
            HANDLE hProcess = GetCurrentProcess();
            DWORD_PTR processAffinityMask;
            DWORD_PTR systemAffinityMask;

            BOOL success = GetProcessAffinityMask(hProcess, &processAffinityMask, &systemAffinityMask);
        ");

        if (!untyped __cpp__("success")) {
            return false;
        }

        untyped __cpp__
		("
			DWORD_PTR affinityMask;
            DWORD bit = 1 << cpuIndex;
            if (value) {
                affinityMask = processAffinityMask | bit;
            } else {
                affinityMask = processAffinityMask & ~bit;
            }
			
            success = SetProcessAffinityMask(hProcess, affinityMask);
        ");

        return untyped __cpp__("success");
	}
}