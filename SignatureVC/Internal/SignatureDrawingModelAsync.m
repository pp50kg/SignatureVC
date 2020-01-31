//
//  SignatureDrawingModelAsync.m
//  SignatureObjCDemo
//
//  Created by 金融研發一部-許祐禎 on 2020/1/15.
//  Copyright © 2020 金融研發一部-許祐禎. All rights reserved.
//

#import "SignatureDrawingModelAsync.h"
#import "SignatureDrawingModel.h"

@interface SignatureDrawingModelAsync ()

/// self.model is atomic, to prevent access by multiple threads at same time
@property (atomic, readonly) SignatureDrawingModel *model;
@property (nonatomic, readonly) NSOperationQueue *operationQueue;

@end

@implementation SignatureDrawingModelAsync

- (instancetype)init
{
    return [self initWithImageSize:CGSizeZero];
}

- (instancetype)initWithImageSize:(CGSize)imageSize
{
    if (self = [super init]) {
        _model = [[SignatureDrawingModel alloc] initWithImageSize:imageSize];
        
        _operationQueue = ({
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            queue.maxConcurrentOperationCount = 1;
            queue;
        });
    }
    
    return self;
}

#pragma mark - Async

- (void)asyncUpdateWithPoint:(CGPoint)point
{
    [self.operationQueue addOperationWithBlock:^{
        [self.model updateWithPoint:point];
    }];
}

- (void)asyncEndContinuousLine
{
    [self.operationQueue addOperationWithBlock:^{
        [self.model endContinuousLine];
    }];
}

- (void)asyncGetOutputWithBlock:(void (^)(UIImage *signatureImage, UIBezierPath *temporarySignatureBezierPath))block
{
    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
    
    [self.operationQueue addOperationWithBlock:^{
        UIImage *signatureImage = self.model.signatureImage;
        UIBezierPath *temporaryBezierPath = self.model.temporarySignatureBezierPath;
        [currentQueue addOperationWithBlock:^{
            block(signatureImage, temporaryBezierPath);
        }];
    }];
}

#pragma mark - Sync

- (void)reset
{
    [self.operationQueue cancelAllOperations];
    [self.model reset];
}

- (void)addImageToSignature:(UIImage *)image
{
    [self.model addImageToSignature:image];
}

- (UIImage *)fullSignatureImage
{
    return [self.model fullSignatureImage];
}

- (CGSize)imageSize
{
    return self.model.imageSize;
}

- (void)setImageSize:(CGSize)imageSize
{
    self.model.imageSize = imageSize;
}

- (UIColor *)signatureColor
{
    return self.model.signatureColor;
}

- (void)setSignatureColor:(UIColor *)signatureColor
{
    self.model.signatureColor = signatureColor;
}

@end
