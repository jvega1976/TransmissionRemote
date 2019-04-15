//
//  TorrentTrackersController.h
//  Transmission Remote
//
//  Created by Johnny Vega on 3/12/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <NSTransmissionRPC/NSTransmissionRPC.h>

NS_ASSUME_NONNULL_BEGIN

@interface TorrentTrackersController : NSViewController

@property (nonatomic) RPCConnector  *connector;
@property (nonatomic) NSArray       *trTrackers;
@property (nonatomic) int           trId;
@property (nonatomic) BOOL          viewAppeared;

@end

NS_ASSUME_NONNULL_END
