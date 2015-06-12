//
//  SBReviewView.m
//  CocoaBloc
//
//  Created by Mark Glagola on 11/24/14.
//  Copyright (c) 2014 StageBloc. All rights reserved.
//

#import "SBReviewView.h"
#import <PureLayout/PureLayout.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "SBCaptionButton.h"
#import "SBOptionsChevronButton.h"

static NSTimeInterval const kAnimationDuration = 0.35f;
static CGFloat const kAnimationDamping = 1.0f;
static CGFloat const kAnimationVelocity = 0.5f;

@interface SBReviewView ()

@property (nonatomic) UITapGestureRecognizer *tapGesture;

@property (nonatomic) NSArray *optionsConstraints;

@property (nonatomic) UIView *centerOptionsSpacerView;

@end

@implementation SBReviewView

#pragma mark - Enum
- (BOOL) optionsContain:(SBReviewViewOptions)option {
    return (self.options  & option) != 0;
}
- (BOOL) shouldShowOptions {
    return ![self optionsContain:SBReviewViewOptionsDoNotShow];
}
- (BOOL) shouldShowButton:(SBReviewViewOptions)option {
    return [self optionsContain:option];
}

#pragma mark - View State
- (instancetype) initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.options = SBReviewViewOptionsDoNotShow;

        // View containing title/caption fields and background toolbar
        self.textContainerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), 0.f)];
        [self addSubview:self.textContainerView];

        // Tool bar backgrounds
        self.toolBarTitleField = [[UIToolbar alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), 50)];
        self.toolBarTitleField.barStyle = UIBarStyleBlack;
        self.toolBarTitleField.translucent = YES;
        [self.textContainerView addSubview:self.toolBarTitleField];

        self.toolBarDescriptionField = [[UIToolbar alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), 50)];
        self.toolBarDescriptionField.barStyle = UIBarStyleBlack;
        self.toolBarDescriptionField.translucent = YES;
        [self.textContainerView addSubview:self.toolBarDescriptionField];

        // Title field
        self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 50)];
        self.titleField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Add a title" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.5f]}];
        [[UITextField appearance] setTintColor:[UIColor whiteColor]];
        self.titleField.textColor = [UIColor whiteColor];
        self.titleField.textAlignment = NSTextAlignmentCenter;
        [self.toolBarTitleField addSubview:self.titleField];

        // Caption field
        self.descriptionField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 50)];
        self.descriptionField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"caption" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.5f]}];
        [[UITextField appearance] setTintColor:[UIColor whiteColor]];
        self.descriptionField.textColor = [UIColor whiteColor];
        self.descriptionField.textAlignment = NSTextAlignmentCenter;
        [self.toolBarDescriptionField addSubview:self.descriptionField];

        [self.titleField autoCenterInSuperview];
        [self.titleField autoMatchDimension:ALDimensionWidth
                                toDimension:ALDimensionWidth
                                     ofView:self.titleField.superview];
        [self.titleField autoMatchDimension:ALDimensionHeight
                                toDimension:ALDimensionHeight
                                     ofView:self.titleField.superview];


        [self.toolBarDescriptionField addSubview:self.descriptionField];

        [self.descriptionField autoCenterInSuperview];
        [self.descriptionField autoMatchDimension:ALDimensionWidth
                                      toDimension:ALDimensionWidth
                                           ofView:self.descriptionField.superview];
        [self.descriptionField autoMatchDimension:ALDimensionHeight
                                      toDimension:ALDimensionHeight
                                           ofView:self.descriptionField.superview];


        [self adjustToolBarConstraints:SBTextFieldLayoutHidden];

        //options menu
        self.optionsViewContainer = [[SBBottomViewContrainer alloc] init];
        self.optionsViewContainer.dragDirection = SBDraggableViewDirectionUpDown;
        self.optionsViewContainer.dragDelegate = self;
        self.optionsViewContainer.height = 250;

        UIToolbar *optionsMenuToolbar = self.optionsViewContainer.toolbar;
        self.officialButton = [[SBCaptionButton alloc] init];
        self.officialButton.offImage = [UIImage imageNamed:@"sb_camera_official_off"];
        self.officialButton.onImage = [UIImage imageNamed:@"sb_camera_official_on"];
        self.officialButton.on = NO;
        self.officialButton.imageView.contentMode = UIViewContentModeCenter;
        self.officialButton.captionLabel.text = @"Official";
        [optionsMenuToolbar addSubview:self.officialButton];

        self.exclusiveButton = [[SBCaptionButton alloc] init];
        self.exclusiveButton.offImage = [UIImage imageNamed:@"sb_camera_exclusive_off"];
        self.exclusiveButton.onImage = [UIImage imageNamed:@"sb_camera_exclusive_on"];
        self.exclusiveButton.imageView.contentMode = UIViewContentModeCenter;
        self.exclusiveButton.on = NO;
        self.exclusiveButton.captionLabel.text = @"Exclusive";
        [optionsMenuToolbar addSubview:_exclusiveButton];

        self.centerOptionsSpacerView = [[UIView alloc] init];
        self.centerOptionsSpacerView.backgroundColor = [UIColor clearColor];
        self.centerOptionsSpacerView.userInteractionEnabled = NO;
        [optionsMenuToolbar addSubview:self.centerOptionsSpacerView];

        [self addSubview:self.optionsViewContainer];

        [self.optionsViewContainer adjustConstraintsHidden:YES];
        CGSize size = CGSizeMake(70, 60);
        [self.officialButton autoSetDimensionsToSize:size];
        [self.exclusiveButton autoSetDimensionsToSize:size];
        [self.centerOptionsSpacerView autoSetDimensionsToSize:size];
        [self.centerOptionsSpacerView autoAlignAxis:ALAxisVertical toSameAxisOfView:self];
        [self.centerOptionsSpacerView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.optionsViewContainer.toolbar];

        //options menu button
        self.optionsMenuButton = [[SBOptionsChevronButton alloc] init];
        [self addSubview:self.optionsMenuButton];
        self.optionsMenuButton.bottomContainerView = self.optionsViewContainer;
        [self.optionsMenuButton autoAlignAxis:ALAxisVertical toSameAxisOfView:self];
        [self.optionsMenuButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self withOffset:-10];
        [self.optionsMenuButton autoSetDimensionsToSize:CGSizeMake(50, 50)];

        //buttons
        self.acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.acceptButton setImage:[[UIImage imageNamed:@"sb_camera_checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.acceptButton.tintColor = [UIColor colorWithRed:.078431373 green:.866666667 blue:.807843137 alpha:1];
        self.acceptButton.imageView.contentMode = UIViewContentModeCenter;
        self.acceptButton.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.acceptButton];

        self.rejectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rejectButton setImage:[[UIImage imageNamed:@"sb_camera_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.rejectButton.tintColor = [UIColor colorWithRed:1 green:.294117647 blue:.376470588 alpha:1];
        self.rejectButton.imageView.contentMode = UIViewContentModeCenter;
        self.rejectButton.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.rejectButton];

        [self adjustBottomButtonConstraintsWithBottomOffset:-40];

        CGSize buttonSize = CGSizeMake(50, 50);
        CGPoint buttonOffset = CGPointMake(20, 20);

        self.drawButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.drawButton setImage:[UIImage imageNamed:@"sb_camera_draw_circle"] forState:UIControlStateNormal];
        self.drawButton.imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.drawButton];

        [self.drawButton autoSetDimensionsToSize:buttonSize];
        [self.drawButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.textContainerView withOffset:buttonOffset.y];
        [self.drawButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:-buttonOffset.x];

        self.undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.undoButton setImage:[UIImage imageNamed:@"sb_camera_undo_circle"] forState:UIControlStateNormal];
        self.undoButton.imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.undoButton];

        [self.undoButton autoSetDimensionsToSize:buttonSize];
        [self.undoButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.textContainerView withOffset:buttonOffset.y];
        [self.undoButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:buttonOffset.x];


        //notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

        @weakify(self)
        //gestures
        self.tapGesture = [[UITapGestureRecognizer alloc] init];
        self.tapGesture.delegate = self;
        [self addGestureRecognizer:self.tapGesture];

        [[[self.tapGesture rac_gestureSignal] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(UITapGestureRecognizer *gesture) {
            @strongify(self);

            if (self.descriptionField.isEditing || self.titleField.isEditing) {
                [self endEditing:YES];
                return;
            }

            if (self.currentLayout == SBTextFieldLayoutHidden) {
                if (self.titleField.text.length > 0) {
                    self.currentLayout = SBTextFieldLayoutTitleDescription;
                } else {
                    self.currentLayout = SBTextFieldLayoutTitle;
                }
            }
            else if (self.currentLayout == SBTextFieldLayoutTitle && self.titleField.text.length == 0){
                self.currentLayout = SBTextFieldLayoutHidden;
            }
        }];

        [[[self.titleField.rac_textSignal skip:1] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *text) {
            @strongify(self);
            if (text.length == 0) {
                self.currentLayout = SBTextFieldLayoutTitle;
            } else {
                self.currentLayout = SBTextFieldLayoutTitleDescription;
            }
        }];

        [[[self.titleField rac_signalForControlEvents:UIControlEventEditingDidEndOnExit] map:^NSNumber*(UITextField *field) {
            return @(field.text.length > 0);
        }] subscribeNext:^(NSNumber *isTextEntered) {
            @strongify(self);
            if (isTextEntered.boolValue) {
                [self.descriptionField becomeFirstResponder];
            }
        }];

        [[RACObserve(self.officialButton, on) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *value) {
            @strongify(self);
            BOOL isOn = value.boolValue;
            [self adjustOptionsButtonsAndAnimate];

            if (!isOn) {
                self.exclusiveButton.on = NO;
            }
        }];

        [[RACObserve(self, options) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *opts) {
            @strongify(self);
            self.optionsMenuButton.hidden = ![self shouldShowOptions];
            [self adjustOptionsButtonsAndAnimate];
        }];

        RAC(self.acceptButton, enabled) =
        [[self.titleField.rac_textSignal map:^id(NSString *string) {
            return @(string.length > 0);
        }] distinctUntilChanged];

        self.currentLayout = SBTextFieldLayoutTitle;
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return !(touch.view == self.optionsViewContainer || touch.view == self.exclusiveButton || touch.view == self.officialButton || touch.view == self.optionsMenuButton);
}

#pragma mark - Layout
- (void) layoutSubviews {
    [super layoutSubviews];
    _acceptButton.layer.cornerRadius = CGRectGetHeight(_acceptButton.frame) / 2;
    _rejectButton.layer.cornerRadius = CGRectGetHeight(_rejectButton.frame) / 2;
}

- (void) setCurrentLayout:(SBTextFieldLayout)currentLayout {
    [self willChangeValueForKey:@"currentLayout"];
    _currentLayout = currentLayout;
    if (currentLayout != SBTextFieldLayoutTitleDescription) self.descriptionField.text = @"";
    [self didChangeValueForKey:@"currentLayout"];
    [self adjustToolBarConstraints:currentLayout];
}

- (void) adjustToolBarConstraints:(SBTextFieldLayout)layoutType {
    [self.toolbarConstraints autoRemoveConstraints];

    NSMutableArray *constraints = [NSMutableArray array];

    void (^animations)(void) = nil;

    CGFloat height = 105;
    CGFloat offset = height - 100;
    CGFloat titleOffset = offset;

    self.toolBarDescriptionField.alpha = 1;
    self.toolBarTitleField.alpha = 1;

    [self.textContainerView sendSubviewToBack:self.toolBarDescriptionField];

    switch (layoutType) {
        case SBTextFieldLayoutTitle: {
            height = 50 + offset;
            break;
        }
        case SBTextFieldLayoutTitleDescription:
            [self.textContainerView sendSubviewToBack:self.toolBarTitleField];
            break;
        default: { //hidden
            animations = ^ {
                self.toolBarDescriptionField.alpha = 0;
                self.toolBarTitleField.alpha = 0;
            };
            offset = height;
            titleOffset = 50;
            break;
        }
    }

    [constraints addObject:[self.textContainerView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self]];
    [constraints addObject:[self.textContainerView autoSetDimension:ALDimensionHeight toSize:height]];
    [constraints addObject:[self.textContainerView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self withOffset:-offset]]; //hidden

    [constraints addObject:[self.toolBarTitleField autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.textContainerView]];
    [constraints addObject:[self.toolBarTitleField autoSetDimension:ALDimensionHeight toSize:50]];
    [constraints addObject:[self.toolBarTitleField autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.textContainerView withOffset:titleOffset]];

    [constraints addObject:[self.toolBarDescriptionField autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.textContainerView]];
    [constraints addObject:[self.toolBarDescriptionField autoSetDimension:ALDimensionHeight toSize:50]];
    [constraints addObject:[self.toolBarDescriptionField autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.textContainerView]];

    self.toolbarConstraints = [constraints copy];

    [self animateLayoutChangeWithDuration:kAnimationDuration damping:kAnimationDamping velocity:kAnimationVelocity completion:nil];
    [UIView animateWithDuration:kAnimationDuration delay:kAnimationDuration usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:animations completion:nil];
}

- (void) adjustBottomButtonConstraintsWithBottomOffset:(CGFloat)bottomOffset {
    [self.bottomButtonConstraints autoRemoveConstraints];
    NSMutableArray *constraints = [NSMutableArray array];

    CGPoint buttonOffset = CGPointMake(40, bottomOffset);
    CGSize buttonSize = CGSizeMake(60, 60);

    [constraints addObjectsFromArray:[self.acceptButton autoSetDimensionsToSize:buttonSize]];
    [constraints addObject:[self.acceptButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self withOffset:buttonOffset.y]];
    [constraints addObject:[self.acceptButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:-buttonOffset.x]];

    [constraints addObjectsFromArray:[self.rejectButton autoSetDimensionsToSize:buttonSize]];
    [constraints addObject:[self.rejectButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self withOffset:buttonOffset.y]];
    [constraints addObject:[self.rejectButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:buttonOffset.x]];

    self.bottomButtonConstraints = [constraints copy];
}

- (void) adjustOptionsButtonsAndAnimate {
    //don't care, ignore
    if (![self shouldShowOptions])
        return;

    [self.optionsConstraints autoRemoveConstraints];
    NSMutableArray *constraints = [NSMutableArray array];

    CGPoint offset = CGPointMake(10, 30);
    UIToolbar *optionsMenuToolbar = _optionsViewContainer.toolbar;
    BOOL isOfficialOn = self.officialButton.on;

    BOOL bothButtonsEnabled = [self shouldShowButton:SBReviewViewOptionsShowOfficialButton] && [self shouldShowButton:SBReviewViewOptionsShowExclusiveButton];
    if (bothButtonsEnabled) {
        if (isOfficialOn) {
            [constraints addObject:[self.officialButton autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.centerOptionsSpacerView withOffset:--offset.x]];
            [constraints addObject:[self.officialButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:optionsMenuToolbar withOffset:offset.y]];

            [constraints addObject:[self.exclusiveButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.centerOptionsSpacerView withOffset:offset.x]];
            [constraints addObject:[self.exclusiveButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:optionsMenuToolbar withOffset:offset.y]];
        } else {
            [constraints addObject:[self.officialButton autoAlignAxis:ALAxisVertical toSameAxisOfView:self]];
            [constraints addObject:[self.officialButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:optionsMenuToolbar withOffset:offset.y]];

            [constraints addObject:[self.exclusiveButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:optionsMenuToolbar withOffset:5]];
            [constraints addObject:[self.exclusiveButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:optionsMenuToolbar withOffset:offset.y]];
        }
    } else {
        NSArray *buttons = @[self.officialButton, self.exclusiveButton];
        for (UIView *button in buttons) {
            [constraints addObject:[button autoAlignAxis:ALAxisVertical toSameAxisOfView:self]];
            [constraints addObject:[button autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:optionsMenuToolbar withOffset:offset.y]];
        }
    }

    [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
        if (bothButtonsEnabled) {
            self.exclusiveButton.alpha = isOfficialOn ? 1 : 0;
        } else {
            if ([self shouldShowButton:SBReviewViewOptionsShowExclusiveButton]) {
                self.exclusiveButton.alpha = 1;
                self.officialButton.alpha = 0;
            } else {
                self.officialButton.alpha = 1;
                self.exclusiveButton.alpha = 0;
            }
        }
        [self.superview layoutIfNeeded];
    } completion:nil];


    self.optionsConstraints = [constraints copy];
}

#pragma mark - Signals
- (RACSignal*) tapSignal {
    return self.tapGesture.rac_gestureSignal;
}

#pragma mark - Animations
- (void) animateLayoutChangeWithCompletion:(void(^)(BOOL finished))completion {
    [self animateLayoutChangeWithDuration:kAnimationDuration damping:kAnimationDamping velocity:kAnimationVelocity completion:completion];
}

- (void) animateLayoutChangeWithDuration:(NSTimeInterval)duration damping:(CGFloat)damping velocity:(CGFloat)velocity completion:(void(^)(BOOL finished))completion{
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:velocity options:0 animations:^{
        [self.superview.superview layoutIfNeeded];
    } completion:completion];
}

#pragma mark - Button animation methods

- (void)keyboardWillShow:(NSNotification*)notification {
    [self adjustButtonsForKeyboardNotification:notification isHiding:NO];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [self adjustButtonsForKeyboardNotification:notification isHiding:YES];
}

- (void)adjustButtonsForKeyboardNotification:(NSNotification *)notification isHiding:(BOOL)isHiding{
    NSDictionary *notificationInfo = [notification userInfo];
    CGRect finalKeyboardFrame = [[notificationInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[notificationInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    finalKeyboardFrame = [self convertRect:finalKeyboardFrame fromView:self.window];
    if (isHiding) [self adjustBottomButtonConstraintsWithBottomOffset:-40];
    else [self adjustBottomButtonConstraintsWithBottomOffset:-finalKeyboardFrame.size.height - 20];
    [self animateLayoutChangeWithDuration:animationDuration damping:.95 velocity:.5 completion:nil];
}


@end
