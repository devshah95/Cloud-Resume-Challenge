from playwright.sync_api import sync_playwright
import requests

# Testing to see if counter is updating
def run(playwright):
    browser = playwright.chromium.launch()
    page = browser.new_page()
    page.goto("http://devarsh.net")
    page.wait_for_timeout(2000)
    initial_count_string = page.text_content("#visitor-count")
    initial_count = int("".join([char for char in initial_count_string if char.isdigit()]))

    page.reload()
    page.wait_for_timeout(2000)
    
    updated_count_string = page.text_content("#visitor-count")
    updated_count = int("".join([char for char in updated_count_string if char.isdigit()]))
    assert updated_count == initial_count + 1

    browser.close()

# Testing API
def run(playwright):
    api_url = "https://aiafkymg70.execute-api.us-east-1.amazonaws.com/prod/counter"
    response = requests.post(api_url)
    assert response.status_code == 200

with sync_playwright() as playwright:
    run(playwright)
