#X Schedule

X Schedule is an iOS app that fetches the bell schedule for St. Xavier High School from the [St. X website](http://www.stxavier.org).  It shows an in-app view of the schedule and has a Notification Center widget.  Its modular approach makes it easy to adapt to other situations.

#Screenshots

To be added.

#Download and Installation

X Schedule will be available on the iOS App Store for free when it is released.

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

File bug reports and feature requests on the GitHub issues tracker to the left.  I will look at them as soon as I can.

#Forking

Feel free to fork and modify this code for any schedule or organization as you see fit.  Be sure to include the copyright notice as indicated in the MIT License.  To adapt it to another website, modify the `ScheduleParser.swift` and `ScheduleDownloader.swift` files.

The `ScheduleDownloader` class contains one method to override, `downloadSchedule(date: NSDate, completionHandler: String -> Void)`, which returns nothing.  It should fetch a schedule in some way for the given `date`, and pass a String representation to the given `completionHandler`.  This class will usually download an HTML or XML webpage.  The other method, `downloadSchedule(completionHandler: String -> Bool)`, simply calls the first as a convenience method, and shouldn't be overrode.

The `ScheduleParser` class has one method to override, `parseForSchedule(string: String)`, which returns a Schedule object as described in `Schedule.swift`.  It should take the `String` output from `ScheduleDownloader`, parses it, and return a matching Schedule object.  It can use other methods as helpers.  For example, my implementation uses `NSXMLParserDelegate` methods to help with parsing.  The code in `parseForSchedule` may block the thread.

#Legal

The authors and content of this app are not affiliated with or endorsed by St. Xavier High School in any way, shape, or form.

This is licensed under the MIT License.  The text of the license is located in `LICENSE.txt`.
