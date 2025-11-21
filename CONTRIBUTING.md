# PuzzleParty Development Workflow

## Branch Strategy

- `main` - Production branch (protected)
- `develop` - Main development branch (protected)
- `feature/*` - Feature branches (created from develop)
- `hotfix/*` - Emergency fixes (created from main)

## Development Process

### Starting New Work
```bash
# Always start from develop
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/your-feature-name
```
### Submitting Changes
```bash
# Push feature branch
git push origin feature/your-feature-name

# Create PR to develop branch (not main!)
# After review and merge, delete feature branch
```

### Releases
```bash
# Only when ready for production:
# Create PR from develop to main
# After merge to main, Laravel Cloud auto-deploys to production
```
### Rules
❌ Never push directly to main or develop
❌ Never create PRs to main from feature branches
✅ Always branch from develop
✅ Always PR to develop first
✅ Only PR to main from develop

## **6. IDE/Git Client Configuration**

### **VS Code Settings (add to `.vscode/settings.json`):**
```json
{
  "git.defaultCloneDirectory": "./",
  "git.branchProtection": ["main", "develop"],
  "git.suggestSmartCommit": false,
  "git.confirmSync": true,
  "git.showPushSuccessNotification": true
}
```
