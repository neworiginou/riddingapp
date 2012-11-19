//
//  PhotoListViewController.m
//  Ridding
//
//  Created by zys on 12-10-8.
//
//

#import "PhotoListViewController.h"
#import "RiddingPictureDao.h"
#import "KTPhotoScrollViewController.h"
#import "StaticInfo.h"
#import "RequestUtil.h"
#import "ImageUtil.h"
#import "ResponseCodeCheck.h"
#import "RNBlurModalView.h"
#import "PhotoUploadBlurView.h"
@interface PhotoListViewController ()

@end

@implementation PhotoListViewController
@synthesize riddingId=_riddingId;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self initHUD];
//  [self.barView.rightButton setTitle:@"上传照片" forState:UIControlStateNormal];
//  [self.barView.rightButton setFrame:CGRectMake(225,6, 84,31)];
//  [self.barView.rightButton setHidden:NO];
  self.barView.titleLabel.text=@"骑行相册";
  queue=[[NSOperationQueue alloc]init];
  // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  //插入数据
  if (myPhotos_ == nil) {
    myPhotos_ = [[Photos alloc] init];
    myPhotos_.riddingId=self.riddingId;
    [myPhotos_ setDelegate:self];
  }
  [self setDataSource:myPhotos_];
  
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  [myPhotos_ flushCache];
  // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark PhotosDelegate
- (void)didFinishSave
{
  [self reloadThumbs];
}


#pragma mark -
#pragma mark photo
- (void)deleteImageAtName:(NSString*)name
{
  dispatch_queue_t q;
  q=dispatch_queue_create("deleteImageAtName", NULL);
  dispatch_async(q, ^{
    NSRange range = [name rangeOfString:@".jpg"];
    [[RiddingPictureDao getSinglton] deleteRiddingPicture:self.riddingId userId:[StaticInfo getSinglton].user.userId dbId:[name substringToIndex:range.location]];
  });
}


- (void)savePhoto:(UIImage *)photo withName:(NSString *)name addToPhotoAlbum:(BOOL)addToPhotoAlbum{
  [myPhotos_ savePhoto:photo withName:name addToPhotoAlbum:addToPhotoAlbum];
}


- (void)didSelectThumbAtIndex:(NSUInteger)index {
  KTPhotoScrollViewController *newController = [[KTPhotoScrollViewController alloc]
                                                initWithDataSource:self.dataSource
                                                andStartWithPhotoAtIndex:index];
  [self.navigationController pushViewController:newController animated:YES];
}

#pragma mark -
#pragma mark navBtn
- (void)leftBtnClicked:(id)sender{
  [self.navigationController popViewControllerAnimated:YES];
}
- (void)rightBtnClicked:(id)sender
{
  if([[ResponseCodeCheck getSinglton] isWWAN]){
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"小提示"
                                                    message:@"您当前处于蜂窝数据网络，上传照片将消耗大量流量，确定要上传吗?"
                                                   delegate:self cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"上传",nil];
    [alert show];
  }else{
    [self uploadPhoto];
  }
}

- (void)uploadPhoto{
  PhotoUploadBlurView *view=[[PhotoUploadBlurView alloc]initWithFrame:CGRectMake(0, 0, 260, 260)];
  RNBlurModalView *modal=[[RNBlurModalView alloc] initWithViewController:self view:view];
  [modal show];
  [view setValue:nil text:@"加载中" value:0];
  dispatch_queue_t q;
  q=dispatch_queue_create("uploadPhoto", NULL);
  dispatch_async(q, ^{
    //取出已经上传的图片，做判断，如果已经上传了，就不上传了
    NSArray *onlinePhotosArray=[[RequestUtil getSinglton]getUploadedPhoto:self.riddingId userId:[StaticInfo getSinglton].user.userId];
    NSMutableDictionary *photoDic=[[NSMutableDictionary alloc]init];
    for(RiddingPicture *photo in onlinePhotosArray){
      [photoDic setObject:photo forKey:photo.fileName];
    }
    NSArray *pictureArray=[[RiddingPictureDao getSinglton]getRiddingPicture:_riddingId userId:[StaticInfo getSinglton].user.userId];
    if(!pictureArray||[pictureArray count]==0){
      return;
    }
    NSString *prefixPath=[NSString stringWithFormat:@"ridding/%@/userId/%@",_riddingId,[StaticInfo getSinglton].user.userId];
    int index=0;
    [NSThread sleepForTimeInterval:1];
    for(RiddingPicture *picture in pictureArray){
      Photos *photos=[[Photos alloc]init];
      photos.riddingId=_riddingId;
      UIImage *image=[photos getPhoto:picture.fileName];
      if(image&&![photoDic objectForKey:picture.fileName]){
        NSString *photoUrl=[ImageUtil uploadPhotoToServer:[photos getPhotoPath:picture.fileName] prefixPath:prefixPath type:IMAGETYPE_PICTURE];
        if(photoUrl){
          picture.photoUrl=[NSString stringWithFormat:@"/%@",photoUrl];
          [[RequestUtil getSinglton]uploadRiddingPhoto:picture];
        }
      }
      index++;
      dispatch_async(dispatch_get_main_queue(), ^{
        if(modal.isVisible){
          [view setValue:image text:[NSString stringWithFormat:@"第%d张(共%d张)",index,[pictureArray count]] value:index*1.0/[pictureArray count]];
          if(index==[pictureArray count]){
            [view setValue:image text:@"已完成" value:index*1.0/[pictureArray count]];
          }
        }
      });
    }
  });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if(buttonIndex==1){
    [self uploadPhoto];
  }
}


@end
