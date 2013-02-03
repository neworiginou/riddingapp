//
//  PublicCommentCell.h
//  Ridding
//
//  Created by zys on 12-12-9.
//
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@class PublicCommentCell;

@protocol PublicCommentCellDelegate <NSObject>

@optional
- (void)callBackBtnClick:(PublicCommentCell *)cell;

- (void)avatorBtnClick:(PublicCommentCell *)cell;

@end


@interface PublicCommentCell : UITableViewCell {

  CGFloat _viewHeight;
  UIImageView *_headImageView;
  UIButton *_headImageBtn;
  UILabel *_nameLabel;
  UILabel *_descLabel;
  UILabel *_dateLabel;
  UIImageView *_headLineView;
  UIButton *_callBackBtn;
  UIImageView *_headIconView;
  UIImageView *_timeImageView;
  UIImageView *_lineImageView;
}
@property (nonatomic, retain) Comment *comment;
@property (nonatomic) int index;

@property (nonatomic, assign) id <PublicCommentCellDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
            comment:(Comment *)comment;

+ (CGFloat)cellHeightByCommentInfo:(Comment *)comment;

- (void)initContentView;
@end
