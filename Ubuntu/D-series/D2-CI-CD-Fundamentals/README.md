D2 - CI/CD Fundamentals
Objective
Learn teh fundamentals of Continuous Integration and Continuous Deployment using GitHub Actions.

This module demonstrates:

Understand what CI/CD is and why companies use it
Building a real pipeline from scratch
Triggerring pipelines automatically on code push
Handling pipeline failures
Running a Python app through a CI pipeline
What is CI/CD
CI/CD stands for continous Integration and Continuous Deployment

it is a DevOps practice that automates building, testing, and deploying applications

Without CI/CD:

Developers manually build, test, and deploy code
Human errors cause production failures
Releases are slow and risky
CI/CD solves this by automating the entire process.

Continuous Integration (CI)
CI means every time a developer pushes code, it is automatically:

Built
Tested
Validated
Goal: Catch bugs early before they reach production.

Continuous Delivery vs Continuous Deployment
Continuous Delivery	Continuous Deployment
Tests pass	Code is ready to deploy	Code deploys automatically
Human approval	Required	Not required
Risk	Lower	Higher
CI/CD Pipeline Stages
Code Push -> Build -> Test -> Deploy 
Each stage runs automatically one after another. If any stage fails, the pipeline stops and notifies the team.

What is GitHub Actions
GitHub Actions is a CI/CD platform built into GitHub

It allows you to:

Define pipelines using YAML files
Trigger pipelines on code push, pull requests, or schedules
Run pipelines on cloud Ubuntu servers
See results directly in your GitHub repository
Pipeline Structure
name: Pipeline name

on: 
  Push:
    Branches:
      - main

jobs:
  job-name:
    runs-on: Ubuntu-latest

    steps:
      - name: Step name 
        run: command
Key components:

name - Name of the pipeline
on - What triggers the pipeline
runs-on - What server to run on
steps - Commands to execute one by one
Lab
Step 1 - Create workflow file

.github/workflows/main.yml
Step 2 - Write basic pipelines

name: My first CI Pipeline

on: 
  push:
    branches:
      - main

jobs:
  build-and-test:
    runs-on: Ubuntu-latest

    steps:
      - name: Checkout code
	uses: actions/checkout@v3

      - name: Say Hello
	run: echo "Pipeline is working!"
   
      - name: Check Linux version
	run: uname -a 

- name: List files in repo
        run: ls -la
Step 3 — Commit and trigger pipeline

Push code to main branch and verify pipeline runs in Actions tab.

Step 4 — Deliberately break the pipeline

Add a failing step:

- name: Deliberate failure
  run: cat nonexistentfile.txt
Observe pipeline stops at the failed step with red X.

Step 5 — Fix and restore pipeline

Remove the failing step and push again. Verify pipeline returns to green.

Step 6 — Build Python CI pipeline independently

Create app.py:

print("App is running successfully!")
Write pipeline from scratch:

name: Python CI Pipeline

on:
  push:
    branches:
      - main

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Run the app
        run: python3 app.py

      - name: Check python version
        run: python3 --version

      - name: List files in repo
        run: ls -la
Verify output:

App is running successfully!
Python 3.12.3
Skills Learned
CI/CD concepts and pipeline stages
Difference between Continuous Delivery and Deployment
GitHub Actions pipeline structure and YAML syntax
Triggering pipelines automatically on code push
Debugging and fixing pipeline failures
Building a Python CI pipeline independently
Key Takeaway
CI/CD is not just theory. It is a real automated system that protects production from broken code by catching failures early in the pipeline. Every push triggers a fresh Ubuntu server in the cloud that runs your steps automatically.

Environment Used
Kali Linux host
GitHub Actions cloud runner
Ubuntu Latest (GitHub hosted)
Python 3.12.3
GitHub CLI / Web UI
