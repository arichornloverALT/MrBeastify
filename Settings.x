#import "Header.h"
#import "../YouTubeHeader/YTSettingsViewController.h"
#import "../YouTubeHeader/YTSettingsSectionItem.h"
#import "../YouTubeHeader/YTSettingsSectionItemManager.h"
#import "../YouTubeHeader/YTAppSettingsSectionItemActionController.h"
#import "../YouTubeHeader/YTSettingsCell.h"

extern BOOL TweakEnabled();

static const NSInteger mrBeastifySection = 511;

@interface YTSettingsSectionItemManager (MrBeastify)
- (void)updateMrBeastifySectionWithEntry:(id)entry;
@end

%hook YTAppSettingsPresentationData

+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound)
        [mutableOrder insertObject:@(mrBeastifySection) atIndex:insertIndex + 1];
    return mutableOrder;
}

%end

%hook YTSettingsSectionItemManager

%new(v@:@)
- (void)updateMrBeastifySectionWithEntry:(id)entry {
    YTSettingsViewController *delegate = [self valueForKey:@"_dataDelegate"];
    NSMutableArray *sectionItems = [NSMutableArray array];
    YTSettingsSectionItem *enabledSwitchItem = [%c(YTSettingsSectionItem) switchItemWithTitle:@"Enabled"
        titleDescription:@"Restart Required"
        accessibilityIdentifier:nil
        switchOn:TweakEnabled()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:EnabledKey];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:enabledSwitchItem];
    if ([delegate respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)])
        [delegate setSectionItems:sectionItems forCategory:mrBeastifySection title:@"MrBeastify" icon:nil titleDescription:nil headerHidden:NO];
    else
        [delegate setSectionItems:sectionItems forCategory:mrBeastifySection title:@"MrBeastify" titleDescription:nil headerHidden:NO];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == mrBeastifySection) {
        [self updateMrBeastifySectionWithEntry:entry];
        return;
    }
    %orig;
}

%end
