//
//  AppDelegate.m
//  verticalshooter
//
//  Created by Steven Stewart on 1/4/15.
//  Copyright (c) 2015 Steven Stewart. All rights reserved.
//

#import "AppDelegate.h"
#import "renderer.h"
#import "controller.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    lastMillies = CACurrentMediaTime() * 1000;
    running = false;
    
    //testing
    [self loadModelFromFile:@"ship2_model"];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
    screenWidthInPixels = (float)screenSize.width;
    screenHeightInPixels = (float)screenSize.height;
    
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
    initDataModel();
    initView(screenWidthInPixels, screenHeightInPixels);
    
    GLKView *view = [[GLKView alloc] initWithFrame:[[UIScreen mainScreen] bounds] context:context];
    view.delegate = self;
    
    GLKViewController *controller = [[GLKViewController alloc] init];
    controller.view = view;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [controller setPreferredFramesPerSecond:60];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
    
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    running = false;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //start update thread
    if(!running)
    {
        running = true;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self updateLoop];
        });
        //[NSThread detachNewThreadSelector:@selector(updateLoop) toTarget:self withObject:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

# pragma mark - GlkView Delegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    renderScene();
}

- (void)updateLoop
{
    NSLog(@"update thread started");
    while(running)
    {
        long currentMillies = CACurrentMediaTime() * 1000;
        long diff = currentMillies - lastMillies;
        lastMillies = currentMillies;
        if(diff > 200) diff = 200;
        
        updateWorld((int)diff);
        
        [NSThread sleepForTimeInterval:0.002];
    }
    NSLog(@"update thread finished");
}
-(void)loadModelFromFile:(NSString*)filename
{
    NSError *error;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:filename ofType:@"txt"];
    NSString *fileContents = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    NSArray *sections = [fileContents componentsSeparatedByString:@" "];
    int vertexCount = 0;
    int indexCount = 0;
    NSArray* vertexComponentStrings = [[NSMutableArray alloc] init];
    NSArray* indexStrings = [[NSMutableArray alloc] init];
    for(int i=0;i<sections.count;i++)
    {
        NSString* section = (NSString*)sections[i];
        if(i==0)
        {
            vertexCount = [section intValue];
        }
        else if(i==1)
        {
            indexCount = [section intValue];
        }
        else if(i==2)
        {
            vertexComponentStrings = [section componentsSeparatedByString:@","];
        }
        else if(i==3)
        {
            indexStrings = [section componentsSeparatedByString:@","];
        }
    }
    
    Vertex* vertices = malloc(sizeof(Vertex)*vertexCount);
    for(int i=0;i<vertexCount;i++)
    {
        vertices[i].x  = [((NSString*)[vertexComponentStrings objectAtIndex:i*9+0]) floatValue];
        vertices[i].y  = [((NSString*)[vertexComponentStrings objectAtIndex:i*9+1]) floatValue];
        vertices[i].z  = [((NSString*)[vertexComponentStrings objectAtIndex:i*9+2]) floatValue];
        vertices[i].nx = [((NSString*)[vertexComponentStrings objectAtIndex:i*9+3]) floatValue];
        vertices[i].ny = [((NSString*)[vertexComponentStrings objectAtIndex:i*9+4]) floatValue];
        vertices[i].nz = [((NSString*)[vertexComponentStrings objectAtIndex:i*9+5]) floatValue];
        vertices[i].r  = [((NSString*)[vertexComponentStrings objectAtIndex:i*9+6]) floatValue];
        vertices[i].g  = [((NSString*)[vertexComponentStrings objectAtIndex:i*9+7]) floatValue];
        vertices[i].b  = [((NSString*)[vertexComponentStrings objectAtIndex:i*9+8]) floatValue];
    }
    
    GLushort* indices = malloc(sizeof(GLushort)*indexCount);
    for(int i=0;i<indexCount;i++)
        indices[i] = (GLushort)[((NSString*)[indexStrings objectAtIndex:i]) intValue];
    
    loadModel(vertexCount, indexCount, vertices, indices);
}
-(void)loadModelFromFile
{
    NSError *error;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:@"potion_model" ofType:@"txt"];
    NSString *fileContents = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    NSArray *sections = [fileContents componentsSeparatedByString:@" "];
    int vertexCount = 0;
    int indexCount = 0;
    NSArray* vertexComponentStrings = [[NSMutableArray alloc] init];
    NSArray* indexStrings = [[NSMutableArray alloc] init];
    for(int i=0;i<sections.count;i++)
    {
        NSString* section = (NSString*)sections[i];
        if(i==0)
        {
            vertexCount = [section intValue];
        }
        else if(i==1)
        {
            indexCount = [section intValue];
        }
        else if(i==2)
        {
            vertexComponentStrings = [section componentsSeparatedByString:@","];
        }
        else if(i==3)
        {
            indexStrings = [section componentsSeparatedByString:@","];
        }
    }
    
    Vertex* vertices = malloc(sizeof(Vertex)*vertexCount);
    for(int i=0;i<vertexCount;i++)
    {
        vertices[i].x  = [((NSString*)[vertexComponentStrings objectAtIndex:i*9+0]) floatValue];
        vertices[i].y  = [((NSString*)[vertexComponentStrings objectAtIndex:i*9+1]) floatValue];
        vertices[i].z  = [((NSString*)[vertexComponentStrings objectAtIndex:i*9+2]) floatValue];
        vertices[i].nx = [((NSString*)[vertexComponentStrings objectAtIndex:i*9+3]) floatValue];
        vertices[i].ny = [((NSString*)[vertexComponentStrings objectAtIndex:i*9+4]) floatValue];
        vertices[i].nz = [((NSString*)[vertexComponentStrings objectAtIndex:i*9+5]) floatValue];
        vertices[i].r  = [((NSString*)[vertexComponentStrings objectAtIndex:i*9+6]) floatValue];
        vertices[i].g  = [((NSString*)[vertexComponentStrings objectAtIndex:i*9+7]) floatValue];
        vertices[i].b  = [((NSString*)[vertexComponentStrings objectAtIndex:i*9+8]) floatValue];
    }
    
    GLushort* indices = malloc(sizeof(int)*indexCount);
    for(int i=0;i<indexCount;i++)
        indices[i] = (GLushort)[((NSString*)[indexStrings objectAtIndex:i]) intValue];
    
    loadModel(vertexCount, indexCount, vertices, indices);
}

@end









