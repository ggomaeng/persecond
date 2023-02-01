const plugin = require('tailwindcss/plugin');

const paddedHorizontal = plugin(function ({ addUtilities }) {
  addUtilities({
    '.padded-horizontal': {
      'padding-left': 'calc((100% - 1280px) / 2)',
      'padding-right': 'calc((100% - 1280px) / 2)'
    },
    '@media only screen and (max-width: 1320px)': {
      '.padded-horizontal': {
        'padding-left': '20px',
        'padding-right': '20px'
      }
    }
  });
});

module.exports = paddedHorizontal;
