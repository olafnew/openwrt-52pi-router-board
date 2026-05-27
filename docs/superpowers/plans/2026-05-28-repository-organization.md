# Repository Organization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a public-safe local repository skeleton for the 52Pi OpenWrt firmware project.

**Architecture:** The maintained git repo lives in `\\192.168.1.2\Development\Software\OpenWRT\openwrt-52pi-router-board`. Old builds, private files, and large artifacts stay in sibling archive/reference folders outside git.

**Tech Stack:** Git, GitHub CLI, PowerShell for Windows/NAS filesystem management, Debian VM for later OpenWrt builds.

---

### Task 1: Verify NAS layout

**Files:** none

- [x] Confirm top-level archive/reference folders exist.
- [x] Confirm `openwrt-52pi-router-board` starts empty before scaffolding.
- [x] Confirm private files are outside the repository.

### Task 2: Create publishable skeleton

**Files:**

- Create: `README.md`
- Create: `.gitignore`
- Create: `docs/*.md`
- Create: `profiles/README.md`
- Create: `scripts/README.md`
- Create: `files/README.md`
- Create: `patches/README.md`

- [x] Create documentation and placeholder directories.
- [x] Create README with project purpose, profiles, credits, and donation addresses.
- [x] Create source inventory and security guardrails.
- [x] Create OLED, package, partition, build, and testing docs.

### Task 3: Initialize git and publish

**Files:** git metadata only

- [ ] Initialize local git repository.
- [ ] Commit initial skeleton.
- [ ] Create `olafnew/openwrt-52pi-router-board` if it does not exist.
- [ ] Push initial branch.

### Task 4: Next engineering step

**Files:** future scripts and configs

- [ ] Export redacted running-router source-of-truth data.
- [ ] Reconcile production router state with March rc5 script.
- [ ] Implement current-stable OpenWrt build scripts.
- [ ] Build on Debian VM.
- [ ] Test on spare board.
