//
//  FKViewController.m
//  MoviePlayerTest
//
//  Created by yeeku on 13-8-7.
//  Copyright (c) 2013年 crazyit.org. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "FKViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@interface FKViewController ()
@property (nonatomic ,strong)NSMutableArray     *frameImages;
@end

@implementation FKViewController
MPMoviePlayerController *moviePlayer;
UIImageView *iv ;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _frameImages = [NSMutableArray array];
    
	// 创建本地URL（也可创建基于网络的URL)
	NSURL* movieUrl = [[NSBundle mainBundle]
					   URLForResource:@"song" withExtension:@"mp4"];
	// 使用指定URL创建MPMoviePlayerController
	// MPMoviePlayerController将会播放该URL对应的视频
	moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieUrl];
	// 设置该播放器的控制条风格。
	moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
	// 设置该播放器的缩放模式
	moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    moviePlayer.shouldAutoplay = NO;
	[moviePlayer.view setFrame: CGRectMake(0 , 0 , _movieView.frame.size.width , _movieView.frame.size.height)];
    [self.movieView addSubview: moviePlayer.view];
    
    
    
    UIImage *thumbnail = [moviePlayer thumbnailImageAtTime:33.0
                                                timeOption:MPMovieTimeOptionNearestKeyFrame];
    
    iv = [[UIImageView alloc] initWithImage:thumbnail];
    iv.userInteractionEnabled = YES;
    iv.frame = _movieView.frame;
    [self.view addSubview:iv];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.numberOfTapsRequired = 1;
    [iv addGestureRecognizer:tap];
    
    [self addNotifications];

    [self clipVideoToFrame];
    
    [self initSlideView];
}


- (void)initSlideView
{
    _slideView.frame = CGRectMake(7, 252, 20, 60);
    UIPanGestureRecognizer* gesture = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(handlePan:)];
    // 设置该点击手势处理器至少需要1个手指
    gesture.minimumNumberOfTouches = 1;
    // 设置该点击手势处理器最多需要2个手指
    gesture.maximumNumberOfTouches = 2;
    // 为gv控件添加手势处理器。
    [self.slideView addGestureRecognizer:gesture];

}

- (void)clipVideoToFrame
{
    //本例中，width为300，所以共5个展示帧的image
    int frames = (int)_videoFrameImageView.frame.size.width/60;

    //创建URL
    NSURL *url = [[NSBundle mainBundle]
                 URLForResource:@"song" withExtension:@"mp4"];
    //根据url创建AVURLAsset
    AVURLAsset *urlAsset=[AVURLAsset assetWithURL:url];
    //根据AVURLAsset创建AVAssetImageGenerator
    AVAssetImageGenerator *imageGenerator=[AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    
    //获取video的时长
    CGFloat durationOfVideo = CMTimeGetSeconds([urlAsset duration]);
    //每个截取图片的帧间隔
    CGFloat framePad = durationOfVideo/frames+1;
    
    for (int i = 0; i < frames; i++) {
        /*截图
         * requestTime:缩略图创建时间
         * actualTime:缩略图实际生成的时间
         */
        NSError *error=nil;
        
        //计算每个帧的时间点
        CGFloat timeBySecond = i*framePad;
        
        CMTime time=CMTimeMakeWithSeconds(timeBySecond, 10);//CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
        CMTime actualTime;
        CGImageRef cgImage= [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
        if(error){
            NSLog(@"截取视频缩略图时发生错误，错误信息：%@",error.localizedDescription);
            return;
        }
        CMTimeShow(actualTime);
        UIImage *image=[UIImage imageWithCGImage:cgImage];//转化为UIImage
        [_frameImages addObject:image];
        //保存到相册
        //    UIImageWriteToSavedPhotosAlbum(image,nil, nil, nil);
        CGImageRelease(cgImage);
    }
    
    //将_frameImages显示在View上
    for (int i = 0; i < frames; i++) {
        UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(i*60, 0, 60, 60)];
        iv.image = _frameImages[i];
        [_videoFrameImageView addSubview:iv];
    }
}

#pragma mark- 通知

- (void)addNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(stateChanged) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    // 2. 播放完成
    [nc addObserver:self selector:@selector(finished) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    // 3. 全屏
    [nc addObserver:self selector:@selector(finished) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    // 4. 截屏完成通知
    [nc addObserver:self selector:@selector(captureFinished:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:nil];
    
    // 数组中有多少时间,就通知几次
    // MPMovieTimeOptionExact 精确
    // MPMovieTimeOptionNearestKeyFrame 大概齐
    [moviePlayer requestThumbnailImagesAtTimes:@[@(5.0), @(7.0)] timeOption:MPMovieTimeOptionNearestKeyFrame];
}
- (void)captureFinished:(NSNotification *)notification
{
    NSLog(@"%@", notification);
    UIImage *im =  notification.userInfo[MPMoviePlayerThumbnailImageKey];
    _capture1.image = im;
}

- (void)finished
{
    // 1. 删除通知监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 2. 返回上级窗体
    NSLog(@"完成");
}

/**
 MPMoviePlaybackStateStopped,           停止
 MPMoviePlaybackStatePlaying,           播放
 MPMoviePlaybackStatePaused,            暂停
 MPMoviePlaybackStateInterrupted,       中断
 MPMoviePlaybackStateSeekingForward,    下一个
 MPMoviePlaybackStateSeekingBackward    前一个
 */
- (void)stateChanged
{
    switch (moviePlayer.playbackState) {
        case MPMoviePlaybackStatePlaying:
            NSLog(@"播放");
            break;
        case MPMoviePlaybackStatePaused:
            NSLog(@"暂停");
            break;
        case MPMoviePlaybackStateStopped:
            // 执行[self.moviePlayer stop]或者前进后退不工作时会触发
            NSLog(@"停止");
            break;
        default:
            break;
    }
}

#pragma mark- 播放控制

- (IBAction)play:(id)sender
{
    iv.hidden = YES;
	[moviePlayer play];
}

- (IBAction)pause:(id)sender {
    [moviePlayer pause];
}

- (IBAction)stop:(id)sender {
    [moviePlayer stop];
}

#pragma mark- 手势处理
- (void)handleTap:(UITapGestureRecognizer *)gesture{
    iv.hidden = YES;
    [moviePlayer play];
}

- (void) handlePan:(UIPanGestureRecognizer*)gesture
{
    CGPoint velocity = [gesture velocityInView:self.slideView];
    
    // 1.在view上面挪动的距离
    CGPoint translation = [gesture translationInView:gesture.view];
    CGPoint center = gesture.view.center;
    center.x += translation.x;
//    center.y += translation.y;
    gesture.view.center = center;
    
    // 2.清空移动的距离
    [gesture setTranslation:CGPointZero inView:gesture.view];
    
    NSString *tmpStr = [NSString stringWithFormat:
                       @"水平速度为：%g, 垂直速度为：%g, 水平位移为：%g, 垂直位移为：%g"
                       , velocity.x , velocity.y
                       , translation.x , translation.y];
    NSLog(@"slideView%@",tmpStr);

}



#pragma mark- action

- (IBAction)changeFrame:(id)sender {
    
    
    //创建URL
    NSURL *url = [[NSBundle mainBundle]
                  URLForResource:@"song" withExtension:@"mp4"];
    //根据url创建AVURLAsset
    AVURLAsset *urlAsset=[AVURLAsset assetWithURL:url];
    //根据AVURLAsset创建AVAssetImageGenerator
    AVAssetImageGenerator *imageGenerator=[AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    
    //获取video的时长
    CGFloat durationOfVideo = CMTimeGetSeconds([urlAsset duration]);

    /*截图
     * requestTime:缩略图创建时间
     * actualTime:缩略图实际生成的时间
     */
    NSError *error=nil;
    
    //计算每个帧的时间点
    CGFloat timeBySecond = durationOfVideo * _slider.value/1000;
    CGFloat svx = _slider.value/1000 * _videoFrameImageView.frame.size.width;
    _slideView.frame = CGRectMake(svx, _slideView.frame.origin.y, 20, 60);
    
    CMTime time=CMTimeMakeWithSeconds(timeBySecond, 10);//CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
    CMTime actualTime;
    CGImageRef cgImage= [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if(error){
        NSLog(@"截取视频缩略图时发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    CMTimeShow(actualTime);
    UIImage *image=[UIImage imageWithCGImage:cgImage];//转化为UIImage
    _capture2.image = image;
    //保存到相册
    //    UIImageWriteToSavedPhotosAlbum(image,nil, nil, nil);
    CGImageRelease(cgImage);

}

// 重写该方法，控制该视图控制器只支持横屏显示
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

@end
