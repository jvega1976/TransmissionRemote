//
//  TransmissionRPCExtensions.h
//  Transmission Remote
//
//  Created by Johnny Vega on 4/1/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TransmissionRPC/TransmissionRPC.h>

#define TR_STATUS_IMAGE_DOWNLOAD    @"StatusDownload"
#define TR_STATUS_IMAGE_ALL         @"StatusAll"
#define TR_STATUS_IMAGE_UPLOAD      @"StatusUpload"
#define TR_STATUS_IMAGE_ERROR       @"StatusError"
#define TR_STATUS_IMAGE_WAIT        @"StatusWait"
#define TR_STATUS_IMAGE_COMPLETED   @"StatusCompleted"
#define TR_STATUS_IMAGE_STOP        @"StatusStop"
#define TR_STATUS_IMAGE_VERIFY      @"StatusVerify"
#define TR_STATUS_IMAGE_ACTIVE      @"StatusActive"


#define TR_PEER_CLIENT_UTORRENT      @"uTorrent.png"
#define TR_PEER_CLIENT_BITTORRENT    @"BitTorrent.png"
#define TR_PEER_CLIENT_DELUGE        @"Deluge.png"
#define TR_PEER_CLIENT_VUZE          @"Vuze.png"
#define TR_PEER_CLIENT_QBITTORRENT   @"qBitTorrent.png"
#define TR_PEER_CLIENT_TRANSMISSION  @"Transmission.png"

NS_ASSUME_NONNULL_BEGIN


@interface TRInfo (TransmissionRemote)

@property (nonatomic,readonly) NSImage *statusImage;

@property (nonatomic,readonly) NSString *detailInfo;

@property (nonatomic) BOOL isSelected;

@property (nonatomic,readonly) NSInteger sortValue;

@end


@interface FSItem (TransmissionRemote)

@property (nonatomic,readonly) NSImage *priorityImage;

//@property (nonatomic) BOOL isEditable;

@end

@interface TRPeerInfo (TransmissionRemote)

@property (nonatomic,readonly) NSImage *clientImage;

@property (nonatomic,readonly) NSImage *flagImage;

@property (nonatomic) NSString *countryName;

@property (nonatomic) NSString *flagCode;

@end

NS_ASSUME_NONNULL_END
