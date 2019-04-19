//
//  PreferencesUpdateController.m
//  Transmission Remote
//
//  Created by Johnny Vega on 4/19/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "PreferencesUpdateController.h"

@interface PreferencesUpdateController ()

@property (strong) IBOutlet NSButton *automaticallyDownloadUpdates;

@end

@implementation PreferencesUpdateController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}


- (SUUpdater *)updater {
    return [SUUpdater updaterForBundle:[NSBundle bundleForClass:[self class]]];
}

-(IBAction)close:(id)sender {
    if(_automaticallyDownloadUpdates.state == NSControlStateValueOn)
        [[SUUpdater updaterForBundle:[NSBundle bundleForClass:[self class]]] setAutomaticallyDownloadsUpdates:YES];
    else
        [[SUUpdater updaterForBundle:[NSBundle bundleForClass:[self class]]] setAutomaticallyDownloadsUpdates:NO];
    [self.view.window performClose:self];
}

@end
