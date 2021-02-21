@interface ShakeBlurView : UIVisualEffectView
+(instancetype)sharedInstance;
-(void)unblur;
-(void)blur;
@end

BOOL blurred = NO;

@implementation ShakeBlurView
+(instancetype)sharedInstance {
	static ShakeBlurView *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (@available(iOS 13, *)) {
			UIBlurEffect *blur;
			blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
			sharedInstance = [[ShakeBlurView alloc] initWithEffect:blur];

			[sharedInstance setFrame:[[UIScreen mainScreen] bounds]];
			[sharedInstance setAlpha:0.0];
		}
	});
	return sharedInstance;
}

-(void)unblur {
	[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		[[%c(ShakeBlurView) sharedInstance] setAlpha:0.0];
    } completion:nil];
}

-(void)blur {
	[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		[[%c(ShakeBlurView) sharedInstance] setAlpha:1.0];
    } completion:nil];
}

@end

// Function to toggle the blur effect alpha
void toggleBlur() {
	if (!blurred){
		[[%c(ShakeBlurView) sharedInstance] blur];
		blurred = YES;
	} else if (blurred) {
		[[%c(ShakeBlurView) sharedInstance] unblur];
		blurred = NO;
	}
}

%hook UIWindow
// Toggle blur on shake
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    %orig;
    if(event.type == UIEventSubtypeMotionShake && self == [[UIApplication sharedApplication] keyWindow]) {
		[[[UIApplication sharedApplication] keyWindow].rootViewController.view insertSubview:[%c(ShakeBlurView) sharedInstance] atIndex:1000];
		toggleBlur();
    }
}
%end


