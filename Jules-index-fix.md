# Task: External Drive Indexing & Explorer Optimization

## Context
The user is experiencing significant lag, File Explorer crashes, and slow video playback when using an external drive. The goal is to streamline indexing and ensure stable video thumbnail performance.

## Part 1: System Optimization Prompt
> **Objective:** Write a PowerShell script to fix system bottlenecks.
>
> 1. **Rebuild Search Index:** Clear and restart the Windows Search service.
> 2. **Exclusion Logic:** Add the external drive to indexing exclusions to prevent constant background scanning.
> 3. **Folder Template:** Set the external drive's optimization to 'General Items' instead of 'Videos' to prevent deep metadata polling.
> 4. **Cache Maintenance:** Flush the File Explorer history and current thumbnail/icon cache.

## Part 2: Permanent Thumbnail Cache Prompt
> **Objective:** Ensure video thumbnails are stored permanently and not deleted by Windows.
>
> 1. **Disable SilentCleanup:** Provide commands to disable the `SilentCleanup` task in Task Scheduler.
> 2. **Registry Tweak:** Set `Autorun` to `0` in `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache`.
> 3. **Icaros Integration:** Explain how to configure Icaros for faster, more stable thumbnail generation for large video libraries.

## Part 3: Execution Instructions
* Provide code in a single, runnable PowerShell script.
* Include comments for each section.
* Ensure the script prompts for the External Drive letter before applying drive-specific changes.
