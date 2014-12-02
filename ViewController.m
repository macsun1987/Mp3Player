//
//  ViewController.m
//  Mp3Player
//
//  Created by sunzhen on 14-12-1.
//  Copyright (c) 2014年 sunzhen. All rights reserved.
//

#import "ViewController.h"
#import "FSAudioStream.h"
#import "Player.h"

@interface ViewController ()
{
    FSAudioStream *_audioStream;
//    NSTimer * _timer;
    CADisplayLink * gameTimer;
}
@property (weak, nonatomic) IBOutlet UILabel *beginLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.slider addTarget:self action:@selector(tapSlider) forControlEvents:UIControlEventTouchDown];
    
    [self.slider addTarget:self action:@selector(tapUpSlider) forControlEvents:UIControlEventTouchUpInside];
    NSString * url = @"http://d.pcs.baidu.com/file/87a75c7979945177647749e5d149f448?fid=2337020227-250528-1120062439639966&time=1417487759&rt=sh&sign=FDTAERV-DCb740ccc5511e5e8fedcff06b081203-yCrt%2BZHRrsTPhR8bpXYC5HDm1n4%3D&expires=8h&prisign=GF6x2T2CVlRV01o7Pki028kp4XDNjnf6DEaBONVnjf612EcuJMuRsnKz+HfXG/Q2MvIBe085VS9KFVk7+Z/mfCUzLQRwxROMf90inBs7sPseOaCzjNnmw7AO1vTJeKp6mmFgqvCvheQoGj51hg3KAYNZ+uowY50RjdNouMW6ZJs3R8EZEh0RAiZUN6+8p+NEOUNnkDz9Kmzc7F49OlDKdJ59Mu8R7HPxbtc0MXsneCLfRocnTqHIy3OmhsFzMyn4l7mehWG59a+AT4P2nxYhhaBSw2OKuYURgWE5cxJgy5HdfwffLwoC2A==&chkv=1&chkbd=0&chkpc=&r=875422378";
    NSString * name = @"我相信";
    Player * player = [[Player alloc]initWithUrl:url title:name];
    player.frame = CGRectMake(10, 400, 300, 60);
    
    [self.view addSubview:player];
    
//    [self play];
    
}
-(void)tapUpSlider
{
    [self jump];
    [self addTimer];
}
-(void)tapSlider
{
    [self removeTimer];
}

-(void)removeTimer
{
    //移除监听器
    [gameTimer invalidate];
    gameTimer = nil;
}

-(void)addTimer
{
    gameTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(sliderChange)];
    [gameTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)jump
{
    FSStreamPosition pos = {0};
    pos.position = self.slider.value;
    [_audioStream seekToPosition:pos];
}

- (IBAction)click:(id)sender
{
    [self jump];
    
}

-(void)valueChange
{
    NSLog(@"value change --%f",self.slider.value);
}
- (IBAction)play:(id)sender {
    NSLog(@"%f",_audioStream.currentTimePlayed.position);
}
- (IBAction)pause:(id)sender {
    [_audioStream pause];
    if (_audioStream.isPlaying) {
        [self.playBtn setTitle:@"暂停" forState:UIControlStateNormal];
    }else
    {
         [self.playBtn setTitle:@"开始" forState:UIControlStateNormal];
    }
}

-(void)sliderChange
{
    self.slider.value =_audioStream.currentTimePlayed.position;
//    NSLog(@"%d---%d",_audioStream.currentTimePlayed.minute, _audioStream.currentTimePlayed.second);
    self.beginLabel.text = [NSString stringWithFormat:@"%02d:%02d/%02d:%02d",_audioStream.currentTimePlayed.minute,_audioStream.currentTimePlayed.second,_audioStream.duration.minute,_audioStream.duration.second];
    if (_audioStream.currentTimePlayed.position >= 0.99) {

        [gameTimer invalidate];
        gameTimer = nil;
        
        [self play];
    }
}

-(void)play
{
    _audioStream = [[FSAudioStream alloc] init];
    [_audioStream playFromURL:[NSURL URLWithString:@"http://d.pcs.baidu.com/file/87a75c7979945177647749e5d149f448?fid=2337020227-250528-1120062439639966&time=1417487759&rt=sh&sign=FDTAERV-DCb740ccc5511e5e8fedcff06b081203-yCrt%2BZHRrsTPhR8bpXYC5HDm1n4%3D&expires=8h&prisign=GF6x2T2CVlRV01o7Pki028kp4XDNjnf6DEaBONVnjf612EcuJMuRsnKz+HfXG/Q2MvIBe085VS9KFVk7+Z/mfCUzLQRwxROMf90inBs7sPseOaCzjNnmw7AO1vTJeKp6mmFgqvCvheQoGj51hg3KAYNZ+uowY50RjdNouMW6ZJs3R8EZEh0RAiZUN6+8p+NEOUNnkDz9Kmzc7F49OlDKdJ59Mu8R7HPxbtc0MXsneCLfRocnTqHIy3OmhsFzMyn4l7mehWG59a+AT4P2nxYhhaBSw2OKuYURgWE5cxJgy5HdfwffLwoC2A==&chkv=1&chkbd=0&chkpc=&r=875422378"]];
    
    [self addTimer];
    
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask , YES)lastObject];
    NSString *fileName = [path stringByAppendingPathComponent:@"test.mp3"];
    _audioStream.outputFile = [NSURL fileURLWithPath:fileName];
    
//    self.slider.frame = CGRectMake(0, 0, 300, 50);
    [self.slider setThumbImage:[UIImage imageNamed:@"b"] forState:UIControlStateNormal];
    UIImage * minImage = [UIImage imageNamed:@"c"];
    UIImage * maxImage = [UIImage imageNamed:@"b"];
   minImage =  [minImage stretchableImageWithLeftCapWidth:5 topCapHeight:0];
   maxImage =  [maxImage stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    [self.slider setMinimumTrackImage: minImage forState:UIControlStateNormal];
    
    [self.slider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
//    UISlider * slider1 = [[UISlider alloc]initWithFrame:CGRectMake(10, 10, 300, 100)];
//    [self.view addSubview:slider1];
//    [slider1 setMaximumTrackImage:[UIImage imageNamed:@"b"] forState:UIControlStateNormal];
    
   
    
}



@end
