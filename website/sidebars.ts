import type { SidebarsConfig } from "@docusaurus/plugin-content-docs";

const sidebars: SidebarsConfig = {
  tutorialSidebar: [
    'intro',
    'installation',
    'setup',
    {
      type: 'category',
      label: 'Advanced Features',
      collapsible: true,
      collapsed: false,
      items: [
        'advanced-features/real-time-preview',
        'advanced-features/screenshots',
        'advanced-features/sdk-controls',
      ]
    },
    {
      type: 'category',
      label: 'Guides',
      collapsible: true,
      collapsed: false,
      items: [
        'guides/screenshots-automation',
        'guides/debug-and-logging',
        'guides/swift-ui',
        'guides/sdk-structure',
      ]
    },
    'example',
    'security',
    'faq'
  ],
};

module.exports = sidebars;
