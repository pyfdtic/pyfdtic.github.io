
Scrapy 命令行工具使用汇总

## 1. Configuration settings
Scrapy will look for configuration parameters in *ini-style* `scrapy.cfg` files in standard locations:
1. `/etc/scrapy.cfg` or `c:\scrapy\scrapy.cfg` --> system-wide
2. `~/.config/scrapy/cfg` and `~/.scrapy.cfg` --> user-wide
3. `scrapy.cfg` inside a scrapy project's root. --> project-wite

priority:
```
project-wide > user-wide > system-wide
```
## 2. environment variables:
- `SCRAPY_SETTING_MODULE`
- `SCRAPY_PROJECT`
- `SCRAPY_PYTHON_SHELL`

## 3. scrapy command line
```shell  
# creating projects 
# by default project_dir == myproject
$ scrapy startproject myproject [project_dir]

# some cmd must be run from inside a Scrapy project
$ cd project_dir

# scrapy help
$ scrapy -h

# scrapy subcmd help
$ scrapy SUB_CMD --help
```

### 3.1 Global commands : work without an active Scrapy project

- `startprojects`
    ```
    # Create a new Scrapy project named 'project_name', under the 'project_dir'
    # if 'project_dir' wasn't specified , it will be the same with the 'project_name'
    $ scrapy startproject <project_name> [project_dir]
    ```
- `genspider`

    Create a new spider in the current folder or in the current project's `spiders` folder, if called from inside a project.

    This is just a shortcut for creating spiders. You can just create the spider source code files yourself, instead of using this command.

    The `name` parameter is set as the spider's name. while `domain` is used to generate the `allowed_domains` and `start_urls` spider's attributes.
    ```
    # create spider 'name' using `template`
    $ scrapy genspider [-t template] <name> <domain>

    # list all available templates:
    $ scrapy genspider -l
        basic         # default
        crawl
        csvfeed
        xmlfeed
    ```
- `settings`
    
    get the value of a Scrapy setting.
    ```
    $ scrapy settings [options]

    $ scrapy settings --get BOT_NAME
    $ scrapy settings --get DOWNLOAD_DELAY
    ```
- `runspider`
    
    run a spider self-contained in a Python file, without having to create a project.
    ```
    $ scrapy runspider myspider.py
    ```
- `shell`
    
    Starts the Scrapy shell for the given URL or empty if no URL is given. Also support UNIX-style local file path, both relative path or absolute path.
    ```
    $ scrapy shell [url]
        --spider=SPIDER
        -c code : evaluate the code in the shell print the result and exit.
        -no-redirect : 
    ```
    Examples:
    ```
    $ scrapy shell http://www.example.com/some/page.html
    [ ... scrapy shell starts ... ]

    $ scrapy shell --nolog http://www.example.com/ -c '(response.status, response.url)'
    (200, 'http://www.example.com/')

    # shell follows HTTP redirects by default
    $ scrapy shell --nolog http://httpbin.org/redirect-to?url=http%3A%2F%2Fexample.com%2F -c '(response.status, response.url)'
    (200, 'http://example.com/')

    # you can disable this with --no-redirect
    # (only for the URL passed as command line argument)
    $ scrapy shell --no-redirect --nolog http://httpbin.org/redirect-to?url=http%3A%2F%2Fexample.com%2F -c '(response.status, response.url)'
    (302, 'http://httpbin.org/redirect-to?url=http%3A%2F%2Fexample.com%2F')
    ```
- `fetch`

    Downloads the given URL using the Scrapy downloader and write the contents to the output.
    ```
    $ scrapy fetch <url>
    --spider=SPIDER : bypass spider autodetection and force use of specific spider
    --headers       : print response HTTP headers
    --no-redirect   : no follow HTTP 3xx redirects
    ```
- `view`
    
    Open the given URL in a brower, as your Scrapy spider would 'see' it.
    ```
    $ scrapy view <url>
        --spider=SPIDER :
        --no-redirect   : 
    ```
- `version` 
    
    prints the Scrapy version.
    ```
    $ scrapy version [-v]
        -v : also prints Python, Twisted and Platform info.
    ```

### 3.2 Project-only Commands: work from inside a Scrapy project

- `crawl`
    
    Start crawling using a spider
    ```
    $ scrapy crawl <spider_name>
    ```
- `check`
    
    check spider contracts
    ```
    $ scrapy check [-l] <spider_name>
    ```
- `list`
    
    list all available spiders in the current project.
    ```
    $ scrapy list
    ```
- `edit`
    
    Edit the given spider using the system default editor.
    ```
    $ scrapy edit <spider_name>
    ```
- `parse`
    
    Fetchs the given URL and parses it with the spider that handler it , using the method pased with the `--callcheck` option, or `parse` if not given.
    ```
    $ scrapy parse <url> [options]
        --spider=SPIDER
        --a NAME=VALUE : set spider argument (may be repeated)
        --callback, -c : spider method to use as callback fot parsing the response.
        --pipeline: process items through pipelines
        --rules, -r : use 'CrawlSpider' rules to discover the callback to use for parsing the response.
        --noitems : don't show scraped items
        --nolinks : don't show extracted links
        --nocolour : avoid using pygments to colorize the output.
        --depth, -d : depth level for which the requests should be followed recursively, default 1.
        --verbose, -v : display informatioin fot each depth level.
    ```
- `bench`
    
    run a quick benchmark test.
    ```
    $ scrapy bench
    ```