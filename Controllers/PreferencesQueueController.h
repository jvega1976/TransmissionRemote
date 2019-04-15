//
//  PreferencesDownloadController.h
//  TransmissionRemote
//
//  Created by Johnny Vega on 2/23/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <NSTransmissionRPC/NSTransmissionRPC.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreferencesQueueController : NSViewController

@property(nonatomic)    TRSessionInfo *trSessionInfo;

@end

NS_ASSUME_NONNULL_END
