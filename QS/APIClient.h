#import <Foundation/Foundation.h>

@interface APIClient : NSObject

-(void)submitDiscreteEvent:(NSDate *)timestamp ofType:(NSInteger)type withURI:(NSString *)eventURI andMetadata:(NSString *)metadata completion:(void (^)(NSData *data, NSHTTPURLResponse *response, NSError *error))completion;

@end
