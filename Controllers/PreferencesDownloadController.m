//
//  PreferencesDownloadController.m
//  TransmissionRemote
//
//  Created by Johnny Vega on 2/23/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "PreferencesDownloadController.h"
#import "PreferencesController.h"

@interface PreferencesDownloadController () <RPCConnectorDelegate>

@end

@implementation PreferencesDownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear {
    [self setTrSessionInfo: [TRSessionInfo sharedTRSessionInfo]];
    if (!_trSessionInfo) {
        RPCConnector *connector = [RPCConnector sharedConnector];
        if (connector) {
            connector.delegate = self;
            [connector getSessionInfo];
        }
    }
    [self.view setWantsLayer:YES];
    self.view.layer.backgroundColor =  [NSColor windowBackgroundColor].CGColor;
  //  [self.view.window setContentSize:NSMakeSize(700, 400)];
}



-(void)gotSessionWithInfo:(TRSessionInfo *)info {
    [self setTrSessionInfo: info];
}

@end
