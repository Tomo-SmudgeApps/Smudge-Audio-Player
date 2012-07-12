//
//  SmudgeAudioControls.m
//  SmudgeAudioPlayer
//
//  Created by Hisatomo Umaoka on 12/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SmudgeAudioControls.h"

@interface SmudgeAudioControls (){
    float totalTimeInSeconds;
}
@end

@implementation SmudgeAudioControls
@synthesize totalTimeLabel;
@synthesize playThroughLabel;
@synthesize playbackSlider;
@synthesize playButton;
@synthesize audioPlayer;
@synthesize timeObserver;

- (void) addAudioTimeObserver{
    CMTime interval = CMTimeMake(33, 1000);
    self.timeObserver = [audioPlayer addPeriodicTimeObserverForInterval:interval queue:dispatch_get_current_queue() usingBlock:^(CMTime time){
        CMTime endTime = CMTimeConvertScale (audioPlayer.currentItem.asset.duration, audioPlayer.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
        if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
            //Figure out the percentage
            double normalizedTime = (double) audioPlayer.currentTime.value / (double) endTime.value;
            playbackSlider.value = normalizedTime;
        }
    }];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        playButton.enabled = YES;
        
        CMTime duration = self.audioPlayer.currentItem.asset.duration;
        totalTimeInSeconds = CMTimeGetSeconds(duration);
        
        int minutes = totalTimeInSeconds/60;
        int seconds = totalTimeInSeconds-(minutes * 60);
        
        totalTimeLabel.text = @"0:00";
        playThroughLabel.text = [NSString stringWithFormat:@"-%d:%d", minutes, seconds];
    }
}

#pragma mark - Notifications
-(void) finishedPlayingNotification{
    
    playButton.selected = NO;
    [self.audioPlayer pause];
    [audioPlayer seekToTime:CMTimeMake(0.0, 1)];
}

#pragma mark - Initialization
-(void) localInit{
    
    //Add the observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedPlayingNotification) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    //Modify the slider graphics
    [playbackSlider setThumbImage:[UIImage imageNamed:@"Tracker"] forState:UIControlStateNormal];
    
    //Just a local version. We can change this easily
    self.audioPlayer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:@"http://promodj.com/download/3430355/Flo_Rida_vs_Kalwi_Made_in_Whistle_DJ_Style_Mash_Up.mp3"]];
    playButton.enabled = NO;
    
    totalTimeLabel.text = @"";
    playThroughLabel.text = @"Loading...";
    [self.audioPlayer addObserver:self forKeyPath:@"currentTime" options:0 context:nil];
    [self.audioPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
}

#pragma mark - Static Method
+(SmudgeAudioControls *) newControls{
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"SmudgeAudioControls" owner:self options:nil];
    SmudgeAudioControls *view = [nibObjects objectAtIndex:0];
    //This will initialize everything
    [view localInit];
    
    return view;
}

#pragma mark - IBActions

- (IBAction)togglePlayStatus:(id)sender {
    
    if (audioPlayer.status == AVPlayerStatusReadyToPlay) {
        playButton.selected = !playButton.selected;
        
        if (audioPlayer.rate == 0.0) {
                  
            [audioPlayer removeTimeObserver:self.timeObserver];
            [self addAudioTimeObserver];
            
            CMTime updateInterval = CMTimeMake(1, 1);
                        
            __block float totalPlayingSeconds = totalTimeInSeconds;
            [audioPlayer addPeriodicTimeObserverForInterval:updateInterval queue:dispatch_get_current_queue() usingBlock:^(CMTime time){
                
                int currentTime = CMTimeGetSeconds(audioPlayer.currentTime);
                
                int minutesLeft = (totalPlayingSeconds - currentTime)/60;
                int secondsLeft = (totalPlayingSeconds - currentTime)-(minutesLeft * 60);
                
                int progressedMinutes = currentTime/60;
                int progressedSeconds = currentTime-(progressedMinutes * 60);
                
                totalTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", progressedMinutes, progressedSeconds];
                playThroughLabel.text = [NSString stringWithFormat:@"-%02d:%02d", minutesLeft, secondsLeft];
            }];
            
            [audioPlayer play];
        }
        else{
            [audioPlayer removeTimeObserver:self.timeObserver];
            [audioPlayer pause];
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Buffering" message:@"Player still buffering contnet" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }

}

- (IBAction)sliderUpdated:(id)sender {
    [audioPlayer pause];
    
    [self addAudioTimeObserver];
    
    [audioPlayer seekToTime:CMTimeMake(playbackSlider.value * totalTimeInSeconds, 1)];
    
    if (playButton.selected) {
        [audioPlayer play];
    }
}

- (IBAction)sliderBegin:(id)sender {    
    NSLog(@"here");
    [audioPlayer removeTimeObserver:self.timeObserver];
}

@end
