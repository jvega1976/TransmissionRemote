//
//  TorrentPeersController.m
//  Transmission Remote
//
//  Created by Johnny Vega on 3/11/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "TorrentPeersController.h"

@interface TorrentPeersController () <RPCConnectorDelegate>

@property (nonatomic) NSTimer *refreshTimer;

@end

@implementation TorrentPeersController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

-(void)viewWillAppear {
    [self.view setWantsLayer:YES];
    self.view.layer.backgroundColor =  [NSColor unemphasizedSelectedContentBackgroundColor].CGColor;
    
    if (!_trPeerInfos) {
        if (!_connector)
            [self setConnector: [RPCConnector sharedConnector]];
        _connector.delegate = self;
        [_connector getAllPeersForTorrentWithId:_trId];
    }
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(autorefreshTimerUpdateHandler) userInfo:nil repeats:YES];
}

-(void)viewDidAppear {
    _viewAppeared = YES;
}

-(void)autorefreshTimerUpdateHandler{
    _connector.delegate = self;
    [_connector getAllPeersForTorrentWithId:_trId];
}

-(void)gotAllPeers:(NSArray *)peerInfos withPeerStat:(TRPeerStat *)stat forTorrentWithId:(int)torrentId {
    [self setTrPeerInfos:[NSArray arrayWithArray: peerInfos]];
    [self setTrPeerStat:stat];
}

-(void)viewDidDisappear {
    [_refreshTimer invalidate];
    _viewAppeared = NO;
    [self dismissController:self];
}


@end
