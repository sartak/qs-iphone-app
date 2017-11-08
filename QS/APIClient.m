#import "APIClient.h"

@interface APIClient ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation APIClient

-(instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        self.session = session;
    }
    return self;
}

-(NSString *)host {
    return @"https://qs.sartak.org";
}

-(NSString *)username {
    return @"";
}

-(NSString *)password {
    return @"";
}

-(NSString *)queryParametersforDiscreteEvent:(NSDate *)timestamp ofType:(NSInteger)type withURI:(NSString *)uri andMetadata:(NSString *)metadata {
    if (!timestamp) {
        timestamp = [NSDate date];
    }
    if (!uri) {
        uri = [NSNull null];
    }
    if (!metadata) {
        metadata = [NSNull null];
    }
    NSDictionary *params = @{
                             @"timestamp": [NSString stringWithFormat:@"%ld", [@([timestamp timeIntervalSince1970]) integerValue]],
                             @"type": [NSString stringWithFormat:@"%ld", type],
                             @"uri": uri,
                             @"metadata": metadata,
                             @"isDiscrete": @"1",
                             };
    
    NSMutableArray *parts = [NSMutableArray array];
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        if ([value isKindOfClass:[NSNull class]]) {
            return;
        }
        
        [parts addObject:[NSString stringWithFormat:@"%@=%@",
                          [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]],
                          [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]]]];
    }];
    
    return [parts componentsJoinedByString:@"&"];
}

-(NSMutableURLRequest *)requestForDiscreteEvent:(NSDate *)timestamp ofType:(NSInteger)type withURI:(NSString *)eventURI andMetadata:(NSString *)metadata {
    NSString *query = [self queryParametersforDiscreteEvent:timestamp ofType:type withURI:eventURI andMetadata:metadata];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/add?%@", [self host], query]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setAllowsCellularAccess:YES];
    [request addValue:[self username] forHTTPHeaderField:@"X-QS-Username"];
    [request addValue:[self password] forHTTPHeaderField:@"X-QS-Password"];
    return request;
}

-(void)submitDiscreteEvent:(NSDate *)timestamp ofType:(NSInteger)type withURI:(NSString *)eventURI andMetadata:(NSString *)metadata completion:(void (^)(NSData *data, NSHTTPURLResponse *response, NSError *error))completion {
    NSMutableURLRequest *request = [self requestForDiscreteEvent:timestamp ofType:type withURI:eventURI andMetadata:metadata];
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(data, (NSHTTPURLResponse *)response, error);
            });
        }
    }];
    [task resume];
}

@end
