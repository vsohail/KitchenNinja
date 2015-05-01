//
//  WinPopup.m
//  KitchenNinja
//
//  Created by Sohil on 4/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "WinPopup.h"

@implementation WinPopup {
    CCLabelTTF *_gameScoreLabel;
}


- (void) setScore:(int)score {
   [_gameScoreLabel setString:[NSString stringWithFormat:@"%d", score]];
}

@end
