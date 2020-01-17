# Changelog
This files keeps track of all of the changes made betweem version of X Schedule.  For more detailed information, see the commit log.

# 0.1
- Build number: 124
- Initial beta release
- Vertical iPhone and iPad schedule view
  - Navigate days with buttons
- Horizontal iPad week view
  - Navigate weeks with buttons
- Widget with today's schedule
- More tab with:
  - About view with app icon
  - App version and build
  - Licensing and image licensing pages
  - Donors page
  - Contact page
- Schedule parsing from St. X website
  - Parses times and titles
  - Get titles of schedule for day
  - Buggy highlighting of current class
- App icon
  - Light blue minimalistic color scheme with rounded corners

# 0.1.1
- Build number: 134
- Fixed issue which prevented app from archiving successfully.
- Added thank you for Aaron Wright.

# 0.1.2
- Build number: 139
- Made parser correcly determine day and AM/PM of times.
- Fixed bugs with highlighting of current class.
  - Added highlighting to widget.
- Fixed issues with concurrent downloading.
- Added display of year on schedule.
- Fixed bugs with military time.

# 1.0.0
- Build number: 149
- Initial App Store release.
- Fixed bug where all schedule titles would appear as "Weekend" on iPad week view.
- Added network error handling.
- Fixed bug where app would set date to today when using control center/notification center.

# 1.1.0
- Build number: 289
- Restructured and refactored internal code.
- Downloaded schedules are now cached for offline access and quicker load times.
- Re-added settings tab with:
  - 'Clear cache' button.
  - Substitutions editing.
- Added tab bar loading indicator.
- Added substitutions feature.
  - Editable list of text to replace downloaded schedule names with.
  - Interface to add and remove items.
  - Can be turned on and off with switch.
- Added gestures, swiping, and animations to the iPhone.
- Bug fixes and tweaks.

# 1.1.1
- Build number: 308
- Fixed major bug where schedules would not properly download.
- Fixed bug where donors view would crash app.
- Updated code to Swift 2.

# 1.2.0
- Build number: 351
- Made widget show next day's schedule after 8 PM.
- Improved class substitutions.  They now ignore case and whitespace.
- Added class substitutions to the widget.
- Added iPad Pro support.
- Added Apple Watch app.
  - Shows the current day's schedule.

# 1.3.0
- Build number: 410
- Added support for new types of schedule items (i.e. classes with no end, or only one time).
- Added announcements tab for homeroom announcements.
- Added notifications if an unusual schedule is coming up.
- Added support for Slide Over, Split Screen, and new screen sizes.
- Adapted widget to iOS 10 look.
- Fixed many UI bugs.
- Restructured ScheduleItem class to support more types of schedules.
- Updated code to Swift 3.

# 1.3.1
- Build number: 415
- Fixed bug where schedule notification trigger code would display.

# 1.3.2
- Build number: 428
- Fixed major "No classes" bug where schedules would fail to load.
 
# 1.3.3
- Build number: 441
- Fixed several bugs that caused new schedules not to display.
  - This fixes a bug where schedules would only show the text "<p>".
- Updated code to Swift 5.  It now compiles under Xcode 11.

