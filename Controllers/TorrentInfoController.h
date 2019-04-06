//
//  TorrentInfoController.h
//  TransmissionRemote
//
//  Created by  on 2/1/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TransmissionRPC/TransmissionRPC.h>

NS_ASSUME_NONNULL_BEGIN

@interface TorrentInfoController : NSViewController

@property (nonatomic) TRInfo *trInfo;
@property (nonatomic) int trId;

@property (nonatomic) IBOutlet NSVisualEffectView *torrentInfoView;

@property BOOL viewAppeared;

@end

NS_ASSUME_NONNULL_END
