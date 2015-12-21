//
//  AppDelegate.h
//  RemoteController_OXServer
//
//  Created by heqichang on 12/2/15.
//  Copyright © 2015 heqichang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RCPanelController.h"
#import "RCBLEServer.h"
@interface AppDelegate : NSObject <NSApplicationDelegate, RCPanelControllerDelegate, RCBLEServerDelegate>


@end

