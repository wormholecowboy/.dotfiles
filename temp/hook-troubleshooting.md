# Claude Code Hooks Troubleshooting

## Current Issue
Hooks configured in `.claude/settings.json` are not firing at all - the debug log file is never created.

## What We've Discovered
1. Settings file is correctly symlinked: `~/.claude/settings.json` → `~/.dotfiles/claude/.claude/settings.json`
2. Write permissions to `/tmp` are working
3. JSON syntax is valid
4. After multiple tool uses (Read tool x3), the log file was never created - hooks aren't executing

## What We Changed
1. Updated `PostToolUse` hook to write to a log file instead of using `say` for easier debugging
2. Standardized matcher syntax: changed `"matcher": "*"` to `"matcher": ""` for consistency with other hooks

### Original Hook
```json
"command": "say \"I'm Ready buddy\""
```

### Debug Hook (Current)
```json
"command": "echo \"Hook fired at $(date)\" >> /tmp/claude-hook-test.txt"
```

## Testing Steps

1. **Check hook registration first**:
   ```
   /hooks
   ```
   This shows which hooks Claude Code has loaded. If your hooks don't appear, there's a config issue.

2. **Restart Claude Code in debug mode**:
   ```bash
   claude --debug
   ```

3. **Use any tool** - Ask Claude to do something that uses a tool (e.g., "read a file", "run git status")

4. **Check if hook fired**:
   ```bash
   cat /tmp/claude-hook-test.txt
   ```

   - **If file exists with timestamps**: Hooks ARE working! The issue is with `say` in the hook context
   - **If file doesn't exist**: Hooks are NOT executing at all (current status)

## Next Steps Based on Results

### If hooks ARE working (file exists):
- The `say` command might not work in the hook execution context
- Try using `afplay` with a sound file instead
- Or use `osascript -e 'display notification "Hook fired"'` for notifications

### If hooks are NOT working (no file):
- Verify settings.json is in the correct location: `~/.dotfiles/claude/.claude/settings.json`
- Check if there's another settings file taking precedence
- Look for Claude Code error logs
- Check if hooks feature is enabled in your Claude Code version

## Current Hook Configuration

Your settings.json has 3 hooks configured:
- **Notification**: `say "Claude code needs your attention"` (matcher: `""`)
- **Stop**: `say "I'm Ready"` (matcher: `""`)
- **PostToolUse**: Writes to `/tmp/claude-hook-test.txt` (matcher: `""` - changed from `"*"`)

All hooks now use consistent empty string matcher syntax.

## Restore Original Hooks

Once debugging is complete, restore the original `say` command or switch to:
```json
"command": "osascript -e 'beep'"
```
