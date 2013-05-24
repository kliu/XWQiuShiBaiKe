//
//  CommentCell.m
//  XWQSBK
//
//  Created by renxinwei on 13-5-5.
//  Copyright (c) 2013年 renxinwei. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [_authorNameLabel release];
    [_floorLabel release];
    [_commentLabel release];
    [_blockLineImageView release];
    [super dealloc];
}

#pragma mark - Public methods

- (void)configCommentCellWithComment:(Comment *)comment
{
    _authorNameLabel.text = comment.author;
    _floorLabel.text = IntergerToString(comment.floor);
    
    CGFloat commentHeight = [comment.content sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(290, 1000) lineBreakMode:NSLineBreakByCharWrapping].height;
    CGRect rect = _commentLabel.frame;
    rect.size.height = commentHeight;
    _commentLabel.frame = rect;
    
    _commentLabel.text = comment.content;
    _visibleFloor = comment.floor;
    
    rect = _blockLineImageView.frame;
    rect.origin.y = _commentLabel.frame.origin.y + commentHeight + 10;
    _blockLineImageView.frame = rect;
}

+ (CGFloat)getCellHeight:(NSString *)comment
{
    CGFloat height = 65;
    CGFloat commentHeight = [comment sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(280, 1000) lineBreakMode:NSLineBreakByCharWrapping].height;
    height = height - 30 +commentHeight;
    
    return height;
}

@end
