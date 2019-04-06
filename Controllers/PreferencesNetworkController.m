//
//  PreferencesNetworkController.m
//  TransmissionRemote
//
//  Created by Johnny Vega on 3/2/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "PreferencesNetworkController.h"
#import "PreferencesController.h"

@interface PreferencesNetworkController () <RPCConnectorDelegate>

@property (strong) IBOutlet NSTextField *portTestMessage;
@property (strong) IBOutlet NSPopUpButton *encryption;

@end

@implementation PreferencesNetworkController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}


- (void)viewWillAppear {
    [_portTestMessage setHidden:YES];
    
    [self setTrSessionInfo: [TRSessionInfo sharedTRSessionInfo]];
    if (!_trSessionInfo) {
        RPCConnector *connector = [RPCConnector sharedConnector];
        if (connector) {
            connector.delegate = self;
            [connector getSessionInfo];
        }
    }
    else {
        [_encryption selectItemWithTitle:_trSessionInfo.encryption.capitalizedString];
        [_encryption synchronizeTitleAndSelectedItem];
    }
    //  [self.view.window setContentSize:NSMakeSize(700, 400)];
}

-(IBAction)testPort:(id)sender{
    RPCConnector *connector = [RPCConnector sharedConnector];
    if (connector) {
        connector.delegate = self;
        [connector portTest];
    }
}

-(IBAction)selectEncryption:(id)sender {
    _trSessionInfo.encryption = [[_encryption titleOfSelectedItem] lowercaseString];
     [_encryption synchronizeTitleAndSelectedItem];
}

#pragma -- RPCConnectorDelegate

-(void)gotSessionWithInfo:(TRSessionInfo *)info {
    [self setTrSessionInfo: info];
    [_encryption selectItemWithTitle:_trSessionInfo.encryption.capitalizedString];
    [_encryption synchronizeTitleAndSelectedItem];
}

-(void)gotPortTestedWithSuccess:(BOOL)portIsOpen {
    if (portIsOpen) {
        _portTestMessage.stringValue = @"Port is Open";
        _portTestMessage.textColor = [NSColor systemGreenColor];
        [_portTestMessage setHidden:NO];
    }
   else {
        _portTestMessage.stringValue = @"Port is Closed";
        _portTestMessage.textColor = [NSColor systemRedColor];
        [_portTestMessage setHidden:NO];
    }
}

@end
