/*
 * CGSMisc.h
 *
 * Created by Joe Ranieri on 7/23/07.
 * Copyright 2007 Alacatia Labs. All rights reserved.
 *
 */

#pragma once
#include "CGSInternal.h"

CG_EXTERN_C_BEGIN

/*! DOCUMENTATION PENDING */
CG_EXTERN CGError CGSFetchDirtyScreenRegion(CGSConnectionID cid, CGSRegionObj *outDirtyRegion);

/*! Is someone watching this screen? Applies to Apple's remote desktop only? */
CG_EXTERN bool CGSIsScreenWatcherPresent(void);

/*! Returns     `True` if the application has been deemed unresponsive for a certain amount of time. */
CG_EXTERN bool CGSEventIsAppUnresponsive(CGSConnectionID cid, const ProcessSerialNumber *psn);

/*! Sets the cursor position. */
CG_EXTERN CGError CGSWarpCursorPosition(CGSConnectionID cid, float x, float y);

/*! DOCUMENTATION PENDING */
CG_EXTERN CGError CGSHideBackstopMenuBar(CGSConnectionID cid);
CG_EXTERN CGError CGSShowBackstopMenuBar(CGSConnectionID cid);

/*! Determines if this computer is portable. Internally this just checks to see if it has a battery. */
CG_EXTERN bool CGSIsPortableMachine(void);

/*! Sets the area taken up by the dock. Requires the caller to be a universal owner. */
CG_EXTERN CGError CGSSetDockRect(CGSConnectionID cid, float x, float y, float width, float height);

/*! DOCUMENTATION PENDING - returns false. Perhaps related to the CGSTBE_QDACCEL env variable. */
CG_EXTERN bool CGSIsClassicBuffered(void);

#pragma mark errors
/* Logs an error and returns `err`. */
CG_EXTERN CGError CGSGlobalError(CGError err, const char *msg);

/* Logs an error and returns `err`. */
CG_EXTERN CGError CGSGlobalErrorv(CGError err, const char *msg, ...);

/*! Gets the error message for an error code. */
CG_EXTERN char *CGSErrorString(CGError error);

#pragma mark input
/*! Gets and sets the status of secure input. When secure input is enabled, keyloggers, etc are harder to do. */
CG_EXTERN bool CGSIsSecureEventInputSet(void);
CG_EXTERN CGError CGSSetSecureEventInput(CGSConnectionID cid, bool useSecureInput);

CG_EXTERN OSStatus CGSFindWindowByGeometry(int cid, int zero, int one, int zero_again,
										CGPoint *screen_point, CGPoint *window_coords_out,
										int *wid_out, int *cid_out);

CG_EXTERN_C_END