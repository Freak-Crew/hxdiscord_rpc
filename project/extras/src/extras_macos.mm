#include "discord_extras.hpp"

#import <ApplicationServices/ApplicationServices.h>

double DiscordExtras_GetIdleTime(void)
{
	return (double)CGEventSourceSecondsSinceLastEventType(kCGEventSourceStateCombinedSessionState, kCGAnyInputEventType);
}
