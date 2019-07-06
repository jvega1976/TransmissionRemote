//
//  PreferencesOtherController.h
//  Transmission Remote
//
//  Created by Johnny Vega on 3/24/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray (NSDictionaryCreation)
-(NSArray*)arrayOfPlist;
+(NSMutableArray*)arrayOfDirectoryMappings:(NSArray*)array;
@end

@interface DirectoryMapping : NSObject

@property (nonatomic)           NSString*       remoteDirectory;
@property (nonatomic)           NSString*       localDirectory;
@property (readonly,nonatomic)  NSDictionary*   plist;

+(DirectoryMapping*)mappingtWithRemote:(NSString*)remote andLocal:(NSString*)local;

+(DirectoryMapping*)mappingFromPlist:(NSDictionary*)plist;

- (instancetype)initWithRemote:(NSString*)remote andLocal:(NSString*)local;

- (instancetype)initFromPlist:(NSDictionary*)plist;

@end


@interface PreferencesOtherController : NSViewController

@end

NS_ASSUME_NONNULL_END
