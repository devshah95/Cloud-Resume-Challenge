document.addEventListener("DOMContentLoaded", () => {
  const visitorCountElement = document.getElementById("visitor-count")

  // API URL
  const apiUrl =
    "https://aiafkymg70.execute-api.us-east-1.amazonaws.com/prod/counter"

  function updateVisitorCounter() {
    fetch(apiUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
      },
      body: JSON.stringify({}),
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error("Network response was not ok")
        }
        return response.json()
      })
      .then((data) => {
        const parsedBody = JSON.parse(data.body)
        visitorCountElement.textContent = `Visitor Count: ${parsedBody.new_count}`
      })
      .catch((error) => console.error("Error:", error))
  }

  updateVisitorCounter()
})
