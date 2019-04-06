//
//  MoveTorrentToController.h
//  Transmission Remote
//
//  Created by Johnny Vega on 3/30/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TransmissionRPC/TransmissionRPC.h>

NS_ASSUME_NONNULL_BEGIN

@interface MoveTorrentToController : NSViewController

@property (nonatomic) int trId;
@property (nonatomic) RPCConnector *connector;

@end

NS_ASSUME_NONNULL_END
