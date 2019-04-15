//
//  CategorizationKitExtensions.h
//  Transmission Remote
//
//  Created by Johnny Vega on 4/1/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <NSCategorization/NSCategorization.h>

NS_ASSUME_NONNULL_BEGIN

#define TR_GL_TITLE_ALL       NSLocalizedString(@"All", @"StatusCategory title")
#define TR_GL_TITLE_DOWN      NSLocalizedString(@"Downloading", @"StatusCategory title")
#define TR_GL_TITLE_SEED      NSLocalizedString(@"Seeding", @"StatusCategory title")
#define TR_GL_TITLE_STOP      NSLocalizedString(@"Stopped", @"StatusCategory title")
#define TR_GL_TITLE_ACTIVE    NSLocalizedString(@"Active", @"StatusCategory title")
#define TR_GL_TITLE_CHECK     NSLocalizedString(@"Checking", @"StatusCategory title")
#define TR_GL_TITLE_WAIT      NSLocalizedString(@"Waiting", @"StatusCategory title")
#define TR_GL_TITLE_ERROR     NSLocalizedString(@"Error", @"StatusCategory title")
#define TR_GL_TITLE_COMPL     NSLocalizedString(@"Completed", @"StatusCategory title")


#define TR_STATUS_IMAGE_DOWNLOAD    @"StatusDownload"
#define TR_STATUS_IMAGE_ALL         @"StatusAll"
#define TR_STATUS_IMAGE_UPLOAD      @"StatusUpload"
#define TR_STATUS_IMAGE_ERROR       @"StatusError"
#define TR_STATUS_IMAGE_WAIT        @"StatusWait"
#define TR_STATUS_IMAGE_COMPLETED   @"StatusCompleted"
#define TR_STATUS_IMAGE_STOP        @"StatusStop"
#define TR_STATUS_IMAGE_VERIFY      @"StatusVerify"
#define TR_STATUS_IMAGE_ACTIVE      @"StatusActive"

typedef enum : NSUInteger {
    SortName,
    SortPosition,
    SortSize,
    SortETA,
    SortDone,
    SortSeeds,
    SortPeers,
    SortDownRate,
    SortUpRate,
    SortDateAdded,
    SortDateDone
} SortOptions;


@interface Label (TorrentLabel)

@property (nonatomic,readonly) NSImage *image;

@end


@interface GroupLabel (TorrentLabel)

+(GroupLabel*)torrentLabels;

@end


NS_ASSUME_NONNULL_END
