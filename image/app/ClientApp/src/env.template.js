(function (window) {
    window.__env = window.__env || {};
  
    window.__env.apiUrl = '${WEB_API_URL}';
    window.__env.appEnvironment = '${APP_ENVIRONMENT}';
    window.__env.hostname = '${HOSTNAME}';
    window.__env.githubUrl = '${GITHUB_URL}';
  }(this));