//
//  TorrentInfoController.m
//  TransmissionRemote
//
//  Created by  on 2/1/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "TorrentInfoController.h"

@interface TorrentInfoController () <RPCConnectorDelegate>

@property (nonatomic) RPCConnector *connector;

@end

@implementation TorrentInfoController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

-(void)viewWillAppear {
    [self.view setWantsLayer:YES];
    self.view.layer.backgroundColor =  [NSColor unemphasizedSelectedContentBackgroundColor].CGColor;
    if(!_connector)
        _connector = [RPCConnector sharedConnector];
    if(!_trInfo) {
        _connector.delegate = self;
        [_connector getDetailedInfoForTorrentWithId:_trId];
    }
}

-(void)viewDidAppear {
    _viewAppeared = YES;
}

-(void)viewDidDisappear {
    _viewAppeared = NO;
}

-(void)gotTorrentDetailedInfo:(TRInfo *)torrentInfo {
    [self setTrInfo:torrentInfo];
}

@end
