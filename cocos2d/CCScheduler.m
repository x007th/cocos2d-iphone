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


#import "CCScheduler.h"

@implementation CCScheduler {
    NSMutableArray*             _schedulerList;
    NSMutableDictionary*        _schedulerDict;
}

// ---------------------------------------------------------------------
#pragma mark - create and destroy
// ---------------------------------------------------------------------

+( id )scheduler {
    return( [ [ self alloc ] init ] );
}

// ---------------------------------------------------------------------

-( id )init {
    self = [ super init ];
    NSAssert( self != nil, @"Unable to create class" );
    
    // initialize
    _totalRunTime = 0;
    _schedulerList = [ NSMutableArray array ];
    _schedulerDict = [ NSMutableDictionary dictionary ];
    
    // done
    return( self );
}

// ---------------------------------------------------------------------
#pragma mark - scheduling, controlling and unscheduling selectors
// ---------------------------------------------------------------------
// this is the basic function for scheduling updates ( performing ticks )
// selector and target must always be provided
// interval is the average interval between ticks
// repeat is the number of times the tick should be performed ( CCSchedulerForever repeats forever )
// delay is the delay before first tick
// paused is whether the schedulers starts in running or paused mode
// NOTE
// trying to execute ticks faster than the current framerate, will result in an assertion
// for entries with same priority ( which includes no priority ), scheduled ticks are executed in the order they were added

-( CCSchedulerEntry* )scheduleSelector:( SEL )selector forTarget:( id )target interval:( NSTimeInterval )interval repeat:( uint )repeat delay:( NSTimeInterval )delay paused:( BOOL )paused priority:( int )priority {
    NSAssert( [ self getSchedulerEntryForSelector:selector forTarget:target ] == nil, @"Selector <%@> for target <%@>, has allready been scheduled", NSStringFromSelector( selector ), [ target class ] );
    
    // create a new schedule entry
    CCSchedulerEntry* entry = [ CCSchedulerEntry new ];

    entry.target = target;
    entry.selector = selector;
    entry.interval = interval;
    entry.startDelay = delay;
    entry.isPaused = paused;
    entry.repeat = repeat;
    entry.priority = priority;
    entry.removeAfterCompletion = YES;
    
    [ entry reset ];
        
    // add the new entry to scheduling list
    [ self addEntry:entry ];
    
    // done
    return( entry );
}

-( CCSchedulerEntry* )scheduleSelector:( SEL )selector forTarget:( id )target interval:( NSTimeInterval )interval repeat:( uint )repeat delay:( NSTimeInterval )delay paused:( BOOL )paused {
    return( [ self scheduleSelector:selector forTarget:target interval:interval repeat:repeat delay:delay paused:paused priority:CCSchedulerNoPriority ] );
}

-( CCSchedulerEntry* )scheduleSelector:( SEL )selector forTarget:( id )target interval:( NSTimeInterval )interval {
    return( [ self scheduleSelector:selector forTarget:target interval:interval repeat:CCSchedulerForever delay:0 paused:NO priority:CCSchedulerNoPriority ] );
}

-( CCSchedulerEntry* )scheduleSelector:( SEL )selector forTarget:( id )target {
    return( [ self scheduleSelector:selector forTarget:target interval:CCSchedulerEachFrame repeat:CCSchedulerForever delay:0 paused:NO priority:CCSchedulerNoPriority ] );
}

-( CCSchedulerEntry* )scheduleSelector:( SEL )selector forTarget:( id )target priority:( int )priority {
    NSAssert( priority > CCSchedulerSystemPriority, @"System priority is for internal use only" );
    return( [ self scheduleSelector:selector forTarget:target interval:CCSchedulerEachFrame repeat:CCSchedulerForever delay:0 paused:NO priority:priority ] );
}

-( CCSchedulerEntry* )scheduleUpdate:( id )target {
    return( [ self scheduleSelector:@selector( update: ) forTarget:target interval:CCSchedulerEachFrame repeat:CCSchedulerForever delay:0 paused:NO priority:CCSchedulerNoPriority ] );
}

// ---------------------------------------------------------------------

-( void )pauseSelector:( SEL )selector forTarget:( id )target {
    
    // get scheduler entry
    CCSchedulerEntry* entry = [ self getSchedulerEntryForSelector:selector forTarget:target ];
    NSAssert( entry != nil, @"Selector <%@> for target <%@>, has not been scheduled", NSStringFromSelector( selector ), [ target class ] );

    // pause the entry
    entry.isPaused = YES;
}

-( void )pauseAllSelectorsForTarget:( id )target {
    
    // loop entries and pause for matching target
    for ( CCSchedulerEntry* entry in _schedulerList ) {
        if ( entry.target == target ) entry.isPaused = YES;
    }
}

-( void )resumeSelector:( SEL )selector forTarget:( id )target {
    
    // get scheduler entry
    CCSchedulerEntry* entry = [ self getSchedulerEntryForSelector:selector forTarget:target ];
    NSAssert( entry != nil, @"Selector <%@> for target <%@>, has not been scheduled", NSStringFromSelector( selector ), [ target class ] );
    
    // resume the entry
    entry.isPaused = NO;
}

-( void )resumeAllSelectorsForTarget:( id )target {
    
    // loop entries and resume for matching target
    for ( CCSchedulerEntry* entry in _schedulerList ) {
        if ( entry.target == target ) entry.isPaused = NO;
    }
}

// ---------------------------------------------------------------------

-( void )unscheduleSelector:( SEL )selector forTarget:( id )target {
    
    // get scheduler entry
    CCSchedulerEntry* entry = [ self getSchedulerEntryForSelector:selector forTarget:target ];
    NSAssert( entry != nil, @"Selector <%@> for target <%@>, has not been scheduled", NSStringFromSelector( selector ), [ target class ] );
    
    // remove scheduler
    // this is done by marking it as expired, so that no schedulers are removed other than in update loop
    entry.isExpired = YES;    
}

-( void )unscheduleUpdate:( id )target {
    [ self unscheduleSelector:@selector( update: ) forTarget:target ];
}

-( void )unscheduleAllSelectorsForTarget:( id )target {
    
    // loop entries and expire matching target
    for ( CCSchedulerEntry* entry in _schedulerList ) {
        if ( entry.target == target ) entry.isExpired = YES;
    }
}

-( void )unscheduleAllSelectors {
    for ( CCSchedulerEntry* entry in _schedulerList ) entry.isExpired = YES;
}

// ---------------------------------------------------------------------
#pragma mark - helper functions
// ---------------------------------------------------------------------

-( CCSchedulerEntry* )getSchedulerEntryForSelector:( SEL )selector forTarget:( id )target {
    return( [ _schedulerDict objectForKey:[ self keyForSelector:selector andTarget:target ] ] );
    
    /*
     
    // manually maintain an index due to fast iterating
    int index = 0;
    for ( CCSchedulerEntry* entry in _schedulerList ) {
        
        // if target and selector, return index
        if ( ( entry.selector == selector ) && ( entry.target == target ) ) return( entry );
        index ++;
    }
    
    // not found
    return( nil );
     
    */
}

// ---------------------------------------------------------------------
#pragma mark - internal functions
// ---------------------------------------------------------------------
// returns a unique key based on target and selector

-( NSString* )keyForSelector:( SEL )selector andTarget:( id )target {
    return( [ NSString stringWithFormat:@"%@%p", NSStringFromSelector( selector ), target ] );
}

// ---------------------------------------------------------------------

// this is called on main game tick from main window

-( void )update:( NSTimeInterval )ellapsed {
    
    // maintain a total scheduler runtime
    _totalRunTime += ellapsed;
    
    // update all
    // loop backwards to be able to remove expired shedulers on the fly
    for ( int index = _schedulerList.count - 1; index >= 0; index -- ) {
        CCSchedulerEntry* entry = [ _schedulerList objectAtIndex:index ];
        
        // update the entry
        [ entry update:ellapsed ];
        
        // check for expired
        // this is the only place, a scheduled entry is ever removed
        // as this is in the loop calling the schedulers, the shit will never hit the crash-fan ...
        if ( ( entry.isExpired == YES ) && ( entry.removeAfterCompletion ) ) {
            [ _schedulerDict removeObjectForKey:[ self keyForSelector:entry.selector andTarget:entry.target ] ];
            [ _schedulerList removeObjectAtIndex:index ];
        }
    }
}

// ---------------------------------------------------------------------
// adds an entry to the scheduled entry list
// if the entry has priority, it is inserted in the list as last entry with that priority
// use priority, to make sure, that events ticked each frame, will be executed in a fixed sequence

-( void )addEntry:( CCSchedulerEntry* )newEntry {
    
    if ( newEntry.priority == CCSchedulerNoPriority ) {
        
        // if entry has no priority, just smack it in
        [ _schedulerList addObject:newEntry ];
        
    } else {
        
        // if entry has priority, add the entry after a higher priority ( which is a lower number )
        // yeah, it is confusing, but the lower the number, the higher the priority
        
        // set up stuff
        BOOL hasBeenAdded = NO;
        int index = 0;
        
        // iterate from the start, which is highest priority
        for ( CCSchedulerEntry* entry in _schedulerList ) {
            
            // check if we are in the right spot
            // lowest numbers are the highest priorities
            // if new entry priority is lower than current entry priority, this is where it should be inserted
            if ( newEntry.priority < entry.priority ) {
                
                // insert entry, mark that it has been added, and leave the loop
                [ _schedulerList insertObject:newEntry atIndex:index ];
                hasBeenAdded = YES;
                break;
                
            }
            
            // manually keep track of position in fast iteration
            index ++;
            
        }
        
        // check if entry entry was added
        if ( hasBeenAdded == NO ) [ _schedulerList addObject:newEntry ];
        
    }
    
    // add to dictionary
    [ _schedulerDict setObject:newEntry forKey:[ self keyForSelector:newEntry.selector andTarget:newEntry.target ] ];


}

// ---------------------------------------------------------------------

@end





















































