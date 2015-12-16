//
//  AppDelegate.m
//  RemoteController_OXServer
//
//  Created by heqichang on 12/2/15.
//  Copyright © 2015 heqichang. All rights reserved.
//

#import "AppDelegate.h"
#import "RCPanelController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (nonatomic, strong) RCPanelController *panel;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    self.panel = [[RCPanelController alloc] init];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
