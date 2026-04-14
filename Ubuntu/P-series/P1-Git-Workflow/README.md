# P1 - Git Workflow

# P1 - Git Workflow

## What is Git Workflow?
Git workflow is the practice of using Git branching, merging, rebasing, and tagging strategies to manage code changes in a team environment. It defines how developers collaborate on a shared codebase without breaking each other's work.

## Why It Matters?
- **Collaboration** - multiple engineers can work on the same codebase simultaneously without conflicts
- **Safety** - feature branches protect main/production from broken code
- **History** - clean commit history makes it easy to track what changed, when, and why
- **Interview relevance** - branching, conflict resolution, and undoing mistakes are standard Junior DevOps interview topics

## Key Concepts

| Term | Meaning |
|------|---------|
| Feature Branch | An isolated branch for a specific task — keeps main safe |
| git stash | Temporarily saves uncommitted changes into a stack without committing |
| git stash pop | Restores the last stashed changes back to the working directory |
| git rebase | Replays your branch commits on top of another branch for clean linear history |
| git merge | Combines two branches — can create a merge commit |
| Merge Conflict | When two branches edit the same lines — Git stops and asks you to decide |
| git reset --soft | Removes last commit but keeps file changes |
| git reset --hard | Removes last commit AND deletes file changes permanently |
| git revert | Creates a new commit that undoes a previous commit — history is preserved |
| git tag -a | Annotated tag — stores who tagged it, when, and a message |
| HEAD~1 | One commit behind the current HEAD |
| Conventional Commits | Commit message format: feat:, fix:, docs: — makes history readable |

## Core Commands

```bash
# Create and switch to a feature branch
git checkout -b feature/branch-name

# Check current branch
git branch

# Stash uncommitted changes
git stash

# Restore stashed changes
git stash pop

# Rebase current branch on top of main
git rebase main

# Continue rebase after resolving conflict
git rebase --continue

# Abort rebase
git rebase --abort

# Undo last commit, keep file changes
git reset --soft HEAD~1

# Undo last commit, delete file changes
git reset --hard HEAD~1

# Safely undo a pushed commit
git revert HEAD

# Create an annotated tag
git tag -a v1.0 -m "release message"

# Push tag to remote
git push origin v1.0

# View recent log
git log --oneline -5
```

### Scenario Practised

### Scenario 1 - Feature Branch and Merge Conflict
**Problem:** Two branches edited the same file - Git cannot auto-merge.
**Investigate:** Ran `cat P1-notes.txt` - saw conflict markers `<<<<<<<`, `=======`, `>>>>>>>`.
**Fix:** Manually Kept both versions, removed markers, then:
```bash
git add p1-notes.txt
git commit -m "fix: resolve merge conflict in P1-notes"
```
**Key lesson:** Git stops at conflicts and asks you to decide. You pick what to keep, remove the markers, then commit.

### Scenario 2 - git stash
**Problem:** Had uncommitted work in progress but needed a clean working directory to switch context.
**Fix:**
```bash
git stash	# parks the changes
git stash pop	#brings them back
```
**Key lesson:** `git stash` saves to a stack. `stack pop` restores AND removes from stack. `stash apply` restores but keeps it in the stack.

### Scenario 3 - git rebase
**Problem:** Feature branch was behind main by several commits - needed clean linear history merging.
**Fix:**
```bash
git checkout feature/rebase-demo
git rebase main
# resolved conflict, then:
git rebase --continue
```
**Key lesson:** Rebase replants your branch commits on top of the latest main. Result is linear with no merge commit. 

## Scenario 4 - git reset vs git revert
**Problem:** Bad commit made - needed to undo it safely.

**Reset --soft (not yet pushed):**
```bash
git reset --soft HEAD~1		# commit gone, file changes kept
```

**reset --hard (not yet pushed, want changes gone too):**
```bash
git reset --hard HEAD~1		# commit gone, file changes deleted

**reset (already pushed to remote):**
```bash
git revert HEAD			# new commit added that undoes the bad commit
```
**Key lesson:** Never use reset on pushed commits - it rewrites history and breaks trammates' copies. Always use revert on shared branches.

### Sceanrio 5 - Annotated Tagging
**Problem:** Need to mark a release point in the repo.
**Fix:**
```bash
git tag -a v1.1 -m "P1 complete - git workflow"
git push origin v1.1
```
**key lesson:** `git tag -a` stores metadata (who, when, message). Plain `git tag` is just a pointer with no extra info. Teams always use annotated tags for releases.

## Key Commands Table

| Command | What it does |
|---------|-------------|
| `git checkout -b branch` | Create and switch to new branch |
| `git stash` | Save uncommitted work to stack |
| `git stash pop` | Restore from stack and remove entry |
| `git rebase main` | Replay branch commits on top of main |
| `git reset --soft HEAD~1` | Undo commit, keep changes |
| `git reset --hard HEAD~1` | Undo commit, delete changes |
| `git revert HEAD` | New commit that undoes last commit |
| `git tag -a v1.0 -m ""` | Create annotated release tag |
| `git log --oneline -5` | View last 5 commits in short format |

## Golden Rules
- **Never commit directly to main** - always use a feature branch
- **Never use git reset on pushed commits** - use git revert instead
- **Always use git tag -a** - for release, not plain git tag
- **Use Conventional Commits** - flat:, fix:, docs: prefixes in every commit message
- **Rebase before merging** - Keeps history clean ad linear

## Skills Gained
- Creating and managing feature branches
- Identifying and resolving merge conflicts manually
- Using git stash to park work and restore it
- Understanding git rebase and when to use it over merge
- Knowing the difference betweeen reset --soft, reset --hard, and revert
- Tagging releases with annotated tags
- Writing clean commit messages using Conventional Commits format

## Environment Used

| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Lab Node | Ubuntu 24.04 VM on VirtualBox (CLI only) |
| Remote Repo | github.com/sachin-linux/linux-admin-homelab |
| Key Tools | git, nano |
- Understanding 
