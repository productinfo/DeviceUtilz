//
//  AppDelegate.h
//  DeviceUtilz
//
//  Created by h3adsh0tzz on 02/10/2016.
//  Copyright © 2016 h3adsh0tzz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MobileDevice.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSWindow *window;

- (void)populateData;
- (void)dePopulateData;
- (void)recoveryCallback;

@end

