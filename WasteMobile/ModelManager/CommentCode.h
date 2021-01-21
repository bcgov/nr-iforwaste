//
//  CommentCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WastePiece;

@interface CommentCode : NSManagedObject

@property (nonatomic, retain) NSString * commentCode;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSSet *commentCodePiece;
@end

@interface CommentCode (CoreDataGeneratedAccessors)

- (void)addCommentCodePieceObject:(WastePiece *)value;
- (void)removeCommentCodePieceObject:(WastePiece *)value;
- (void)addCommentCodePiece:(NSSet *)values;
- (void)removeCommentCodePiece:(NSSet *)values;

@end
