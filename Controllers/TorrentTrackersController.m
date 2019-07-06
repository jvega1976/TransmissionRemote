//
//  TorrentTrackersController.m
//  Transmission Remote
//
//  Created by Johnny Vega on 3/12/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "TorrentTrackersController.h"

@interface TorrentTrackersController () <RPCConnectorDelegate>
@property (strong) IBOutlet NSArrayController *trackerArrayController;
@property (strong) IBOutlet NSMenu *trackerContextMenu;
@property (weak) IBOutlet NSTableView *trackerTableView;

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

- (void)rightMouseDown:(NSEvent *)theEvent {
    [NSMenu popUpContextMenu:_trackerContextMenu withEvent:theEvent forView:_trackerTableView];
}

-(IBAction)removeTracker:(id)sender {
    NSMenuItem *menuItem;
    menuItem = sender;
    NSUInteger index;
    index = [_trackerArrayController selectionIndex];
    int trackerId = [[_trTrackers objectAtIndex:index] trackerId];
    switch (menuItem.tag) {
        case 0:
            _connector.delegate = self;
            [_connector removeTracker:trackerId forTorrent: _trId];
            [_trackerArrayController removeObjectAtArrangedObjectIndex:index];
            break;
        case 2:
            _connector.delegate = self;
            [_connector addTrackers:@[@(trackerId)] forTorrent: _trId];
        default:
            break;
    }
}

#pragma mark - RPCConnector delegate

-(void)gotAllTrackers:(NSArray *)trackerStats forTorrentWithId:(int)torrentId {
    [self setTrTrackers:trackerStats];
}

-(void)gotTrackerRemoved:(int)trackerId forTorrentWithId:(int)torrentId {
    
}

@end
