//
//  TorrentTrackersController.m
//  Transmission Remote
//
//  Created by Johnny Vega on 3/12/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "TorrentTrackersController.h"

@interface TorrentTrackersController () <RPCConnectorDelegate>

@end

@implementation TorrentTrackersController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

-(void)viewWillAppear {
    [self.view setWantsLayer:YES];
    self.view.layer.backgroundColor =  [NSColor unemphasizedSelectedContentBackgroundColor].CGColor;
    if (!_connector)
        [self setConnector:[RPCConnector sharedConnector]];
    if (!_trTrackers) {
        _connector.delegate = self;
        [_connector getAllTrackersForTorrentWithId:_trId];
    }
}

-(void)viewDidAppear {
    _viewAppeared = YES;
}

-(void)viewDidDisappear{
    _viewAppeared = NO;
}


-(void)gotAllTrackers:(NSArray *)trackerStats forTorrentWithId:(int)torrentId {
    [self setTrTrackers:trackerStats];
}

@end
