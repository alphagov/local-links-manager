# Link Status Messages

The link checker runs overnight with the list of current links, and the outcome of that check is displayed in various places: the Broken Links tab, the Councils tab (council homepages only), in the individual council pages and in the individual service pages. They are in three groups.

# Good

All links that are marked Good have been visited by the link checker without a problem. No action is required.

# Warning

Warning links highlight pages that cannot be properly checked, and come in the following types.

* Note: Security problem
* Note: Page blocks robots - this can mean the page is behind a CDN (such as Cloudflare) which treats the GOV.UK webcrawler as a potential attack and
  prompts it with a captcha to continue (the crawler cannot interact with the captcha).

# Error

* Broken: Website unavailable - this means the link returns a 404. SOLUTION: find the correct link and edit it.
* missing - this means the link is empty. SOLUTION: find the correct link and edit it.
