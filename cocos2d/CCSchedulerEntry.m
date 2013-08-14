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

#import "CCSchedulerEntry.h"
#import "CCScheduler.h"
#import <objc/message.h>

// ---------------------------------------------------------------------

@implementation CCSchedulerEntry

// ---------------------------------------------------------------------

-( void )reset {
    
    _isExpired = NO;
    _ellapsed = 0;
    _lastTickTime = 0;
    _nextTickTime = _startDelay;
    _tickCount = 0;
    _runtime = 0;

}

// ---------------------------------------------------------------------

-( void )update:( NSTimeInterval )ellapsed {
    
    // check for paused or expired
    if ( ( _isPaused == YES ) || ( _isExpired == YES ) ) return;
    
    // increment runtime, and check if ready for next tick
    _runtime += ellapsed;
    if ( _runtime < _nextTickTime ) return;
    
    // calculate ellapsed and perform block or selector
    // this is done to prevent ARC warnings
    _ellapsed = _runtime - _lastTickTime;
    objc_msgSend( _target, _selector, _ellapsed, nil );
    
    // set up new tick timing
    _lastTickTime = _runtime;
    if ( _interval > 0 ) {
        _nextTickTime += _interval;
        
        // make sure that ticks can be maintained
        NSAssert( _nextTickTime >= _lastTickTime, @"Selector <%@> for target <%@>, can not maintain update interval of <%.3f Sec>", NSStringFromSelector( _selector ), [ _target class ], _interval );
    }
    
    // increment tick counter
    _tickCount ++;
    
    // check for repeat
    if ( _repeat != CCSchedulerForever ) {
        
        // check for scheduler expired
        if ( _tickCount >= _repeat ) _isExpired = YES;
    }

}

// ---------------------------------------------------------------------

@end
















































