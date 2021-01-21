//
//  SiteCode+CoreDataProperties.h
//  WasteMobile
//
//  Created by Jack Wong on 2016-11-04.
//  Copyright © 2016 Salus Systems. All rights reserved.
//

#import "SiteCode+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface SiteCode (CoreDataProperties)

+ (NSFetchRequest<SiteCode *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *desc;
@property (nullable, nonatomic, copy) NSString *siteCode;
@property (nullable, nonatomic, copy) NSDate *effectiveDate;
@property (nullable, nonatomic, copy) NSDate *expiryDate;
@property (nullable, nonatomic, copy) NSDate *updateTimestamp;
@property (nullable, nonatomic, retain) NSSet<WasteBlock *> *siteCodeBlock;

@end

@interface SiteCode (CoreDataGeneratedAccessors)

- (void)addSiteCodeBlockObject:(WasteBlock *)value;
- (void)removeSiteCodeBlockObject:(WasteBlock *)value;
- (void)addSiteCodeBlock:(NSSet<WasteBlock *> *)values;
- (void)removeSiteCodeBlock:(NSSet<WasteBlock *> *)values;

@end

NS_ASSUME_NONNULL_END
