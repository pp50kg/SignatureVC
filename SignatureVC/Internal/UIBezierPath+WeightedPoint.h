//
//  UIBezierPath+WeightedPoint.h
//  SignatureObjCDemo
//
//  Created by 金融研發一部-許祐禎 on 2020/1/15.
//  Copyright © 2020 金融研發一部-許祐禎. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

/**
 A struct that defines a point that has an associated weight
 */
typedef struct
{
    CGPoint point;
    CGFloat weight;
} WeightedPoint;

/**
 Provides a set of class methods for generating @c UIBezierPaths between weighted points. It provides a dot for a single point, up to a full bezier curve for 4 points.
 
 The bezierPaths generated are actually a shape that needs to be filled. This is how the weight varies gradually between each point rather than using the @c UIBezierPath @c thickness property that sets the thickness of a whole path.
 */
@interface UIBezierPath (WeightedPoint)

/**
 Provides a dot with the given point.
 @param pointA The co-ordinate for the dot's center.
 @return A @c UIBezierPath for the dot.
 */
+ (UIBezierPath *)dotWithWeightedPoint:(WeightedPoint)pointA;

/**
 Provides a straight line between the given points.
 @param pointA @c WeightedPoint for the start of the line.
 @param pointB The @c WeightedPoint for the end of the line.
 @return A \c UIBezierPath shape (that should be filled) for the line.
 */
+ (UIBezierPath *)lineWithWeightedPointA:(WeightedPoint)pointA pointB:(WeightedPoint)pointB;

/**
 Provides a quad curve between the given points.
 @param pointA @c WeightedPoint for the start of the curve.
 @param pointB The @c WeightedPoint for the middle of the curve.
 @param pointC The @c WeightedPoint for the end of the curve.
 @return A @c UIBezierPath shape (that should be filled) for the curve.
 */
+ (UIBezierPath *)quadCurveWithWeightedPointA:(WeightedPoint)pointA pointB:(WeightedPoint)pointB pointC:(WeightedPoint)pointC;

/**
 Provides a bezier curve between the given points.
 @param pointA The @c WeightedPoint for the start of the curve.
 @param pointB The @c WeightedPoint for the first control point of the curve.
 @param pointC The @c WeightedPoint for the second control point of the curve.
 @param pointD The @c WeightedPoint for the end of the curve.
 @return A @c UIBezierPath shape (that should be filled) for the curve.
 */
+ (UIBezierPath *)bezierCurveWithWeightedPointA:(WeightedPoint)pointA pointB:(WeightedPoint)pointB pointC:(WeightedPoint)pointC pointD:(WeightedPoint)pointD;

@end

NS_ASSUME_NONNULL_END
