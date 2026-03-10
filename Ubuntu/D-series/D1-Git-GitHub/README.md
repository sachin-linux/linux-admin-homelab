# D1 – Git & GitHub

## Objective

Learn the fundamentals of version control using Git and how repositories are managed and shared through GitHub.

This module demonstrates:

- Initializing a Git repository
- Tracking file changes
- Creating commits
- Working with branches
- Merging branches
- Pushing code to GitHub

 
----------------------------------------------------

## What is Version Control

Version control is a system that records changes to files over time.

Benefits:

- Track history of changes
- Collaborate with other developers
- Revert mistakes
- Maintain different versions of a project

Example problem without version control:

script.sh 
script_v2.sh 
script_final.sh 
script_final_final.sh 

Version control systems solve this by keeping a structured history of changes.


----------------------------------------------------

## What is Git

Git is a distributed version control system used by developers and DevOps engineers.

Key characteristics:

- Distributed architecture
- Fast and lightweight
- Tracks file changes
- Supports branching and merging
- Maintains full project history

Each developer has a full copy of the repository.


----------------------------------------------------

## What is GitHub

GitHub is a cloud platform used to host Git repositories.

It allows developers to:

- Store code remotely
- Collaborate with teams
- Review code through pull requests
- Track issues
- Integrate CI/CD pipelines


----------------------------------------------------

## Git Workflow

Typical Git workflow:

Working Directory
        ↓
Staging Area
        ↓
Commit
        ↓
Remote Repository (GitHub)

Steps:

1. Modify files
2. Add files to staging area
3. Commit changes
4. Push to remote repository


----------------------------------------------------

## Common Git Commands

Initialize repository

git init

Check repository status

git status

Add file to staging

git add filename

Commit changes

git commit -m "message"

View commit history

git log

Create branch

git branch branch-name

Switch branch

git checkout branch-name

Merge branch

git merge branch-name

Push to GitHub

git push


----------------------------------------------------

## Lab Exercise


### Step 1 – Navigate to Lab Folder

cd ~/linux-admin-homelab/Ubuntu/D-series/D1-Git-GitHub


### Step 2 – Initialize Git Repository

git init

Expected output:

Initialized empty Git repository


Verify:

ls -a

You should see:

.git


----------------------------------------------------

### Step 3 – Create README File

Create a documentation file.

nano README.md


----------------------------------------------------

### Step 4 – Check Git Status

git status

Expected output:

Untracked files:
README.md


----------------------------------------------------

### Step 5 – Stage File

git add README.md

Verify:

git status

Expected:

Changes to be committed


----------------------------------------------------

### Step 6 – Commit Changes

git commit -m "Initial commit"

Check history:

git log


----------------------------------------------------

### Step 7 – Create Deployment Script

nano deploy.sh

Add the following content:

#!/bin/bash

echo "Deploying application"
date


Make it executable:

chmod +x deploy.sh


----------------------------------------------------

### Step 8 – Commit Script

git add deploy.sh

git commit -m "Add deployment script"


----------------------------------------------------

### Step 9 – Create Branch

git branch feature-update

Check branches:

git branch


----------------------------------------------------

### Step 10 – Switch Branch

git checkout feature-update

Modify the script and commit changes.


----------------------------------------------------

### Step 11 – Merge Branch

git checkout main

git merge feature-update


----------------------------------------------------

### Step 12 – Connect to GitHub

git remote add origin https://github.com/YOUR_USERNAME/linux-admin-homelab.git

Verify remote:

git remote -v


----------------------------------------------------

### Step 13 – Push Repository

git push -u origin main


----------------------------------------------------

## Expected Repository Structure

D1-Git-GitHub
│
├── README.md
└── deploy.sh


----------------------------------------------------

## Skills Learned

- Git repository initialization
- File tracking and commits
- Branch creation and switching
- Branch merging
- Connecting repository to GitHub
- Pushing code to remote repository

These skills form the foundation of DevOps workflows where code and infrastructure are managed using version control.

---

# Environment Used 
Ubuntu Linux
VirtualBox
Linux CLI tools
