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
+ (id)sharedInstance;
- (bool)isMainSwitcherVisible;
@end

@interface SBHIconManager : NSObject
- (bool)isShowingSpotlightOrTodayView;
@end

@interface SBFloatingDockController : NSObject
- (void)_dismissFloatingDockIfPresentedAnimated:(bool)arg1 completionHandler:(id /* block */)arg2;
- (void)_presentFloatingDockIfDismissedAnimated:(bool)arg1 completionHandler:(id /* block */)arg2;
@end

@interface SBIconController : UIViewController
@property (nonatomic, readonly) SBHIconManager *iconManager;
@property (nonatomic, readonly) SBFloatingDockController *floatingDockController;
- (bool)isTodayOverlayPresented;
- (bool)isLibraryOverlayPresented;
- (bool)isAnySearchVisibleOrTransitioning;
@end
