//
//  RCTrackView.m
//  RemoteController_IOSClient
//
//  Created by heqichang on 12/22/15.
//  Copyright © 2015 heqichang. All rights reserved.
//

#import "RCTrackView.h"

@interface RCTrackView ()

@property (nonatomic, assign) BOOL isInTouch;
@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, strong) NSDate *beginTime;
//@property (nonatomic, strong) NSDate *trackTimestamp;

//@property (nonatomic, assign) CGFloat velocity;
//
//
//@property (nonatomic, assign) NSTimeInterval previousMovingTimeStamp;

@end


@implementation RCTrackView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.isInTouch = YES;
    UITouch *touch = [touches anyObject];
    self.beginPoint = [touch locationInView:self];
    
    self.beginTime = [NSDate date];
//    self.trackTimestamp = [NSDate date];
    
    // 初始化速度
//    self.velocity = 0.0f;
//
//    self.previousMovingTimeStamp = [[touches anyObject] timestamp];

}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesMoved:touches withEvent:event];
    
    NSDate *date = [NSDate date];

    
    NSTimeInterval executionTime = [date timeIntervalSinceDate:self.beginTime];
    
    // 单指，对于短时触摸，解释为点击
    if ([touches count] == 1 && executionTime <= 0.15) {
        return;
    }
    
    NSMutableArray *pointArray = [NSMutableArray array];
    
    for (UITouch *touch in touches) {
        CGPoint pre = [touch previousLocationInView:self];
        CGPoint now = [touch locationInView:self];
        
        [pointArray addObject:NSStringFromCGPoint(CGPointMake(now.x - pre.x, now.y - pre.y))];
    }
    
    // 双指同方向滚动，需要计算移动速度
//    if ([touches count] == 2) {
//        CGPoint point1 = CGPointFromString([pointArray objectAtIndex:0]);
//        CGPoint point2 = CGPointFromString([pointArray objectAtIndex:1]);
//        
//        // 双指同方向
//        if ((point1.y > 0 && point2.y > 0) || (point1.y < 0 && point2.y < 0)) {
//            CGFloat diffTime = [[touches anyObject] timestamp] - self.previousMovingTimeStamp;
//            
//            CGFloat speed1 = point1.y / diffTime;
//            CGFloat speed2 = point2.y / diffTime;
//            
//            self.velocity = fabs(speed1) > fabs(speed2) ? speed2 : speed1;
//        }
//    }
    
    
    // 平常解析为移动光标
    if (self.moveBlock) {
        self.moveBlock([pointArray copy]);
    }
    
    // 记录发生移动的时间戳
    // self.previousMovingTimeStamp = [[touches anyObject] timestamp];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesEnded:touches withEvent:event];
    
    NSDate *date = [NSDate date];
    NSTimeInterval executionTime = [date timeIntervalSinceDate:self.beginTime];
    
    // 这个事件中的touches不能表示当前所有的手指，只是当前移开的手指
    NSArray *eventTouch = [[event allTouches] allObjects];
    
    // 单指
    if ([eventTouch count] == 1) {
        if (executionTime < 0.15 && self.tapBlock) {
            self.tapBlock();
        }
    }
}

@end
