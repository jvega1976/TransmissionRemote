//
//  AddTorrentController.m
//  TransmissionRemote
//
//  Created by Johnny Vega on 3/1/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "AddTorrentController.h"

@interface AddTorrentController () 

@property RPCConnector *connector;
@end

@implementation AddTorrentController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setConnector: [RPCConnector sharedConnector]];
    // Do view setup here.
}

-(void)viewWillAppear {
    [self.view setWantsLayer:YES];
    self.view.layer.backgroundColor =  [NSColor unemphasizedSelectedContentBackgroundColor].CGColor;
}


- (IBAction)addTorrent:(id)sender {
    if (_torrentFile.fileList) {
        _connector.delegate = self;
        [_connector addTorrentWithFile:_torrentFile priority:1 startImmidiately:YES];
    }
    else {
        _connector.delegate = self;
        [_connector addTorrentWithData:_torrentFile.torrentData priority:1 startImmidiately:YES];
    }
    [self dismissController:self];
}


#pragma -- RPCConnectorDelegate

-(void)gotTorrentAddedWithResult:(NSDictionary*)jsonResponse {
    if ([[jsonResponse descriptionInStringsFileFormat] containsString:@"torrent-duplicate"]) {
        NSDictionary *userError = @{NSLocalizedDescriptionKey: @"Torrent already exists.  Do you want to add the tracker to the existing Torrent?",
                                    NSHelpAnchorErrorKey: @"Torrent already exists.  Do you want to add the tracker to the existing Torrent?"};
        NSError *error = [NSError errorWithDomain:NSMachErrorDomain code:20400 userInfo:userError];
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"No"];
        NSModalResponse alertResponse = [alert runModal];
        
        if(alertResponse == NSAlertFirstButtonReturn) {
            [[RPCConnector sharedConnector] addTrackers:_torrentFile.trackerList forTorrent:[jsonResponse[@"id"] intValue]];
        }
    };
    [self dismissController:self];
}

@end
