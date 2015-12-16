//
//  RCPanelController.h
//  RemoteController_OXServer
//
//  Created by heqichang on 12/3/15.
//  Copyright © 2015 heqichang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, RCConnectStatus) {
    RCConnect_BlueToothIsOff,
    RCConnect_NoConnected,
    RCConnect_Scanning,
    RCConnect_Connected
};


@interface RCPanelController : NSWindowController

@property (nonatomic, assign) RCConnectStatus status;
@property (nonatomic, assign) BOOL isPanelActive;


@end
