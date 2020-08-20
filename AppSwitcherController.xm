NSString *domainString = @"com.tomaszpoliszuk.appswitchercontroller";

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

	setHomeScreenBlur = [([tweakSettings valueForKey:@"setHomeScreenBlur"] ?: @(1.000000)) doubleValue];
	setHomeScreenOpacity = [([tweakSettings valueForKey:@"setHomeScreenOpacity"] ?: @(0.500000)) doubleValue];
	setWallpaperScale = [([tweakSettings valueForKey:@"setWallpaperScale"] ?: @(1.200000)) doubleValue];
	setHomeScreenScale = [([tweakSettings valueForKey:@"setHomeScreenScale"] ?: @(0.900000)) doubleValue];
	setDimmingAlpha = [([tweakSettings valueForKey:@"setDimmingAlpha"] ?: @(0.670000)) doubleValue];
}

%hook SBAppSwitcherSettings
- (long long)switcherStyle {
	long long origValue = %orig;
	if ( enableTweak ) {
		return switcherStyle;
	} else {
		return origValue;
	}
}
%end

%hook SBFluidSwitcherItemContainer
- (void)setTitleOpacity:(double)arg1 {
	double origValue = arg1;
	if ( enableTweak && !showAppName ) {
		origValue = 0;
	}
	%orig(origValue);
}
%end

%hook SBFluidSwitcherIconImageContainerView
- (void)setImage:(id)arg1 animated:(bool)arg2 {
	id origValue = arg1;
	if ( enableTweak && !showAppIcon ) {
		origValue = nil;
	}
	%orig(origValue, arg2);
}
%end

%hook SBFluidSwitcherAnimationSettings
- (void)setHomeScreenBlurInSwitcher:(double)arg1 {
	if ( enableTweak && setHomeScreenBlur != 999 ) {
		%orig(setHomeScreenBlur);
	} else {
		%orig;
	}
}
- (void)setHomeScreenOpacityInSwitcher:(double)arg1 {
	if ( enableTweak && setHomeScreenOpacity != 999 ) {
		%orig(setHomeScreenOpacity);
	} else {
		%orig;
	}
}
- (void)setWallpaperScaleInSwitcher:(double)arg1 {
	if ( enableTweak && setWallpaperScale != 999 ) {
		%orig(setWallpaperScale);
	} else {
		%orig;
	}
}
- (void)setHomeScreenScaleInSwitcher:(double)arg1 {
	if ( enableTweak && setHomeScreenScale != 999 ) {
		%orig(setHomeScreenScale);
	} else {
		%orig;
	}
}
- (void)setDimmingAlphaInSwitcher:(double)arg1 {
	if ( enableTweak && setDimmingAlpha != 999 ) {
		%orig(setDimmingAlpha);
	} else {
		%orig;
	}
}
%end

%ctor {
	SettingsChanged();
	CFNotificationCenterAddObserver( CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)SettingsChanged, CFSTR("com.tomaszpoliszuk.appswitchercontroller.settingschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately );
	%init;
}
