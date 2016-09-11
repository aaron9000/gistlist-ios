@import Nimble;
#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import "KeychainStorage.h"
#import <OCMock/OCMock.h>

QuickSpecBegin(KeychainStorageTests)

it(@"resets and has 0 stars", ^{
    [KeychainStorage setStars:5];
    expect(@(KeychainStorage.stars)).to(equal(@(5)));
});


QuickSpecEnd