# How to Create a Branch on PracticeRepo Using VS Code

This guide will walk you through creating a new branch on the PracticeRepo repository using Visual Studio Code.

## Prerequisites

Before you begin, ensure you have:

- Git installed on your machine
- Visual Studio Code installed
- Access to the repository: `https://github.com/NathiDEV-dot/PracticeRepo.git`

## Step 1: Clone the Repository

Open VS Code and clone the repository:

1. Open the integrated terminal in VS Code (`` Ctrl+` `` or `Cmd+` ` on Mac)
2. Run the following command:
```bash
git clone https://github.com/NathiDEV-dot/PracticeRepo.git
```
3. Navigate into the repository:
```bash
cd PracticeRepo
```
4. Open the folder in VS Code: `File > Open Folder` and select the PracticeRepo folder

## Step 2: Create a New Branch

### Method 1: Using the Command Palette (Recommended)

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Type `Git: Create Branch` and select it
3. Enter a name for your new branch (e.g., `feature/my-feature` or `bugfix/issue-name`)
4. Press Enter

Your new branch will be created and automatically checked out.

### Method 2: Using the Source Control Sidebar

1. Look for the Source Control icon on the left sidebar (it looks like a branch icon)
2. Click on it to open the Source Control panel
3. At the top of the panel, you'll see the current branch name
4. Click the three dots menu (`...`) at the top right
5. Select `Branch` → `Create Branch`
6. Enter your branch name and press Enter

### Method 3: Using the Terminal

In the integrated terminal, run:
```bash
git checkout -b your-branch-name
```

Replace `your-branch-name` with your desired branch name (e.g., `feature/new-feature`).

## Step 3: Verify Your Branch

You can verify that you've successfully created and switched to the new branch:

- Look at the bottom-left corner of VS Code—you'll see the current branch name
- Or run in the terminal:
```bash
git branch
```

The branch with an asterisk (`*`) is your current branch.

## Step 4: Make Changes and Commit

1. Make your changes to the files in the repository
2. Stage your changes in the Source Control panel or run:
```bash
git add .
```
3. Commit your changes:
```bash
git commit -m "Your commit message"
```

## Step 5: Push Your Branch to GitHub

Once you've committed your changes, push your branch to the remote repository:

```bash
git push origin your-branch-name
```

Replace `your-branch-name` with the name of your branch.

## Best Practices for Branch Naming

- Use lowercase letters
- Separate words with hyphens (`-`)
- Include a type prefix: `feature/`, `bugfix/`, `hotfix/`, or `docs/`
- Be descriptive but concise

**Examples:**
- `feature/user-authentication`
- `bugfix/login-error`
- `docs/update-readme`
- `hotfix/critical-patch`

## Switching Between Branches

To switch between existing branches:

1. Click on the branch name at the bottom-left corner of VS Code
2. Select the branch you want to switch to from the dropdown menu

Or use the terminal:
```bash
git checkout branch-name
```

## Troubleshooting

**Issue: "fatal: pathspec 'branch-name' did not match any file(s)"**
- Make sure you're in the correct directory and use `git checkout -b` to create a new branch

**Issue: Uncommitted changes prevent switching branches**
- Commit or stash your changes first:
```bash
git stash
```

## Next Steps

- Create a pull request (PR) on GitHub to merge your branch into the main branch
- Keep your branch up-to-date with the main branch by pulling changes regularly
- Delete your branch after it's been merged to keep the repository clean

## Additional Resources

- [Git Documentation](https://git-scm.com/doc)
- [VS Code Git Support](https://code.visualstudio.com/docs/editor/versioncontrol)
- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)
