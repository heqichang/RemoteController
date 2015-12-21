//
//  RCGesture.m
//  RemoteController_OXServer
//
//  Created by heqichang on 12/21/15.
//  Copyright © 2015 heqichang. All rights reserved.
//

#import "RCGesture.h"
@import AppKit;

@interface RCGesture ()

@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat maxHeight;

@end


@implementation RCGesture

- (id)init {
    self = [super init];
    if (self) {
        //TODO: 暂时主屏，如果外接显示器需要另外考虑
        NSScreen *mainScreen = [NSScreen mainScreen];
        NSRect mainRect = [mainScreen visibleFrame];
        self.maxWidth = mainRect.size.width;
        self.maxHeight = mainRect.size.height;
    }
    return self;
}

// 指令为[]，如[tap]，多个手指由 ; 分隔，单个手指的 x y 由 , 分割，如 10,20，指 x + 10, y + 20

- (void)parseCommand:(NSString *)command {
    // 转换成位移
    NSMutableArray *pointArray = [NSMutableArray array];
    
    NSArray *dArray = [command componentsSeparatedByString:@";"];
    for (NSString *s in dArray) {
        
        if ([s hasPrefix:@"["]) {
            [pointArray addObject:s];
            continue;
        }
        
        NSArray *pArray = [s componentsSeparatedByString:@","];
        NSString *x1 = [pArray objectAtIndex:0];
        NSString *y1 = [pArray objectAtIndex:1];
        NSPoint point = CGPointMake([x1 floatValue], [y1 floatValue]);
        [pointArray addObject:NSStringFromPoint(point)];
    }
    
    // 单指或者指令
    if ([pointArray count] == 1) {
        
        NSString *command = [pointArray objectAtIndex:0];
        
        if ([command hasPrefix:@"["]) {
            // 单击
            if ([command isEqualToString:@"[tap]"]) {
                [self postMouseEventWithButton:0 withType:kCGEventLeftMouseDown andPoint:CGEventGetLocation(CGEventCreate(NULL))];
                [self postMouseEventWithButton:0 withType:kCGEventLeftMouseUp andPoint:CGEventGetLocation(CGEventCreate(NULL))];
            }
            
        } else {
            // 鼠标滑动
            NSPoint point = NSPointFromString([pointArray objectAtIndex:0]);
            
            CGEventRef ourEvent = CGEventCreate(NULL);
            CGPoint originCoordOfMouse = CGEventGetLocation(ourEvent);
            
            float x = originCoordOfMouse.x + 4 * point.x;
            x = x < 0 ? 0 : x;
            x = x > self.maxWidth ? self.maxWidth : x;
            float y = originCoordOfMouse.y + 4 * point.y;
            y = y < 0 ? 0 : y;
            y = y > self.maxHeight ? self.maxHeight : y;
            
            [self postMouseEventWithButton:0 withType:kCGEventMouseMoved andPoint:CGPointMake(x, y)];
            CFRelease(ourEvent);
        }
    }
    
    // 双指
    if ([pointArray count] == 2) {
        
        NSPoint point1 = NSPointFromString([pointArray objectAtIndex:0]);
        NSPoint point2 = NSPointFromString([pointArray objectAtIndex:1]);
        
        // 双指向同一个方向，屏幕滚动
        if ((point1.y >= 0 && point2.y >= 0) || (point1.y < 0 && point2.y < 0)) {
            [self postScrollWheelEventWithCount: 5 * point1.y];
        }
    }
}

#pragma mark - private

- (void)postMouseEventWithButton:(CGMouseButton)b withType:(CGEventType)t andPoint:(CGPoint)p
{
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, t, p, b);
    CGEventSetType(theEvent, t);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
}

- (void)postScrollWheelEventWithCount:(NSInteger)count {
    int32_t c = (int32_t)count;
    CGEventRef theEvent = CGEventCreateScrollWheelEvent(NULL, kCGScrollEventUnitPixel, 1, c);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
}

@end
