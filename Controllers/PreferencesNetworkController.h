//
//  PreferencesNetworkController.h
//  TransmissionRemote
//
//  Created by Johnny Vega on 3/2/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <NSTransmissionRPC/NSTransmissionRPC.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreferencesNetworkController : NSViewController

@property(nonatomic)    TRSessionInfo *trSessionInfo;

@end

NS_ASSUME_NONNULL_END
