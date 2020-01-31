//
//  SignatureDrawingModel.m
//  SignatureObjCDemo
//
//  Created by 金融研發一部-許祐禎 on 2020/1/15.
//  Copyright © 2020 金融研發一部-許祐禎. All rights reserved.
//

#import "SignatureDrawingModel.h"
#import "SignatureBezierProvider.h"

@interface SignatureDrawingModel () <SignatureBezierProviderDelegate>

@property (nonatomic) UIImage *signatureImage;
@property (nonatomic) UIBezierPath *temporarySignatureBezierPath;

@property (nonatomic, readonly) SignatureBezierProvider *bezierProvider;

@end


@implementation SignatureDrawingModel

#pragma mark - Initializers

- (instancetype)init
{
    return [self initWithImageSize:CGSizeZero];
}

- (instancetype)initWithImageSize:(CGSize)imageSize
{
    if (self = [super init]) {
        _imageSize = imageSize;
        
        _bezierProvider = [[SignatureBezierProvider alloc] init];
        _bezierProvider.delegate = self;
    }
    
    return self;
}

#pragma mark - Public

- (void)setImageSize:(CGSize)imageSize
{
    if (CGSizeEqualToSize(imageSize, self.imageSize)) {
        return;
    }
    
    // Add the temporary bezier into the current signature image, so the image can be resized
    [self endContinuousLine];
    
    _imageSize = imageSize;
    
    // Resize signature image
    self.signatureImage = [self.class _imageWithImage:self.signatureImage size:self.imageSize];
}

- (void)updateWithPoint:(CGPoint)point
{
    [self.bezierProvider addPointToSignatureBezier:point];
}

- (void)endContinuousLine
{
    self.signatureImage = [self fullSignatureImage];
    self.temporarySignatureBezierPath = nil;
    [self.bezierProvider reset];
}

- (void)reset
{
    self.signatureImage = nil;
    self.temporarySignatureBezierPath = nil;
    [self.bezierProvider reset];
}

- (UIImage *)fullSignatureImage
{
    return [self _signatureImageAddingBezierPath:self.temporarySignatureBezierPath];
}

- (void)addImageToSignature:(UIImage *)image
{
    self.signatureImage = [self.class _imageWithImageA:self.signatureImage imageB:image size:self.imageSize];
}

- (UIColor *)signatureColor
{
    if (!_signatureColor) {
        return [UIColor blackColor];
    }
    
    return _signatureColor;
}

#pragma mark - Private

- (UIImage *)_signatureImageAddingBezierPath:(UIBezierPath *)bezierPath
{
    return [self.class _imageWithImage:self.signatureImage bezierPath:bezierPath color:self.signatureColor size:self.imageSize];
}

#pragma mark - <SignatureBezierProviderDelegate>

- (void)signatureBezierProvider:(SignatureBezierProvider *)provider updatedTemporarySignatureBezier:(UIBezierPath *)temporarySignatureBezier
{
    self.temporarySignatureBezierPath = temporarySignatureBezier;
}

- (void)signatureBezierProvider:(SignatureBezierProvider *)provider generatedFinalizedSignatureBezier:(UIBezierPath *)finalizedSignatureBezier
{
    self.signatureImage = [self _signatureImageAddingBezierPath:finalizedSignatureBezier];
}

#pragma mark - Helpers

+ (UIImage *)_imageWithImage:(UIImage *)image size:(CGSize)size
{
    return [self.class _imageWithImageA:image imageB:nil bezierPath:nil color:nil size:size];
}

+ (UIImage *)_imageWithImageA:(UIImage *)imageA imageB:(UIImage *)imageB size:(CGSize)size
{
    return [self.class _imageWithImageA:imageA imageB:imageB bezierPath:nil color:nil size:size];
}

+ (UIImage *)_imageWithImage:(UIImage *)image bezierPath:(UIBezierPath *)bezierPath color:(UIColor *)color size:(CGSize)size
{
    return [self.class _imageWithImageA:image imageB:nil bezierPath:bezierPath color:color size:size];
}

+ (UIImage *)_imageWithImageA:(UIImage *)imageA imageB:(UIImage *)imageB bezierPath:(UIBezierPath *)bezierPath color:(UIColor *)color size:(CGSize)size
{
    if (![self.class _isPositiveSize:size]) {
        return nil;
    }
    
    if (!imageA && !imageB && !bezierPath) {
        return nil;
    }
    
    CGRect imageFrame = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(imageFrame.size, NO, 0);
    
    [imageA drawInRect:imageFrame];
    [imageB drawInRect:imageFrame];
    
    if (bezierPath) {
        [color setStroke];
        [color setFill];
        
        [bezierPath stroke];
        [bezierPath fill];
    }
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

+ (BOOL)_isPositiveSize:(CGSize)size
{
    return (size.width > 0 && size.height > 0);
}

@end
