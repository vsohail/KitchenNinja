//
//  Level.h
//  KitchenNinja
//
//  Created by Sohil on 4/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Level : NSObject

@property (nonatomic) NSTimeInterval itemFrequency;
@property (nonatomic) int timer;
@property (nonatomic) int force;
@property (nonatomic) int speed;
@property (nonatomic) int scoreDelta;

@end
