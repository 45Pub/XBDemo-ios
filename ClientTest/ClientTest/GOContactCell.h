//
//  GOContactCell.h
//  GoComIM
//
//  Created by Zhang Studyro on 13-5-9.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOMultiSelectCell.h"
@class IMUser;
@interface GOContactCell : GOMultiSelectCell
{
	UILabel *_departLabel;
}

@property (nonatomic, copy) void (^accessoryActionBlock)(GOContactCell *);
@property (nonatomic, retain) IMUser *imUser;
@property (nonatomic) BOOL showDepart;
@property (nonatomic, assign) BOOL canMultiSelected;
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)setThumbnail:(UIImage *)thumbnail
                name:(NSString *)nameString;

@end
