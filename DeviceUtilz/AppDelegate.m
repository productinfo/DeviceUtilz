//
//  AppDelegate.m
//  DeviceUtilz
//
//  Created by h3adsh0tzz on 02/10/2016.
//  Copyright © 2016 h3adsh0tzz. All rights reserved.
//

#import "AppDelegate.h"

static AppDelegate *classPointer;
struct am_device *device;
struct am_device_notification *notification;

void notification_callback(struct am_device_notification_callback_info *info, int cookie) {
    if (info->msg == ADNCI_MSG_CONNECTED) {
        NSLog(@"DeviceUtilz: Device Connected");
        device = info->dev;
        AMDeviceConnect(device);
        AMDeviceIsPaired(device);
        AMDeviceValidatePairing(device);
        AMDeviceStartSession(device);
        [classPointer populateData];
    } else if (info->msg == ADNCI_MSG_DISCONNECTED) {
        NSLog(@"DeviceUtilz: Device Disconnected");
        [classPointer dePopulateData];
    } else {
        NSLog(@"Recieved device notification: %d", info->msg);
    }
}

void recovery_connect_callback(struct am_recovery_device *rdev) {
    [classPointer recoveryCallback];
}

void recovery_disconnect_callback(struct am_recovery_device *rdev) {
    [classPointer dePopulateData];
}

@interface AppDelegate ()

//Buttons
@property (nonatomic, strong) IBOutlet NSButton *enterRecButton;
@property (nonatomic, strong) IBOutlet NSButton *exitRecButton;

//Device Info Labels
@property (nonatomic, strong) IBOutlet NSTextField *deviceNameLbl;
@property (nonatomic, strong) IBOutlet NSTextField *deviceModelLbl;
@property (nonatomic, strong) IBOutlet NSTextField *boardConfigLbl;
@property (nonatomic, strong) IBOutlet NSTextField *iosVersionLbl;
@property (nonatomic, strong) IBOutlet NSTextField *serialNumberLbl;
@property (nonatomic, strong) IBOutlet NSTextField *ibootVersionLbl;
@property (nonatomic, strong) IBOutlet NSTextField *bootromVersionLbl;

//Bottom Labels
@property (nonatomic, strong) IBOutlet NSTextField *connectedDeviceLabel;

@property BOOL isRecoveryDeviceConnected;
@property BOOL isLimera1n;

- (void)loadingProgress;
- (void)enterRecovery;
- (NSString *)getDeviceInfo:(NSString *)value;

@end

@implementation AppDelegate

- (NSString *)getDeviceInfo:(NSString *)value {
    return (__bridge NSString *)AMDeviceCopyValue(device, 0, (__bridge CFStringRef)value);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    classPointer = self;
    AMDeviceNotificationSubscribe(notification_callback, 0, 0, 0, &notification);
    AMRestoreRegisterForDeviceNotifications(recovery_disconnect_callback, recovery_connect_callback, recovery_disconnect_callback, recovery_disconnect_callback, 0, NULL);
    
    if (self.isRecoveryDeviceConnected) {
        [self.exitRecButton setEnabled:YES];
    } else {
        [self.exitRecButton setEnabled:NO];
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)enterRec:(id)pId {
    [self enterRecovery];
    [self dePopulateData];
    [self loadingProgress];
}

- (void)enterRecovery {
    AMDeviceConnect(device);
    AMDeviceEnterRecovery(device);
}

- (IBAction)exitRec:(id)pId {
    self.isRecoveryDeviceConnected = NO;
    
    [self loadingProgress];
    //Allow the user to exit recovery mode through the application.
    
    //Makes recoverset the NSTask to be used.
    NSTask *recoverset = [[NSTask alloc] init];
    
    //Sets launch path.
    [recoverset setLaunchPath: [[NSBundle mainBundle] pathForResource:@"irecovery" ofType:nil]];
    //Sends the following command to irecovery.
    [recoverset setArguments:[NSArray arrayWithObjects:@"-c", @"setenv auto-boot true",nil]];
    [recoverset launch];
    [recoverset waitUntilExit];
    
    //Makes recoversave the NSTask to be used.
    NSTask *recoversave = [[NSTask alloc] init];
    //Sets launch path.
    [recoversave setLaunchPath: [[NSBundle mainBundle] pathForResource:@"irecovery" ofType:nil]];
    //Sends the following command to irecovery.
    [recoversave setArguments:[NSArray arrayWithObjects:@"-c", @"saveenv",nil]];
    [recoversave launch];
    [recoversave waitUntilExit];
    
    //Makes recoverreboot the NSTask to be used.
    NSTask *recoverreboot = [[NSTask alloc] init];
    //Sets launch path.
    [recoverreboot setLaunchPath: [[NSBundle mainBundle] pathForResource:@"irecovery" ofType:nil]];
    //Sends the following command to irecovery.
    [recoverreboot setArguments:[NSArray arrayWithObjects:@"-c", @"reboot",nil]];
    [recoverreboot launch];
}

- (void)populateData {
    
    if (!self.isRecoveryDeviceConnected) {
        
        //NSString *deviceConnected = [self getDeviceInfo:@"ProductType"];
        
        [self.connectedDeviceLabel setStringValue:@"Device Connected"];
        
        [self.deviceNameLbl setStringValue:[self getDeviceInfo:@"DeviceName"]];
        [self.deviceModelLbl setStringValue:[self getDeviceInfo:@"ProductType"]];
        
        [self.iosVersionLbl setStringValue:[NSString stringWithFormat:@"iOS%@", [self getDeviceInfo:@"ProductVersion"]]];
        [self.serialNumberLbl setStringValue:[self getDeviceInfo:@"SerialNumber"]];
        [self.ibootVersionLbl setStringValue:[self getDeviceInfo:@"FirmwareVersion"]];
        [self.boardConfigLbl setStringValue:[self getDeviceInfo:@"HardwareModel"]];
        [self.bootromVersionLbl setStringValue:[self getDeviceInfo:@"HardwarePlatform"]];

    }
    
}

- (void)dePopulateData {
    
    [self.deviceNameLbl setStringValue:@"N/A"];
    [self.deviceModelLbl setStringValue:@"N/A"];
    [self.boardConfigLbl setStringValue:@"N/A"];
    [self.iosVersionLbl setStringValue:@"N/A"];
    [self.serialNumberLbl setStringValue:@"N/A"];
    [self.ibootVersionLbl setStringValue:@"N/A"];
    [self.boardConfigLbl setStringValue:@"N/A"];
    [self.bootromVersionLbl setStringValue:@"N/A"];

    
    [self.connectedDeviceLabel setStringValue:@"No Device Connected"];
    [self.exitRecButton setEnabled:NO];
    
}

- (void)recoveryCallback {
    [self.connectedDeviceLabel setStringValue:@"Recovery Device Connected"];
    self.isRecoveryDeviceConnected = YES;
    
    [self.exitRecButton setEnabled:YES];
    
    [self.deviceNameLbl setHidden:YES];
    [self.deviceModelLbl setHidden:YES];
    [self.boardConfigLbl setHidden:YES];
    [self.iosVersionLbl setHidden:YES];
    [self.serialNumberLbl setHidden:YES];
    [self.ibootVersionLbl setHidden:YES];
    [self.bootromVersionLbl setHidden:YES];

}

- (void)loadingProgress {
    
}

- (IBAction)info:(id)sender {
    NSWindowController *infoWindow = [[NSWindowController alloc] initWithWindowNibName:@"infoWindow"];
    [infoWindow showWindow:self];
}

@end
