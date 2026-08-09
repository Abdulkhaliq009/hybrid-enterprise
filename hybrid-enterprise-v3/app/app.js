require("dotenv").config();

if (process.env.APPLICATIONINSIGHTS_CONNECTION_STRING) {
  const appInsights = require("applicationinsights");
  appInsights.setup(process.env.APPLICATIONINSIGHTS_CONNECTION_STRING)
    .setAutoDependencyCorrelation(true)
    .setAutoCollectRequests(true)
    .setAutoCollectPerformance(true)
    .setAutoCollectExceptions(true)
    .setAutoCollectDependencies(true)
    .start();
}

const { createApp } = require("./server");
const PORT = process.env.PORT || 3000;

const app = createApp();
app.listen(PORT, () => {
  console.log(`API on port ${PORT} | DB: ${process.env.DB_HOST}/${process.env.DB_NAME}`);
});
