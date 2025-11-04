---
name: tilt-debug
description: Debug Tilt applications by accessing the Tilt web UI at localhost:10350. This skill should be used when users request to debug Tilt apps, investigate resource issues, view logs, or troubleshoot build and deployment problems. Triggered by requests mentioning Tilt debugging, resource names, or error investigation.
---

# Tilt Debug

## Overview

This skill enables debugging of Tilt applications through the Tilt web UI (localhost:10350) using Chrome DevTools MCP. It provides capabilities to view resource status, access logs, and diagnose build and deployment issues.

## When to Use This Skill

Use this skill when users request to:
- Debug a Tilt application or specific resources
- View logs for Tilt resources
- Investigate why a service or resource is failing in Tilt
- Check the status or health of Tilt resources
- Troubleshoot build or deployment issues in Tilt

Typical user requests include:
- "Debug my Tilt app"
- "Show me the logs for [resource-name] in Tilt"
- "Why is [service-name] failing in Tilt?"
- "What's wrong with my Tilt deployment?"

## Debugging Workflow

### 1. Access the Tilt Web UI

Start by accessing the Tilt web UI at `http://localhost:10350`:

```
Use mcp__chrome-devtools__navigate_page or mcp__chrome-devtools__new_page to navigate to http://localhost:10350
```

If the page fails to load, verify that:
- Tilt is actually running (user should have started it with `tilt up`)
- The URL is accessible on localhost:10350 (this is Tilt's default port)

### 2. Take a Snapshot and Identify Resources

After the page loads, take a snapshot to understand the UI structure:

```
Use mcp__chrome-devtools__take_snapshot to see the page structure
```

The Tilt UI typically displays:
- A list of resources (services, containers, jobs, etc.) on the left sidebar or main panel
- Each resource shows its current status (running, error, building, etc.)
- Resource names, build status, and runtime status

Identify the target resource by:
- Looking for the resource name mentioned by the user
- Checking resource status indicators (errors, warnings, success)
- Noting any resources with error states if the user asked for general debugging

### 3. Navigate to Resource Details

Click on the target resource to view its detailed information:

```
Use mcp__chrome-devtools__click with the resource's uid from the snapshot
```

Resource detail pages typically include:
- **Build logs**: Output from building the resource (Docker builds, etc.)
- **Runtime logs**: Output from the running container/service
- **Resource status**: Current state, pod information, endpoints
- **Errors**: Highlighted error messages and stack traces

### 4. Extract and Analyze Logs

Once on the resource detail page:

1. **Take another snapshot** to see the log content and structure
2. **Look for error patterns**:
   - Build failures (compilation errors, missing dependencies, Docker errors)
   - Runtime errors (application crashes, connection failures)
   - Resource state issues (CrashLoopBackOff, ImagePullBackOff, etc.)
3. **Scroll through logs if needed** using `mcp__chrome-devtools__evaluate_script` to scroll or expand log sections
4. **Extract relevant error messages** and present them to the user

### 5. Check Multiple Resources (if needed)

If debugging the entire Tilt app rather than a specific resource:
- Navigate back to the resource list
- Identify all resources with error states
- Repeat steps 3-4 for each problematic resource

### 6. Provide Diagnostic Summary

Present findings to the user including:
- Resource name and current status
- Relevant error messages from logs
- Specific build or runtime failures
- Potential causes and suggested fixes (based on error patterns)

## Common Tilt Issues and Patterns

### Build Failures
- Docker build errors (missing files, syntax errors in Dockerfile)
- Compilation errors in source code
- Missing dependencies or packages
- Registry authentication issues

### Runtime Failures
- Application crashes or startup errors
- Port conflicts or binding issues
- Configuration errors (missing environment variables, bad config files)
- Connection failures to dependencies (databases, APIs)

### Kubernetes Issues
- Pod status: CrashLoopBackOff, ImagePullBackOff, Pending
- Resource constraints (CPU, memory limits)
- Volume mount issues
- Service networking problems

## Using Chrome DevTools MCP Effectively

### Key Tools for Tilt Debugging

1. **take_snapshot**: Primary tool for viewing page content and UI structure
2. **click**: Navigate between resources and expand log sections
3. **evaluate_script**: Scroll through logs or interact with dynamic elements
4. **wait_for**: Wait for log content to load after navigation

### Navigation Pattern

```
1. Navigate to localhost:10350
2. Take snapshot to see resource list
3. Click on target resource
4. Wait for logs to load (if needed)
5. Take snapshot to read logs
6. Repeat for additional resources
```

## Tilt Documentation Reference

For understanding Tilt concepts and configuration:
- Main documentation: https://docs.tilt.dev/
- Tiltfile authoring: https://docs.tilt.dev/tiltfile_authoring.html

Use WebFetch to retrieve documentation when users ask about:
- Tiltfile configuration issues
- How to configure specific Tilt features
- Tilt API or function reference

## Tips for Effective Debugging

1. **Be specific**: If the user mentions a resource name, focus on that resource first
2. **Look for patterns**: Multiple failing resources might indicate a common root cause
3. **Check timestamps**: Recent log entries are usually most relevant for current issues
4. **Differentiate build vs runtime**: Build errors happen during image creation, runtime errors happen when the container runs
5. **Note dependencies**: A failing database resource might cause dependent services to fail
