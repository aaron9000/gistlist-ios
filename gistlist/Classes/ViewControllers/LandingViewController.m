#import "LandingViewController.h"
#import "TasksViewController.h"
#import "MainMenuViewController.h"
#import "AppService.h"
#import "AppDelegate.h"
#import "GLTheme.h"
#import "Macros.h"

@interface LandingViewController ()

@end

@implementation LandingViewController

- (void) showMainMenu{
    MainMenuViewController* menuVC = [[MainMenuViewController alloc] init];
    [self pushViewController:menuVC];
}

#pragma mark - ViewController Lifecycle

- (void) animateAndTransition{
    [UIView animateWithDuration:1.0 animations:^{
        _bg.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self showMainMenu];
    }];
}

- (NSString*) backgroundImageName{
    switch ([self phoneType]) {
        case PhoneTypeIphone4:
            return @"Default@2x.png";
        case PhoneTypeIphone5:
            return @"Default-568h@2x";
        case PhoneTypeIphone6:
            return @"Default-375w-667h@2x.png";
        case PhoneTypeIphone6P:
            return @"Default-414w-736h@3x.png";
    }
}

- (void) setup{
    _bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self backgroundImageName]]];
    [_bg setFrame:self.view.frame];
    [self.view addSubview:_bg];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setup];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self animateAndTransition];
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    _bg.alpha = 1.0f;
}

@end
