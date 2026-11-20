#include "discord_extras.hpp"

#include <windows.h>

double DiscordExtras_GetIdleTime(void)
{
	LASTINPUTINFO info;
	info.cbSize = sizeof(LASTINPUTINFO);
	info.dwTime = 0;

	if (!GetLastInputInfo(&info))
		return -1.0;

	return (double)(GetTickCount() - info.dwTime) / 1000.0;
}
