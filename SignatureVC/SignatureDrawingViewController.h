//
//  SignatureDrawingViewController.h
//  SignatureObjCDemo
//
//  Created by 金融研發一部-許祐禎 on 2020/1/15.
//  Copyright © 2020 金融研發一部-許祐禎. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SignatureDrawingViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol SignatureDrawingViewControllerDelegate <NSObject>
@optional
/// Callback when @c isEmpty changes, due to user drawing or reset being called.
- (void)signatureDrawingViewController:(SignatureDrawingViewController *)signatureDrawingViewController isEmptyDidChange:(BOOL)isEmpty;

@end

/**
 A view controller that allows the user to draw a signature and provides additional functionality.
 */
@interface SignatureDrawingViewController : UIViewController
/**
 Init
 @param image An optional starting image for the signature.
 @return An instance
 */
- (instancetype)initWithImage:(nullable UIImage *)image NS_DESIGNATED_INITIALIZER;

/// Resets the signature
- (void)reset;

/// Returns a @c UIImage of the signature (with a transparent background).
- (UIImage *)fullSignatureImage;

/**
 Whether the signature drawing is empty or not.
 This changes when the user draws or the view is reset.
 @note Defaults to @c NO if there's a starting image.
 */
@property (nonatomic, readonly) BOOL isEmpty;

/**
 The color of the signature.
 Defaults to black.
 */
@property (nonatomic) UIColor *signatureColor;

/**
 Delegate to receive view controller callbacks.
 */
@property (nullable, nonatomic, weak) id<SignatureDrawingViewControllerDelegate> delegate;

#pragma mark - Unavailable
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
