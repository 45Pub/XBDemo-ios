//
//  ContactLeftCell.m
//  IMLite
//
//  Created by Ethan on 13-8-26.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "ContactLeftCell.h"

@implementation ContactLeftCell

- (void)dealloc {

    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"list_bg_92"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeTile]] autorelease];
        self.editingAccessoryView = nil;
        self.showAvatarView = NO;
    }
    return self;
}

- (void)setIsSelected:(BOOL)isSelected {
    
    if (isSelected) {
        self.backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"multilevel_selected_230"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 50) resizingMode:UIImageResizingModeTile]] autorelease];
//        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 115, self.frame.size.height);

    } else {
        self.backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"list_bg_92"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeTile]] autorelease];
    }
    
}


@end
