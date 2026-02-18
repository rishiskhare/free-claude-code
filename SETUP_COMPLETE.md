# Free Claude Code - Windows Setup Complete! 🎉

## ✅ What's Been Set Up

1. **Prerequisites Installed:**
   - ✅ PM2 (process manager)
   - ✅ uv (Python package runner)
   - ✅ fzf (fuzzy finder)

2. **Configuration:**
   - ✅ `.env` file created with your NVIDIA API key
   - ✅ Proxy server configured

3. **Proxy Server:**
   - ✅ Running on `http://localhost:8082`
   - ✅ Managed by PM2 (auto-restarts on failure)

## 🚀 How to Use

### Option 1: Command Line (CLI)

You can run the Claude Code CLI with free models using the batch file:

```cmd
cd C:\Users\Administrator\Downloads\free-claude-code
claude-free.bat
```

This will show you a list of available models to choose from.

**To make it accessible from anywhere:**

1. Add `C:\Users\Administrator\Downloads\free-claude-code` to your PATH:
   - Press `Win + X` and select "System"
   - Click "Advanced system settings"
   - Click "Environment Variables"
   - Under "User variables", select "Path" and click "Edit"
   - Click "New" and add: `C:\Users\Administrator\Downloads\free-claude-code`
   - Click "OK" on all dialogs

2. Then you can run from anywhere:
   ```cmd
   claude-free.bat
   ```

### Option 2: VSCode Extension

To use the Claude Code VSCode extension with the free proxy:

1. Install the [Claude Code VSCode extension](https://marketplace.visualstudio.com/items?itemName=anthropics.claude-code)

2. Open VSCode Settings (`Ctrl + ,`)

3. Search for `claude-code.environmentVariables`

4. Click **Edit in settings.json** and add:

```json
"claude-code.environmentVariables": [
  { "name": "ANTHROPIC_BASE_URL", "value": "http://localhost:8082" },
  { "name": "ANTHROPIC_AUTH_TOKEN", "value": "freecc" }
]
```

5. Reload VSCode or restart the extension

6. **If you see a login screen:** Click "Anthropic Console" and authorize. The extension will work even if you're redirected to buy credits - just ignore that page.

**To use a specific model in VSCode:**
Change the token to include the model ID:
```json
{ "name": "ANTHROPIC_AUTH_TOKEN", "value": "freecc:moonshotai/kimi-k2.5" }
```

## 🔧 Managing the Proxy Server

The proxy server is managed by PM2. Here are useful commands:

```cmd
# Check if the proxy is running
pm2 list

# View server logs (useful for troubleshooting)
pm2 logs claude-proxy

# Stop the proxy
pm2 stop claude-proxy

# Start the proxy
pm2 start claude-proxy

# Restart the proxy (e.g., after editing .env)
pm2 restart claude-proxy

# Make PM2 start on system boot
pm2 startup
pm2 save
```

## 📝 Available Models

Your setup includes access to multiple free models through NVIDIA NIM. The default model is `stepfun-ai/step-3.5-flash`, but you can choose from many others when using `claude-free.bat`.

To see all available models, check: `nvidia_nim_models.json`

## 🔑 API Key Management

Your NVIDIA API key is stored in `.env` file:
- Location: `C:\Users\Administrator\Downloads\free-claude-code\.env`
- Key variable: `NVIDIA_NIM_API_KEY`

If you need to change it:
1. Edit the `.env` file
2. Restart the proxy: `pm2 restart claude-proxy`

## ⚠️ Important Notes

1. **Claude Code CLI Installation:** You still need to install the official Claude Code CLI from Anthropic:
   - Visit: https://github.com/anthropics/claude-code
   - Follow their installation instructions
   - Once installed, the `claude` command will work with `claude-free.bat`

2. **Rate Limits:** NVIDIA NIM provides 40 free requests per minute

3. **Proxy Must Be Running:** The proxy server must be running for Claude Code to work. PM2 keeps it running automatically.

## 🐛 Troubleshooting

**Proxy won't start:**
```cmd
# Check what's using port 8082
netstat -ano | findstr :8082

# Kill the process if needed (replace PID with actual process ID)
taskkill /F /PID <PID>

# Restart the proxy
pm2 restart claude-proxy
```

**Can't find claude command:**
- Make sure you've installed the Claude Code CLI from Anthropic
- Check if it's in your PATH

**VSCode extension not working:**
- Make sure the proxy is running: `pm2 list`
- Check the environment variables in VSCode settings
- Try reloading VSCode

## 📚 Additional Resources

- Original Project: https://github.com/rishiskhare/free-claude-code
- Claude Code CLI: https://github.com/anthropics/claude-code
- NVIDIA NIM: https://build.nvidia.com/
- Get API Keys: https://build.nvidia.com/settings/api-keys

---

**Setup completed successfully!** 🎉

Your proxy server is running and ready to use. Start coding with Claude for free!
