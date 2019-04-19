//
//  PreferencesUpdateController.h
//  Transmission Remote
//
//  Created by Johnny Vega on 4/19/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Sparkle/Sparkle.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreferencesUpdateController : NSViewController

@property (nonatomic,readonly) SUUpdater *updater;
@end

NS_ASSUME_NONNULL_END
