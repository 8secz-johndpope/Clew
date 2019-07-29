//
//  VisualAlignment.h
//  Clew
//
//  Created by Kawin Nikomborirak on 7/9/19.
//  Copyright © 2019 OccamLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <simd/SIMD.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    float yaw;
    simd_float3x3 square_rotation1;
    simd_float3x3 square_rotation2;
} VisualAlignmentReturn;

@interface VisualAlignment : NSObject
/**
 Deduce the yaw between two images.
 
 - returns: The yaw in radians between the pictures assuming portrait orientation.
 
 - parameters:
 - image1: The image the returned yaw is relative to.
 - intrinsics1: The camera intrinsics used to take image1 in the format [fx, fy, ppx, ppy].
 - pose1: The pose of the camera in the arsession used to take the first image.
 - image2: The image the returned yaw rotates to.
 - intrinsics2: The camera intrinsics used to take image2 in the format [fx, fy, ppx, ppy].
 - pose2: The pose of the camera in the arsession used to take the second image.
 */
+ (VisualAlignmentReturn) visualYaw :(UIImage *)image1 :(simd_float4)intrinsics1 :(simd_float4x4)pose1 :(UIImage *)image2 :(simd_float4)intrinsics2 :(simd_float4x4)pose2;
@end

NS_ASSUME_NONNULL_END
