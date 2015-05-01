//
//  LossPopup.m
//  KitchenNinja
//
//  Created by Sohil Veljee on 5/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LossPopup.h"

@implementation LossPopup {
    CCLabelTTF *_lossReasonLabel;
}


- (void) setReason:(NSString *)reason {
    [_lossReasonLabel setString:reason];
}

@end
