//
//  TorrentSettingsController.h
//  Transmission Remote
//
//  Created by Johnny Vega on 3/10/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <NSTransmissionRPC/NSTransmissionRPC.h>

NS_ASSUME_NONNULL_BEGIN

@interface TorrentSettingsController : NSViewController

@property (nonatomic) TRInfo *trInfo;
@property (nonatomic) int trId;
@property (nonatomic) RPCConnector *connector;
@end

NS_ASSUME_NONNULL_END
