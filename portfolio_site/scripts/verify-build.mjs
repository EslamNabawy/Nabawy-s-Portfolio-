import { existsSync, readFileSync, statSync } from 'node:fs';
import { resolve } from 'node:path';

const dist = resolve('dist');
const basePath = '/Nabawy-s-Portfolio-/';
const failures = [];

const requireFile = (relativePath) => {
  const path = resolve(dist, relativePath);
  if (!existsSync(path)) failures.push(`Missing generated file: ${relativePath}`);
  return path;
};

const readHtml = (relativePath) => readFileSync(requireFile(relativePath), 'utf8');
const home = readHtml('index.html');
const admin = readHtml('admin/index.html');

const requireHtml = (html, marker, label) => {
  if (!html.includes(marker)) failures.push(`Missing ${label}: ${marker}`);
};

[
  ['<link rel="canonical" href="https://eslamnabawy.github.io/Nabawy-s-Portfolio-/">', 'homepage canonical URL'],
  ['property="og:title"', 'Open Graph title'],
  ['name="twitter:card" content="summary_large_image"', 'Twitter card metadata'],
  ['type="application/ld+json"', 'structured data'],
  ['class="skip-link" href="#main-content"', 'skip link'],
  ['class="v2-nav-hire" href="#contact"', 'Hire Me contact anchor'],
  ['https://drive.google.com/drive/folders/', 'required Google Drive resume URL'],
].forEach(([marker, label]) => requireHtml(home, marker, label));

requireHtml(admin, '<meta name="robots" content="noindex, nofollow">', 'admin noindex metadata');

['favicon.svg', 'robots.txt', 'site.webmanifest', 'sitemap.xml', 'projects/brox/index.html'].forEach(requireFile);

const publicHrefPattern = /(?:href|src)="([^"#]+)"/g;
for (const match of home.matchAll(publicHrefPattern)) {
  const href = match[1];
  if (!href.startsWith(basePath)) continue;

  const relativePath = decodeURIComponent(href.slice(basePath.length));
  const target = relativePath ? resolve(dist, relativePath) : resolve(dist, 'index.html');
  const resolvedTarget = href.endsWith('/') && relativePath ? resolve(target, 'index.html') : target;
  if (!existsSync(resolvedTarget) || !statSync(resolvedTarget).isFile()) {
    failures.push(`Broken homepage asset/link: ${href}`);
  }
}

if (failures.length > 0) {
  console.error('Static output verification failed:');
  failures.forEach((failure) => console.error(`- ${failure}`));
  process.exit(1);
}

console.log('Static output verification passed.');
