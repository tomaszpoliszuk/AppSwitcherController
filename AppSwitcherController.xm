NSString *const domainString = @"com.tomaszpoliszuk.appswitchercontroller";

NSMutableDictionary *tweakSettings;

static BOOL enableTweak;

static long long switcherStyle;

static BOOL showAppIcon;
static BOOL showAppName;

static double setHomeScreenBlur;
static double setHomeScreenOpacity;
static double setWallpaperScale;
static double setHomeScreenScale;
static double setDimmingAlpha;

void SettingsChanged() {
	NSUserDefaults *tweakSettings = [[NSUserDefaults alloc] initWithSuiteName:domainString];

	enableTweak = [([tweakSettings objectForKey:@"enableTweak"] ?: @(YES)) boolValue];

	switcherStyle = [([tweakSettings valueForKey:@"switcherStyle"] ?: @(0)) integerValue];

	showAppIcon = [([tweakSettings objectForKey:@"showAppIcon"] ?: @(YES)) boolValue];
	showAppName = [([tweakSettings objectForKey:@"showAppName"] ?: @(YES)) boolValue];

	setHomeScreenBlur = [([tweakSettings valueForKey:@"setHomeScreenBlur"] ?: @(1)) doubleValue];
	setHomeScreenOpacity = [([tweakSettings valueForKey:@"setHomeScreenOpacity"] ?: @(0.5)) doubleValue];
	setWallpaperScale = [([tweakSettings valueForKey:@"setWallpaperScale"] ?: @(1.2)) doubleValue];
	setHomeScreenScale = [([tweakSettings valueForKey:@"setHomeScreenScale"] ?: @(0.9)) doubleValue];
	setDimmingAlpha = [([tweakSettings valueForKey:@"setDimmingAlpha"] ?: @(0.6)) doubleValue];
}

%hook SBAppSwitcherSettings
- (long long)switcherStyle {
	long long origValue = %orig;
	if ( enableTweak ) {
		return switcherStyle;
	}
	return origValue;
}
%end

%hook SBFluidSwitcherItemContainer
- (void)setTitleOpacity:(double)arg1 {
	if ( enableTweak && !showAppName ) {
		arg1 = 0;
	}
	%orig;
}
%end

%hook SBFluidSwitcherIconImageContainerView
- (void)setImage:(id)arg1 animated:(bool)arg2 {
	if ( enableTweak && !showAppIcon ) {
		arg1 = nil;
	}
	%orig;
}
%end

%hook SBFluidSwitcherAnimationSettings
- (void)setHomeScreenBlurInSwitcher:(double)arg1 {
	if ( enableTweak && setHomeScreenBlur != 999 ) {
		arg1 = setHomeScreenBlur;
	}
	%orig;
}
- (void)setHomeScreenOpacityInSwitcher:(double)arg1 {
	if ( enableTweak && setHomeScreenOpacity != 999 ) {
		arg1 = setHomeScreenOpacity;
	}
	%orig;
}
- (void)setWallpaperScaleInSwitcher:(double)arg1 {
	if ( enableTweak && setWallpaperScale != 999 ) {
		arg1 = setWallpaperScale;
	}
	%orig;
}
- (void)setHomeScreenScaleInSwitcher:(double)arg1 {
	if ( enableTweak && setHomeScreenScale != 999 ) {
		arg1 = setHomeScreenScale;
	}
	%orig;
}
- (void)setDimmingAlphaInSwitcher:(double)arg1 {
	if ( enableTweak && setDimmingAlpha != 999 ) {
		arg1 = setDimmingAlpha;
	}
	%orig;
}
%end

%ctor {
	SettingsChanged();
	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		(CFNotificationCallback)SettingsChanged,
		CFSTR("com.tomaszpoliszuk.appswitchercontroller.settingschanged"),
		NULL,
		CFNotificationSuspensionBehaviorDeliverImmediately
	);
	%init;
}
