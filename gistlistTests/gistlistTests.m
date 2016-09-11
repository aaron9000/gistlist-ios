// Objective-C

#import <Quick/Quick.h>
#import <Nimble/Nimble.h>

QuickSpecBegin(DolphinSpec)

it(@"is friendly", ^{
    expect(@([[Dolphin new] isFriendly])).to(beTruthy());
});

it(@"is smart", ^{
    expect(@([[Dolphin new] isSmart])).to(beTruthy());
});

QuickSpecEnd