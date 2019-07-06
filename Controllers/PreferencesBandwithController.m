//
//  PreferencesBandwithController.m
//  TransmissionRemote
//
//  Created by Johnny Vega on 3/8/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "PreferencesBandwithController.h"
#import "PreferencesController.h"

@interface PreferencesBandwithController () <RPCConnectorDelegate>

@end

@implementation PreferencesBandwithController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}


-(void)viewWillAppear {
    [self setTrSessionInfo: [TRSessionInfo sharedTRSessionInfo]];
    if (!_trSessionInfo) {
        RPCConnector *connector = [RPCConnector sharedConnector];
        if (connector) {
            connector.delegate = self;
            [connector getSessionInfo];
        }
    }
 //   [self.view setWantsLayer:YES];
 //   self.view.layer.backgroundColor =  [NSColor windowBackgroundColor].CGColor;
}

-(void)gotSessionWithInfo:(TRSessionInfo *)info {
    _trSessionInfo = info;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == 'Transmission Remote'"];
    NSWindow *window = [[NSApplication.sharedApplication.windows filteredArrayUsingPredicate:predicate] firstObject];
    predicate = [NSPredicate predicateWithFormat:@"label == 'Alt Speed'"];
    NSToolbarItem *toolbarItem = [[window.toolbar.items filteredArrayUsingPredicate:predicate] firstObject];
    if (info.altLimitEnabled)
        [toolbarItem.view performSelector:@selector(setState:) withObject:(__bridge id)(void*)NSControlStateValueOn];
    else
        [toolbarItem.view performSelector:@selector(setState:) withObject:(__bridge id)(void*)NSControlStateValueOff];
}

@end
