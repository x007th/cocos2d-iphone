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

#import "CCActionManager.h"

// -----------------------------------------------------------------

@implementation CCActionManager {
    // ivars only belonging to this class
    
}

// -----------------------------------------------------------------

+( id )actionManager {
    return( [ [ self alloc ] init ] );
}

// -----------------------------------------------------------------

-( id )init {
    self = [ super init ];
    NSAssert( self != nil, @"Unable to create class" );
    // initialize
    
    
    
    
    // done
    return( self );
}

// -----------------------------------------------------------------

-( void )addAction:( CCAction* )action target:( id )target paused:( BOOL )paused {
    NSAssert( [ self objectForKey:action ] == nil, @"Action already added for target <%@", [ target class ] );
    action.isPaused = paused;
    [ self setObject:target forKey:action ];
    [ action startWithTarget:target ];
}

// -----------------------------------------------------------------

-( CCAction* )getActionByTag:( int )tag target:( id )target {
    for ( CCAction* action in self ) {
        if ( ( action.tag == tag ) && ( [ self objectForKey:action ] == target ) ) return( action );
    }
    return( nil );
}

// -----------------------------------------------------------------

-( int )numberOfRunningActionsInTarget:( id )target {
    int result = 0;
    for ( CCAction* action in self ) {
        if ( [ self objectForKey:action ] == target ) result ++;
    }
    return( result );
}

// -----------------------------------------------------------------

-( void )pauseTarget:( id )target {
    for ( CCAction* action in self ) {
        if ( [ self objectForKey:action ] == target ) action.isPaused = YES;
    }
}

// -----------------------------------------------------------------

-( NSSet* )pauseAllRunningActions {
    NSMutableSet* result = [ NSSet set ];
    for ( CCAction* action in self ) {
        if ( action.isPaused == NO ) {
            action.isPaused = YES;
            [ result addObject:[ self objectForKey:action ] ];
        }
    }
    return( result );
}

// -----------------------------------------------------------------

-( void )resumeTarget:( id )target {
    for ( CCAction* action in self ) {
        if ( [ self objectForKey:action ] == target ) action.isPaused = NO;
    }
}

// -----------------------------------------------------------------

-( void )resumeTargets:( NSSet* )targetsToResume {
    for ( id target in targetsToResume ) [ self resumeTarget:target ];
}

// -----------------------------------------------------------------

-( void )removeAllActionsFromTarget:( id )target {
    for ( CCAction* action in [ self allKeys ] ) {
        if ( [ self objectForKey:action ] == target ) [ self removeObjectForKey:action ];
    }
}

// -----------------------------------------------------------------

-( void )removeAction:( CCAction* )action {
    [ self removeObjectForKey:action ];
}

// -----------------------------------------------------------------

-( void )removeActionByTag:( int )tag target:( id )target {
    CCAction* action = [ self getActionByTag:tag target:target ];
    if ( action != nil ) [ self removeAction:action ];
}

// -----------------------------------------------------------------

-( void )removeAllActions {
    [ self removeAllObjects ];
}

// -----------------------------------------------------------------

-( void )update:( NSTimeInterval )ellapsed {
    for ( CCAction* action in [ self allKeys ] ) {
        if ( action.isPaused == NO ) {
            [ action step:ellapsed ];
            if ( action.isDone == YES ) [ self removeAction:action ];
        }
    }
}

// -----------------------------------------------------------------

@end










































