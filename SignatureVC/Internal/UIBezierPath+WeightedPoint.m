//
//  UIBezierPath+WeightedPoint.m
//  SignatureObjCDemo
//
//  Created by 金融研發一部-許祐禎 on 2020/1/15.
//  Copyright © 2020 金融研發一部-許祐禎. All rights reserved.
//

#import "UIBezierPath+WeightedPoint.h"
#import "CGPointHelpers.h"


/**
 A struct to represent a line between a start and end point
 */
typedef struct
{
    CGPoint startPoint;
    CGPoint endPoint;
} Line;

/**
 A struct to represent a pair of Lines
 */
typedef struct
{
    Line firstLine;
    Line secondLine;
} LinePair;


@implementation UIBezierPath (WeightedPoint)

#pragma mark - Public

+ (UIBezierPath *)dotWithWeightedPoint:(WeightedPoint)pointA
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:pointA.point radius:pointA.weight startAngle:0 endAngle:(CGFloat)M_PI * 2.0 clockwise:YES];
    
    return bezierPath;
}

+ (UIBezierPath *)lineWithWeightedPointA:(WeightedPoint)pointA pointB:(WeightedPoint)pointB
{
    LinePair linePair = [UIBezierPath _linesPerpendicularToLineWithWeightedPointA:pointA pointB:pointB];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:linePair.firstLine.startPoint];
    [bezierPath addLineToPoint:linePair.secondLine.startPoint];
    [bezierPath addLineToPoint:linePair.secondLine.endPoint];
    [bezierPath addLineToPoint:linePair.firstLine.endPoint];
    [bezierPath closePath];
    
    return bezierPath;
}

+ (UIBezierPath *)quadCurveWithWeightedPointA:(WeightedPoint)pointA pointB:(WeightedPoint)pointB pointC:(WeightedPoint)pointC
{
    LinePair linePairAB = [self.class _linesPerpendicularToLineWithWeightedPointA:pointA pointB:pointB];
    LinePair linePairBC = [self.class _linesPerpendicularToLineWithWeightedPointA:pointB pointB:pointC];
    
    Line lineA = linePairAB.firstLine;
    Line lineB = [self.class _averageLine:linePairAB.secondLine andLine:linePairBC.firstLine];
    Line lineC = linePairBC.secondLine;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:lineA.startPoint];
    [bezierPath addQuadCurveToPoint:lineC.startPoint controlPoint:lineB.startPoint];
    [bezierPath addLineToPoint:lineC.endPoint];
    [bezierPath addQuadCurveToPoint:lineA.endPoint controlPoint:lineB.endPoint];
    [bezierPath closePath];
    
    return bezierPath;
}

+ (UIBezierPath *)bezierCurveWithWeightedPointA:(WeightedPoint)pointA pointB:(WeightedPoint)pointB pointC:(WeightedPoint)pointC pointD:(WeightedPoint)pointD
{
    LinePair linePairAB = [self.class _linesPerpendicularToLineWithWeightedPointA:pointA pointB:pointB];
    LinePair linePairBC = [self.class _linesPerpendicularToLineWithWeightedPointA:pointB pointB:pointC];
    LinePair linePairCD = [self.class _linesPerpendicularToLineWithWeightedPointA:pointC pointB:pointD];
    
    Line lineA = linePairAB.firstLine;
    Line lineB = [self.class _averageLine:linePairAB.secondLine andLine:linePairBC.firstLine];
    Line lineC = [self.class _averageLine:linePairBC.secondLine andLine:linePairCD.firstLine];
    Line lineD = linePairCD.secondLine;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:lineA.startPoint];
    [bezierPath addCurveToPoint:lineD.startPoint controlPoint1:lineB.startPoint controlPoint2:lineC.startPoint];
    [bezierPath addLineToPoint:lineD.endPoint];
    [bezierPath addCurveToPoint:lineA.endPoint controlPoint1:lineC.endPoint controlPoint2:lineB.endPoint];
    [bezierPath closePath];
    
    return bezierPath;
}

#pragma mark - Private

+ (LinePair)_linesPerpendicularToLineWithWeightedPointA:(WeightedPoint)pointA pointB:(WeightedPoint)pointB
{
    Line line = (Line){pointA.point, pointB.point};
    
    Line linePerpendicularToPointA = [self.class _linePerpendicularToLine:line withMiddlePoint:pointA.point length:pointA.weight];
    Line linePerpendicularToPointB = [self.class _linePerpendicularToLine:line withMiddlePoint:pointB.point length:pointB.weight];
    
    return (LinePair){linePerpendicularToPointA, linePerpendicularToPointB};
}

+ (Line)_linePerpendicularToLine:(Line)line withMiddlePoint:(CGPoint)middlePoint length:(CGFloat)newLength
{
    // Calculate end point if line started at 0,0
    CGPoint relativeEndPoint = CGPointDifferentialPointOfPoints(line.startPoint, line.endPoint);
    
    if (newLength == 0 || CGPointEqualToPoint(relativeEndPoint, CGPointZero)) {
        return (Line){middlePoint, middlePoint};
    }
    
    // Modify line's length to be the length needed either side of the middle point
    CGFloat lengthEitherSideOfMiddlePoint = newLength / 2.0f;
    CGFloat originalLineLength = [self.class _lengthOfLine:line];
    CGFloat lengthModifier = lengthEitherSideOfMiddlePoint / originalLineLength;
    relativeEndPoint.x *= lengthModifier;
    relativeEndPoint.y *= lengthModifier;
    
    // Swap X/Y and invert one axis to get perpendicular line
    CGPoint perpendicularLineStartPoint = CGPointMake(relativeEndPoint.y, -relativeEndPoint.x);
    // Make other axis negative for perpendicular line in the opposite direction
    CGPoint perpendicularLineEndPoint = CGPointMake(-relativeEndPoint.y, relativeEndPoint.x);
    
    // Move perpendicular line to middle point
    perpendicularLineStartPoint.x += middlePoint.x;
    perpendicularLineStartPoint.y += middlePoint.y;
    
    perpendicularLineEndPoint.x += middlePoint.x;
    perpendicularLineEndPoint.y += middlePoint.y;
    
    return (Line){perpendicularLineStartPoint, perpendicularLineEndPoint};
}

#pragma mark - Helpers

+ (Line)_averageLine:(Line)lineA andLine:(Line)lineB
{
    return (Line){CGPointAveragePoints(lineA.startPoint, lineB.startPoint), CGPointAveragePoints(lineA.endPoint, lineB.endPoint)};
}

+ (CGFloat)_lengthOfLine:(Line)line
{
    return CGPointDistanceBetweenPoints(line.startPoint, line.endPoint);
}

@end

