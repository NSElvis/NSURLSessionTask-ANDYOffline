@import XCTest;

#import "OHHTTPStubs.h"
#import "OHHTTPStubsResponse+JSON.h"
#import "AFHTTPSessionManager.h"
#import "NSURLSessionTask+ANDYOffline.h"

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithJSONObject:@{@"name" : @"Hello World"}
                                                statusCode:0
                                                   headers:@{@"Content-Type":@"text/json"}];
    }];
}

- (void)tearDown
{
    [OHHTTPStubs removeAllStubs];

    [super tearDown];
}

- (void)testPOST
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Networking expectations"];

    NSURL *url = [NSURL URLWithString:@"http://www.sample.com"];
    NSString *path = @"/note.json";

    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    NSDictionary *params = @{@"text" : @"Note content", @"date" : @"14-02-89T+01:00Z"};

    [manager POST:path parameters:params success:nil failure:^(NSURLSessionDataTask *task, NSError *error) {

        [task saveWithParams:params];

        NSURLSessionTask *offlineTask = [[NSURLSessionTask offlineTasks] lastObject];
        XCTAssertEqualObjects(offlineTask, task);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:60.0f handler:nil];
}

@end
