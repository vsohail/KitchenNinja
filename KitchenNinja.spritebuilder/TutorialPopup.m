//
//  TutorialPopup.m
//  KitchenNinja
//
//  Created by Sohil Veljee on 5/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "TutorialPopup.h"

@implementation TutorialPopup {
    CCLabelTTF *_tutorialLabel;
}


- (void) setTutorialMessage:(NSString *)message {
    [_tutorialLabel setString:message];
}

@end
