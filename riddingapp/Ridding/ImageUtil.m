//
//  ImageUtil.m
//  Ridding
//
//  Created by zys on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "ImageUtil.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "rscli.h"
@implementation ImageUtil

+ (NSString*)uploadPhotoToServer:(NSString*)localPath prefixPath:(NSString*)prefixPath type:(IMAGETYPE)type{
  NSFileManager *manager = [NSFileManager defaultManager];
  
  //obtaining saving path
  QBOX_ACCESS_KEY = "8djjv3hXfS8eDOg9gR5UxxIpkmhfGg069FBv5c1e";
  QBOX_SECRET_KEY = "7oebuztbTfddVtI8dtY_QeftnWB09uZFPIQ8JuUm";
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat: @"yyyyMMddHHmmsszzz"];
  
  NSString *timeDesc = [formatter stringFromDate:[NSDate date]];
  NSString *fileName=[NSString stringWithFormat:@"%@/%d_%@.jpg",prefixPath,type,timeDesc];
  QBox_AuthPolicy auth;
  QBox_Zero(auth);
  char* uptoken = QBox_MakeUpToken(&auth);
  if (uptoken == NULL) {
    return nil;
  }
  
  QBox_UP_Progress* prog = QBox_UP_NewProgress([[manager attributesOfItemAtPath:localPath error:nil] fileSize]);
  QBox_UP_PutRet putRet;
  
  QBox_Error err = [RSClient resumablePutFile:[NSString stringWithUTF8String:uptoken]
                                    tableName:@"photo"
                                          key:fileName
                                     mimeType:nil
                                         file:localPath progress:prog
                                  blockNotify:nil
                                  chunkNotify:nil
                                 notifyParams:(__bridge void *)(self)
                                       putRet:&putRet
                                   customMeta:nil
                               callbackParams:nil];
  if(err.code==200){
    return [NSString stringWithFormat:@"/%@",fileName];
  }
  QBox_UP_Progress_Release(prog);
  return nil;
}

+ (NSString*)uploadPhotoToServerByImage:(UIImage*)image prefixPath:(NSString*)prefixPath type:(IMAGETYPE)type{
  NSString *localPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.jpg"];
  [UIImageJPEGRepresentation(image, 1.0) writeToFile:localPath atomically:YES];
  return [self uploadPhotoToServer:localPath prefixPath:prefixPath type:type];
}


@end
