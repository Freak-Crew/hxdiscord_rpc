#include "discord_extras.hpp"

#include <cstring>
#include <dlfcn.h>
#include <mutex>

namespace
{
	typedef void Display;
	typedef unsigned long XID;

	struct ScreenSaverInfo
	{
		XID window;
		int state;
		int kind;
		unsigned long til_or_since;
		unsigned long idle;
		unsigned long eventMask;
	};

	typedef Display *(*OpenDisplayFn)(const char *);
	typedef XID (*DefaultRootWindowFn)(Display *);
	typedef int (*QueryInfoFn)(Display *, XID, ScreenSaverInfo *);

	Display *g_display = nullptr;
	XID g_root = 0;
	QueryInfoFn g_queryInfo = nullptr;
	std::once_flag g_once;

	void *OpenLibrary(const char *versioned, const char *unversioned)
	{
		void *library = dlopen(versioned, RTLD_LAZY);

		return library ? library : dlopen(unversioned, RTLD_LAZY);
	}

	void Load()
	{
		void *x11 = OpenLibrary("libX11.so.6", "libX11.so");
		void *xss = OpenLibrary("libXss.so.1", "libXss.so");

		if (!x11 || !xss)
			return;

		auto openDisplay = reinterpret_cast<OpenDisplayFn>(dlsym(x11, "XOpenDisplay"));
		auto defaultRoot = reinterpret_cast<DefaultRootWindowFn>(dlsym(x11, "XDefaultRootWindow"));
		auto queryInfo = reinterpret_cast<QueryInfoFn>(dlsym(xss, "XScreenSaverQueryInfo"));

		if (!openDisplay || !defaultRoot || !queryInfo)
			return;

		g_display = openDisplay(nullptr);

		if (!g_display)
			return;

		g_root = defaultRoot(g_display);
		g_queryInfo = queryInfo;
	}
}

double DiscordExtras_GetIdleTime(void)
{
	std::call_once(g_once, Load);

	if (!g_queryInfo)
		return -1.0;

	ScreenSaverInfo info;
	memset(&info, 0, sizeof(info));

	if (!g_queryInfo(g_display, g_root, &info))
		return -1.0;

	return (double)info.idle / 1000.0;
}
