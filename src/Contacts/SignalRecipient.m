//  Created by Frederic Jacobs on 17/11/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.

#import "SignalRecipient.h"
#import "TSStorageHeaders.h"
#import "TSStorageManager+IdentityKeyStore.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SignalRecipient

+ (NSString *)collection {
    return @"SignalRecipient";
}

- (instancetype)initWithTextSecureIdentifier:(NSString *)textSecureIdentifier
                                       relay:(nullable NSString *)relay
                               supportsVoice:(BOOL)voiceCapable
{
    self = [super initWithUniqueId:textSecureIdentifier];
    if (!self) {
        return self;
    }

    _devices = [NSMutableOrderedSet orderedSetWithObject:[NSNumber numberWithInt:1]];
    _relay = [relay isEqualToString:@""] ? nil : relay;
    _supportsVoice = voiceCapable;

    return self;
}

+ (nullable instancetype)recipientWithTextSecureIdentifier:(NSString *)textSecureIdentifier
                                           withTransaction:(YapDatabaseReadTransaction *)transaction
{
    return [self fetchObjectWithUniqueID:textSecureIdentifier transaction:transaction];
}

+ (nullable instancetype)recipientWithTextSecureIdentifier:(NSString *)textSecureIdentifier
{
    __block SignalRecipient *recipient;
    [self.dbConnection readWithBlock:^(YapDatabaseReadTransaction *_Nonnull transaction) {
        recipient = [self recipientWithTextSecureIdentifier:textSecureIdentifier withTransaction:transaction];
    }];
    return recipient;
}

+ (instancetype)selfRecipient
{
    SignalRecipient *myself = [self recipientWithTextSecureIdentifier:[TSStorageManager localNumber]];
    if (!myself) {
        myself = [[self alloc] initWithTextSecureIdentifier:[TSStorageManager localNumber] relay:nil supportsVoice:YES];
    }
    return myself;
}

- (NSMutableOrderedSet *)devices {
    return [_devices copy];
}

- (void)addDevices:(NSSet *)set {
    [self checkDevices];
    [_devices unionSet:set];
}

- (void)removeDevices:(NSSet *)set {
    [self checkDevices];
    [_devices minusSet:set];
}

- (void)checkDevices {
    if (_devices == nil || ![_devices isKindOfClass:[NSMutableOrderedSet class]]) {
        _devices = [NSMutableOrderedSet orderedSetWithObject:[NSNumber numberWithInt:1]];
    }
}

@end

NS_ASSUME_NONNULL_END
