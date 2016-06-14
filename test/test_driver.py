#!/usr/bin/env python

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

import os
import time

driver = webdriver.Firefox()
driver.get("file://%s" % (os.path.join(os.getcwd(), "test/test_runner.html")))

button = driver.find_element_by_id('run')
button.click()

WebDriverWait(driver, 10).until(
    EC.presence_of_element_located((
        By.XPATH, '//*[@id="info" and text() != ""]')))

textarea = driver.find_element_by_id('info')
logs = textarea.get_attribute('innerHTML')

print logs

driver.close()
