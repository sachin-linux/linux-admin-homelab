# D1 – Git & GitHub

## Objective

Learn the fundamentals of version control using Git and how repositories are managed and shared through GitHub.

---

## Topics Covered
- Initializing a Git repository
- Tracking file changes
- Creating commits
- Working with branches
- Merging branches
- Pushing code to GitHub

 
---


## What is Version Control

Version control is a system that records changes to files over time.

Without version control, file management looks like this:
```
script.sh 
script_v2.sh 
script_final.sh 
script_final_final.sh 
```
Version control systems solve this by keeping a structured history of changes.

**Benefits:**
- Track full hitory of changes
- Collaborate with other developers
- Revert mistakes
- Maintain different versions of a project


---


## What is Git
Git is a distributed version control system used by developers and DevOps engineers.

- Distributed architecture - every developer has a full copy of the repository
- Fast and lightweight
- Tracks file changes
- Supports branching and merging
- Maintains full project history


---


## What is GitHub
GitHub is a cloud platform used to host Git repositories.

- Store code remotely
- Collaborate with teams
- Review code through pull requests
- Track issues
- Integrate CI/CD pipelines


---


## Git Workflow
```
Working Directory
       ↓
  Staging Area
       ↓
     Commit
       ↓
Remote Repository (GitHub)
```

---


## Key Commands
| Command | Purpose |
|---------|---------|
| `git init` | Initialize a repository |
| `git status` | Check repository status |
| `git add <file>` | Add file to staging area |
| `git commit -m "message"` | Commit changes |
| `git log` | View commit history |
| `git branch <name>` | Create a branch |
| `git checkout <branch>` | Switch branch |
| `git merge <branch>` | Merge branch into current |
| `git push` | Push to remote repository |


---

## Lab Exercise


### Step 1 – Navigate to Lab Folder
```bash
cd ~/linux-admin-homelab/Ubuntu/D-series/D1-Git-GitHub
```

### Step 2 – Initialize Git Repository
```bash
git init
ls -a 	# Verify .git folder exists
```

### Step 3 – Create README File
```bash
nano README.md
```

### Step 4 – Check Git Status
```bash
git status 	# Shows README.md as untracked
```

### Step 5 – Stage File
```bash
git add README.md
git status	# Shows: Changes to be committed
```

### Step 6 – Commit Changes
```bash
git commit -m "Initial commit"
git log
```

### Step 7 – Create Deployment Script
```bash
nano deploy.sh
```
```bash
#!/bin/bash
echo "Deploying application"
date
```
```bash
chmod +x deploy.sh
```

### Step 8 – Commit Script
```bash
git add deploy.sh
git commit -m "Add deployment script"
```

### Step 9 – Create Branch
```bash
git branch feature-update
git branch 	# Verify branch exists
```

### Step 10 – Switch Branch
```bash
git checkout feature-update
# Modify the script and commit changes.
```

### Step 11 – Merge Branch
```bash
git checkout main
git merge feature-update
```

### Step 12 – Connect to GitHub
```bash
git remote add origin https://github.com/YOUR_USERNAME/linux-admin-homelab.git
git remote -v	#Verify remote
```

### Step 13 – Push Repository
```bash
git push -u origin main
```

---


## Expected Repository Structure
```
D1-Git-GitHub
│
├── README.md
└── deploy.sh
```

----------------------------------------------------


## Skills Learned

- Git repository initialization
- File tracking and commits
- Branch creation and switching
- Branch merging
- Connecting repository to GitHub
- Pushing code to remote repository


---


# Environment Used 
| Component | Detail |
|-----------|--------|
| Host Machine | Kali Linux |
| Lab Machine | Ubuntu Linux VM on VirtualBox |
| Interface | Linux CLI |
