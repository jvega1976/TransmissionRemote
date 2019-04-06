//
//  TorrentsFileController.h
//  TransmissionRemote
//
//  Created by Johnny Vega on 2/10/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TransmissionRPC/TransmissionRPC.h>
#import "TransmissionRPCExtensions.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    Trackers,
    Peers,
    Files,
    Pieces,
    Settings,
} ViewTab;

@interface TorrentFilesController : NSViewController

@property RPCConnector  *connector;
@property  FSDirectory  *torrentFiles;
@property BOOL          viewAppeared;
@property int           torrentId;


@end

NS_ASSUME_NONNULL_END
