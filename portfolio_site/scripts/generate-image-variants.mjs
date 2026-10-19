/**
 * Generates AVIF and WebP variants for the raster images in public/.
 *
 * Sources stay untouched so they remain the fallback for browsers without
 * AVIF/WebP, and so Supabase-served images (which never pass through this
 * script) keep working. Variants are written to public/_img/<same path>, which
 * is gitignored and regenerated on every build.
 *
 * The manifest it writes (src/lib/image-variants.json) is what SmartImage.astro
 * reads to decide whether a given src has variants to offer.
 */
import { createHash } from 'node:crypto';
import { mkdir, readdir, readFile, stat, writeFile } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { dirname, extname, join, posix, relative, resolve, sep } from 'node:path';
import sharp from 'sharp';

const PUBLIC_DIR = resolve('public');
const OUT_ROOT = resolve('public/_img');
const MANIFEST = resolve('src/lib/image-variants.json');
const SCAN_DIRS = ['project-assets', 'scene-assets'];
const SOURCE_EXTENSIONS = new Set(['.png', '.jpg', '.jpeg']);
const TARGET_WIDTHS = [640, 1280];
const AVIF = { quality: 50, effort: 4 };
const WEBP = { quality: 78, effort: 4 };

const toPosix = (value) => value.split(sep).join(posix.sep);

async function* walk(dir) {
  let entries;
  try {
    entries = await readdir(dir, { withFileTypes: true });
  } catch {
    return;
  }
  for (const entry of entries) {
    const full = join(dir, entry.name);
    if (entry.isDirectory()) {
      yield* walk(full);
    } else if (SOURCE_EXTENSIONS.has(extname(entry.name).toLowerCase())) {
      yield full;
    }
  }
}

/** Only re-encode when the source changed; keeps rebuilds cheap. */
async function isStale(source, output) {
  if (!existsSync(output)) return true;
  const [a, b] = await Promise.all([stat(source), stat(output)]);
  return a.mtimeMs > b.mtimeMs;
}

async function buildVariants(sourcePath) {
  const relPath = toPosix(relative(PUBLIC_DIR, sourcePath));
  const buffer = await readFile(sourcePath);
  const image = sharp(buffer);
  const meta = await image.metadata();
  if (!meta.width || !meta.height) return null;

  const widths = [...new Set([...TARGET_WIDTHS, meta.width].filter((w) => w <= meta.width))].sort(
    (a, b) => a - b,
  );
  const base = relPath.slice(0, relPath.length - extname(relPath).length);
  const entry = { width: meta.width, height: meta.height, avif: [], webp: [] };

  for (const width of widths) {
    for (const [format, options, list] of [
      ['avif', AVIF, entry.avif],
      ['webp', WEBP, entry.webp],
    ]) {
      const outRel = `_img/${base}-${width}.${format}`;
      const outAbs = resolve(PUBLIC_DIR, outRel);
      if (await isStale(sourcePath, outAbs)) {
        await mkdir(dirname(outAbs), { recursive: true });
        await sharp(buffer).resize({ width, withoutEnlargement: true })[format](options).toFile(outAbs);
      }
      list.push([width, outRel]);
    }
  }
  return [relPath, entry];
}

async function main() {
  const sources = [];
  for (const dir of SCAN_DIRS) {
    for await (const file of walk(join(PUBLIC_DIR, dir))) sources.push(file);
  }
  sources.sort();

  const manifest = {};
  let generated = 0;
  // Bounded concurrency: AVIF encoding is CPU bound and unbounded parallelism
  // just thrashes on a laptop.
  const queue = [...sources];
  const workers = Array.from({ length: 4 }, async () => {
    for (;;) {
      const next = queue.shift();
      if (!next) return;
      const result = await buildVariants(next);
      if (result) {
        manifest[result[0]] = result[1];
        generated += 1;
      }
    }
  });
  await Promise.all(workers);

  const ordered = Object.fromEntries(Object.entries(manifest).sort(([a], [b]) => a.localeCompare(b)));
  const json = `${JSON.stringify(ordered, null, 2)}\n`;
  const previous = existsSync(MANIFEST) ? await readFile(MANIFEST, 'utf8') : '';
  const changed = createHash('sha1').update(json).digest('hex') !== createHash('sha1').update(previous).digest('hex');
  if (changed) await writeFile(MANIFEST, json, 'utf8');

  console.log(`Image variants: ${generated} source image(s) mapped, manifest ${changed ? 'updated' : 'unchanged'}.`);
}

main().catch((error) => {
  console.error('Image variant generation failed:', error);
  process.exit(1);
});
