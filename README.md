# Warped Speed

A database-driven, AI-powered text adventure game that combines procedural narrative generation with RPG mechanics in an immersive sci-fi universe.

## Project Overview

Warped Speed is built around a modular, database-first architecture where all content, including narrative prompts, game mechanics, and visual assets, is stored in structured databases rather than hardcoded. This enables:

- Dynamic content generation tailored to player choices
- Genre swapping without code changes
- Efficient content updates and expansion
- Multi-agent AI systems for narrative depth

## Documentation

Comprehensive documentation is available in the `docs/` directory:

- [Master Documentation](docs/MASTER.md) - Complete project overview
- [Architecture](docs/ARCHITECTURE.md) - System architecture details
- [Database Schema](docs/DATABASE_SCHEMA.md) - Database design
- [Game Mechanics](docs/MECHANICS.md) - Game systems and rules
- [UI Specifications](docs/UI_SPEC.md) - Interface design
- [Lore](docs/LORE.md) - Game world and narrative setting

## Development Phases

The project follows a three-phase development approach:

1. **Phase 1**: Core Text-Based Gameplay
2. **Phase 2**: Visual Enhancement
3. **Phase 3**: Advanced Features

See the [Roadmap](docs/ROADMAP.md) and [Features](docs/FEATURES.md) documentation for detailed plans.

## Automated Backup System

This project includes an automated backup system to ensure code preservation:

### GitHub Actions Backup

The repository is automatically backed up through GitHub Actions:
- Daily automated backups
- Milestone branches for significant versions
- Backup tags with timestamps
- Cleanup of old backups to manage storage

The GitHub Actions workflow can be found in `.github/workflows/automated-backup.yml`

### GitHub CLI Integration

This project uses GitHub CLI for streamlined GitHub operations:

1. Ensure GitHub CLI is installed:
   ```
   # Check if GitHub CLI is installed
   gh --version
   
   # Install GitHub CLI if needed (via winget)
   winget install GitHub.cli
   ```

2. Authenticate with your GitHub account:
   ```
   gh auth login
   ```

3. Create a repository and push your code with a single command:
   ```
   gh repo create Warpedspeed --public --source=. --push
   ```

4. Configure automated backups:
   ```
   # Run the backup script manually
   powershell -ExecutionPolicy Bypass -File scripts\auto-backup.ps1
   ```

### Local Configuration

To set up automatic backups on your local machine:

1. Ensure Git is configured with your username and email:
   ```
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

2. The auto-backup script will automatically create a scheduled task for daily backups

## Development Rules

All development must follow the `.cursorrules` guidelines:
- Maximum 300 lines per file
- Database-driven architecture
- Phase-based development controls
- Comprehensive documentation
- Test-driven development

See [Cursor Rules Implementation](docs/CURSOR_RULES_IMPLEMENTATION.md) for details.

## Getting Started

1. Clone this repository:
   ```
   gh repo clone Skeptic1222/Warpedspeed
   ```
   
2. Review the documentation in `docs/`
3. Set up the required databases (see [DATABASE.md](docs/DATABASE.md))
4. Follow the development workflow in [DEVELOPMENT_WORKFLOW.md](docs/DEVELOPMENT_WORKFLOW.md)

## License

[MIT License](LICENSE) 