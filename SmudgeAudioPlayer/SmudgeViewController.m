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

- (IBAction)changeSong:(id)sender {
    
    UIButton *selectedButton = sender;
    
    switch (selectedButton.tag) {
        case 0:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeAudioSrc" object:@"http://promodj.com/download/3430355/Flo_Rida_vs_Kalwi_Made_in_Whistle_DJ_Style_Mash_Up.mp3"];
            break;
            
        case 1:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeAudioSrc" object:@"http://dl.tehranhits19.com/upnewmusic/updater/farvardin91/20/Rihanna%20-%20Where%20Have%20You%20Been/Rihanna%20-%20Where%20Have%20You%20Been%20(Hardwell%20Club%20Mix)[192].mp3"];

            break;
            
        case 2:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeAudioSrc" object:@"http://dl7ah.info/Songs/Chris%20Brown/Dont%20Wake%20Up%20Me/128/Chris%20Brown%20-%20Dont%20Wake%20Me%20Up.mp3"];

            break;
        default:
            break;
    }
}
@end
