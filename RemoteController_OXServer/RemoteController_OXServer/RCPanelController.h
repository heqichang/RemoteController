//
//  RCPanelController.h
//  RemoteController_OXServer
//
//  Created by heqichang on 12/3/15.
//  Copyright © 2015 heqichang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RCDefine.h"


@protocol RCPanelControllerDelegate <NSObject>

@optional
- (void)connectClientButtonDidClick;

@end


@interface RCPanelController : NSWindowController

@property (nonatomic, assign) RCConnectStatus status;
@property (nonatomic, assign) BOOL isPanelActive;
@property (nonatomic, weak, nullable) id<RCPanelControllerDelegate> delegate;

@end
