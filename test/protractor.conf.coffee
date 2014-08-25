exports.config =
  allScriptsTimeout: 11000
  #seleniumServerJar: "../node_modules/protractor/selenium/selenium-server-standalone-2.42.2.jar"

  multipleCapabilities : [
      {
        browserName : "chrome"
      },
      {
        browserName : "firefox"
      }
  ]

  baseUrl: "http://localhost:9999"

  specs: ["e2e/*_spec.js", "e2e/*_spec.coffee"]

  framework: "jasmine"

  jasmineNodeOpts:
    showColors: true
    defaultTimeoutInterval: 30000
    isVerbose: true
    includeStackTrace: false
