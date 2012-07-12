//
//  SmudgeAudioControls.h
//  SmudgeAudioPlayer
//
//  Created by Hisatomo Umaoka on 12/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <AVFoundation/AVAsset.h>

@interface SmudgeAudioControls : UIView

#pragma mark - Instance Variables
@property (nonatomic, strong) AVPlayer *audioPlayer;
@property (nonatomic, strong) id timeObserver;

#pragma mark - IBOutlets
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *playThroughLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UISlider *playbackSlider;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *playButton;

#pragma mark - Static Methods
+(SmudgeAudioControls *) newControls;


#pragma mark - Instance Methods
-(void) localInit;

#pragma mark - IBActions
- (IBAction)togglePlayStatus:(id)sender;
- (IBAction)sliderUpdated:(id)sender;
- (IBAction)sliderBegin:(id)sender;

@end
