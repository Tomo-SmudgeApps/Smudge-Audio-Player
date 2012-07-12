//
//  SmudgeViewController.m
//  SmudgeAudioPlayer
//
//  Created by Hisatomo Umaoka on 12/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SmudgeViewController.h"
#import "SmudgeAudioControls.h"

@interface SmudgeViewController ()

@end

@implementation SmudgeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    SmudgeAudioControls *newControl = [SmudgeAudioControls newControls];
    newControl.center = self.view.center;
    [self.view addSubview:newControl];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
