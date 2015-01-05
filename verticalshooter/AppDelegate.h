//
//  AppDelegate.h
//  verticalshooter
//
//  Created by Steven Stewart on 1/4/15.
//  Copyright (c) 2015 Steven Stewart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,GLKViewDelegate>
{
    bool running; //When this is false, update should stop being called.
    
    float screenWidthInPixels;
    float screenHeightInPixels;
    float lastMillies;
}

@property (strong, nonatomic) UIWindow *window;


@end

