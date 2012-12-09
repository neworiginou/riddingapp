//
//  MapCreateVCTL.h
//  Ridding
//
//  Created by zys on 12-11-15.
//
//

#import "BasicViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import "MyAnnotation.h"
#import "CreateAnnotationView.h"
#import "Map.h"
@class MapCreateVCTL;
@protocol MapCreateVCTLDelegate <NSObject>

- (void)finishCreate:(MapCreateVCTL*)controller info:(Map*)info;

@end


@interface MapCreateVCTL : BasicViewController<MKAnnotation,MKMapViewDelegate,UISearchBarDelegate,UITextFieldDelegate,UIScrollViewDelegate,CreateAnnotationViewDelegate>{
  BOOL _isSearching;
  NSMutableArray *_locationViews;
  MyAnnotation *_nowAnnotation;
  NSMutableArray *_routes;
  UIColor *line_color;
  BOOL _succCreate;
  Map *_map;
  UIImage *_newCoverImage;
}
@property(nonatomic,retain) IBOutlet UIImageView *route_view;
@property(nonatomic,retain) IBOutlet MKMapView *mapView;
@property(nonatomic,retain) IBOutlet UIView *coverImageView;
@property(nonatomic,retain) IBOutlet UITextField *searchField;
@property(nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic,retain) IBOutlet UIView *tapView;
@property(nonatomic,retain) IBOutlet UIButton *beginBtn;
@property(nonatomic,retain) IBOutlet UIButton *midBtn;
@property(nonatomic,retain) IBOutlet UIButton *endBtn;
@property(nonatomic,retain) IBOutlet UIButton *createBtn;
@property(nonatomic,retain) IBOutlet UIButton *clearBtn;
@property(nonatomic,retain) IBOutlet UILabel *tipsLabel;
@property(nonatomic,retain) IBOutlet UIButton *myLocationBtn;

@property(nonatomic,assign) id<MapCreateVCTLDelegate> delegate;

@end
