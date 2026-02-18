module.exports = {
  apps: [{
    name: 'claude-proxy',
    script: 'C:\\Users\\Administrator\\.local\\bin\\uv.exe',
    args: 'run uvicorn server:app --host 0.0.0.0 --port 8082',
    cwd: 'C:\\Users\\Administrator\\Downloads\\free-claude-code',
    interpreter: 'none',
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production'
    }
  }]
};
