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
			blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
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

%hook UIWindow
// Toggle blur on shake
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    %orig;
    if(event.type == UIEventSubtypeMotionShake && self == [[UIApplication sharedApplication] keyWindow]) {
		[[%c(ShakeBlurView) sharedInstance] setFrame:[self frame]];
		[[%c(ShakeBlurView) sharedInstance] setAlpha:0.0];
		[[[UIApplication sharedApplication] keyWindow].rootViewController.view insertSubview:[%c(ShakeBlurView) sharedInstance] atIndex:100];
        toggleBlur();
    }
}
%end


