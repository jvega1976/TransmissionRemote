//
//  PreferencesController.m
//  TransmissionRemote
//
//  Created by Johnny Vega on 2/23/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "PreferencesController.h"

@interface PreferencesController ()
 
@end

@implementation PreferencesController

- (void)viewDidLoad {
    [super viewDidLoad];
}


-(void)viewWillAppear {
    [self setSelectedTabViewItemIndex:0];
    [self setTabStyle:NSTabViewControllerTabStyleToolbar];
    [self setConnector:[RPCConnector sharedConnector]];
    [_connector getSessionInfo];
    [self.view setWantsLayer:YES];
    self.view.layer.backgroundColor =  [NSColor windowBackgroundColor].CGColor;
}


-(IBAction)setTorrentSessionInfo:(id)sender {
    _trSessionInfo = [TRSessionInfo sharedTRSessionInfo];
    _connector.delegate = self;
    [_connector setSessionWithSessionInfo:_trSessionInfo];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == 'Transmission Remote'"];
    NSWindow *window = [[NSApplication.sharedApplication.windows filteredArrayUsingPredicate:predicate] firstObject];
    predicate = [NSPredicate predicateWithFormat:@"label == 'Alt Speed'"];
    NSToolbarItem *toolbarItem = [[window.toolbar.items filteredArrayUsingPredicate:predicate] firstObject];
    if (_trSessionInfo.altLimitEnabled)
        [toolbarItem.view performSelector:@selector(setState:) withObject:(__bridge id)(void*)NSControlStateValueOn];
    else
        [toolbarItem.view performSelector:@selector(setState:) withObject:(__bridge id)(void*)NSControlStateValueOff];
    [self dismissController:self];
}



#pragma -- RPCConnector Delegate

-(void)gotSessionWithInfo:(TRSessionInfo *)info {
    [self setTrSessionInfo: info];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == 'Transmission Remote'"];
    NSWindow *window = [[NSApplication.sharedApplication.windows filteredArrayUsingPredicate:predicate] firstObject];
    predicate = [NSPredicate predicateWithFormat:@"label == 'Alt Speed'"];
    NSToolbarItem *toolbarItem = [[window.toolbar.items filteredArrayUsingPredicate:predicate] firstObject];
    if (_trSessionInfo.altLimitEnabled)
        [toolbarItem.view performSelector:@selector(setState:) withObject:(__bridge id)(void*)NSControlStateValueOn];
    else
        [toolbarItem.view performSelector:@selector(setState:) withObject:(__bridge id)(void*)NSControlStateValueOff];
}

@end
