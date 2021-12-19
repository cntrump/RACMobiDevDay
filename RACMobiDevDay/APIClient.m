#import "APIClient.h"
@import ReactiveObjC;

static NSString * const APIClientDefaultEndpoint = @"http://localhost:4567";

@interface APIClient ()

@property (nonatomic, strong) AFHTTPSessionManager *requestManager;

@end

@implementation APIClient

+ (instancetype)sharedClient
{
    static APIClient *apiClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        apiClient = [[APIClient alloc] init];
    });
    return apiClient;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.requestManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:APIClientDefaultEndpoint]];
    }
    return self;
}

- (RACSignal *)createAccountForEmail:(NSString *)email
                           firstName:(NSString *)firstName
                            lastName:(NSString *)lastName
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [self.requestManager POST:@"/accounts"
                                                       parameters:@{ @"first_name": firstName, @"last_name": lastName, @"email": email }
                                                          headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                            [subscriber sendNext:responseObject];
                                            [subscriber sendCompleted];
                                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                            [subscriber sendError:[NSError errorWithDomain:@"com.example"
                                                             code:error.code
                                                         userInfo:@{NSLocalizedFailureReasonErrorKey : error.localizedFailureReason ?: @"Failed to create account" }]];
                                        }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

@end
