/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013 Lars Birkemose
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


#ifdef __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>		// Needed for UIDevice
#endif

#import "CCSchedulerEntry.h"

// ---------------------------------------------------------------------
// Various hard values for CCScheduler
// Do NOT change!

typedef enum {
    CCSchedulerEachFrame                    = 0,
    CCSchedulerForever                      = 0,
    CCSchedulerNoPriority                   = 0,
    CCSchedulerNotFound                     = -1,
    CCSchedulerSystemPriority               = INT_MIN,
} tCCScheduler;

// ---------------------------------------------------------------------

@interface CCScheduler : NSObject

// ---------------------------------------------------------------------

@property ( nonatomic, readonly ) NSTimeInterval totalRunTime;

// ---------------------------------------------------------------------

+( id )scheduler;
-( id )init;

-( void )update:( NSTimeInterval )ellapsed;

-( CCSchedulerEntry* )scheduleSelector:( SEL )selector forTarget:( id )target interval:( NSTimeInterval )interval repeat:( uint )repeat delay:( NSTimeInterval )delay paused:( BOOL )paused;
-( CCSchedulerEntry* )scheduleSelector:( SEL )selector forTarget:( id )target interval:( NSTimeInterval )interval;
-( CCSchedulerEntry* )scheduleSelector:( SEL )selector forTarget:( id )target;
-( CCSchedulerEntry* )scheduleSelector:( SEL )selector forTarget:( id )target priority:( int )priority;
-( CCSchedulerEntry* )scheduleUpdate:( id )target;

-( void )pauseSelector:( SEL )selector forTarget:( id )target;
-( void )pauseAllSelectorsForTarget:( id )target;
-( void )resumeSelector:( SEL )selector forTarget:( id )target;
-( void )resumeAllSelectorsForTarget:( id )target;

-( void )unscheduleSelector:( SEL )selector forTarget:( id )target;
-( void )unscheduleUpdate:( id )target;
-( void )unscheduleAllSelectorsForTarget:(id)target;
-( void )unscheduleAllSelectors;

-( CCSchedulerEntry* )getSchedulerEntryForSelector:( SEL )selector forTarget:( id )target;


// ---------------------------------------------------------------------

@end




















































