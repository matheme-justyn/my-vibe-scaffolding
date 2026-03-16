# CLI DESIGN

**Status**: Active | **Domain**: Project Types  
**Related Modules**: LIBRARY_DESIGN, STYLE_GUIDE

## Purpose

This module defines standards for designing command-line interfaces (CLIs) that are intuitive, consistent, and delightful to use. It covers argument parsing, help text, output formatting, error handling, and interactive prompts.

## When to Use This Module

- Building CLI tools or applications
- Designing command structures and flags
- Writing help text and documentation
- Implementing interactive prompts
- Formatting output for terminal display
- Handling errors and exit codes

---

## 1. Core CLI Principles

### 1.1 Predictable Behavior

```bash
# ✅ GOOD: Consistent command structure
mycli <command> [subcommand] [options] [arguments]

mycli deploy --env production app-name
mycli config set database.host localhost
mycli user create --name "John Doe" --email john@example.com

# ❌ BAD: Inconsistent structure
mycli --env production deploy app-name
mycli database.host=localhost config set
mycli create-user John Doe john@example.com
```

### 1.2 Follow POSIX Conventions

```bash
# ✅ GOOD: Standard conventions
-v, --verbose     # Short and long forms
-f, --force       # Boolean flags
--output=json     # Long option with value
--output json     # Also accept space separator

# ✅ Multiple short flags can be combined
mycli -vf  # Same as mycli -v -f
```

---

## 2. Command Structure

### 2.1 Verb-Noun Pattern

```bash
# ✅ GOOD: Clear action (verb) + target (noun)
git commit
docker build
kubectl get pods
npm install package

# ❌ BAD: Ambiguous commands
git do
docker make
kubectl pods
npm package
```

### 2.2 Subcommands for Organization

```bash
# ✅ GOOD: Hierarchical structure
mycli user create
mycli user delete
mycli user list

mycli config get
mycli config set
mycli config reset

# Implementation example (Node.js with Commander)
const { Command } = require('commander');
const program = new Command();

program
  .name('mycli')
  .description('My awesome CLI tool')
  .version('1.0.0');

program
  .command('user')
  .description('Manage users')
  .action(() => {
    console.log('Use: mycli user <create|delete|list>');
  });

program
  .command('user:create')
  .description('Create a new user')
  .option('-n, --name <name>', 'User name')
  .option('-e, --email <email>', 'User email')
  .action((options) => {
    console.log('Creating user:', options);
  });
```

---

## 3. Flags and Options

### 3.1 Boolean Flags

```bash
# ✅ GOOD: Clear boolean flags
mycli deploy --force
mycli build --watch
mycli test --verbose

# Implementation (Node.js)
program
  .command('deploy')
  .option('-f, --force', 'Force deployment without confirmation')
  .option('-d, --dry-run', 'Show what would be deployed without actually deploying')
  .action((options) => {
    if (options.force) {
      // Skip confirmation
    }
  });
```

### 3.2 Options with Values

```bash
# ✅ GOOD: Options that accept values
mycli deploy --env production
mycli build --output dist/
mycli config --format json

# ✅ Support both = and space separators
mycli deploy --env=production
mycli deploy --env production

# Implementation
program
  .command('deploy')
  .option('-e, --env <environment>', 'Target environment', 'development')
  .option('-o, --output <path>', 'Output directory')
  .option('-f, --format <type>', 'Output format (json|yaml)', 'json')
  .action((options) => {
    console.log(`Deploying to ${options.env}`);
  });
```

### 3.3 Required vs Optional

```bash
# ✅ Clearly document required options
mycli deploy <app-name> --env <environment>

# Implementation
program
  .command('deploy <app-name>')  // Required positional argument
  .requiredOption('-e, --env <environment>', 'Target environment')
  .option('-f, --force', 'Force deployment')
  .action((appName, options) => {
    // appName is required
    // options.env is required
    // options.force is optional
  });
```

---

## 4. Help Text

### 4.1 Command-Level Help

```bash
# ✅ GOOD: Comprehensive help text
$ mycli deploy --help

Usage: mycli deploy [options] <app-name>

Deploy an application to the specified environment

Options:
  -e, --env <environment>  Target environment (required)
  -f, --force              Force deployment without confirmation
  -d, --dry-run            Show what would be deployed
  -h, --help               Display help for command

Examples:
  $ mycli deploy my-app --env production
  $ mycli deploy my-app --env staging --dry-run

# Implementation
program
  .command('deploy <app-name>')
  .description('Deploy an application to the specified environment')
  .requiredOption('-e, --env <environment>', 'Target environment')
  .option('-f, --force', 'Force deployment without confirmation')
  .option('-d, --dry-run', 'Show what would be deployed')
  .addHelpText('after', `
Examples:
  $ mycli deploy my-app --env production
  $ mycli deploy my-app --env staging --dry-run
  `)
  .action((appName, options) => {
    // ...
  });
```

### 4.2 Global Help

```bash
# ✅ GOOD: Top-level help overview
$ mycli --help

Usage: mycli [options] [command]

My awesome CLI tool for managing applications

Options:
  -V, --version       Output the version number
  -h, --help          Display help for command

Commands:
  deploy [options] <app-name>  Deploy an application
  build [options]              Build application assets
  config [options]             Manage configuration
  help [command]               Display help for command

Run 'mycli <command> --help' for detailed information on a command.
```

---

## 5. Output Formatting

### 5.1 Human-Readable Output

```bash
# ✅ GOOD: Clear, formatted output
$ mycli user list

ID     Name          Email                Status
────────────────────────────────────────────────────
1      John Doe      john@example.com     Active
2      Jane Smith    jane@example.com     Active
3      Bob Johnson   bob@example.com      Inactive
```

```javascript
// Implementation using cli-table3
const Table = require('cli-table3');

function displayUsers(users) {
  const table = new Table({
    head: ['ID', 'Name', 'Email', 'Status'],
    colWidths: [8, 20, 30, 12]
  });

  users.forEach(user => {
    table.push([user.id, user.name, user.email, user.status]);
  });

  console.log(table.toString());
}
```

### 5.2 Machine-Readable Output

```bash
# ✅ Support JSON output for scripts
$ mycli user list --format json

[
  {"id": 1, "name": "John Doe", "email": "john@example.com", "status": "Active"},
  {"id": 2, "name": "Jane Smith", "email": "jane@example.com", "status": "Active"}
]

# ✅ Support CSV output
$ mycli user list --format csv

ID,Name,Email,Status
1,John Doe,john@example.com,Active
2,Jane Smith,jane@example.com,Active
```

```javascript
// Implementation
program
  .command('user:list')
  .option('-f, --format <type>', 'Output format (table|json|csv)', 'table')
  .action(async (options) => {
    const users = await fetchUsers();
    
    switch (options.format) {
      case 'json':
        console.log(JSON.stringify(users, null, 2));
        break;
      case 'csv':
        console.log('ID,Name,Email,Status');
        users.forEach(u => console.log(`${u.id},${u.name},${u.email},${u.status}`));
        break;
      case 'table':
      default:
        displayUsersTable(users);
    }
  });
```

### 5.3 Colorized Output

```javascript
// ✅ Use colors for visual distinction
const chalk = require('chalk');

console.log(chalk.green('✓ Deployment successful'));
console.log(chalk.red('✗ Deployment failed'));
console.log(chalk.yellow('⚠ Warning: This action is irreversible'));
console.log(chalk.blue('ℹ Building assets...'));

// ✅ Respect NO_COLOR environment variable
const colors = process.env.NO_COLOR ? {
  success: (text) => text,
  error: (text) => text,
  warning: (text) => text,
  info: (text) => text
} : {
  success: chalk.green,
  error: chalk.red,
  warning: chalk.yellow,
  info: chalk.blue
};
```

---

## 6. Progress Indicators

### 6.1 Spinners

```javascript
// ✅ Show progress for long operations
const ora = require('ora');

const spinner = ora('Deploying application...').start();

try {
  await deploy();
  spinner.succeed('Deployment successful');
} catch (error) {
  spinner.fail('Deployment failed');
  console.error(error.message);
}
```

### 6.2 Progress Bars

```javascript
// ✅ Show progress for quantifiable tasks
const cliProgress = require('cli-progress');

const progressBar = new cliProgress.SingleBar({}, cliProgress.Presets.shades_classic);
progressBar.start(100, 0);

for (let i = 0; i <= 100; i++) {
  progressBar.update(i);
  await doWork();
}

progressBar.stop();
```

---

## 7. Interactive Prompts

### 7.1 Confirmation Prompts

```javascript
// ✅ Confirm destructive actions
const inquirer = require('inquirer');

async function deleteUser(userId) {
  const { confirm } = await inquirer.prompt([{
    type: 'confirm',
    name: 'confirm',
    message: 'Are you sure you want to delete this user? This action cannot be undone.',
    default: false
  }]);

  if (!confirm) {
    console.log('Cancelled');
    process.exit(0);
  }

  // Proceed with deletion
}

// ✅ Allow --yes flag to skip confirmation
program
  .command('user:delete <id>')
  .option('-y, --yes', 'Skip confirmation prompt')
  .action(async (id, options) => {
    if (!options.yes) {
      const { confirm } = await inquirer.prompt([{
        type: 'confirm',
        name: 'confirm',
        message: 'Are you sure?',
        default: false
      }]);
      
      if (!confirm) {
        console.log('Cancelled');
        process.exit(0);
      }
    }
    
    await deleteUser(id);
  });
```

### 7.2 Input Prompts

```javascript
// ✅ Interactive input for missing required options
async function promptForMissingOptions(options) {
  const questions = [];

  if (!options.name) {
    questions.push({
      type: 'input',
      name: 'name',
      message: 'User name:',
      validate: (input) => input.length > 0 || 'Name is required'
    });
  }

  if (!options.email) {
    questions.push({
      type: 'input',
      name: 'email',
      message: 'Email address:',
      validate: (input) => /\S+@\S+\.\S+/.test(input) || 'Valid email required'
    });
  }

  if (questions.length > 0) {
    const answers = await inquirer.prompt(questions);
    return { ...options, ...answers };
  }

  return options;
}
```

### 7.3 Selection Prompts

```javascript
// ✅ Let users select from options
const { environment } = await inquirer.prompt([{
  type: 'list',
  name: 'environment',
  message: 'Select deployment environment:',
  choices: ['development', 'staging', 'production'],
  default: 'development'
}]);

// ✅ Multi-select
const { features } = await inquirer.prompt([{
  type: 'checkbox',
  name: 'features',
  message: 'Select features to enable:',
  choices: [
    { name: 'Authentication', value: 'auth', checked: true },
    { name: 'Database', value: 'database' },
    { name: 'Caching', value: 'cache' }
  ]
}]);
```

---

## 8. Error Handling

### 8.1 Clear Error Messages

```javascript
// ✅ GOOD: Descriptive error messages
console.error(chalk.red('✗ Error: Invalid API key'));
console.error('Please check your API key in ~/.mycli/config.json');
console.error('Run "mycli config set api-key YOUR_KEY" to update');
process.exit(1);

// ❌ BAD: Cryptic error messages
console.error('Error: 401');
process.exit(1);
```

### 8.2 Exit Codes

```javascript
// ✅ Use standard exit codes
process.exit(0);   // Success
process.exit(1);   // General error
process.exit(2);   // Misuse of command
process.exit(126); // Command cannot execute
process.exit(127); // Command not found
process.exit(130); // User interrupted (Ctrl+C)

// Implementation
try {
  await runCommand();
  process.exit(0);
} catch (error) {
  if (error.code === 'ENOENT') {
    console.error('File not found:', error.path);
    process.exit(127);
  } else if (error.code === 'EACCES') {
    console.error('Permission denied:', error.path);
    process.exit(126);
  } else {
    console.error('Error:', error.message);
    process.exit(1);
  }
}
```

### 8.3 Validation Errors

```javascript
// ✅ Validate input early and clearly
program
  .command('deploy <app-name>')
  .requiredOption('-e, --env <environment>', 'Target environment')
  .action((appName, options) => {
    // Validate app name
    if (!/^[a-z0-9-]+$/.test(appName)) {
      console.error(chalk.red('Error: Invalid app name'));
      console.error('App name must contain only lowercase letters, numbers, and hyphens');
      process.exit(2);
    }

    // Validate environment
    const validEnvs = ['development', 'staging', 'production'];
    if (!validEnvs.includes(options.env)) {
      console.error(chalk.red(`Error: Invalid environment "${options.env}"`));
      console.error(`Valid environments: ${validEnvs.join(', ')}`);
      process.exit(2);
    }

    // Proceed with deployment
  });
```

---

## 9. Configuration Management

### 9.1 Config File Locations

```javascript
// ✅ Follow XDG Base Directory Specification
const os = require('os');
const path = require('path');

const CONFIG_DIR = process.env.XDG_CONFIG_HOME || path.join(os.homedir(), '.config');
const CONFIG_PATH = path.join(CONFIG_DIR, 'mycli', 'config.json');

// Fallback to legacy location
const LEGACY_CONFIG_PATH = path.join(os.homedir(), '.myclirc');
```

### 9.2 Config Commands

```bash
# ✅ Provide config management commands
mycli config get api-key
mycli config set api-key YOUR_KEY
mycli config list
mycli config reset
```

```javascript
// Implementation
program
  .command('config:get <key>')
  .action((key) => {
    const config = loadConfig();
    const value = config[key];
    if (value === undefined) {
      console.error(`Configuration key "${key}" not found`);
      process.exit(1);
    }
    console.log(value);
  });

program
  .command('config:set <key> <value>')
  .action((key, value) => {
    const config = loadConfig();
    config[key] = value;
    saveConfig(config);
    console.log(chalk.green(`✓ Set ${key} = ${value}`));
  });
```

---

## 10. Autocompletion

### 10.1 Shell Completion Scripts

```bash
# ✅ Generate completion scripts for popular shells
mycli completion bash > /etc/bash_completion.d/mycli
mycli completion zsh > ~/.zsh/completion/_mycli
mycli completion fish > ~/.config/fish/completions/mycli.fish
```

```javascript
// Implementation using omelette
const omelette = require('omelette');

const completion = omelette('mycli <command> <subcommand>');

completion.on('command', ({ reply }) => {
  reply(['deploy', 'build', 'config', 'user']);
});

completion.on('deploy', ({ reply }) => {
  reply(['--env', '--force', '--dry-run']);
});

completion.init();

// Add completion command
program
  .command('completion <shell>')
  .description('Generate shell completion script')
  .action((shell) => {
    completion.setupShellInitFile(shell);
  });
```

---

## 11. Best Practices

### 11.1 Provide Examples

```bash
# ✅ Always include examples in help text
$ mycli deploy --help

Examples:
  # Deploy to production
  $ mycli deploy my-app --env production

  # Dry run deployment
  $ mycli deploy my-app --env staging --dry-run

  # Force deployment without confirmation
  $ mycli deploy my-app --env production --force
```

### 11.2 Support Piping

```bash
# ✅ Work well with Unix pipes
mycli user list --format json | jq '.[] | select(.status == "Active")'
mycli config get api-key | pbcopy
```

### 11.3 Respect Environment Variables

```javascript
// ✅ Allow configuration via env vars
const API_KEY = process.env.MYCLI_API_KEY || config.apiKey;
const ENV = process.env.MYCLI_ENV || 'development';

program
  .command('deploy')
  .option('-e, --env <environment>', 'Target environment', ENV)
  .action((options) => {
    // Use options.env (from flag or env var)
  });
```

### 11.4 Provide Version Info

```bash
# ✅ Show version information
$ mycli --version
mycli/1.2.3 darwin-x64 node-v18.0.0
```

```javascript
program
  .version(require('./package.json').version, '-V, --version', 'Output the version number');
```

---

## Anti-Patterns

### ❌ Ambiguous Commands
Commands that don't clearly indicate their action.

**Solution**: Use verb-noun pattern (e.g., `user create` instead of `add-user`).

### ❌ No Help Text
Missing or inadequate help documentation.

**Solution**: Provide comprehensive help with examples.

### ❌ Silent Failures
Errors that fail silently without clear messages.

**Solution**: Always provide descriptive error messages and appropriate exit codes.

### ❌ Breaking Changes
Changing command structure in minor versions.

**Solution**: Follow semantic versioning, deprecate before removing.

### ❌ Requiring Unnecessary Input
Asking users to confirm non-destructive actions.

**Solution**: Only confirm destructive operations.

---

## Related Modules

- **LIBRARY_DESIGN** - Designing reusable libraries
- **STYLE_GUIDE** - Code conventions

---

## Resources

**Node.js Libraries**:
- Commander.js: https://github.com/tj/commander.js
- Inquirer.js: https://github.com/SBoudrias/Inquirer.js
- Chalk: https://github.com/chalk/chalk
- Ora: https://github.com/sindresorhus/ora

**Guidelines**:
- POSIX Utility Conventions: https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html
- Command Line Interface Guidelines: https://clig.dev/
