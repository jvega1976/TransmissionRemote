//
//  PreferencesMenuItemsController.m
//  Transmission Remote
//
//  Created by Johnny Vega on 4/16/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "PreferencesMenuItemsController.h"
#import "PreferencesController.h"
#import "AppDelegate.h"


@interface PreferencesMenuItemsController ()
@property (strong) IBOutlet NSArrayController *speedMenuItemsArrayController;
@property (strong) IBOutlet NSTableView *speedMenuItemsView;

@end

@implementation PreferencesMenuItemsController
{
    NSUserDefaults *_defaults;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

-(void)viewWillAppear {
    _defaults = [[NSUserDefaults alloc] initWithSuiteName:@"TransmissionRemote"];
    [self setSpeedMenuItems:[NSMutableArray arrayWithArray:[_defaults arrayForKey:@"SpeedMenuItems"]]];
}

-(IBAction)saveSpeedLimits:(id)sender {
     _defaults = [[NSUserDefaults alloc] initWithSuiteName:@"TransmissionRemote"];
    [_defaults setObject:_speedMenuItems forKey:@"SpeedMenuItems"];
    [_defaults synchronize];
    [(AppDelegate*)[[NSApplication sharedApplication] delegate] loadSpeedLimitMenuItems];
    [(PreferencesController*)self.parentViewController setTorrentSessionInfo:self];
}

@end
