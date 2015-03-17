/* This function resides in the executable /usr/sbin/BTLEServer */

@interface ANCAlert : NSObject
@property(readonly, nonatomic) unsigned char categoryID; // @synthesize categoryID=_categoryID;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (_Bool)isEqual:(id)arg1;
- (_Bool)isEqualToAlert:(id)arg1;
- (id)date;
- (id)message;
- (id)subtitle;
- (id)title;
- (id)appIdentifier;
- (_Bool)isImportant;
- (id)initWithCategoryID:(unsigned char)arg1;

@end


@interface ANCService
- (void)updateDataSource:(ANCAlert *)alert central:(id)arg2;
- (void)alertAdded:(id)arg1 isSilent:(_Bool)arg2;
- (void)alertAdded:(id)arg1 isSilent:(_Bool)arg2 isPreExisting:(_Bool)arg3;
@end
