@interface SBHomeScreenBackdropView : UIView
@end



@interface ShakeBlurView : UIVisualEffectView
+(instancetype)sharedInstance;
-(void)unblur;
-(void)blur;
@end

@implementation ShakeBlurView
+(instancetype)sharedInstance {
	static ShakeBlurView *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (@available(iOS 13, *)) {
			UIBlurEffect *blur;
			blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
			sharedInstance = [[ShakeBlurView alloc] initWithEffect:blur];
		}
	});
	return sharedInstance;
}
-(void)unblur {
	[[%c(ShakeBlurView) sharedInstance] setAlpha:0];
}
-(void)blur {
	[[%c(ShakeBlurView) sharedInstance] setAlpha:1];
}
@end


// Function to toggle the blur effect alpha
BOOL blurred = NO;
void toggleBlur() {
	if (!blurred){
		[[%c(ShakeBlurView) sharedInstance] blur];
		blurred = YES;
	} else if (blurred) {
		[[%c(ShakeBlurView) sharedInstance] unblur];
		blurred = NO;
	}
}

// Temporary blur test, this will move to somewhere else
int i = 0;
%hook SBHomeScreenBackdropView
-(void)layoutSubviews {
	%orig;
	if (i == 0) {
		[[%c(ShakeBlurView) sharedInstance] setFrame:self.bounds];
		[[%c(ShakeBlurView) sharedInstance] setAlpha:0.0];
		[self addSubview:[%c(ShakeBlurView) sharedInstance]];
	i++;
	}
}
%end

// @interface BlurPresenter : NSObject
// @property (strong, nonatomic) UIWindow *blurWindow;
// -(void)presentWindow;
// @end

// @implementation BlurPresenter
// -(void)presentWindow {
// 	self.blurWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0,0,200,200)];
// 	self.blurWindow.windowLevel = UIWindowLevelAlert + 1.0;
// 	[self.blurWindow makeKeyAndVisible];

// 	[[%c(ShakeBlurView) sharedInstance] setFrame:[self.blurWindow frame]];
// 	[[%c(ShakeBlurView) sharedInstance] setAlpha:0.0];
// 	[self.blurWindow addSubview:[%c(ShakeBlurView) sharedInstance]];
// }
// @end


%hook UIWindow

// Toggle blur on shake
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    %orig;
    if(event.type == UIEventSubtypeMotionShake && self == [[UIApplication sharedApplication] keyWindow]) {
        toggleBlur();
    }
}
%end