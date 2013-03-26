/*
 * CGSSession.h
 *
 * Created by Joe Ranieri on 7/23/07.
 * Copyright 2007 Alacatia Labs. All rights reserved.
 *
 */

#pragma once
#include "CGSInternal.h"

typedef int CGSSessionID;

CG_EXTERN_C_BEGIN

/*! Gets information about the current login session. Keys as of 10.4:
 kCGSSessionGroupIDKey
 kCGSSessionOnConsoleKey
 kCGSSessionIDKey
 kCGSSessionUserNameKey
 kCGSessionLoginDoneKey
 kCGSessionLongUserNameKey
 kCGSSessionSystemSafeBoot
 kCGSSessionLoginwindowSafeLogin
 kCGSSessionConsoleSetKey
 kCGSSessionUserIDKey
 */
CG_EXTERN CFDictionaryRef CGSCopyCurrentSessionDictionary(void);

/*! Creates a new "blank" login session. Switches to the LoginWindow. This does NOT check to see if fast user switching is enabled! */
CG_EXTERN CGError CGSCreateLoginSession(CGSSessionID *outSession);

/*! Releases a session. */
CG_EXTERN CGError CGSReleaseSession(CGSSessionID session);

/*! Gets a list of sessions. Each session dictionary is in the format returned by `CGSCopyCurrentSessionDictionary`. */
CG_EXTERN CFArrayRef CGSCopySessionList(void);

CG_EXTERN_C_END