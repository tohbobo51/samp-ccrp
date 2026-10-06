# SA-MP Gamemode Development Guide

## Build Commands
- Windows: `.\pawno\pawncc.exe mymode.pwn -Dgamemodes -;+ -(+ -d3 -S8129`
- Linux: `./pawno/pawncc -Dgamemodes mymode.pwn -\;+ -\(+ -d3 -Z+`

## Code Style Guidelines
- **Variables**: 
  - Local variables: `l_` prefix (e.g., `l_playerHealth`)
  - Global variables: `g` prefix (e.g., `gDEBUG_MODE`)
  - Constants: `UPPERCASE` (e.g., `COLOR_WHITE`)
- **Functions**: 
  - Use PascalCase for main functions (e.g., `InitVariables`)
  - Use camelCase for helpers (e.g., `getTime`)
  - Use `hook` keyword for callback extensions
- **Formatting**:
  - 4-space indentation
  - Opening braces on same line as statements
  - Space after keywords and around operators
- **Error Handling**:
  - Use `Logger_Log` for structured logging
  - Return 1 for success in functions
- **File Organization**:
  - Variable declarations in `*_var.pwn` files
  - Separate code into functional modules
  - Use Redis for caching, MySQL for persistent data

Remember to follow the established module structure and patterns found throughout the codebase.