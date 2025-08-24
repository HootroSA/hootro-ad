# Hootro Advertisement System

A comprehensive business advertisement system for FiveM servers with QBCore/QBox and ox_lib support.

Preview: https://streamable.com/trzc6x

## Features

- **Business Advertisement System** - Allow players to create and manage business advertisements
- **Modern UI Interface** - Clean and responsive web-based interface
- **QBCore/QBox Integration** - Seamless integration with popular FiveM frameworks
- **ox_lib Support** - Enhanced UI components and interactions
- **Configurable Settings** - Easy customization through config files
- **Server-Side Management** - Secure advertisement management system

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib) - Required for UI components and interactions
- QBCore or QBox Framework (for player management)

## Installation

1. Download or clone this repository
2. Place the `hootro-ad` folder in your server's `resources` directory
3. Add `ensure hootro-ad` to your `server.cfg`
4. Ensure `ox_lib` is installed and running on your server
5. Configure the resource in `config.lua` to match your server's needs
6. Restart your server

## Configuration

Edit the `config.lua` file to customize:
- Advertisement costs and limits
- UI settings and styling
- Permission requirements
- Business categories and types
- Notification settings

## Usage

### For Players
- Use the configured command or keybind to open the advertisement interface
- Create, edit, and manage business advertisements
- View existing advertisements from other players

### For Administrators
- Monitor and moderate advertisements through server-side controls
- Configure pricing and restrictions
- Manage advertisement categories

## File Structure

```
hootro-ad/
├── client.lua          # Client-side logic and UI interactions
├── server.lua          # Server-side advertisement management
├── config.lua          # Configuration settings
├── fxmanifest.lua      # Resource manifest
├── index.html          # Main UI interface
├── style.css           # UI styling
└── script.js           # Frontend JavaScript logic
```

## Support

For support, please create an issue on the GitHub repository or contact the developer.

## License

This resource is provided as-is for the FiveM community.

## Version

Current Version: 2.0.0

## Author

**HootroSA** 
