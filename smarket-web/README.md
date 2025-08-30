# Smarket Web

A web version of the Smarket shopping list and product tracker app, built with Astro and Tailwind CSS.

## Features

- **Product Management**: Add and track products with prices, purchase dates, and how long they last
- **Smart Categorization**: Products are automatically categorized based on their names
- **Shopping List**: See which products are due for repurchase based on your configured "heads up" days
- **Budget Tracking**: Set monthly budgets and track your spending
- **Insights**: View monthly spending estimates and category breakdowns
- **Responsive Design**: Works great on desktop and mobile devices

## Getting Started

### Prerequisites

- Node.js 18+ installed
- npm or yarn package manager

### Installation

1. Navigate to the project directory:
   ```bash
   cd smarket-web
   ```

2. Install dependencies (if not already installed):
   ```bash
   npm install
   ```

### Development

Run the development server:

```bash
npm run dev
```

The app will be available at `http://localhost:4321`

### Building for Production

Build the project:

```bash
npm run build
```

Preview the production build:

```bash
npm run preview
```

## Tech Stack

- **Astro** - Static site generator with islands architecture
- **Tailwind CSS** - Utility-first CSS framework
- **TypeScript** - Type-safe JavaScript
- **LocalStorage** - Client-side data persistence

## Project Structure

```
smarket-web/
├── public/          # Static assets
├── src/
│   ├── components/  # Reusable components
│   ├── layouts/     # Page layouts
│   ├── lib/         # Utilities and services
│   ├── pages/       # Route pages
│   ├── styles/      # Global styles
│   └── types/       # TypeScript type definitions
└── package.json
```

## Data Storage

The app uses browser LocalStorage to persist data locally. This means:
- Data is stored on your device only
- No server or account required
- Data persists between sessions
- Data can be cleared from the Settings page

## Contributing

Feel free to submit issues or pull requests to improve the app!

## License

This project is part of the Smarket application suite.