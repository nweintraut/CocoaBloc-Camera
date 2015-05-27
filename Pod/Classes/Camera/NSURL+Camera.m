//
//  NSURL+Camera.m
//  CocoaBloc
//
//  Created by Mark Glagola on 12/17/14.
//  Copyright (c) 2014 StageBloc. All rights reserved.
//

#import "NSURL+Camera.h"

NSString *SBDocumentsDirectory() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return documentsDirectory;
}

@implementation NSURL (Camera)

+ (instancetype) randomDocumentsFileURLWithPrefix:(NSString*)prefix extension:(NSString*)extension {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@-%@.%@", SBDocumentsDirectory(), prefix, [[NSUUID UUID] UUIDString] , extension]];
}

+ (instancetype) randomTemporaryFileURLWithPrefix:(NSString*)prefix extension:(NSString*)extension {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@-%@.%@", NSTemporaryDirectory(), prefix, [[NSUUID UUID] UUIDString], extension]];
}

+ (instancetype) randomTemporaryMP4FileURLWithPrefix:(NSString*)prefix {
    return [self randomTemporaryFileURLWithPrefix:prefix extension:@"mp4"];
}

@end
