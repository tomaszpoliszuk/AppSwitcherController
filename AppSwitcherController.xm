/* App Switcher Controller - Control App Switcher on iOS/iPadOS
 * Copyright (C) 2020 Tomasz Poliszuk
 *
 * App Switcher Controller is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * App Switcher Controller is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with App Switcher Controller. If not, see <https://www.gnu.org/licenses/>.
 */


@interface SBFluidSwitcherIconImageContainerView : UIView
@end

@interface SBMainSwitcherViewController : UIViewController
- (bool)isMainSwitcherVisible;
@end

NSString *const domainString = @"com.tomaszpoliszuk.appswitchercontroller";

NSMutableDictionary *tweakSettings;

static bool enableTweak;

static long long switcherStyle;

static bool showStatusBarInAppSwitcher;

static bool showAppIcon;
static bool showAppName;

static bool allowAppSuggestion;
static NSString *deckCardScaleInSwitcher;
static NSString *deckDepthPadding;

static NSString *gridCardScaleInSwitcher;
static NSString *gridYAxisSpacingPortrait;
static NSString *gridXAxisSpacingPortrait;
static NSString *gridYAxisSpacingLandscape;
static NSString *gridXAxisSpacingLandscape;

static NSString *wallpaperScale;
static NSString *homeScreenScale;
static NSString *homeScreenOpacity;
static NSString *homeScreenBlur;
static NSString *dimmingAlpha;

void SettingsChanged() {
	NSUserDefaults *tweakSettings = [[NSUserDefaults alloc] initWithSuiteName:domainString];

	enableTweak = [([tweakSettings objectForKey:@"enableTweak"] ?: @(YES)) boolValue];

	switcherStyle = [([tweakSettings valueForKey:@"switcherStyle"] ?: @(0)) integerValue];

	showStatusBarInAppSwitcher = [([tweakSettings objectForKey:@"showStatusBarInAppSwitcher"] ?: @(NO)) boolValue];

	showAppIcon = [([tweakSettings objectForKey:@"showAppIcon"] ?: @(YES)) boolValue];
	showAppName = [([tweakSettings objectForKey:@"showAppName"] ?: @(YES)) boolValue];

	allowAppSuggestion = [([tweakSettings objectForKey:@"allowAppSuggestion"] ?: @(YES)) boolValue];
	deckCardScaleInSwitcher = [tweakSettings objectForKey:@"deckCardScaleInSwitcher"];
	deckDepthPadding = [tweakSettings objectForKey:@"deckDepthPadding"];

	gridCardScaleInSwitcher = [tweakSettings objectForKey:@"gridCardScaleInSwitcher"];
	gridYAxisSpacingPortrait = [tweakSettings objectForKey:@"gridYAxisSpacingPortrait"];
	gridXAxisSpacingPortrait = [tweakSettings objectForKey:@"gridXAxisSpacingPortrait"];
	gridYAxisSpacingLandscape = [tweakSettings objectForKey:@"gridYAxisSpacingLandscape"];
	gridXAxisSpacingLandscape = [tweakSettings objectForKey:@"gridXAxisSpacingLandscape"];

	wallpaperScale = [tweakSettings objectForKey:@"wallpaperScale"];
	homeScreenScale = [tweakSettings objectForKey:@"homeScreenScale"];
	homeScreenOpacity = [tweakSettings objectForKey:@"homeScreenOpacity"];
	homeScreenBlur = [tweakSettings objectForKey:@"homeScreenBlur"];
	dimmingAlpha = [tweakSettings objectForKey:@"dimmingAlpha"];
}

%hook SBFluidSwitcherIconImageContainerView
- (void)didMoveToWindow {
	%orig;
	if ( enableTweak && !showAppIcon ) {
		self.hidden = YES;
	}
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

%hook SBAppSwitcherSettings
- (void)setSwitcherStyle:(long long)arg1 {
	if ( enableTweak ) {
		arg1 = switcherStyle;
	}
	%orig;
}
- (double)deckSwitcherPageScale {
	double origValue = %orig;
	if ( enableTweak && deckCardScaleInSwitcher.length > 0 ) {
		return origValue * [deckCardScaleInSwitcher doubleValue] / 100;
	}
	return origValue;
}
- (double)depthPadding {
	double origValue = %orig;
	if ( enableTweak && deckDepthPadding.length > 0 ) {
		return [deckDepthPadding doubleValue] / 100;
	}
	return origValue;
}
- (double)gridSwitcherPageScale {
	double origValue = %orig;
	if ( enableTweak && gridCardScaleInSwitcher.length > 0 ) {
		return origValue * [gridCardScaleInSwitcher doubleValue] / 100;
	}
	return origValue;
}
- (double)gridSwitcherVerticalNaturalSpacingPortrait {
	double origValue = %orig;
	if ( enableTweak && gridYAxisSpacingPortrait.length > 0 ) {
		return [gridYAxisSpacingPortrait doubleValue];
	}
	return origValue;
}
- (double)gridSwitcherHorizontalInterpageSpacingPortrait {
	double origValue = %orig;
	if ( enableTweak && gridXAxisSpacingPortrait.length > 0 ) {
		return [gridXAxisSpacingPortrait doubleValue];
	}
	return origValue;
}
- (double)gridSwitcherVerticalNaturalSpacingLandscape {
	double origValue = %orig;
	if ( enableTweak && gridYAxisSpacingLandscape.length > 0 ) {
		return [gridYAxisSpacingLandscape doubleValue];
	}
	return origValue;
}
- (double)gridSwitcherHorizontalInterpageSpacingLandscape {
	double origValue = %orig;
	if ( enableTweak && gridXAxisSpacingLandscape.length > 0 ) {
		return [gridXAxisSpacingLandscape doubleValue];
	}
	return origValue;
}
%end

%hook SBFluidSwitcherAnimationSettings
- (void)setWallpaperScaleInSwitcher:(double)arg1 {
	if ( enableTweak && wallpaperScale.length > 0 ) {
		arg1 = [wallpaperScale doubleValue] / 100;
	}
	%orig;
}
- (void)setHomeScreenScaleInSwitcher:(double)arg1 {
	if ( enableTweak && homeScreenScale.length > 0 ) {
		arg1 = [homeScreenScale doubleValue] / 100;
	}
	%orig;
}
- (void)setHomeScreenOpacityInSwitcher:(double)arg1 {
	if ( enableTweak && homeScreenOpacity.length > 0 ) {
		arg1 = [homeScreenOpacity doubleValue] / 100;
	}
	%orig;
}
- (void)setHomeScreenBlurInSwitcher:(double)arg1 {
	if ( enableTweak && homeScreenBlur.length > 0 ) {
		arg1 = [homeScreenBlur doubleValue] / 100;
	}
	%orig;
}
- (void)setDimmingAlphaInSwitcher:(double)arg1 {
	if ( enableTweak && dimmingAlpha.length > 0 ) {
		arg1 = [dimmingAlpha doubleValue] / 100;
	}
	%orig;
}
%end

%hook SBMainSwitcherViewController
- (void)switcherContentController:(id)arg1 setContainerStatusBarHidden:(bool)arg2 animationDuration:(double)arg3 {
	if ( enableTweak && showStatusBarInAppSwitcher && [self isMainSwitcherVisible]) {
		arg2 = NO;
	}
	%orig;
}
%end

%hook SBSwitcherAppSuggestionViewController
- (void)loadView {
	if ( enableTweak && !allowAppSuggestion ) {
		return;
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
