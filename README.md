# dogweightcalculator.uk

Single-page, SEO-first dog weight calculator website for `https://dogweightcalculator.uk`, ready for Cloudflare Pages.

## What is included

- 1-page website with:
  - Adult dog weight estimation tool (kg/lb)
  - Growth guidance by size class
  - FAQ and medical disclaimer
- Technical SEO setup:
  - Canonical, robots, Open Graph, Twitter metadata
  - JSON-LD (`WebSite`, `WebApplication`, `FAQPage`, `BreadcrumbList`)
  - `robots.txt` and `sitemap.xml`
- Cloudflare Pages compatible static output:
  - `_headers` (security/performance headers)
  - `_redirects` (HTTP -> HTTPS redirect)

## Local structure

- `index.html`
- `styles.css`
- `script.js`
- `robots.txt`
- `sitemap.xml`
- `manifest.webmanifest`
- `_headers`
- `_redirects`

## Deploy on Cloudflare Pages

1. Push this repo to GitHub.
2. In Cloudflare Pages:
   - `Create a project` -> `Connect to Git`
   - Select repository: `dogweightcalculator.uk`
3. Build settings:
   - Framework preset: `None`
   - Build command: *(leave empty)*
   - Build output directory: `/`
4. Add custom domain:
   - `dogweightcalculator.uk`
   - `www.dogweightcalculator.uk` (optional) and redirect to apex.
5. After first deploy, submit:
   - `https://dogweightcalculator.uk/sitemap.xml` to Google Search Console.

## Git remote (from screenshot)

```bash
git remote add origin https://github.com/williamadamseo1-creator/dogweightcalculator.uk.git
git branch -M main
git push -u origin main
```
