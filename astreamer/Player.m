//
//  Player.m
//  Mp3Player
//
//  Created by sunzhen on 14-12-2.
//  Copyright (c) 2014年 sunzhen. All rights reserved.
//

#import "Player.h"
#import "FSAudioStream.h"

#define kfont [UIFont systemFontOfSize:13]
@interface Player()
{
    FSAudioStream * _audioStream;
    CADisplayLink * _timer;
}

@property (weak,nonatomic) UILabel * timeLabel;
@property(weak,nonatomic) UIButton * playBtn;
@property(weak,nonatomic) UISlider * progressSlider;
@property (weak,nonatomic) UILabel * titleLabel;
@property (assign,nonatomic) FSAudioStreamState state;

@end
@implementation Player


-(id)initWithUrl:(NSString *)url title:(NSString *)title
{
    _title = title;
    return [self initWithUrl:url];
}


-(id)initWithUrl:(NSString *)url
{
    //这里给一个默认的大小就好了
    if (self = [super init]) {
        _url = url;
        //添加子控件
        [self initSubViews];
    }
    return self;
}




+(instancetype)playWithUrl:(NSString *)url
{
    return  [[self alloc] initWithUrl:url];
}

+(instancetype)playWithUrl:(NSString *)url title:(NSString *)title
{
   
    return  [[self alloc]initWithUrl:url title:title];
}


//初始化子控件
-(void)initSubViews
{
    //1.添加开始按钮
    UIButton * playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [playBtn setTitle:@"暂停" forState:UIControlStateNormal];
//    [playBtn setTitle:@"播放" forState:UIControlStateSelected];
  
    UIImage * pauseImage = [UIImage imageNamed:[NSString stringWithFormat:@"player.bundle/%@",@"audio_pause"]];
    UIImage * startImage = [UIImage imageNamed:[NSString stringWithFormat:@"player.bundle/%@",@"audio_play"]];
    [playBtn setImage:startImage forState:UIControlStateNormal];
    [playBtn setImage:pauseImage forState:UIControlStateSelected];
    playBtn.titleLabel.font = kfont;
    [playBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    _playBtn = playBtn;
    [self addSubview:playBtn];
    
    //2添加标题按钮
    UILabel * titleLable = [[UILabel alloc]init];
    titleLable.font =kfont;
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.textColor = [UIColor colorWithRed:108/255.0 green:108/255.0 blue:108/255.0 alpha:1];
    titleLable.text = self.title;
    _titleLabel = titleLable;
    [self addSubview:titleLable];
    
    //3.添加时间文本
    UILabel * timeLabel = [[UILabel alloc]init];
    timeLabel.font = kfont;
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.textColor = [UIColor colorWithRed:108/255.0 green:108/255.0 blue:108/255.0 alpha:1];
    timeLabel.text = @"00:00/00:00";
    _timeLabel = timeLabel;
    [self addSubview:timeLabel];
    
    //4.添加滑动
    UISlider * slider = [[UISlider alloc]init];
    //4.1设置轨迹图片
    UIImage * minImage = [UIImage imageNamed:[NSString stringWithFormat:@"player.bundle/%@",@"audio_progress_bar0"]];
    minImage = [minImage stretchableImageWithLeftCapWidth:5 topCapHeight:2];
    
    UIImage * maxImage = [UIImage imageNamed:[NSString stringWithFormat:@"player.bundle/%@",@"audio_progress_bar1"]];
    maxImage = [maxImage stretchableImageWithLeftCapWidth:5 topCapHeight:2];
    
    UIImage * thumbImage = [UIImage imageNamed:[NSString stringWithFormat:@"player.bundle/%@",@"audio_progress_bar_spot"]];
    
    [slider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [slider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [slider setThumbImage:thumbImage forState:UIControlStateNormal];
    
    //设置原点图片
    //设置值大小
    [slider setMinimumValue:0.0f];
    [slider setMaximumValue:1.0f];
    
    //4.2添加监听事件
    //手指按下去的事件
    [slider addTarget:self action:@selector(tapSliderDown) forControlEvents:UIControlEventTouchDown];
    //手指抬起来的事件
    [slider addTarget:self action:@selector(tapSliderUp) forControlEvents:UIControlEventTouchUpInside];
    
    _progressSlider = slider;
    [self addSubview:slider];
    
    //5.添加播放器
    [self addPlayer];
    
    [self addTimer];
    
}
-(void)tapSliderDown
{
    //移除定时器
    [self removeTimer];
    
}

-(void)tapSliderUp
{
    if(self.state != kFsAudioStreamPlaybackCompleted)
    {//恢复定时器
        [self addTimer];
        FSStreamPosition pos = {0};
        pos.position = self.progressSlider.value;
        [_audioStream seekToPosition:pos];
        self.playBtn.selected = _audioStream.isPlaying;

        
    }
}
//5.添加播放器
-(void)addPlayer
{
    _audioStream = [[FSAudioStream alloc]init];
    [_audioStream playFromURL:[NSURL URLWithString:self.url]];
    __block Player * me = self;
    [_audioStream setOnStateChange:^(FSAudioStreamState state) {
       if(state == kFsAudioStreamPlaybackCompleted)
       {
           //移除定时器
           [me removeTimer];
           //更新状态
           me.state =kFsAudioStreamPlaybackCompleted;
           me.playBtn.selected = YES;

           
       }
    }];
}

//添加定时器
-(void)addTimer
{
    //每一秒刷新60次
    _timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateUI)];
    [_timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)removeTimer
{
    [_timer invalidate];
    _timer = nil;
}

//更新界面
-(void)updateUI
{
    //更新进度条
    self.progressSlider.value = _audioStream.currentTimePlayed.position;

    //更新时间
    NSString * str = [NSString stringWithFormat:@"%02d:%02d/%02d:%02d",_audioStream.currentTimePlayed.minute,_audioStream.currentTimePlayed.second,_audioStream.duration.minute,_audioStream.duration.second];
    self.timeLabel.text = str;
    
  
    NSLog(@"---");
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    //调整子控件的位置
    
    
    CGFloat margin = 10;
    //button位置
    CGFloat playBtnX = 0;
    CGFloat playBtnW = 44;
    CGFloat playBtnH = self.bounds.size.height * 2 / 3.0;
    CGFloat playBtnY =0;
    self.playBtn.frame = CGRectMake(playBtnX, playBtnY, playBtnW, playBtnH);
    
    //2.时间标签位置
    CGFloat timeLabelW = 80;
    CGFloat timeLabelX =self.bounds.size.width - timeLabelW ;
    CGFloat timeLabelY = 0;
    CGFloat timeLabelH = playBtnH;
    self.timeLabel.frame = CGRectMake(timeLabelX, timeLabelY, timeLabelW, timeLabelH);
    
    //3.标题标签位置
    CGFloat titleLabelX  = playBtnW + playBtnX;
    CGFloat titleLabelY = 0;
    CGFloat titleLabelW = timeLabelX - titleLabelX;
    CGFloat titleLabelH = playBtnH;
    self.titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    
    //4.slider位置
    CGFloat sliderX = margin;
    CGFloat sliderY = playBtnH;
    CGFloat sliderW = self.bounds.size.width - margin*2;
    CGFloat sliderH = self.bounds.size.height - sliderY;
    self.progressSlider.frame = CGRectMake(sliderX, sliderY, sliderW, sliderH);
}


-(void)play
{
    if (self.state == kFsAudioStreamPlaybackCompleted) {
        self.state = kFsAudioStreamPlaying;
        [_audioStream playFromURL:[NSURL URLWithString:self.url]];
        [self addTimer];
        self.playBtn.selected = NO;
    }else
    {
         [_audioStream pause];
        self.playBtn.selected = !_audioStream.isPlaying;

    }
   
}

-(void)pause
{
    [self play];
}

//-(instancetype)initWithFrame:(CGRect)frame
//{
//    if (self = [super initWithFrame:frame]) {
//        
//    }
//    return self;
//}

- (void)drawRect:(CGRect)rect
{
    //1.画矩形
    CGContextRef  ctx = UIGraphicsGetCurrentContext();
    CGContextAddRect(ctx, rect);
    [[UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1] set];
    CGContextFillPath(ctx);
    
    //画下面的矩形
    CGFloat H = rect.size.height / 3.0;
    CGFloat Y = rect.size.height -H;
    CGFloat W = rect.size.width;
    CGContextAddRect(ctx, CGRectMake(0, Y, W, H));
    [[UIColor colorWithRed:177/255.0 green:177/255.0 blue:177/255.0 alpha:1] set];
    CGContextFillPath(ctx);
}


-(void)dealloc
{
    //移除定时器
    [self removeTimer];
    _audioStream = nil;
}



@end
