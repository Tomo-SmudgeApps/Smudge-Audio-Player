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
@synthesize playerBackground;
@synthesize audioPlayer;
@synthesize sliderObserver;
@synthesize timeProgressObserver;

- (void) addAudioSliderObserver{
    CMTime interval = CMTimeMake(33, 1000);
    
    if (self.sliderObserver) {
        [audioPlayer removeTimeObserver:sliderObserver];
        self.sliderObserver = nil;
    }
    self.sliderObserver = [audioPlayer addPeriodicTimeObserverForInterval:interval queue:NULL usingBlock:^(CMTime time){
        CMTime endTime = CMTimeConvertScale (audioPlayer.currentItem.asset.duration, audioPlayer.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
        if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
            //Figure out the percentage
            double normalizedTime = (double) audioPlayer.currentTime.value / (double) endTime.value;
            playbackSlider.value = normalizedTime;
        }
    }];
}

-(void) addAudioProgressOverver{
    CMTime updateInterval = CMTimeMake(1, 1);
    
    __block float totalPlayingSeconds = totalTimeInSeconds;
    
    if (self.timeProgressObserver) {
        [audioPlayer removeTimeObserver:timeProgressObserver];
        self.timeProgressObserver = nil;
    }
    self.timeProgressObserver = [audioPlayer addPeriodicTimeObserverForInterval:updateInterval queue:NULL usingBlock:^(CMTime time){
        
        int currentTime = CMTimeGetSeconds(audioPlayer.currentTime);
        
        int minutesLeft = (totalPlayingSeconds - currentTime)/60;
        int secondsLeft = (totalPlayingSeconds - currentTime)-(minutesLeft * 60);
        
        int progressedMinutes = currentTime/60;
        int progressedSeconds = currentTime-(progressedMinutes * 60);
        
        totalTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", progressedMinutes, progressedSeconds];
        playThroughLabel.text = [NSString stringWithFormat:@"-%02d:%02d", minutesLeft, secondsLeft];
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
        
        totalTimeLabel.text = @"00:00";
        playThroughLabel.text = [NSString stringWithFormat:@"-%02d:%02d", minutes, seconds];
    }
}

#pragma mark - Notifications
-(void) finishedPlayingNotification{
    
    playButton.selected = NO;
    [self.audioPlayer pause];
    [audioPlayer seekToTime:CMTimeMake(0.0, 1)];
}

-(void) changeAudioSrc:(NSNotification *)notification{
    
    [audioPlayer pause];
    
    NSString *newSource = notification.object;
    
    if ([newSource isKindOfClass:[NSString class]]) {
        //Reset all the values
        playButton.selected = NO;
        playbackSlider.value = 0.0;
        [self.audioPlayer removeObserver:self forKeyPath:@"status"];
        
        //Remove all the time observers
        [audioPlayer removeTimeObserver:self.sliderObserver];
        self.sliderObserver = nil;
        
        [audioPlayer removeTimeObserver:self.timeProgressObserver];
        self.timeProgressObserver = nil;
        
        //Release the player and allocate a new one
        self.audioPlayer = nil;
        self.audioPlayer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:newSource]];
        playButton.enabled = NO;
        
        //Reset each player state
        totalTimeLabel.text = @"";
        playThroughLabel.text = @"Loading...";
        [self.audioPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    }
}

#pragma mark - Initialization
-(void) localInit{
    
    //Add the observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAudioSrc:) name:@"ChangeAudioSrc" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedPlayingNotification) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    //Modify the slider graphics
    [playbackSlider setThumbImage:[UIImage imageNamed:@"Tracker"] forState:UIControlStateNormal];
    
    //Just a local version. We can change this easily
    self.audioPlayer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:@"http://promodj.com/download/3430355/Flo_Rida_vs_Kalwi_Made_in_Whistle_DJ_Style_Mash_Up.mp3"]];
    playButton.enabled = NO;
    
    [playerBackground.layer setCornerRadius:5.0];
    
    totalTimeLabel.text = @"";
    playThroughLabel.text = @"Loading...";
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
                  
            [audioPlayer removeTimeObserver:self.sliderObserver];
            [self addAudioSliderObserver];
            [self addAudioProgressOverver];
            
            [audioPlayer play];
        }
        else{
            [audioPlayer removeTimeObserver:self.sliderObserver];
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
    
    [self addAudioSliderObserver];
    
    [audioPlayer seekToTime:CMTimeMake(playbackSlider.value * totalTimeInSeconds, 1)];
    
    if (playButton.selected) {
        [audioPlayer play];
    }
}

- (IBAction)sliderBegin:(id)sender {    
    [audioPlayer removeTimeObserver:self.sliderObserver];
}

- (void) stopPlaying{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.sliderObserver) {
        [self.audioPlayer removeTimeObserver:self.sliderObserver];
    }
    if (self.timeProgressObserver) {
        [self.audioPlayer removeTimeObserver:self.timeProgressObserver];
    }
    [self.audioPlayer removeObserver:self forKeyPath:@"status"];
    
    if (self.audioPlayer) {
        [self.audioPlayer pause];
        self.audioPlayer = nil;
    }
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.sliderObserver) {
        [self.audioPlayer removeTimeObserver:self.sliderObserver];
    }
    if (self.timeProgressObserver) {
        [self.audioPlayer removeTimeObserver:self.timeProgressObserver];
    }
    [self.audioPlayer removeObserver:self forKeyPath:@"status"];
    
    if (self.audioPlayer) {
        [self.audioPlayer pause];
        self.audioPlayer = nil;
    }
}

@end
