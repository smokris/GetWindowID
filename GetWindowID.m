#include <Cocoa/Cocoa.h>
#include <CoreGraphics/CGWindow.h>

int main(int argc, char **argv)
{
    NSString *owner = [NSString stringWithUTF8String:argv[1]];
    NSString *name = argv[2] ? [NSString stringWithUTF8String:argv[2]] : nil;
    NSArray *windows = (NSArray *)CGWindowListCopyWindowInfo(kCGWindowListExcludeDesktopElements,kCGNullWindowID);
    for(NSDictionary *window in windows)
    {
        NSString *windowName = [window objectForKey:(NSString *)kCGWindowName];
        if ([[window objectForKey:(NSString *)kCGWindowOwnerName] isEqualToString:owner] && ((name == nil && windowName.length > 0) || [windowName isEqualToString:name]))
        {
            printf("%d\n", [[window objectForKey:(NSString *)kCGWindowNumber] intValue]);
            break;
        }
    }
}
