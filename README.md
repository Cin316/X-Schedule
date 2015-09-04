#X Schedule

X Schedule is an iOS app that fetches the bell schedule for St. Xavier High School from the [St. X website](http://www.stxavier.org).  It shows an in-app view of the schedule and has a Notification Center widget.  Its modular approach makes it easy to adapt to a multitude of situations.

#Screenshots

![Screenshot](/Screenshots/screenshot1.png?raw=true “Schedule View”)
![Screenshot](/Screenshots/screenshot4.png?raw=true “Notification Center Widget”)
![Screenshot](/Screenshots/screenshot5.png?raw=true “iPad Week View”)

#Download and Installation

X Schedule is available on the App Store for iPhone and iPad.

[![Download on the App Store](https://cdn.rawgit.com/Cin316/X-Schedule/develop/App_Store_Badge.svg)](https://itunes.apple.com/app/id987185535)

#Compiling

To download and compile X Schedule, you will need:

- OS X 10.10+
- Xcode 6+
- git

Clone the repository from GitHub.

```git clone http://github.com/Cin316/X-Schedule.git```

Navigate to the Xcode project file and open it.

```
cd "X Schedule"
open "X Schedule.xcodeproj"
```

You should now be able to compile and run X Schedule through Xcode.

#Issues

File bug reports and feature requests on the GitHub issues tracker.  I will look at them as soon as I can.

#Forking

Feel free to fork and modify this code for any type of schedule or organization as you see fit.  Be sure to include the copyright notice as indicated in the MIT License.  To adapt it to another website, modify the [XScheduleParser.swift](/XScheduleKit/XScheduleParser.swift) and [XScheduleDownloader.swift](/XScheduleKit/XScheduleDownloader.swift) files.

The `XScheduleDownloader` class contains one method to override, `downloadSchedule(date: NSDate, completionHandler: String -> Void, errorHandler: String -> Void)`, which returns an `NSURLSessionTask`.  It should fetch a schedule in some way for the given `date`, and pass a String representation to the given `completionHandler`.  If an error occurs, it should pass an error message to the `errorHandler`.  The method returns the `NSURLSessionTask` of the download if it is being fetched via the web.  It should return `NSURLSessionTask()` in all other cases.  This class will usually download an HTML or XML webpage.  It may use other methods as helpers.  This method should **not** block the thread.

The `XScheduleParser` class has two methods to override.  `parseForSchedule(string: String, date: NSDate)` returns a Schedule object as described in [Schedule.swift](/XScheduleKit/Schedule.swift).  It should take the `String` output from `XScheduleDownloader`, parse it, and return a matching `Schedule` object with the `date` specified.  It may use other methods as helpers.  For example, my implementation uses `NSXMLParserDelegate` methods to help with parsing.  The code in `parseForSchedule` may block the thread. `storeScheduleInString(schedule: Schedule)` returns a `String` representation of the `Schedule` provided.  It should be in the same format as the output of `XScheduleDownloader` and be able to be parsed by `XScheduleParser`.  This method is used to cache and store schedules.

#Legal

The authors and content of this app are not affiliated with or endorsed by St. Xavier High School in any way, shape, or form.

This is licensed under the MIT License.  The text of the license is located in [LICENSE.txt](/LICENSE.txt).

The images in this project are licensed under the Creative Commons Attribution License unless otherwise noted.  The text of the license is located at http://creativecommons.org/licenses/by/4.0/.

The GitHub logo and icons located in [GitHub.imageset](/X Schedule/Images.xcassets/GitHub.imageset) are (c) 2015 GitHub, Inc and are not licensed under CC-BY 4.0.
