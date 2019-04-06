//
//  PreferencesBandwithController.h
//  TransmissionRemote
//
//  Created by Johnny Vega on 3/8/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TransmissionRPC/TransmissionRPC.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreferencesBandwithController : NSViewController

@property(nonatomic)    TRSessionInfo *trSessionInfo;
@property NSMutableArray *selectedDays;
@end

NS_ASSUME_NONNULL_END
