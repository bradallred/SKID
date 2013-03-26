/*
* CGSCursor.h
*
* Created by Joe Ranieri on 7/23/07.
* Copyright 2007 Alacatia Labs. All rights reserved.
*
*/

#pragma once
#include "CGSConnection.h"

typedef int CGSCursorID;


CG_EXTERN_C_BEGIN

/*! Does the system support hardware cursors? */
CG_EXTERN CGError CGSSystemSupportsHardwareCursor(CGSConnectionID cid, bool *outSupportsHardwareCursor);

/*! Does the system support hardware color cursors? */
CG_EXTERN CGError CGSSystemSupportsColorHardwareCursor(CGSConnectionID cid, bool *outSupportsHardwareCursor);

/*! Shows the cursor. */
CG_EXTERN CGError CGSShowCursor(CGSConnectionID cid);

/*! Hides the cursor. */
CG_EXTERN CGError CGSHideCursor(CGSConnectionID cid);

/*! Hides the cursor until the mouse is moved. */
CG_EXTERN CGError CGSObscureCursor(CGSConnectionID cid);

/*! Gets the cursor location. */
CG_EXTERN CGError CGSGetCurrentCursorLocation(CGSConnectionID cid, CGPoint *outPos);

/*! Gets the name (in reverse DNS form) of a system cursor. */
CG_EXTERN char *CGSCursorNameForSystemCursor(CGSCursorID cursor);

/*! Gets the size of the data for the connection's cursor. */
CG_EXTERN CGError CGSGetCursorDataSize(CGSConnectionID cid, int *outDataSize);

/*! Gets the data for the connection's cursor. */
CG_EXTERN CGError CGSGetCursorData(CGSConnectionID cid, void *outData);

/*! Gets the size of the data for the current cursor. */
CG_EXTERN CGError CGSGetGlobalCursorDataSize(CGSConnectionID cid, int *outDataSize);

/*! Gets the data for the current cursor. */
CG_EXTERN CGError CGSGetGlobalCursorData(CGSConnectionID cid, void *outData, int *outRowBytes, CGRect *outRect, CGRect *outHotSpot, int *outDepth, int *outComponents, int *outBitsPerComponent);

/*! Gets the size of data for a system-defined cursor. */
CG_EXTERN CGError CGSGetSystemDefinedCursorDataSize(CGSConnectionID cid, CGSCursorID cursor, int *outDataSize);

/*! Gets the data for a system-defined cursor. */
CG_EXTERN CGError CGSGetSystemDefinedCursorData(CGSConnectionID cid, CGSCursorID cursor, void *outData, int *outRowBytes, CGRect *outRect, CGRect *outHotSpot, int *outDepth, int *outComponents, int *outBitsPerComponent);

/*! Gets the cursor 'seed'. Every time the cursor is updated, the seed changes. */
CG_EXTERN int CGSCurrentCursorSeed(void);

/*! Shows or hides the spinning beachball of death. */
CG_EXTERN CGError CGSForceWaitCursorActive(CGSConnectionID cid, bool showWaitCursor);

CG_EXTERN_C_END