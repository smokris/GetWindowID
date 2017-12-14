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
			"    %s GLFW ''\n",
			argv[0],
			argv[0],
			argv[0],
			argv[0]);
		return -1;
	}

	NSString *requestedApp = @(argv[1]);
	NSString *requestedWindow = @(argv[2]);

	NSArray *windows = (NSArray *)CGWindowListCopyWindowInfo(kCGWindowListExcludeDesktopElements,kCGNullWindowID);
	for(NSDictionary *window in windows)
	{
		NSString *currentApp = window[(NSString *)kCGWindowOwnerName];
		NSString *currentWindow = window[(NSString *)kCGWindowName];
		CGRect currentBounds;
		CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)window[(NSString *)kCGWindowBounds], &currentBounds);

		if ([currentApp isEqualToString:requestedApp])
		{
			if ([currentWindow isEqualToString:requestedWindow]
			 || (!currentWindow && requestedWindow.length == 0))
			{
				double aspect = currentBounds.size.width / currentBounds.size.height;
				if (aspect > 30)
					// If it's that wide and short, it's probably the system menu bar, so ignore it.
					continue;

				printf("%d\n", [window[(NSString *)kCGWindowNumber] intValue]);
				return 0;
			}
		}
	}

	return -2;
}
