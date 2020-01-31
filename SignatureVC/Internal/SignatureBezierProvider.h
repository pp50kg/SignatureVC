//
//  SignatureBezierProvider.h
//  SignatureObjCDemo
//
//  Created by 金融研發一部-許祐禎 on 2020/1/15.
//  Copyright © 2020 金融研發一部-許祐禎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIBezierPath+WeightedPoint.h"
@class SignatureBezierProvider;

NS_ASSUME_NONNULL_BEGIN

@protocol SignatureBezierProviderDelegate <NSObject>

/**
 Provides the temporary signature bezier.
 This can be displayed to represent the most recent points of the signature,
 to give the feeling of real-time drawing but should not be permanently
 drawn, as it will change as more points are added.
 */
- (void)signatureBezierProvider:(SignatureBezierProvider *)provider updatedTemporarySignatureBezier:(nullable UIBezierPath *)temporarySignatureBezier;

/**
 Provides the finalized signature bezier.
 When enough points are added to form a full bezier curve, this will be
 returned as the finalized bezier and the temporary will reset.
 */
- (void)signatureBezierProvider:(SignatureBezierProvider *)provider generatedFinalizedSignatureBezier:(UIBezierPath *)finalizedSignatureBezier;

@end

/**
 Provides signature styled beziers using delegate callbacks as points are added.
 
 Temporary signature will change every time a point is added, occasionally a
 finalized bezier will be generated, which should be cached, as the temporary
 will then reset.
 
 Forms one continuous signature line. Call @c reset to start generating a new line.
 */
@interface SignatureBezierProvider : NSObject

/**
 Adds points to the signature line.
 The weight of the signature is based on the distance apart these points are,
 further apart making the line thinner.
 
 The delegate will receive callbacks when this method is used.
 */
- (void)addPointToSignatureBezier:(CGPoint)point;

/// Resets the provider. addPointToSignatureBezier: will start a new line
- (void)reset;

@property (nullable, nonatomic, weak) id<SignatureBezierProviderDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

