#include <Cocoa/Cocoa.h>
#include <CoreGraphics/CGWindow.h>

int main(int argc, char **argv)
{
	NSArray *windows = (NSArray *)CGWindowListCopyWindowInfo(kCGWindowListExcludeDesktopElements,kCGNullWindowID);
	for(NSDictionary *window in windows)
		if ([[window objectForKey:(NSString *)kCGWindowOwnerName] isEqualToString:[NSString stringWithUTF8String:argv[1]]])
			if ([[window objectForKey:(NSString *)kCGWindowName] isEqualToString:[NSString stringWithUTF8String:argv[2]]])
				printf("%d\n", [[window objectForKey:(NSString *)kCGWindowNumber] intValue]);
}
