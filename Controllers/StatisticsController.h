//
//  StatisticsController.h
//  Transmission Remote
//
//  Created by Johnny Vega on 3/15/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <NSTransmissionRPC/NSTransmissionRPC.h>

NS_ASSUME_NONNULL_BEGIN

@interface StatisticsController : NSViewController

@property (nonatomic) TRSessionStats *trSessionStats;
@property (nonatomic) NSString *currentTimeActive;
@property (nonatomic) NSString *cumulativeTimeActive;
@property (nonatomic) NSString *downloadSpeed;
@property (nonatomic) NSString *uploadSpeed;

@end

NS_ASSUME_NONNULL_END
