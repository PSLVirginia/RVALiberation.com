# Agent Guide for linkyee

This guide helps AI agents understand the structure, conventions, and workflows of the linkyee project—a fully customizable, open-source LinkTree alternative deployed on GitHub Pages.

## Overview

- **Purpose**: Static link-in-bio page generator with plugin support
- **Tech Stack**: Ruby, Liquid templating, GitHub Pages, Font Awesome
- **Core Files**: `config.yml` (configuration), `scaffold.rb` (build script), `deploy.sh` (deployment)
- **Themes**: Located in `./themes/` (default theme included)
- **Plugins**: Ruby classes in `./plugins/` that fetch dynamic data (e.g., GitHub star counts)

## Essential Commands

### Build the site locally
```bash
bundle exec ruby "./scaffold.rb"
```
Generates the static site in `_output/` using the active theme and plugins.

### Deploy (GitHub Actions only)
```bash
bash deploy.sh
```
**Note**: The deploy script is designed to run only in a GitHub Actions environment (`GITHUB_ACTION` must be set). It:
1. Builds the site
2. Switches to the `gh-pages` branch
3. Moves the built files to the root
4. Commits and pushes to the remote

### Install dependencies
```bash
bundle install
```
Uses the `Gemfile` (includes `liquid`, `nokogiri`, `bigdecimal`, `base64`, `yaml`).

### Run CI workflow locally (simulate)
Not directly supported; use the GitHub Actions workflow file (`.github/workflows/build.yml`) as reference.

## Project Structure

```
.
├── config.yml              # Site configuration (title, avatar, links, plugins)
├── scaffold.rb             # Build script: copies theme, processes Liquid, runs plugins
├── deploy.sh               # Deployment script (GitHub Actions only)
├── Gemfile                 # Ruby dependencies
├── .ruby-version           # Ruby version (3.4.2)
├── .github/workflows/build.yml  # CI/CD pipeline (runs on push & daily schedule)
├── themes/
│   └── default/            # Default theme (can be duplicated/renamed)
│       ├── index.html      # Liquid template
│       ├── styles.css      # Theme styles
│       ├── scripts.js      # Theme JavaScript
│       └── images/         # Static assets (profile, favicons)
│       └── fontawesome/    # Font Awesome assets (copied locally)
├── plugins/                # Custom plugins (inherit from Plugin.rb)
│   ├── Plugin.rb           # Base plugin class
│   └── GithubRepoStarsCountPlugin.rb  # Example plugin fetching GitHub stars
└── _output/                # Generated site (ignored by git except AUTO_GEN_FOLDER_DO_NOT_EDIT_FILE_HERE)
```

## Configuration

The primary configuration file is `config.yml`. Key sections:

- `theme`: directory name inside `themes/` to use
- `lang`: HTML language attribute
- `plugins`: list of plugin configurations (see plugin section below)
- `google_analytics_id`: optional Google Analytics tracking ID
- `title`, `avatar`, `name`, `tagline`: site identity
- `links`: list of link buttons (icon, text, url, target, alt, title)
- `socials`: list of social media icons
- `footer`, `copyright`: footer text (supports HTML)

**Note**: For a custom domain, add a `CNAME` file to the root (not tracked in `config.yml`). The `deploy.sh` script preserves it during deployment.

### Plugin Configuration
Plugins are listed under the `plugins` key. Each plugin entry is a map where the key is the plugin class name and the value is an array of parameters passed to the plugin’s constructor.

Example:
```yaml
plugins:
  - GithubRepoStarsCountPlugin:
      - ZhgChgLi/ZMarkupParser
      - ZhgChgLi/ZReviewTender
```

Plugin output is available in Liquid templates as `{{ vars.PLUGIN_NAME }}`. For the example above, `{{ vars.GithubRepoStarsCountPlugin['ZhgChgLi/ZMarkupParser'] }}` returns the star count.

## Themes

- Each theme resides in `./themes/<theme_name>/`.
- Must contain at least `index.html` (Liquid template).
- Assets (CSS, JS, images) are referenced relative to the theme root.
- The template uses Liquid variables defined in `config.yml` and plugin outputs.
- To create a new theme: duplicate the `default` folder, update `theme:` in `config.yml`.

## Plugins

- Plugins are Ruby classes that inherit from `Plugin` (defined in `plugins/Plugin.rb`).
- Must implement `initialize(data)` and `execute` methods.
- `data` is the array of parameters from `config.yml`.
- `execute` must return a value that will be exposed as `vars.PLUGIN_NAME`.
- Example: `GithubRepoStarsCountPlugin` fetches GitHub star counts via HTTP and returns a hash mapping repo names to star counts.
- **Note**: HTTP requests in plugins may be subject to rate limiting (e.g., GitHub API). Consider caching or using authenticated requests if needed.

### Writing a New Plugin
1. Create `plugins/MyPlugin.rb`.
2. Require `'Plugin'` and define a class inheriting from `Plugin`.
3. Implement `initialize` and `execute`.
4. Add the plugin to `config.yml`.
5. Use `{{ vars.MyPlugin }}` in the theme template.

## Development Workflow

1. **Modify configuration**: Edit `config.yml` (links, socials, plugins).
2. **Customize theme**: Edit files in `./themes/default/` (or create a new theme).
3. **Add plugins**: Create new Ruby classes in `plugins/`.
4. **Test locally**: Run `bundle exec ruby "./scaffold.rb"` and open `_output/index.html` in a browser.
5. **Commit and push**: Changes to `main` trigger an automatic build and deployment via GitHub Actions.

### Local Testing Notes
- The build script copies the theme to `_output/` and processes Liquid.
- Plugin HTTP requests may fail if offline; mock data may be needed for offline development.
- The `_output/` directory is ignored by git (except `AUTO_GEN_FOLDER_DO_NOT_EDIT_FILE_HERE`). Do not commit its contents.

## CI/CD

- **Workflow**: `.github/workflows/build.yml`
- **Triggers**: Push to `main` (ignoring `.gitignore`, `README.md`, `LICENSE`), manual dispatch, and daily cron (midnight UTC).
- **Steps**: Checkout, setup Ruby (3.4.2), install dependencies, run `bash deploy.sh`.
- **Deployment branch**: `gh-pages` (GitHub Pages source).

### Gotchas
- `deploy.sh` **must not be run outside GitHub Actions**—it checks for `GITHUB_ACTION` environment variable and exits otherwise.
- The daily cron ensures plugin data (e.g., GitHub stars) stays fresh; remove the `schedule` block in `build.yml` if not needed.
- The `gh-pages` branch is force‑pushed on each deployment; any manual commits there will be lost.
- Font Awesome assets are copied (not a submodule) in `themes/default/fontawesome/`. Do not remove them unless you plan to use a CDN.
- The `_output/` directory is ignored except for `AUTO_GEN_FOLDER_DO_NOT_EDIT_FILE_HERE` (a placeholder file that ensures the folder exists in git).
- Ruby version is pinned to 3.4.2 (see `.ruby-version`). Use that version for local development.

## Code Style & Conventions

- Ruby: No enforced linter; follow standard Ruby style (2‑space indentation, snake_case).
- HTML/CSS/JS: No minification or bundling; keep assets human‑readable.
- Liquid: Use `{{ ... }}` for variables, `{% ... %}` for control flow (loops, conditionals).
- YAML: Use consistent indentation (two spaces) and keep strings unquoted unless they contain special characters.

## Missing Practices

- **Tests**: No test suite is currently set up.
- **Linting**: No RuboCop or style checker configured.
- **Preview server**: No live‑reload server; manually refresh the browser after each build.

## Useful References

- [Font Awesome Icons](https://fontawesome.com/search?o=r&m=free) – icons for links and socials
- [Liquid Template Language](https://shopify.github.io/liquid/) – templating syntax
- [GitHub Pages Documentation](https://docs.github.com/en/pages) – deployment details

---

*This file was generated by an AI agent. Update it as the project evolves.*