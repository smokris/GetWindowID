#include <Cocoa/Cocoa.h>
#include <CoreGraphics/CGWindow.h>

int main(int argc, char **argv)
{
	if (argc != 3)
	{
		fprintf(stderr,
			"Usage: %s <application-bundle-name> <window-title>\n"
			"\n"
			"For example, to get the ID of the iOS/tvOS/watchOS Simulator:\n"
			"    %s Simulator 'iPhone X - iOS 11.0'\n"
			"\n"
			"…and to capture a screenshot of it:\n"
			"    screencapture -l$(%s Simulator 'iPhone X - iOS 11.0') simulator.png\n"
			"\n"
			"To get the ID of a window without a title, pass an empty string as the title:\n"
			"    %s GLFW ''\n"
			"\n"
			"To list all of an app's windows, pass `--list` as the title:\n"
			"    %s Simulator --list\n",
			argv[0],
			argv[0],
			argv[0],
			argv[0],
			argv[0]);
		return -1;
	}

	CFDictionaryRef session = CGSessionCopyCurrentDictionary();
	if (!session)
		fprintf(stderr,
			"Warning: %s is not running within a Quartz GUI session,\n"
			"so it won't be able to retrieve information on any windows.\n"
			"\n"
			"If you're using continuous integration, consider launching\n"
			"your agent as a GUI process (an `.app` bundle started via\n"
			"System Preferences > Users & Group > Login Items)\n"
			"instead of using a LaunchDaemon or LaunchAgent.\n",
			argv[0]);
	else
		CFRelease(session);

	NSString *requestedApp = @(argv[1]);
	NSString *requestedWindow = @(argv[2]);
	bool showList = [requestedWindow isEqualToString:@"--list"];
	bool appFound = false;

	NSArray *windows = (NSArray *)CGWindowListCopyWindowInfo(kCGWindowListExcludeDesktopElements,kCGNullWindowID);
	for(NSDictionary *window in windows)
	{
		NSString *currentApp = window[(NSString *)kCGWindowOwnerName];
		NSString *currentWindowTitle = window[(NSString *)kCGWindowName];
		CGRect currentBounds;
		CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)window[(NSString *)kCGWindowBounds], &currentBounds);

		if ([currentApp isEqualToString:requestedApp])
		{
			appFound = true;

			double aspect = currentBounds.size.width / currentBounds.size.height;
			if (aspect > 30)
				// If it's that wide and short, it's probably the system menu bar, so ignore it.
				continue;

			// If CGWindowListCopyWindowInfo didn't give us the window title, try to extract it from the Accessibility API.
			if (currentWindowTitle.length == 0)
			{
				AXUIElementRef axapp = AXUIElementCreateApplication([window[(NSString *)kCGWindowOwnerPID] intValue]);
				NSArray *windows;
				if (AXUIElementCopyAttributeValue(axapp, kAXWindowsAttribute, (CFTypeRef *)&windows) == kAXErrorSuccess)
					for (id window in windows)
					{
						// The Accessibility API doesn't expose a unique identifier for the window, so guess based on its frame.
						bool possibleMatch = true;
						CFTypeRef value;
						if (AXUIElementCopyAttributeValue((AXUIElementRef)window, kAXPositionAttribute, &value) == kAXErrorSuccess)
						{
							CGPoint p;
							if (AXValueGetValue(value, kAXValueTypeCGPoint, &p))
								if (p.x != currentBounds.origin.x || p.y != currentBounds.origin.y)
									possibleMatch = false;
						}
						if (AXUIElementCopyAttributeValue((AXUIElementRef)window, kAXSizeAttribute, &value) == kAXErrorSuccess)
						{
							CGSize s;
							if (AXValueGetValue(value, kAXValueTypeCGSize, &s))
								if (s.width != currentBounds.size.width || s.height != currentBounds.size.height)
									possibleMatch = false;
						}

						if (possibleMatch)
						{
							AXUIElementCopyAttributeValue((AXUIElementRef)window, kAXTitleAttribute, (CFTypeRef *)&currentWindowTitle);
							break;
						}
					}
			}

			if ([currentWindowTitle isEqualToString:@"Focus Proxy"]
			 && currentBounds.size.width == 1
			 && currentBounds.size.height == 1)
				 continue;

			if (showList)
			{
				printf(
					"\"%s\" size=%gx%g id=%d\n",
					currentWindowTitle.UTF8String,
					currentBounds.size.width,
					currentBounds.size.height,
					[window[(NSString *)kCGWindowNumber] intValue]);
				continue;
			}

			if ([currentWindowTitle isEqualToString:requestedWindow]
			 || (!currentWindowTitle && requestedWindow.length == 0))
			{
				printf("%d\n", [window[(NSString *)kCGWindowNumber] intValue]);
				return 0;
			}
		}
	}

	if (showList)
		return appFound ? 0 : -2;
	else
		return -2;
}
