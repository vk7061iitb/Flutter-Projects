const fetch = require("node-fetch");

const url = "https://automation-for-road-dev.cloudfunctions.net/addRandomData";

fetch(url, {
  method: "POST",
})
  .then((response) => response.text())
  .then((data) => console.log(data))
  .catch((error) => console.error("Error making HTTP request:", error));
