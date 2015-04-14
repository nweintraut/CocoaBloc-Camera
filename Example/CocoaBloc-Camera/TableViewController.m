//
//  TableViewController.m
//  Demo
//
//  Created by Mark Glagola on 11/3/14.
//  Copyright (c) 2014 Mark Glagola. All rights reserved.
//

#import "TableViewController.h"
#import <SBReviewController.h>
#import <CocoaBloc-Camera/SBCameraViewController.h>
#import "SBAsset.h"
#import <CocoaBloc-Camera/SBAssetsManager.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "SBOverlayView.h"
#import "SBCameraAccessViewController.h"

typedef NS_ENUM(NSUInteger, LaunchType) {
    LaunchTypePresent = 0,
    LaunchTypePush = 1,
};

static NSString* const CellId = @"Cell";

@interface TableViewController () <SBCaptureViewControllerDelegate, SBReviewControllerDelegate>

@property (nonatomic) NSArray *rowData;
@property (nonatomic) NSArray *sectionHeaders;

@property (nonatomic, copy) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) ALAssetsLibrary *library;

@property (nonatomic, strong) SBOverlayView *overlayHud;

@end

@implementation TableViewController

- (BOOL) canOpenSettings {
    return (&UIApplicationOpenSettingsURLString != NULL);
}

- (ALAssetsLibrary*)library {
    if (!_library)
        _library = [[ALAssetsLibrary alloc] init];
    return _library;
}

- (NSArray*) rowData {
    if (!_rowData) {
        if ([self canOpenSettings]) {
        _rowData = @[
                     @"Launch Video Controller",
                     @"Launch Photo Controller",
                     @"Launch Review Controller",
                     @"Launch Overlay",
                     @"Launch Settings",
                     ];
        } else {
            _rowData = @[
                         @"Launch Video Controller",
                         @"Launch Photo Controller",
                         @"Launch Review Controller",
                         @"Launch Overlay",
                         ];
        }
    }
    return _rowData;
}

- (NSArray*) sectionHeaders {
    if (!_sectionHeaders) {
        _sectionHeaders = @[
                            @"Present",
//                            @"EXPERIMENTAL - Push view controller" //won't work anymore
                            ];
    }
    return _sectionHeaders;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellId];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionHeaders.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rowData.count; //will be same per section
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId forIndexPath:indexPath];
    cell.textLabel.text = self.rowData[indexPath.row];
    return cell;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionHeaders[section];
}

#pragma mark - Table view delegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SBReviewViewOptions reviewOptions = SBReviewViewOptionsShowOfficialButton | SBReviewViewOptionsShowExclusiveButton;
    
    @weakify(self);
    UIViewController *controller = nil;
    switch (indexPath.row) {
        case 0:
            controller = [[SBCameraViewController alloc] initWithReviewOptions:reviewOptions initialCaptureType:SBCaptureTypeVideo ];
            break;
        case 1:
            controller = [[SBCameraViewController alloc] initWithReviewOptions:reviewOptions initialCaptureType:SBCaptureTypePhoto];
            break;
        case 2:
            controller = [[SBReviewController alloc] initWithAsset:[[SBAsset alloc] initWithImage:[UIImage imageNamed:@"screenshot"] type:SBAssetTypeImage]];
            ((SBReviewController*)controller).delegate = self;
            break;
        case 3: {
            [self.overlayHud dismiss];
            self.overlayHud = [SBOverlayView showInView:self.view.window text:@"Processing Video" dismissOnTap:YES];
            [self.overlayHud.dismissButton setTitle:@"cancel" forState:UIControlStateNormal];
            [self.overlayHud setOnDismissTap:^{
                @strongify(self);
                [self.overlayHud dismiss];
            }];
            break;
        }
        case 4:
            [self openSettings];
            return;
        default:
            break;
    }
    
    if ([controller isKindOfClass:[SBCameraViewController class]]) {
        SBCameraViewController *camController = (SBCameraViewController*) controller;
        camController.captureDelegate = self;
    }
    
    if (controller) {
        if (indexPath.section == LaunchTypePush) {
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
}

- (void) openSettings {
    if ([self canOpenSettings]) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - SBCameraViewControllerDelegate
- (void) cameraControllerCancelled:(SBCameraViewController *)controller {
    if (self.selectedIndexPath.section == LaunchTypePush) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void) reviewController:(SBReviewController *)controller acceptedAsset:(SBAsset *)asset {
    NSLog(@"Got back asset: %@", asset.title);
    
    switch (asset.type) {
        case SBAssetTypeImage: {
            @weakify(self);
            [[asset fetchImage] subscribeNext:^(UIImage *image) {
                @strongify(self);
                [self.library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (error) {
                        NSLog(@"error saving - %@", error);
                        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Your photo couldn't be exported to the photos app at this time." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
                        return;
                    }
                    [[[UIAlertView alloc] initWithTitle:@"Saved!" message:@"Your photo can be viewed in the photos app" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
                }];
            }];
            break;
        }
        case SBAssetTypeVideo:
            [self.library writeVideoAtPathToSavedPhotosAlbum:asset.fileURL completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Your video couldn't be exported to the photos app at this time." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
                    return;
                }
                [[[UIAlertView alloc] initWithTitle:@"Saved!" message:@"Your video can be viewed in the photos app" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
            }];
        default:
            break;
    }
    
    if (self.selectedIndexPath.section == LaunchTypePush) {
        [controller.navigationController popViewControllerAnimated:YES];
    } else {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) reviewController:(SBReviewController *)controller rejectedAsset:(SBAsset *)asset {
    if (self.selectedIndexPath.section == LaunchTypePush) {
        [controller.navigationController popViewControllerAnimated:YES];
    } else {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
