//
//  RCTrackView.h
//  RemoteController_IOSClient
//
//  Created by heqichang on 12/22/15.
//  Copyright © 2015 heqichang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCTrackView : UIView

@property (nonatomic, copy) void (^moveBlock)(NSArray *points);
@property (nonatomic, copy) void (^tapBlock)();
@property (nonatomic, copy) void (^doubleTapBlock)();
@property (nonatomic, copy) void (^autoScrollingBlock)(NSString *velocity);

@end
