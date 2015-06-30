//
//  CocoaBloc-CameraTests.m
//  CocoaBloc-CameraTests
//
//  Created by John Heaton on 03/25/2015.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

@import UIKit;
@import Foundation;

SpecBegin(TestImageResources)

describe(@"Images", ^{
    
    NSArray *imageNames = @[@"sb_camera_arrow_down",
                            @"sb_camera_arrow_right",
                            @"sb_camera_checkmark",
                            @"sb_camera_close",
                            @"sb_camera_draw_circle",
                            @"sb_camera_exclusive_off",
                            @"sb_camera_exclusive_on",
                            @"sb_camera_existing",
                            @"sb_camera_flash_auto",
                            @"sb_camera_flash_off",
                            @"sb_camera_flash_on",
                            @"sb_camera_flip",
                            @"sb_camera_official_off",
                            @"sb_camera_official_on",
                            @"sb_camera_ratio_1_1",
                            @"sb_camera_ratio_4_3",
                            @"sb_camera_ratio_16_9",
                            @"sb_camera_undo_circle",
                            ];
    
    NSBundle *bundle = [NSBundle bundleForClass:objc_getClass("SBCaptureView")];
    
    [imageNames enumerateObjectsUsingBlock:^(NSString *imageName, NSUInteger idx, BOOL *stop) {
        
        it([NSString stringWithFormat:@"should find UIImage named: %@", imageName], ^{
            UIImage *image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
            expect(image).notTo.equal(nil);
        });

    }];
    
});

SpecEnd