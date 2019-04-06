//
//  TorrentPeersController.h
//  Transmission Remote
//
//  Created by Johnny Vega on 3/11/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TransmissionRPC/TRPeerInfo.h>
#import <TransmissionRPC/RPCConnector.h>

NS_ASSUME_NONNULL_BEGIN

@interface TorrentPeersController : NSViewController

@property (nonatomic) RPCConnector *connector;
@property (nonatomic) NSArray *trPeerInfos;
@property (nonatomic) TRPeerStat *trPeerStat;
@property (nonatomic) int trId;
@property (nonatomic) BOOL viewAppeared;


@end

NS_ASSUME_NONNULL_END
