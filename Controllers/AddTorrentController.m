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
    if (_torrentFile.fileList)
        [[RPCConnector sharedConnector] addTorrentWithFile:_torrentFile priority:1 startImmidiately:YES];
    else
        [[RPCConnector sharedConnector] addTorrentWithData:_torrentFile.torrentData priority:1 startImmidiately:YES];
    [self dismissController:self];
}


#pragma -- RPCConnectorDelegate

-(void)gotTorrentAddedWithResult:(NSDictionary*)jsonResponse {
    if ([[jsonResponse descriptionInStringsFileFormat] containsString:@"torrent-duplicate"]) {
        NSDictionary *userError = @{NSLocalizedDescriptionKey: @"Torrent Duplicated",
                                    NSHelpAnchorErrorKey: @"Torrent already exists."};
        NSError *error = [NSError errorWithDomain:NSMachErrorDomain code:20400 userInfo:userError];
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    };
    [self dismissController:self];
}

@end
