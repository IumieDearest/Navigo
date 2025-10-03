# NaviGo - Travel Planning Website

This project has been reorganized for PHP deployment on XAMPP. React/Vite artifacts were removed and components were converted to PHP sections.

## 🌟 Features

- **Fully Responsive Design** - Optimized for desktop, tablet, and mobile devices
- **Modern UI/UX** - Clean, professional design with smooth animations
- **Dark Mode Support** - Toggle between light and dark themes
- **Interactive Navigation** - Smooth scrolling and mobile-friendly navigation
- **Form Validation** - Real-time form validation with user feedback
- **Performance Optimized** - Fast loading times and smooth interactions
- **SEO Friendly** - Semantic HTML structure and meta tags
- **Accessibility** - WCAG compliant with keyboard navigation support

## 📁 Production Structure

```
/NaviGo_Project
  /assets
    /images
    /fonts
  /css
    global.css
    navbar.css
    footer.css
    home.css
    features.css
    pricing.css
    business.css
    user.css
  /js
    main.js
    navbar.js
    forms.js
  /components
    /business
      Business.php
      BillingPlans.php
      AccountSettings.php
    /users
      UserProfile.php
      BottomNavigation.php
      AccountTypeSelect.php
  index.php
  navbar.php
  footer.php
```

## 🚀 Getting Started

### Prerequisites

- A modern web browser (Chrome, Firefox, Safari, Edge)
- A local web server (optional, for development)

### Run with XAMPP

1. Move the folder to `htdocs/NaviGo_Project`.
2. Start Apache in XAMPP Control Panel.
3. Visit `http://localhost/NaviGo_Project/index.php`.

## 🎨 Design Features

### Color Scheme
- **Primary Colors**: Sky Blue (#0ea5e9), Teal (#14b8a6)
- **Secondary Colors**: Orange (#f97316), Violet (#8b5cf6)
- **Neutral Colors**: Gray scale for text and backgrounds
- **Gradients**: Modern gradient combinations for visual appeal

### Typography
- **Font Family**: Inter (Google Fonts)
- **Font Weights**: 300, 400, 500, 600, 700, 800
- **Responsive Typography**: Scales appropriately across devices

### Layout
- **Grid System**: CSS Grid and Flexbox for responsive layouts
- **Container**: Max-width 1200px with responsive padding
- **Breakpoints**: Mobile (320px+), Tablet (768px+), Desktop (1024px+)

## 📱 Responsive Design

The website is fully responsive with the following breakpoints:

- **Mobile**: 320px - 767px
- **Tablet**: 768px - 1023px
- **Desktop**: 1024px+

### Mobile Features
- Hamburger menu navigation
- Touch-friendly buttons and links
- Optimized typography and spacing
- Swipe-friendly interactions

### Desktop Features
- Full navigation menu
- Hover effects and animations
- Multi-column layouts
- Enhanced visual effects

## ⚡ Performance Features

- **Optimized Images**: Compressed and properly sized images
- **Minified CSS**: Production-ready stylesheets
- **Efficient JavaScript**: Vanilla JS with no external dependencies
- **Fast Loading**: Optimized for quick page loads
- **Smooth Animations**: Hardware-accelerated CSS transitions

## 🔧 Customization

### Colors
Edit the CSS variables in `css/global.css`:
```css
:root {
  --primary-sky: #0ea5e9;
  --primary-teal: #14b8a6;
  /* ... other variables */
}
```

### Content
- **Text Content**: Edit PHP sections in `index.php` or under `components/`
- **Images**: Replace images in `assets/images/`
- **Styling**: Modify CSS files in the `css/` directory

### Functionality
- **JavaScript**: Customize behavior in `js/` files
- **Forms**: Modify form validation in `js/forms.js`
- **Navigation**: Update navigation logic in `js/navbar.js`

## 🌐 Browser Support

- **Chrome**: 60+
- **Firefox**: 60+
- **Safari**: 12+
- **Edge**: 79+
- **Mobile Browsers**: iOS Safari 12+, Chrome Mobile 60+

## 📋 Features Breakdown

### Navigation
- Fixed header with scroll effects
- Mobile hamburger menu
- Smooth scrolling to sections
- Active section highlighting
- Keyboard navigation support

### Hero Section
- Animated background elements
- Gradient text effects
- Call-to-action buttons
- Trust indicators
- Responsive typography

### Features Section
- Grid layout with hover effects
- Icon animations
- Card-based design
- Responsive grid system

### Pricing Section
- Interactive pricing cards
- Popular plan highlighting
- Feature comparisons
- Trust statistics
- Responsive pricing grid

### Contact Section
- Contact information display
- Form validation
- Auto-save functionality
- Character counters
- Success/error feedback

### Footer
- Multi-column layout
- Social media links
- Contact information
- Legal links
- Responsive design

## 🎯 SEO Features

- Semantic HTML structure
- Meta tags for search engines
- Open Graph tags for social sharing
- Structured data markup
- Alt text for images
- Proper heading hierarchy

## ♿ Accessibility Features

- WCAG 2.1 AA compliant
- Keyboard navigation support
- Screen reader friendly
- High contrast mode support
- Focus indicators
- ARIA labels and roles

## 🔒 Security Features

- Form validation and sanitization
- XSS protection
- CSRF protection considerations
- Secure form handling

## 📊 Analytics Ready

The website is ready for analytics integration:
- Google Analytics
- Facebook Pixel
- Custom event tracking
- Performance monitoring

## 🚀 Deployment

### Static Hosting
Deploy to any static hosting service:
- **Netlify**: Drag and drop the project folder
- **Vercel**: Connect your Git repository
- **GitHub Pages**: Push to a GitHub repository
- **AWS S3**: Upload files to an S3 bucket

### Web Server
Upload files to any web server:
- Apache
- Nginx
- IIS
- Any PHP-enabled server

## 🛠️ Development

### Local Development
1. Use a local server for development
2. Enable browser developer tools
3. Use live reload for faster development
4. Test across different devices and browsers

### Code Organization
- **HTML**: Semantic structure with proper nesting
- **CSS**: Modular stylesheets with BEM-like naming
- **JavaScript**: Object-oriented approach with classes
- **Assets**: Organized in logical folders

## 📝 License

This project is created for NaviGo Adventure Travels. All rights reserved.

## 🤝 Contributing

For contributions or modifications:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

For support or questions:
- **Email**: navigo@astrinatravels.com
- **Phone**: (+63)953 062-4663
- **Location**: Cebu City, Philippines

## 🎉 Acknowledgments

- Original design from Figma
- Icons from Lucide React
- Fonts from Google Fonts
- Inspiration from modern web design trends

---

**NaviGo** - Your intelligent travel companion for unforgettable adventures! ✈️🌍
