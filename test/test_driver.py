#!/usr/bin/env python

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

import os
import sys

driver = webdriver.Firefox()
driver.get("file://%s" % (os.path.join(os.getcwd(), "test/test_runner.html")))

WebDriverWait(driver, 10).until(
    lambda driver: driver.execute_script("return (window.webtest != undefined)"))

driver.execute_script("webtest.run()")

WebDriverWait(driver, 10).until(
    lambda driver: driver.execute_script("return webtest.finished"))

webtest = driver.execute_script("return webtest")
print webtest["log"]

driver.close()

if not webtest["passed"]:
    sys.exit(1)
