import type { SectionBlock, SectionBlockAction, SectionBlockItem } from './types';

const blockTypes = new Set([
  'heroText',
  'cardGrid',
  'metricStrip',
  'timeline',
  'media',
  'ctaRow',
  'callout',
  'architecturePanel',
]);

export function readSectionBlocks(content: Record<string, unknown>): SectionBlock[] {
  if (Array.isArray(content.blocks)) {
    return content.blocks
      .filter(isRecord)
      .map(readBlock)
      .filter((block): block is SectionBlock => block !== null);
  }

  const items = readItems(content.items);
  const actions = readActions(content.actions);
  return [
    ...(items.length > 0 ? [{ type: 'cardGrid' as const, items }] : []),
    ...(actions.length > 0 ? [{ type: 'ctaRow' as const, actions }] : []),
  ];
}

export function validateSectionBlocks(
  sectionTitle: string,
  blocks: SectionBlock[],
): void {
  if (blocks.length === 0) {
    throw new Error(`Published page section "${sectionTitle}" needs at least one block.`);
  }
  for (const block of blocks) {
    if (['cardGrid', 'metricStrip', 'timeline', 'architecturePanel'].includes(block.type)) {
      if (!block.items || block.items.length === 0) {
        throw new Error(`Page section "${sectionTitle}" has an empty ${block.type} block.`);
      }
      for (const item of block.items) {
        if (!item.title && !item.copy) {
          throw new Error(`Page section "${sectionTitle}" has an empty item.`);
        }
        if (item.url && !safeHref(item.url)) {
          throw new Error(`Page section "${sectionTitle}" has an unsafe item URL.`);
        }
      }
    }
    if (block.type === 'ctaRow') {
      for (const action of block.actions ?? []) {
        if (!action.label || !action.url || !safeHref(action.url)) {
          throw new Error(`Page section "${sectionTitle}" has an invalid CTA.`);
        }
      }
    }
    if (block.type === 'media') {
      if (!block.mediaUrl || !safeMediaUrl(block.mediaUrl)) {
        throw new Error(`Page section "${sectionTitle}" has an invalid media URL.`);
      }
      if (!block.altText && !block.caption) {
        throw new Error(`Page section "${sectionTitle}" media needs alt text or caption.`);
      }
    }
  }
}

export function safeHref(value: unknown): string {
  const url = readString(value);
  if (
    url.startsWith('#') ||
    url.startsWith('/') ||
    url.startsWith('https://') ||
    url.startsWith('http://') ||
    url.startsWith('mailto:')
  ) {
    return url;
  }
  return '';
}

export function safeMediaUrl(value: unknown): string {
  const url = readString(value);
  return url.startsWith('https://') || url.startsWith('http://') ? url : '';
}

export function readString(value: unknown): string {
  return typeof value === 'string' ? value.trim() : '';
}

function readBlock(value: Record<string, unknown>): SectionBlock | null {
  const type = readString(value.type);
  if (!blockTypes.has(type)) {
    return null;
  }
  return {
    type: type as SectionBlock['type'],
    label: readString(value.label) || undefined,
    title: readString(value.title) || undefined,
    copy: readString(value.copy) || undefined,
    url: safeHref(value.url) || undefined,
    mediaUrl: safeMediaUrl(value.mediaUrl) || undefined,
    altText: readString(value.altText) || undefined,
    caption: readString(value.caption) || undefined,
    items: readItems(value.items),
    actions: readActions(value.actions),
  };
}

function readItems(value: unknown): SectionBlockItem[] {
  if (!Array.isArray(value)) {
    return [];
  }
  return value.filter(isRecord).map((item) => ({
    label: readString(item.label) || undefined,
    title: readString(item.title) || undefined,
    copy: readString(item.copy) || undefined,
    url: safeHref(item.url) || undefined,
  }));
}

function readActions(value: unknown): SectionBlockAction[] {
  if (!Array.isArray(value)) {
    return [];
  }
  return value
    .filter(isRecord)
    .map((item) => ({
      label: readString(item.label) || undefined,
      url: safeHref(item.url) || undefined,
    }))
    .filter((item) => item.label && item.url);
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === 'object';
}
