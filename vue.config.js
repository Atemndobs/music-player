const { defineConfig } = require("@vue/cli-service");
module.exports = defineConfig({
  transpileDependencies: ["vuetify"]
});

module.exports = {
  chainWebpack: config => {
    config.module.rules.delete('eslint');
  },
  devServer: {
    port: 8080, // CHANGE YOUR PORT HERE!
    allowedHosts: [
        '*',
        'atemkeng.eu',
        'www.atemkeng.eu',
        'atemkeng.info',
    ]
  },
}