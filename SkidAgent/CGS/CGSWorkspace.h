/*
 * CGSWorkspace.h
 *
 * Created by Joe Ranieri on 7/23/07.
 * Copyright 2007 Alacatia Labs. All rights reserved.
 *
 */

#pragma once
#include "CGSConnection.h"
#include "CGSWindow.h"
#include "CGSTransitions.h"

typedef unsigned int CGSWorkspaceID;


CG_EXTERN_C_BEGIN

/*! Gets and sets the current workspace. */
CG_EXTERN CGError CGSGetWorkspace(CGSConnectionID cid, CGSWorkspaceID *outWorkspace);
CG_EXTERN CGError CGSSetWorkspace(CGSConnectionID cid, CGSWorkspaceID workspace);

/*! Transitions to a workspace asynchronously. Note that `duration` is in seconds. */
CG_EXTERN CGError CGSSetWorkspaceWithTransition(CGSConnectionID cid, CGSWorkspaceID workspace, CGSTransitionType transition, CGSTransitionOption options, float duration);

/*! Gets and sets the workspace for a window. */
CG_EXTERN CGError CGSGetWindowWorkspace(CGSConnectionID cid, CGSWindowID wid, CGSWorkspaceID *outWorkspace);
CG_EXTERN CGError CGSSetWindowWorkspace(CGSConnectionID cid, CGSWindowID wid, CGSWorkspaceID workspace);

CG_EXTERN_C_END