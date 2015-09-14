#import "RACSignal+Extensions.h"
#import <SVProgressHUD.h>
#import "DialogHelper.h"

@implementation RACSignal (Extensions)

- (RACSignal *)withLoadingSpinner {
    __block BOOL firedOnce = NO;
    return [[[self
              initially:^{
                  [SVProgressHUD showWithStatus:@"Loading"];
              }]
             doNext:^(id _) {
                 if (!firedOnce){
                      firedOnce = YES;
                     [SVProgressHUD showSuccessWithStatus:nil];
                 }
             }]
            doError:^(id _) {
                [SVProgressHUD dismiss];
            }];
    
}

- (RACSignal *)withErrorAlert {
    return [self doError:^(NSError *error) {
        [[DialogHelper showOKErrorAlert:error] subscribeNext:^(id x) {            
        }];
    }];
}

@end