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


#import "AppSwitcherController.h"

#define kIsiOS14AndUp (kCFCoreFoundationVersionNumber >= 1740.00)
#define kIsiOS13AndUp (kCFCoreFoundationVersionNumber >= 1665.15)

#define kIconController [%c(SBIconController) sharedInstance]
#define kFloatingDockController [kIconController floatingDockController]
#define kDismissFloatingDockIfPresented [kFloatingDockController _dismissFloatingDockIfPresentedAnimated:YES completionHandler:nil]
#define kPresentFloatingDockIfDismissed [kFloatingDockController _presentFloatingDockIfDismissedAnimated:YES completionHandler:nil]
#define kMainSwitcherViewController [%c(SBMainSwitcherViewController) sharedInstance]
#define kIsMainSwitcherVisible [kMainSwitcherViewController isMainSwitcherVisible]

//	iOS12
#define kIsShowingSpotlightOrTodayView [kIconController isShowingSpotlightOrTodayView]
#define kIsVisible [kMainSwitcherViewController isVisible]
#define kFloatingDockController12 [%c(SBFloatingDockController) sharedInstance]
#define kDismissFloatingDockIfPresented12 [kFloatingDockController12 _dismissFloatingDockIfPresentedAnimated:YES completionHandler:nil]
#define kPresentFloatingDockIfDismissed12 [kFloatingDockController12 _presentFloatingDockIfDismissedAnimated:YES completionHandler:nil]

NSString *const domainString = @"com.tomaszpoliszuk.appswitchercontroller";

NSMutableDictionary *tweakSettings;

static bool enableTweak;

static long long switcherStyle;

static bool showStatusBarInAppSwitcher;
static bool showDockInAppSwitcher;

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

%hook SBFluidSwitcherIconImageContainerView
- (void)didMoveToWindow {
	%orig;
	if ( !showAppIcon ) {
		self.hidden = YES;
	}
}
%end

%hook SBFluidSwitcherItemContainer
- (void)setTitleOpacity:(double)arg1 {
	if ( !showAppName ) {
		arg1 = 0;
	}
	%orig;
}
%end

%hook SBAppSwitcherSettings
- (void)setSwitcherStyle:(long long)arg1 {
	arg1 = switcherStyle;
	%orig;
}
- (double)deckSwitcherPageScale {
	double origValue = %orig;
	if ( deckCardScaleInSwitcher.length > 0 ) {
		return origValue * [deckCardScaleInSwitcher doubleValue] / 100;
	}
	return origValue;
}
- (double)depthPadding {
	double origValue = %orig;
	if ( deckDepthPadding.length > 0 ) {
		return [deckDepthPadding doubleValue] / 100;
	}
	return origValue;
}
- (double)gridSwitcherPageScale {
	double origValue = %orig;
	if ( gridCardScaleInSwitcher.length > 0 ) {
		return origValue * [gridCardScaleInSwitcher doubleValue] / 100;
	}
	return origValue;
}
- (double)gridSwitcherVerticalNaturalSpacingPortrait {
	double origValue = %orig;
	if ( gridYAxisSpacingPortrait.length > 0 ) {
		return [gridYAxisSpacingPortrait doubleValue];
	}
	return origValue;
}
- (double)gridSwitcherHorizontalInterpageSpacingPortrait {
	double origValue = %orig;
	if ( gridXAxisSpacingPortrait.length > 0 ) {
		return [gridXAxisSpacingPortrait doubleValue];
	}
	return origValue;
}
- (double)gridSwitcherVerticalNaturalSpacingLandscape {
	double origValue = %orig;
	if ( gridYAxisSpacingLandscape.length > 0 ) {
		return [gridYAxisSpacingLandscape doubleValue];
	}
	return origValue;
}
- (double)gridSwitcherHorizontalInterpageSpacingLandscape {
	double origValue = %orig;
	if ( gridXAxisSpacingLandscape.length > 0 ) {
		return [gridXAxisSpacingLandscape doubleValue];
	}
	return origValue;
}
%end

%hook SBFluidSwitcherAnimationSettings
- (void)setWallpaperScaleInSwitcher:(double)arg1 {
	if ( wallpaperScale.length > 0 ) {
		arg1 = [wallpaperScale doubleValue] / 100;
	}
	%orig;
}
- (void)setHomeScreenScaleInSwitcher:(double)arg1 {
	if ( homeScreenScale.length > 0 ) {
		arg1 = [homeScreenScale doubleValue] / 100;
	}
	%orig;
}
- (void)setHomeScreenOpacityInSwitcher:(double)arg1 {
	if ( homeScreenOpacity.length > 0 ) {
		arg1 = [homeScreenOpacity doubleValue] / 100;
	}
	%orig;
}
- (void)setHomeScreenBlurInSwitcher:(double)arg1 {
	if ( homeScreenBlur.length > 0 ) {
		arg1 = [homeScreenBlur doubleValue] / 100;
	}
	%orig;
}
- (void)setDimmingAlphaInSwitcher:(double)arg1 {
	if ( dimmingAlpha.length > 0 ) {
		arg1 = [dimmingAlpha doubleValue] / 100;
	}
	%orig;
}
%end

%hook SBMainSwitcherViewController
- (void)switcherContentController:(id)arg1 setContainerStatusBarHidden:(bool)arg2 animationDuration:(double)arg3 {
	if ( showStatusBarInAppSwitcher && [self isMainSwitcherVisible]) {
		arg2 = NO;
	}
	%orig;
}
%end

%hook SBSwitcherAppSuggestionViewController
- (void)loadView {
	if ( !allowAppSuggestion ) {
		return;
	}
	%orig;
}
%end

%group iOS13

%hook SBDeckSwitcherModifier
- (bool)shouldConfigureInAppDockHiddenAssertion {
//	works only for deck switcher
	bool origValue = %orig;
	if ( !showDockInAppSwitcher ) {
		return YES;
	}
	return origValue;
}
%end

%hook SBGridSwitcherViewController
- (bool)isWindowVisible {
//	triggers correctly but when grid switcher is opened from today/spotlight/library dock is showing back
	bool origValue = %orig;
	if ( !showDockInAppSwitcher ) {
		if ( origValue ) {
			if ( kIsMainSwitcherVisible ) {
				kDismissFloatingDockIfPresented;
			}
		}
	}
	return origValue;
}
%end

%hook SBMainSwitcherViewController
- (bool)isMainSwitcherVisible {
//	works but triggers after switcher is visible - using this one to prevent reappearing of dock when grid switcher is opened from today/spotlight/library
	bool origValue = %orig;
	if ( !showDockInAppSwitcher ) {
		if (origValue) {
			kDismissFloatingDockIfPresented;
		}
	}
	return origValue;
}
%end

%hook _SBGridFloorSwitcherModifier
- (id)appLayoutToScrollToBeforeTransitioning {
//	present dock back when last app was closed or when grid app switcher is empty
	id origValue = %orig;
	if ( !showDockInAppSwitcher && !origValue ) {
		if (kIsiOS14AndUp) {
			if (![kIconController isTodayOverlayPresented] && ![kIconController isLibraryOverlayPresented] && ![kIconController isAnySearchVisibleOrTransitioning]) {
				kPresentFloatingDockIfDismissed;
			}
		} else {
			if ( ![[kIconController iconManager] isShowingSpotlightOrTodayView] ) {
				kPresentFloatingDockIfDismissed;
			}
		}
	}
	return origValue;
}
%end

%end

%group iOS12

%hook SBDeckSwitcherPersonality
- (bool)_isPerformingSlideOffTransitionFromSwitcherToHomeScreen {
//	0 = home to switcher, switcher to app (tap), switcher to app (button), app to switcher, close app, close last app,
//	1 = switcher to home (tap), switcher to home (button),
//	nil = home to empty
	bool origValue = %orig;
	if ( !showDockInAppSwitcher && origValue && !kIsShowingSpotlightOrTodayView ) {
//	show dock when user switches back to homescreen and today view or spotlight search are not open
		kPresentFloatingDockIfDismissed12;
	} else if ( !showDockInAppSwitcher && kIsVisible ) {
//	hide dock when user opens deck app switcher
		kDismissFloatingDockIfPresented12;
	}
	return origValue;
}
- (id)topMostAppLayout {
//	show dock after last app is closed
	id origValue = %orig;
	if ( !showDockInAppSwitcher && !origValue && !kIsShowingSpotlightOrTodayView ) {
		kPresentFloatingDockIfDismissed12;
	}
	return origValue;
}
%end

%hook SBGridSwitcherPersonality
- (bool)_isPerformingSlideOffTransitionFromSwitcherToHomeScreen {
//	0 = home to switcher, switcher to app (tap), switcher to app (button), app to switcher, close app, close last app,
//	1 = switcher to home (tap), switcher to home (button),
//	nil = home to empty
	bool origValue = %orig;
	if ( !showDockInAppSwitcher && origValue && !kIsShowingSpotlightOrTodayView ) {
//	show dock when user switches back to homescreen and today view or spotlight search are not open
		kPresentFloatingDockIfDismissed12;
	} else if ( !showDockInAppSwitcher && kIsVisible ) {
//	hide dock when user opens grid app switcher
		kDismissFloatingDockIfPresented12;
	}
	return origValue;
}
%end

%end

void SettingsChanged() {
	NSUserDefaults *tweakSettings = [[NSUserDefaults alloc] initWithSuiteName:domainString];

	enableTweak = [([tweakSettings objectForKey:@"enableTweak"] ?: @(YES)) boolValue];

	switcherStyle = [([tweakSettings valueForKey:@"switcherStyle"] ?: @(0)) integerValue];

	showStatusBarInAppSwitcher = [([tweakSettings objectForKey:@"showStatusBarInAppSwitcher"] ?: @(NO)) boolValue];
	showDockInAppSwitcher = [([tweakSettings objectForKey:@"showDockInAppSwitcher"] ?: @(YES)) boolValue];

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
	if ( enableTweak ) {
		if ( kIsiOS13AndUp ) {
			%init(iOS13);
		} else {
			%init(iOS12);
		}
		%init(_ungrouped);
	}
}
