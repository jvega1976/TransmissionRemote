//
//  TorrentSettingsController.m
//  Transmission Remote
//
//  Created by Johnny Vega on 3/10/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "TorrentSettingsController.h"


@interface TorrentSettingsController () <RPCConnectorDelegate>

@end

@implementation TorrentSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

-(void)viewWillAppear {
    [self.view setWantsLayer:YES];
    self.view.layer.backgroundColor =  [NSColor unemphasizedSelectedContentBackgroundColor].CGColor;
    if (!_connector)
        [self setConnector:[RPCConnector sharedConnector]];
    if (!_trInfo) {
        _connector.delegate = self;
        [_connector getDetailedInfoForTorrentWithId:_trId];
    }
    
}

-(IBAction)saveSeetings:(id)sender {
    if (!_connector)
        _connector = [RPCConnector sharedConnector];
    [_connector setSettings:_trInfo forTorrentWithId:_trId];
    [self dismissController:self];
}

-(void)gotTorrentDetailedInfo:(TRInfo *)torrentInfo {
    _trInfo = torrentInfo;
}

@end
