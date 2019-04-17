//
//  AppDelegate.h
//  TransmissionRPClient
//
//  Created by Johnny Vega on 1/26/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic) IBOutlet NSMenuItem *toggleAltMenuItem;

@property (weak, nonatomic) IBOutlet NSMenu *menuBar;
@property (weak) IBOutlet NSMenuItem *manuBarToggleAlt;
@property (weak) IBOutlet NSMenu *maximumDownloadSpeedSubmenu;
@property (weak) IBOutlet NSMenu *maximumUploadSpeedSubmenu;

-(void)loadSpeedLimitMenuItems;

//@property (strong, nonatomic) NSStatusItem *statusBar;
@end

