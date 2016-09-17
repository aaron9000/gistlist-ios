#import <SVProgressHUD.h>
#import <CocoaLumberjack.h>
#import "TasksViewController.h"
#import "SettingsViewController.h"
#import "Helpers.h"
#import "AppState.h"
#import "Config.h"
#import "Extensions.h"
#import "AppService.h"
#import "TaskCell.h"
#import "GLTheme.h"
#import "Macros.h"

@interface TasksViewController ()

@end

@implementation TasksViewController

#pragma mark - Constants and Keys

#define kCellIdentifier @"CollectionViewCell"

typedef enum InterfaceState {
    InterfaceStateViewTasks = 0,
    InterfaceStateModifyTasks = 1,
    InterfaceStateModifyTasksEditing = 2,
    InterfaceStateModifyTasksEditingNoText = 3,
    InterfaceStateAddTask = 4,
    InterfaceStateAddTaskNoText = 5
} InterfaceState;

#pragma mark - Sizing & View Helpers

#define HEADER_BUTTON_PADDING 17.0f
#define HEADER_ANIMATION_DURATION 0.25f
#define ENTRY_PADDING_BOTTOM 14.0f
#define ENTRY_CONTAINER_HEIGHT (ENTRY_PADDING_BOTTOM + TEXTFIELD_HEIGHT)
#define BUTTON_CONTAINER_HEIGHT (STATUS_BAR_SIZE + BUTTON_SIZE + (HEADER_BUTTON_PADDING * 2))
#define CONTAINER_HEIGHT (ENTRY_CONTAINER_HEIGHT + BUTTON_CONTAINER_HEIGHT)

- (float) entryExpansion{
    switch ([self phoneType]) {
        case PhoneTypeIphone4:
            return 36.0f;
        case PhoneTypeIphone5:
            return 64.0f;
        case PhoneTypeIphone6:
            return 112.0f;
        case PhoneTypeIphone6P:
            return 144.0f;
    }
}

- (float) headerOffset{
    float headerHeight = BUTTON_CONTAINER_HEIGHT + TEXTFIELD_HEIGHT + [self entryExpansion];
    return SCREEN_HEIGHT - (headerHeight + KEYBOARD_HEIGHT);
}

- (CGRect) defaultButtonContainerRect{
    return CGRectMake(0, 0, SCREEN_WIDTH, BUTTON_CONTAINER_HEIGHT);
}

- (CGRect) defaultEntryRect{
    return CGRectMake(0, BUTTON_CONTAINER_HEIGHT, SCREEN_WIDTH, ENTRY_CONTAINER_HEIGHT);
}

- (CGRect) expandedEntryRect{
    float height = ENTRY_CONTAINER_HEIGHT + ([self entryExpansion] - ENTRY_PADDING_BOTTOM);
    return CGRectMake(0, BUTTON_CONTAINER_HEIGHT, SCREEN_WIDTH, height);
}

- (CGRect) defaultContainerRect{
    return CGRectMake(0, 0, SCREEN_WIDTH, CONTAINER_HEIGHT);
}

- (CGRect) expandedContainerRect{
    return CGRectMake(0, [self headerOffset], SCREEN_WIDTH, BUTTON_CONTAINER_HEIGHT + TEXTFIELD_HEIGHT);
}

- (CGRect) lineRectForRect:(CGRect) rect{
    return CGRectMake(0, rect.origin.y + (rect.size.height - LINE_HEIGHT), SCREEN_WIDTH, LINE_HEIGHT);
}

- (UIView*) lineForBottomOfView:(UIView*) view{
    CGRect lineRect = [self lineRectForRect:view.frame];
    UIView* line = [[UIView alloc] initWithFrame:lineRect];
    line.backgroundColor = [GLTheme tileColorDivider];
    return line;
}

#pragma mark - UICollectionView

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return AppState.taskCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Task* task = [AppState taskAtIndex:indexPath.row];
    TaskCell* taskCell = (TaskCell*)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (!taskCell){
        taskCell = [[TaskCell alloc] init];
    }
    [taskCell refreshWithData:task withIndex:(int)indexPath.row isEditMode:_isEditMode isLastItem:indexPath.row == AppState.taskCount - 1];
    [taskCell.toggleButton addTarget:self action:@selector(taskClick:) forControlEvents:UIControlEventTouchUpInside];
    taskCell.taskTextField.delegate = self;
    return taskCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.view.frame.size.width, TASK_CELL_HEIGHT);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark - UITextField delegate

- (void) textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == _taskInput){
        [self expandHeader];
        if (_isEditMode){
            [self changeEditMode:NO];
        }else{
            [self updateButtons];
        }
    }else{
        _cellTextfieldBeingEdited = textField;
        if (textField.tag > 3) {
            [UIView animateWithDuration:1.0f animations:^{
                _collectionView.contentInset =  UIEdgeInsetsMake(0, 0, 160.0f + [self tasksBottomPadding], 0);
            }];
        }
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField{
    if (textField == _taskInput){
        [self shrinkHeader];
        [self updateButtons];
        textField.text = @"";
    }else{
        _cellTextfieldBeingEdited = nil;
        [NSObject performBlock:^{
            if (_cellTextfieldBeingEdited == nil){
                [UIView animateWithDuration:0.5f animations:^{
                    _collectionView.contentInset =  UIEdgeInsetsMake(0, 0, [self tasksBottomPadding], 0);
                }];
            }
        } afterDelay:0.025f];
        if (textField.text.length > 0){
            [self updateTask:textField.tag withText:textField.text];
        }else{
            [self deleteTask:textField.tag];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _taskInput){
        [self attemptAddTaskAndUpdate];
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Task Management

- (void) taskClick:(UIButton*) sender{
    switch ([self interfaceState]) {
        case InterfaceStateAddTask:
        case InterfaceStateAddTaskNoText:
            // Do nothing
            break;
        case InterfaceStateModifyTasks:
        case InterfaceStateModifyTasksEditing:
        case InterfaceStateModifyTasksEditingNoText:
            [self deleteTask:sender.superview.tag];
            break;
        case InterfaceStateViewTasks:
            [self toggleTask:sender.superview.tag];
            break;
    }
}

- (void) updateTask:(NSInteger) index withText:(NSString*) newText{
    [[AppService.sharedService updateTask:index withText:newText] subscribeNext:^(id x) {
    }];
    [self updateInterface];
    [AnalyticsHelper taskModify];
}

- (void) deleteTask:(NSInteger) index{
    Task* task = [AppState taskAtIndex:index];
    if (task.completed){
        [DialogHelper showClearsDailyToast];
    }
    [[AppService.sharedService deleteTask:index] subscribeNext:^(id x) {
    }];
    [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    [self updateInterface];
    [AnalyticsHelper taskDelete];
}

- (void) toggleTask:(NSInteger) index{
    [[AppService.sharedService toggleTask:index] subscribeNext:^(id x) {
    }];
    [self refreshTaskListCells];
    [AnalyticsHelper taskToggle];
}

- (void) addNewTaskWithText:(NSString*) text{
    [[AppService.sharedService addNewTaskWithText:text] subscribeNext:^(id x) {
    }];
    [_collectionView setContentOffset:CGPointZero animated:NO];
    [_collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
    [self updateInterface];
    [AnalyticsHelper taskCreate:text];
}

#pragma mark - Interface Helpers

- (void) syncWithAppState{
    [_collectionView reloadData];
    [self updateInterface];
}

- (void) updateInterface{
    [self updateButtons];
    [self refreshTaskListCells];
}

- (void) setButtonsEnabled:(BOOL) enabled{
    NSArray* buttons = @[_leftButton, _rightButton, _actionButton, _taskInput];
    for (UIView* btn in buttons) {
        btn.userInteractionEnabled = enabled;
    }
}

- (void) changeEditMode:(BOOL) isEditMode{
    _isEditMode = isEditMode;
    [self updateInterface];
}

- (void) dismissKeyboard{
    [_taskInput resignFirstResponder];
}

- (void) dismissListKeyboard{
    for (int i = 0; i < AppState.taskCount; i++) {
        TaskCell* cell = (TaskCell*)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell dismissKeyboard];
    }
}

- (InterfaceState) interfaceState{
    if (_isEditMode){
        if (_cellTextfieldBeingEdited != nil){
            return _cellTextfieldBeingEdited.text.length > 0 ? InterfaceStateModifyTasksEditing : InterfaceStateModifyTasksEditingNoText;
        }else{
            return InterfaceStateModifyTasks;
        }
    }else{
        if (_taskInput.isFirstResponder){
            return _taskInput.text.length > 0 ? InterfaceStateAddTask : InterfaceStateAddTaskNoText;
        }else{
            return InterfaceStateViewTasks;
        }
    }
}

#pragma mark - Header

- (void) setupContainerView{
    
    // Container
    _containerView = [[UIView alloc] initWithFrame:[self defaultContainerRect]];
    _containerView.layer.masksToBounds = NO;
    [self.view addSubview:_containerView];
    
    // Blank Area (abover header) for when it scoots down
    float blankHeight = 400;
    _blankView = [[UIView alloc] initWithFrame:CGRectMake(0, -blankHeight, SCREEN_WIDTH, blankHeight)];
    _blankView.backgroundColor = [GLTheme backgroundColorHeader];
    _blankView.hidden = YES;
    [_containerView addSubview:_blankView];
}

- (void) setupButtonContainerView{
    
    // Header
    _buttonContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, BUTTON_CONTAINER_HEIGHT)];
    _buttonContainerView.backgroundColor = [GLTheme backgroundColorHeader];
    [_containerView addSubview:_buttonContainerView];
    
    // Header Icon
    UIImage* logoIcon = [GLTheme imageOfTaskGlLogo];
    CGRect logoRect = CGRectMake((SCREEN_WIDTH - logoIcon.size.width) * 0.5f, BUTTON_CONTAINER_HEIGHT - logoIcon.size.height - 14.0f, logoIcon.size.width, logoIcon.size.height);
    _headerIcon = [[UIImageView alloc] initWithFrame:logoRect];
    _headerIcon.image = logoIcon;
    [_buttonContainerView addSubview:_headerIcon];
    
    // Button calcs
    float buttonY = BUTTON_CONTAINER_HEIGHT - (BUTTON_SIZE + HEADER_BUTTON_PADDING);
    
    // Right Button
    CGRect rightRect = CGRectMake(SCREEN_WIDTH - (HEADER_BUTTON_PADDING + BUTTON_SIZE), buttonY, BUTTON_SIZE, BUTTON_SIZE);
    _rightButton = [[VBFPopFlatButton alloc] initWithFrame:rightRect buttonType:buttonMenuType buttonStyle:buttonRoundedStyle animateToInitialState:YES];
    _rightButton.lineThickness = BUTTON_LINE_THICKNESS;
    _rightButton.roundBackgroundColor = [GLTheme buttonColorGray];
    _rightButton.tintColor = UIColor.whiteColor;
    [[_rightButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        switch ([self interfaceState]) {
            case InterfaceStateAddTaskNoText:
                break;
            case InterfaceStateAddTask:
                [self attemptAddTaskAndUpdate];
                break;
            case InterfaceStateModifyTasks:
            case InterfaceStateModifyTasksEditing:
            case InterfaceStateModifyTasksEditingNoText:
                [self changeEditMode:NO];
                break;
            case InterfaceStateViewTasks:
                [self changeEditMode:YES];
                break;
        }
    }];
    [_rightButton setHitTestEdgeInsets:BUTTON_HITTEST_INSET];
    [_buttonContainerView addSubview:_rightButton];
    
    // Left Button
    CGRect leftRect = CGRectMake(HEADER_BUTTON_PADDING, buttonY, BUTTON_SIZE, BUTTON_SIZE);
    _leftButton = [[VBFPopFlatButton alloc] initWithFrame:leftRect buttonType:buttonMenuType buttonStyle:buttonRoundedStyle animateToInitialState:YES];
    _leftButton.lineThickness = BUTTON_LINE_THICKNESS;
    _leftButton.roundBackgroundColor = [GLTheme buttonColorGray];
    _leftButton.tintColor = UIColor.whiteColor;
    [_leftButton setHitTestEdgeInsets:BUTTON_HITTEST_INSET];
    [[_leftButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        switch ([self interfaceState]) {
            case InterfaceStateAddTask:
            case InterfaceStateAddTaskNoText:
                [self dismissKeyboard];
                break;
            case InterfaceStateViewTasks:
            case InterfaceStateModifyTasks:
            case InterfaceStateModifyTasksEditing:
            case InterfaceStateModifyTasksEditingNoText:
                [self pushViewController:[[SettingsViewController alloc] init]];
                break;
        }
    }];
    [_buttonContainerView addSubview:_leftButton];
}

- (void) setupEntryView{

    // Search View
    _entryContainerView = [[UIView alloc] initWithFrame:[self defaultEntryRect]];
    _entryContainerView.backgroundColor = [GLTheme backgroundColorHeader];
    [_containerView addSubview:_entryContainerView];
    
    // Input text field
    _taskInput = [self.view addTextFieldWithWidth:SCREEN_WIDTH - (2 * TEXTFIELD_HORIZONTAL_PADDING) withY:0 withShadowText:@"Add New Task" toView:_entryContainerView];
    _taskInput.delegate = self;
    _taskInput.returnKeyType = UIReturnKeyDone;
    [[_taskInput rac_signalForControlEvents:UIControlEventEditingChanged] subscribeNext:^(id x) {
        [self updateButtons];
    }];
    
    // Plus sign
    UIImage* plusImage = [GLTheme imageOfTaskIconAdd];
    _plusIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, plusImage.size.width, plusImage.size.height)];
    _plusIcon.image = plusImage;
    _plusIcon.backgroundColor = [UIColor clearColor];
    [_entryContainerView addSubview:_plusIcon];
    [_plusIcon wta_topAlignInSuperviewOffset:12.0f];
    [_plusIcon wta_leftAlignInSuperviewOffset:18.0f + _plusIcon.frame.origin.y];
    
    /// Line at bottom
    _headerLine = [self lineForBottomOfView:_entryContainerView];
    [_containerView addSubview:_headerLine];
    [_containerView bringSubviewToFront:_headerLine];
}

- (void) setupHeader{
    [self setupContainerView];
    [self setupButtonContainerView];
    [self setupEntryView];
}

- (void) expandedHeader{
    _entryContainerView.frame = [self expandedEntryRect];
    _containerView.frame = [self expandedContainerRect];
    _headerLine.frame = [self lineRectForRect:[self expandedEntryRect]];
    _plusIcon.alpha = 0.0f;
}

- (void) shrunkenHeader{
    _entryContainerView.frame = [self defaultEntryRect];
    _containerView.frame = [self defaultContainerRect];
    _headerLine.frame = [self lineRectForRect:[self defaultEntryRect]];
    _plusIcon.alpha = 1.0f;
}

- (void) expandHeader{
    _blankView.hidden = NO;
    [UIView animateWithDuration:HEADER_ANIMATION_DURATION
                     animations:^{
                         [self expandedHeader];
                     }
                     completion:^(BOOL finished) {
                         if (finished){
                             [self expandedHeader];
                         }
                     }];
}

- (void) shrinkHeader{
    [UIView animateWithDuration:HEADER_ANIMATION_DURATION
                     animations:^{
                         [self shrunkenHeader];
                     }
                     completion:^(BOOL finished) {
                         if (finished){
                             [self shrunkenHeader];
                         }
                     }];
}

#pragma mark - Button Helpers

- (FlatButtonType) rightButtonType{
    switch ([self interfaceState]) {
        case InterfaceStateAddTask:
        case InterfaceStateAddTaskNoText:
            return buttonAddType;
        case InterfaceStateModifyTasks:
        case InterfaceStateModifyTasksEditing:
        case InterfaceStateModifyTasksEditingNoText:
            return buttonCloseType;
        case InterfaceStateViewTasks:
            return buttonMinusType;
    }
}

- (FlatButtonType) leftButtonType{
    switch ([self interfaceState]) {
        case InterfaceStateAddTaskNoText:
        case InterfaceStateAddTask:
            return buttonCloseType;
        default:
            return buttonMenuType;
    }
}

- (UIColor*) leftButtonColor{
    switch ([self interfaceState]) {
        case InterfaceStateAddTask:
        case InterfaceStateAddTaskNoText:
        case InterfaceStateViewTasks:
        case InterfaceStateModifyTasks:
        case InterfaceStateModifyTasksEditing:
        case InterfaceStateModifyTasksEditingNoText:
            return [GLTheme buttonColorGray];
    }
}

- (UIColor*) rightButtonColor{
    switch ([self interfaceState]) {
        case InterfaceStateAddTask:
        case InterfaceStateAddTaskNoText:
            return [GLTheme buttonColorBlue];
        case InterfaceStateViewTasks:
            return [GLTheme buttonColorRed];
        case InterfaceStateModifyTasks:
        case InterfaceStateModifyTasksEditing:
        case InterfaceStateModifyTasksEditingNoText:
            return [GLTheme buttonColorGray];
    }
}

- (void) updateButtons{
    _actionButton.roundBackgroundColor = _isEditMode ? [GLTheme buttonColorGray] : [GLTheme buttonColorBlue];
    _actionButton.currentButtonType = _isEditMode ? buttonCloseType : buttonAddType;
    _actionButton.alpha = [self interfaceState] == InterfaceStateAddTaskNoText ? 0.5f : 1.0f;
    
    _rightButton.currentButtonType = [self rightButtonType];
    _rightButton.roundBackgroundColor = [self rightButtonColor];
    _rightButton.alpha = [self interfaceState] == InterfaceStateAddTaskNoText ? 0.5f : 1.0f;
    
    _leftButton.currentButtonType = [self leftButtonType];
    _leftButton.roundBackgroundColor = [self leftButtonColor];
    _leftButton.alpha = 1.0f;
}

#pragma mark - Gestures

- (void) setupGestures{
    _tap = [[UITapGestureRecognizer alloc]
            initWithTarget:self
            action:@selector(dismissListKeyboard)];

    [_collectionView addGestureRecognizer:_tap];
    [self.view addGestureRecognizer:_tap];
}

#pragma mark - Action Button

#define ACTION_BUTTON_LINE_THICKNESS 5.0f
#define ACTION_BUTTON_SIZE 40.0f

- (void) setupActionButton{
    CGRect buttonRect = CGRectMake(0, 0, ACTION_BUTTON_SIZE, ACTION_BUTTON_SIZE);
    _actionButton = [[VBFPopFlatButton alloc] initWithFrame:buttonRect buttonType:buttonMenuType buttonStyle:buttonRoundedStyle animateToInitialState:YES];
    _actionButton.lineThickness = ACTION_BUTTON_LINE_THICKNESS;
    [_actionButton setHitTestEdgeInsets:BUTTON_HITTEST_INSET];
    _actionButton.roundBackgroundColor = [GLTheme buttonColorRed];
    _actionButton.tintColor = UIColor.whiteColor;
    [[_actionButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (_isEditMode){
            [self changeEditMode:NO];
        }else{
            [_taskInput becomeFirstResponder];
        }
    }];
    [self.view addSubview:_actionButton];
    [_actionButton wta_centerAlignHorizontallyInSuperview];
    [_actionButton wta_bottomAlignInSuperviewOffset:32.0f];
}

#pragma mark - Task List

- (CGRect) collectionViewRectWithOffsetY:(float) offsetY{
    float height = SCREEN_HEIGHT - (CONTAINER_HEIGHT + offsetY);
    return CGRectMake(0, CONTAINER_HEIGHT, SCREEN_WIDTH, height);
}

- (float) tasksBottomPadding{
    return ACTION_BUTTON_SIZE * 2.0f;
}

- (void) setupTaskList{
    CGRect collectionViewFrame = [self collectionViewRectWithOffsetY:0];
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(SCREEN_WIDTH, TASK_CELL_HEIGHT);
    layout.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    _collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:layout];
    [_collectionView registerClass:[TaskCell class] forCellWithReuseIdentifier:kCellIdentifier];
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.backgroundColor = [GLTheme backgroundColorDefault];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, [self tasksBottomPadding], 0.0f);
    [self.view addSubview:_collectionView];
}

- (void) refreshTaskListCells{
    NSInteger len = AppState.taskCount;
    for (int i = 0; i < len; i++) {
        Task* task = [AppState taskAtIndex:i];
        TaskCell* cell = (TaskCell*)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell refreshWithData:task withIndex:i isEditMode:_isEditMode isLastItem:(i == len - 1)];
    }
}

- (void) attemptAddTaskAndUpdate{
    if (_taskInput.text.length == 0){
        [self dismissKeyboard];
        return;
    }
    [self addNewTaskWithText:_taskInput.text];
    _taskInput.text = @"";
    [self dismissKeyboard];
}

#pragma mark - Tutorial

- (void) attemptStartTutorial{
    [[AppService.sharedService startTutorialWithDelay] subscribeNext:^(NSNumber* shouldPlay) {
        if (!shouldPlay.boolValue){
            return;
        }
        [self startTutorialSequence];
    }];
}

- (void) startTutorialSequence{
    [AnalyticsHelper showTutorial];
    [self setButtonsEnabled:NO];
    [[[[[DialogHelper showWelcomeAlert] flattenMap:^RACStream *(id value) {
        [self addNewTaskWithText:@"This is your task list."];
        return [[RACSignal return:nil] delay:0.5f];
    }] flattenMap:^RACStream *(id value) {
        [self addNewTaskWithText:@"Completed tasks will clear daily."];
        return [[RACSignal return:nil] delay:0.5f];
    }] flattenMap:^RACStream *(id value) {
        [self addNewTaskWithText:@"Enjoy!"];
        return [RACSignal return:@(YES)];
    }] subscribeNext:^(id x) {
        [self setButtonsEnabled:YES];
    }];
}

#pragma mark - ViewController lifecycle

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _syncOnViewWillAppear = YES;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_syncOnViewWillAppear){
        _syncOnViewWillAppear = NO;
        [self syncWithAppState];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncWithAppState) name:kGLEventSyncComplete object:nil];
}

- (void) setup{
    [self setupTaskList];
    [self setupHeader];
    [self setupActionButton];
    [self setupGestures];
    [self syncWithAppState];
    [self attemptStartTutorial];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

@end
