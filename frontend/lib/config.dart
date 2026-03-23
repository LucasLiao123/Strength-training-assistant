// API 地址配置
// 部署时将 kApiBaseUrl 改为你的 Railway 后端地址，例如：
// const String kApiBaseUrl = 'https://your-app.railway.app';
// 本地开发时使用 localhost
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);
