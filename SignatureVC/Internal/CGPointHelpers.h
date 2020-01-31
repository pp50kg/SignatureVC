//
//  CGPointHelpers.h
//  SignatureObjCDemo
//
//  Created by 金融研發一部-許祐禎 on 2020/1/15.
//  Copyright © 2020 金融研發一部-許祐禎. All rights reserved.
//

#import <CoreGraphics/CGGeometry.h>
#import <Foundation/Foundation.h>

/*
 Generic helper methods for frequently needed calculations on CGPoint.
 */

/**
 Averages the x and y of 2 points.
 @param pointA the first @c CGPoint to average.
 @param pointB the second @c CGPoint to average with.
 @return A @c CGPoint with an x and y equal to the average of the two points' x and y.
 */
static inline CGPoint
CGPointAveragePoints(CGPoint pointA, CGPoint pointB)
{
    CGPoint p;
    p.x = (pointA.x + pointB.x) * 0.5f;
    p.y = (pointA.y + pointB.y) * 0.5f;
    return p;
}

/**
 Calculates the difference in x and y of two points.
 @param pointA the first @c CGPoint.
 @param pointB the second @c CGPoint to calculate the difference from.
 @return A @c CGPoint with an x and y equal to the difference between the two points' x and y.
 */
static inline CGPoint
CGPointDifferentialPointOfPoints(CGPoint pointA, CGPoint pointB)
{
    CGPoint p;
    p.x = pointB.x - pointA.x;
    p.y = pointB.y - pointA.y;
    return p;
}

/**
 Calculates the hypotenuse of the x and y component of a @c CGPoint.
 @param point A @c CGPoint.
 @return A @c CGFloat for the hypotenuse of @c point.
 */
static inline CGFloat
CGPointHypotenuseOfPoint(CGPoint point)
{
    return (CGFloat)sqrt(point.x * point.x + point.y * point.y);
}

/**
 Calculates the distance between two points.
 @param pointA the first @c CGPoint.
 @param pointB the second @c CGPoint to calculate the distance to.
 @return A @c CGFloat of the distance between the points.
 */
static inline CGFloat
CGPointDistanceBetweenPoints(CGPoint pointA, CGPoint pointB)
{
    return CGPointHypotenuseOfPoint(CGPointDifferentialPointOfPoints(pointA, pointB));
}
