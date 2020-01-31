//
//  SignatureBezierProvider.m
//  SignatureObjCDemo
//
//  Created by 金融研發一部-許祐禎 on 2020/1/15.
//  Copyright © 2020 金融研發一部-許祐禎. All rights reserved.
//

#import "SignatureBezierProvider.h"
#import "CGPointHelpers.h"

/// The weight of a signature-styled dot.
static CGFloat const kDotSignatureWeight = 3.0f;

/// If a new point is added without being at least this distance from the previous point, it will be ignored.
static CGFloat const kTouchDistanceThreshold = 2.0f;

static NSUInteger const kMaxPointIndex = 3;

@interface SignatureBezierProvider ()

@property (nonatomic) WeightedPoint point0;
@property (nonatomic) WeightedPoint point1;
@property (nonatomic) WeightedPoint point2;
@property (nonatomic) WeightedPoint point3;

@property (nonatomic) NSUInteger nextPointIndex;

@end

@implementation SignatureBezierProvider

#pragma mark - Public

- (void)addPointToSignatureBezier:(CGPoint)point
{
    BOOL isFirstPoint = (self.nextPointIndex == 0);
    if (isFirstPoint) {
        [self _startNewLineFromWeightedPoint:(WeightedPoint){point, kDotSignatureWeight}];
    } else {
        CGPoint previousPoint = [self weightedPointAtIndex:self.nextPointIndex - 1].point;
        if (CGPointDistanceBetweenPoints(point, previousPoint) < kTouchDistanceThreshold) {
            return;
        }
        BOOL isStartPointOfNextLine = (self.nextPointIndex > kMaxPointIndex);
        if (isStartPointOfNextLine) {
            [self _finalizeBezierPathWithNextLineStartPoint:point];
            [self _startNewLineFromWeightedPoint:[self weightedPointAtIndex:3]];
        }
        
        WeightedPoint weightedPoint = {point, [self.class _signatureWeightForLineBetweenPoint:previousPoint andPoint:point]};
        [self _addWeightedPointToLine:weightedPoint];
    }
    
    UIBezierPath *newBezier = [self _generateBezierPathWithPointIndex:self.nextPointIndex - 1];
    [self _notifyDelegateWithTemporarySignatureBezier:newBezier];
}

- (void)reset
{
    self.nextPointIndex = 0;
    [self _notifyDelegateWithTemporarySignatureBezier:nil];
}

- (void)dealloc
{
    self.delegate = nil;
}

#pragma mark - Private

- (void)_startNewLineFromWeightedPoint:(WeightedPoint)point
{
    [self _setWeightedPoint:point forPointIndex:0];
    self.nextPointIndex = 1;
}

- (void)_addWeightedPointToLine:(WeightedPoint)point
{
    [self _setWeightedPoint:point forPointIndex:self.nextPointIndex];
    self.nextPointIndex++;
}

- (void)_finalizeBezierPathWithNextLineStartPoint:(CGPoint)nextStartPoint
{
    /*
     Smooth the join between beziers by modifying the last point of the current bezier
     to equal the average of the points either side of it.
     */
    CGPoint touchPoint2 = [self weightedPointAtIndex:2].point;
    WeightedPoint newPoint3 = {CGPointAveragePoints(touchPoint2, nextStartPoint), 0};
    newPoint3.weight = [self.class _signatureWeightForLineBetweenPoint:touchPoint2 andPoint:newPoint3.point];
    [self _setWeightedPoint:newPoint3 forPointIndex:3];
    
    [self _notifyDelegateWithFinalizedSignatureBezier:[self _generateBezierPathWithPointIndex:3]];
}

- (UIBezierPath *)_generateBezierPathWithPointIndex:(NSUInteger)index
{
    switch (index) {
        case 0:
            return [UIBezierPath dotWithWeightedPoint:[self weightedPointAtIndex:0]];
        case 1:
            return [UIBezierPath lineWithWeightedPointA:[self weightedPointAtIndex:0] pointB:[self weightedPointAtIndex:1]];
        case 2:
            return [UIBezierPath quadCurveWithWeightedPointA:[self weightedPointAtIndex:0] pointB:[self weightedPointAtIndex:1] pointC:[self weightedPointAtIndex:2]];
        case 3:
            return [UIBezierPath bezierCurveWithWeightedPointA:[self weightedPointAtIndex:0] pointB:[self weightedPointAtIndex:1] pointC:[self weightedPointAtIndex:2] pointD:[self weightedPointAtIndex:3]];
        default:
            return nil;
    }
}

#pragma mark - Points index set/get

- (void)_setWeightedPoint:(WeightedPoint)point forPointIndex:(NSUInteger)index
{
    switch (index) {
        case 0:
            self.point0 = point;
            break;
        case 1:
            self.point1 = point;
            break;
        case 2:
            self.point2 = point;
            break;
        case 3:
            self.point3 = point;
            break;
        default:
            break;
    }
}

- (WeightedPoint)weightedPointAtIndex:(NSUInteger)index
{
    switch (index) {
        case 0:
            return self.point0;
        case 1:
            return self.point1;
        case 2:
            return self.point2;
        case 3:
            return self.point3;
        default:
            return (WeightedPoint){CGPointZero, 0.0f};
    }
}

#pragma mark - Delegate calls

- (void)_notifyDelegateWithTemporarySignatureBezier:(UIBezierPath *)bezier
{
    if (![self.delegate respondsToSelector:@selector(signatureBezierProvider:updatedTemporarySignatureBezier:)]) {
        return;
    }
    
    [self.delegate signatureBezierProvider:self updatedTemporarySignatureBezier:bezier];
}

- (void)_notifyDelegateWithFinalizedSignatureBezier:(UIBezierPath *)bezier
{
    if (![self.delegate respondsToSelector:@selector(signatureBezierProvider:generatedFinalizedSignatureBezier:)]) {
        return;
    }
    
    [self.delegate signatureBezierProvider:self generatedFinalizedSignatureBezier:bezier];
}

#pragma mark - Helpers

+ (CGFloat)_signatureWeightForLineBetweenPoint:(CGPoint)pointA andPoint:(CGPoint)pointB
{
    CGFloat length = CGPointDistanceBetweenPoints(pointA, pointB);
    
    /**
     The is the maximum length that will vary weight. Anything higher will return the same weight.
     */
    static const CGFloat maxLengthRange = 50.0f;
    
    /*
     These are based on having a minimum line thickness of 2.0 and maximum of 7, linearly over line lengths 0-maxLengthRange. They fit into a typical linear equation: y = mx + c
     
     Note: Only the points of the two parallel bezier curves will be at least as thick as the constant. The bezier curves themselves could still be drawn with sharp angles, meaning there is no true 'minimum thickness' of the signature.
     */
    static const CGFloat gradient = 0.1f;
    static const CGFloat constant = 2.0f;
    
    CGFloat inversedLength = maxLengthRange - length;
    inversedLength = MAX(0, inversedLength);
    
    return (inversedLength * gradient) + constant;
}

@end

