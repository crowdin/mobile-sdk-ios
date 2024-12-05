/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */

// @ts-check

/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
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
