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

#import <Foundation/Foundation.h>

// ---------------------------------------------------------------------

@interface CCSchedulerEntry : NSObject

// ---------------------------------------------------------------------

// setup properties
@property ( nonatomic, strong ) id target;                              // target of the scheduled event
@property ( nonatomic ) SEL selector;                                   // selector
@property ( nonatomic ) float interval;                                 // interval between events
@property ( nonatomic ) float startDelay;                               // startdelay before first tick
@property ( nonatomic ) BOOL isPaused;                                  // is currently paused
@property ( nonatomic ) uint repeat;                                    // times to repeat the event
@property ( nonatomic ) int priority;                                   // used for sorting
@property ( nonatomic ) BOOL removeAfterCompletion;                     // remove scheduler entry after completion

// control properties
@property ( nonatomic ) BOOL isExpired;                                 // has expired

// readonly properties
@property ( nonatomic, readonly ) float ellapsed;                       // ellapsed since last tick
@property ( nonatomic, readonly ) float lastTickTime;                   // last tick time ( used to calculate ellapsed )
@property ( nonatomic, readonly ) float nextTickTime;                   // next tick time
@property ( nonatomic, readonly ) uint tickCount;                       // tick counter
@property ( nonatomic, readonly ) float runtime;                        // total runtime

// ---------------------------------------------------------------------

-( void )reset;
-( void )update:( NSTimeInterval )ellapsed;

// ---------------------------------------------------------------------

@end









































