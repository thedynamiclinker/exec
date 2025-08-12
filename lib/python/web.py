#!/usr/bin/env python3

import os
import re
import bs4
import shutil
import datetime
import requests
import selenium.webdriver
import webdriver_manager
from pathlib import Path
from urllib.parse import urlparse


class Browser:

    USER_AGENT = (
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/35.0.1916.47 Safari/537.36'
    )

    def __init__(self, type='chrome', headless=False, incognito=True, user_agent=USER_AGENT):

        if type == 'chrome':
            from selenium.webdriver.chrome.service import Service
            from selenium.webdriver.chrome.options import Options
            from webdriver_manager.chrome import ChromeDriverManager as DriverManager
            from selenium.webdriver import Chrome as Driver
            self.driver_path = shutil.which('chromedriver')
        elif type == 'firefox':
            from selenium.webdriver.firefox.service import Service
            from selenium.webdriver.firefox.options import Options
            from selenium.webdriver import Firefox as Driver
            from webdriver_manager.firefox import GeckoDriverManager as DriverManager
            self.driver_path = shutil.which('geckodriver')
        else:
            raise ValueError(f"Unsupported browser type: {type}")

        self.options = Options()
        self.service = Service()
        self.type = type

        if headless:
            self.options.add_argument("--headless")
        if incognito:
            self.options.add_argument("--incognito")
        self.options.add_argument("--start-maximized")
        self.options.add_argument(f'--user-agent={user_agent}')

        path = DriverManager().install()
        self.driver = Driver(service=Service(path), options=self.options)

    def __getattr__(self, attr):
        return getattr(self.driver, attr)

    def __dir__(self):
        return super().__dir__() + self.driver.__dir__()

    def page(self):
        return self.driver.page_source

    def soup(self):
        page = self.driver.page_source
        soup = bs4.BeautifulSoup(page, 'html.parser')
        return soup

    def get(self, url):
        self.driver.get(url)
        return self

    def run(self, script):
        return browser.driver.execute_script(script)

    def querySelectorAll(self, selector):
        return self.run(f"""
        return Array.from(document.querySelectorAll("{selector}"));
        """)

    def get_jpgs(self):
        return self.run("""
        return Array.from(document.querySelectorAll("img[src$=jpg]")).map(img => img.src);
        """)

    def get_pngs(self):
        return self.run("""
        return Array.from(document.querySelectorAll("img[src$=png]")).map(img => img.src);
        """)

    def get_gifs(self):
        return self.run("""
        return Array.from(document.querySelectorAll("img[src$=gif]")).map(img => img.src);
        """)

    def get_images(self):
        return self.run("""
        return Array.from(document.querySelectorAll("img")).map(img => img.src);
        """)

    def get_images_full(self):
        return self.run("""
        let a2imgs = Array.from(document.querySelectorAll("a > img"))
        return a2imgs.map(img => img.parentNode.href);
        """)

    def url_to_path(self, url=None):
        if url is None:
            url = self.driver.current_url
        u = urlparse(url)
        return os.path.join(u.netloc, u.path.lstrip('/'))

    def download_images(self, **kwds):
        urls = self.get_images()
        return self.download_urls(urls, **kwds)

    def download_urls(self, urls=(), url=None, outdir='browser', max_workers=8):
        if url is not None:
            self.get(url)
        from concurrent.futures import ThreadPoolExecutor, as_completed
        dirname = os.path.join(outdir, self.url_to_path())
        os.makedirs(dirname, exist_ok=True)
        executor = ThreadPoolExecutor(max_workers=max_workers)
        futures = []
        for url in urls:
            basename = os.path.basename(urlparse(url).path)
            pathname = os.path.join(dirname, basename)
            future = executor.submit(self.download_url, url, pathname)
            future.url = url
            futures.append(future)
        results = {'succeeded': [], 'failed': []}
        for future in as_completed(futures):
            try:
                results['succeeded'].append(future.url)
            except Exception as e:
                results['failed'].append(future.url)
        return results

    def download_url(self, url, pathname):
        try:
            content = requests.get(url).content
        except:
            print(f"Failed to get url: {url!r}")
            return
        with open(pathname, 'wb') as fp:
            fp.write(content)
        relpath = Path(pathname).relative_to(os.getcwd())
        print(f"Downloaded url: {url!r} to {relpath!r}")

