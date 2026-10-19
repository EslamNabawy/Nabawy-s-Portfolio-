/**
 * Builds the Sentinels showcase mockup so the project card matches the house
 * style used by brox/showcase.jpg, fairmatch/cover.png and friends: a 1600x1000
 * light canvas, a white rounded card, the product screenshot inside a dark
 * window frame, a floating secondary panel, label pills and a caption bar.
 *
 * One-off asset generation; run it by hand when the source captures change:
 *   node scripts/build-sentinels-showcase.mjs
 */
import { writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import sharp from 'sharp';

const SRC = 'public/project-assets/sentinels';
const OUT = resolve(`${SRC}/showcase.png`);

const W = 1600;
const H = 1000;

// Brand tokens from the Sentinels deck.
const BG = '#eef5f5';
const INK = '#0b2533';
const MUTED = '#4a6470';
const TEAL = '#0e9aa0';
const MIST = '#dff1f1';
const LINE = '#d3e3e5';

const FONT = 'Segoe UI, Inter, Manrope, Helvetica, Arial, sans-serif';

// Geometry. Screens sit inside a dark bezel, the way the brox laptop frame does.
const card = { x: 70, y: 78, w: 1460, h: 846, r: 26 };
const main = { x: 118, y: 212, w: 940, bar: 36, bezel: 12 };
const side = { x: 1006, y: 474, w: 428, bar: 30, bezel: 10 };
const caption = { x: 118, y: 792, w: 1364, h: 58, r: 12 };

const escapeXml = (value) =>
  value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

/** Rounds an image's corners by masking it with a rounded rect. */
async function rounded(buffer, width, height, radius) {
  const mask = Buffer.from(
    `<svg width="${width}" height="${height}"><rect width="${width}" height="${height}" rx="${radius}" ry="${radius}" fill="#fff"/></svg>`,
  );
  return sharp(buffer)
    .resize(width, height, { fit: 'cover', position: 'top' })
    .composite([{ input: mask, blend: 'dest-in' }])
    .png()
    .toBuffer();
}

async function main_() {
  const mainSrc = `${SRC}/demo/demo-01-dashboard-overview.png`;
  const sideSrc = `${SRC}/demo/demo-05-alert-email.png`;

  const mainMeta = await sharp(mainSrc).metadata();
  const sideMeta = await sharp(sideSrc).metadata();

  const mainScreenW = main.w - main.bezel * 2;
  const sideScreenW = side.w - side.bezel * 2;
  const mainH = Math.round((mainMeta.height / mainMeta.width) * mainScreenW);
  const sideH = Math.round((sideMeta.height / sideMeta.width) * sideScreenW);

  const mainWindow = { ...main, h: mainH + main.bar + main.bezel };
  const sideWindow = { ...side, h: sideH + side.bar + side.bezel };

  // Pills straddle the bottom edge of each frame so they label it without
  // covering the screenshot content.
  const pillMain = { x: main.x + 34, y: main.y + mainWindow.h - 19, w: 196, h: 38 };
  const pillSide = { x: side.x + 22, y: side.y + sideWindow.h - 18, w: 176, h: 36 };

  const svg = `
<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}">
  <defs>
    <filter id="soft" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="18" stdDeviation="22" flood-color="#0b2533" flood-opacity="0.18"/>
    </filter>
    <filter id="cardShadow" x="-10%" y="-10%" width="120%" height="120%">
      <feDropShadow dx="0" dy="10" stdDeviation="18" flood-color="#0b2533" flood-opacity="0.08"/>
    </filter>
  </defs>

  <rect width="${W}" height="${H}" fill="${BG}"/>
  <rect x="${card.x}" y="${card.y}" width="${card.w}" height="${card.h}" rx="${card.r}"
        fill="#ffffff" stroke="${LINE}" stroke-width="1" filter="url(#cardShadow)"/>

  <text x="${card.x + 48}" y="${card.y + 54}" font-family="${FONT}" font-size="19"
        font-weight="700" fill="${INK}">Sentinels</text>
  <text x="${card.x + 48}" y="${card.y + 90}" font-family="${FONT}" font-size="13.5"
        fill="${MUTED}">Autonomous AIOps platform &#183; detect, diagnose, fix, notify</text>

  <!-- main window chrome -->
  <g filter="url(#soft)">
    <rect x="${mainWindow.x}" y="${mainWindow.y}" width="${mainWindow.w}" height="${mainWindow.h}"
          rx="13" fill="${INK}"/>
  </g>
  <circle cx="${main.x + 22}" cy="${main.y + 17}" r="5.5" fill="#ff5f57"/>
  <circle cx="${main.x + 40}" cy="${main.y + 17}" r="5.5" fill="#febc2e"/>
  <circle cx="${main.x + 58}" cy="${main.y + 17}" r="5.5" fill="#28c840"/>
  <text x="${main.x + main.w / 2}" y="${main.y + 21}" text-anchor="middle" font-family="${FONT}"
        font-size="11" fill="#7f98a3">sentinels &#183; command center</text>

  <!-- floating alert panel chrome -->
  <g filter="url(#soft)">
    <rect x="${sideWindow.x}" y="${sideWindow.y}" width="${sideWindow.w}" height="${sideWindow.h}"
          rx="12" fill="${INK}"/>
  </g>
  <circle cx="${side.x + 20}" cy="${side.y + 15}" r="4.5" fill="#ff5f57"/>
  <circle cx="${side.x + 35}" cy="${side.y + 15}" r="4.5" fill="#febc2e"/>
  <circle cx="${side.x + 50}" cy="${side.y + 15}" r="4.5" fill="#28c840"/>
  <text x="${side.x + side.w / 2}" y="${side.y + 19}" text-anchor="middle" font-family="${FONT}"
        font-size="10" fill="#7f98a3">incident alert</text>

  <!-- caption -->
  <rect x="${caption.x}" y="${caption.y}" width="${caption.w}" height="${caption.h}"
        rx="${caption.r}" fill="${MIST}"/>
  <text x="${caption.x + 28}" y="${caption.y + 35}" font-family="${FONT}" font-size="13" fill="${INK}">${escapeXml(
    'Chaos injection, alert correlation, AI root cause analysis, and Ansible remediation after one approval',
  )}</text>
</svg>`;

  const mainImg = await rounded(await sharp(mainSrc).toBuffer(), mainScreenW, mainH, 5);
  const sideImg = await rounded(await sharp(sideSrc).toBuffer(), sideScreenW, sideH, 5);

  // Pills go on last so the screenshots do not cover them.
  const overlay = `
<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}">
  <rect x="${pillMain.x}" y="${pillMain.y}" width="${pillMain.w}" height="${pillMain.h}" rx="10" fill="${INK}"/>
  <text x="${pillMain.x + pillMain.w / 2}" y="${pillMain.y + 24.5}" text-anchor="middle"
        font-family="${FONT}" font-size="12.5" font-weight="600" fill="#ffffff">Command center</text>
  <rect x="${pillSide.x}" y="${pillSide.y}" width="${pillSide.w}" height="${pillSide.h}" rx="10" fill="${TEAL}"/>
  <text x="${pillSide.x + pillSide.w / 2}" y="${pillSide.y + 23.5}" text-anchor="middle"
        font-family="${FONT}" font-size="12" font-weight="600" fill="#ffffff">Anomaly alert</text>
</svg>`;

  await sharp(Buffer.from(svg))
    .composite([
      { input: mainImg, left: main.x + main.bezel, top: main.y + main.bar },
      { input: sideImg, left: side.x + side.bezel, top: side.y + side.bar },
      { input: Buffer.from(overlay), left: 0, top: 0 },
    ])
    .png({ compressionLevel: 9 })
    .toFile(OUT);

  const meta = await sharp(OUT).metadata();
  console.log(`Wrote ${OUT} (${meta.width}x${meta.height})`);
}

main_().catch((error) => {
  console.error('Showcase build failed:', error);
  process.exit(1);
});
