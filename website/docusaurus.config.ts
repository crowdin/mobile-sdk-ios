import type { Config } from "@docusaurus/types";
import type * as Preset from "@docusaurus/preset-classic";
import { themes } from "prism-react-renderer";
import { PluginOptions } from "@easyops-cn/docusaurus-search-local";

const config: Config = {
  title: 'Crowdin iOS SDK',
  tagline: 'Crowdin iOS SDK delivers all new translations from Crowdin project to the application immediately',
  favicon: 'img/favicon.ico',

  url: 'https://crowdin.github.io/',
  baseUrl: '/mobile-sdk-ios',
  organizationName: 'crowdin',
  projectName: 'mobile-sdk-ios',

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      '@docusaurus/preset-classic',
      ({
        docs: {
          routeBasePath: '/',
          sidebarPath: require.resolve('./sidebars.js'),
          editUrl: 'https://github.com/crowdin/mobile-sdk-ios/tree/master/website/',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      } satisfies Preset.Options),
    ],
  ],

  themes: [
    [
      require.resolve("@easyops-cn/docusaurus-search-local"),
      ({
        hashed: true,
        docsRouteBasePath: '/',
        indexBlog: false,
      } satisfies PluginOptions),
    ]
  ],

  themeConfig:
    ({
      navbar: {
        title: 'Crowdin iOS SDK',
        logo: {
          alt: 'Crowdin iOS SDK',
          src: 'img/logo.svg',
        },
        items: [
          {
            href: 'https://github.com/crowdin/mobile-sdk-ios',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Community',
            items: [
              {
                label: 'Forum',
                href: 'https://community.crowdin.com/',
              },
              {
                label: 'Twitter',
                href: 'https://twitter.com/crowdin',
              },
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'GitHub',
                href: 'https://github.com/crowdin/mobile-sdk-ios',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Crowdin.`,
      },
      prism: {
        theme: themes.github,
        darkTheme: themes.dracula,
        additionalLanguages: ['bash', 'swift', 'objectivec']
      },
    } satisfies Preset.ThemeConfig),
};

module.exports = config;
