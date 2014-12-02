//
//  Player.h
//  Mp3Player
//
//  Created by ; on 14-12-2.
//  Copyright (c) 2014年 sunzhen. All rights reserved.
//
//

#import <UIKit/UIKit.h>

@interface Player : UIView

@property (copy,nonatomic) NSString * url;

@property (copy,nonatomic) NSString * title;


/**
 *  初始化方法
 *
 */
+(instancetype)playWithUrl:(NSString *)url;

+(instancetype)playWithUrl:(NSString *)url title:(NSString *)title;

-(id)initWithUrl:(NSString *)url;

-(id)initWithUrl:(NSString *)url title:(NSString *)title;

/**
 *  播放
 */
-(void)play;
/**
 *  暂停
 */
-(void)pause;


@end
