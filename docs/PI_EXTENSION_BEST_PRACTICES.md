# Pi Extension Best Practices Guide

## Overview

This document provides comprehensive best practices for developing, structuring, and publishing Pi agent extensions. Following these guidelines ensures your extensions are production-ready, maintainable, and easy for other users to consume.

---

## 1. Project Structure

### Single-File Extensions (Minimal)

Use for simple, focused extensions with no external dependencies:

```
my-extension.ts
```

**When to use:**
- Simple event listeners
- Single custom tool
- Basic command handlers
- No npm dependencies

### Multi-File Extensions (Recommended for Medium Complexity)

```
my-extension/
├── index.ts              # Entry point (exports default factory)
├── tools.ts              # Tool implementations
├── handlers.ts           # Event handlers
├── utils.ts              # Shared utilities
├── types.ts              # TypeScript types/interfaces
└── constants.ts          # Configuration constants
```

**When to use:**
- Multiple related tools or commands
- Shared utility logic
- Complex event handling
- Better code organization and maintainability

### Packaged Extensions (For Distribution)

```
pi-extension-name/
├── package.json          # Declares name, version, dependencies
├── package-lock.json
├── README.md             # Usage guide and examples
├── src/
│   ├── index.ts          # Extension entry point
│   ├── tools.ts
│   ├── handlers.ts
│   ├── utils.ts
│   └── types.ts
├── skills/               # Optional: bundled skills
│   └── SKILL.md
├── prompts/              # Optional: bundled prompts
│   └── custom.md
├── themes/               # Optional: bundled themes
│   └── dark.json
├── examples/             # Optional: usage examples
└── node_modules/         # After npm install
```

**When to use:**
- Publishing to npm or git
- Sharing with teams or public
- Complex functionality with dependencies
- Bundling related skills/prompts/themes

---

## 2. Package.json Configuration

### Minimal (Single-File or Simple Extensions)

```json
{
  "name": "pi-extension-my-extension",
  "version": "1.0.0",
  "type": "module",
  "description": "Brief description of what it does",
  "keywords": ["pi-extension", "custom-keyword"]
}
```

### Complete (Publishable Package)

```json
{
  "name": "@yourorg/pi-extension-name",
  "version": "1.2.0",
  "type": "module",
  "description": "Detailed description of extension functionality",
  "repository": {
    "type": "git",
    "url": "https://github.com/yourorg/pi-extension-name"
  },
  "homepage": "https://github.com/yourorg/pi-extension-name#readme",
  "bugs": {
    "url": "https://github.com/yourorg/pi-extension-name/issues"
  },
  "license": "MIT",
  "author": "Your Name <email@example.com>",
  "keywords": ["pi-package", "pi-extension", "domain-specific-keywords"],
  "scripts": {
    "clean": "rm -rf dist node_modules package-lock.json",
    "build": "tsc",
    "check": "tsc --noEmit",
    "test": "node --test"
  },
  "pi": {
    "extensions": ["./src/index.ts"],
    "skills": ["./skills"],
    "prompts": ["./prompts"],
    "themes": ["./themes"],
    "image": "https://example.com/screenshot.png",
    "video": "https://example.com/demo.mp4"
  },
  "dependencies": {
    "external-package": "^1.0.0"
  },
  "peerDependencies": {
    "@earendil-works/pi-coding-agent": "*",
    "@earendil-works/pi-tui": "*",
    "@earendil-works/pi-ai": "*",
    "typebox": "*"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "@types/node": "^20.0.0"
  }
}
```

### Key Guidelines

- **Name**: Use `pi-extension-*` or scope + `pi-extension-*` pattern
- **Keywords**: Always include `pi-extension` or `pi-package` for discoverability
- **Peer Dependencies**: Use `"*"` for core Pi packages; do NOT bundle them
- **Runtime Dependencies**: List in `dependencies`; bundled automatically via `npm install`
- **Gallery Metadata**: Add `image` or `video` for npm package gallery display
  - Video: MP4 only, autoplays on hover
  - Image: PNG, JPEG, GIF, or WebP

---

## 3. Extension Factory Function

### Basic Pattern

```typescript
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  // Synchronous initialization
  pi.on("session_start", async (event, ctx) => {
    // Event handling
  });
}
```

### Async Initialization (for Setup Work)

```typescript
export default async function (pi: ExtensionAPI) {
  // One-time async startup work (runs before session_start)
  const config = await fetchRemoteConfig();
  
  // Register dynamic providers/tools based on fetched data
  pi.registerProvider("custom", { /* config */ });

  // Return or complete before pi continues startup
}
```

**When to use async:**
- Fetching remote configuration
- Dynamic model/provider discovery
- Checking external services
- Pre-loading resources

### Important Lifecycle Considerations

```typescript
export default function (pi: ExtensionAPI) {
  // ✅ DO: Subscribe to events (deferred, safe)
  pi.on("session_start", async (event, ctx) => {
    // Run when session starts
  });

  // ❌ DON'T: Start background resources in factory
  // setInterval(() => { /* bad */ }); // Will leak across invocations
  // fs.watch(path, ...); // Will leak

  // ✅ DO: Start resources in session_start
  pi.on("session_start", async (event, ctx) => {
    const watcher = fs.watch(path, handleFileChange);
    // Save reference for cleanup
  });

  // ✅ DO: Clean up in session_shutdown
  pi.on("session_shutdown", async (event, ctx) => {
    watcher.close();
  });
}
```

---

## 4. Event Handling

### Critical Events

#### `session_start` – Initialize Per-Session State

```typescript
pi.on("session_start", async (event, ctx) => {
  // event.reason: "startup" | "reload" | "new" | "resume" | "fork"
  // event.previousSessionFile?: string (for "new"/"resume"/"fork")

  // Reconstruct state from session history
  const entries = ctx.sessionManager.getEntries();
  
  // Start session-scoped resources
  const watcher = fs.watch(ctx.cwd, handleChange);
  
  // Notify user
  ctx.ui.notify("Extension initialized", "info");
});
```

#### `session_shutdown` – Clean Up Resources

```typescript
pi.on("session_shutdown", async (event, ctx) => {
  // event.reason: "quit" | "reload" | "new" | "resume" | "fork"

  // Close all open resources
  watcher?.close();
  connection?.disconnect();
  timers.forEach(clearTimeout);

  // Save state if needed
  await saveExtensionState(ctx.cwd);
});
```

#### `before_agent_start` – Inject Context or Modify Prompt

```typescript
pi.on("before_agent_start", async (event, ctx) => {
  // event.prompt: user's input text
  // event.systemPrompt: current chained system prompt
  // event.systemPromptOptions: structured config data

  // Modify system prompt (chained across extensions)
  return {
    systemPrompt: event.systemPrompt + "\n\nExtra instructions...",
    
    // Or inject a persistent message
    message: {
      customType: "my-extension",
      content: "Additional context",
      display: true,
    }
  };
});
```

#### `tool_call` – Block or Patch Tool Arguments

```typescript
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";

pi.on("tool_call", async (event, ctx) => {
  // Block dangerous commands
  if (isToolCallEventType("bash", event)) {
    if (event.input.command.includes("rm -rf")) {
      const ok = await ctx.ui.confirm("Dangerous!", "Allow rm -rf?");
      if (!ok) return { block: true, reason: "User declined" };
    }
    
    // Patch arguments
    event.input.command = `set -e\n${event.input.command}`;
  }

  if (isToolCallEventType("read", event)) {
    console.log(`Reading: ${event.input.path}`);
  }
});
```

#### `tool_result` – Modify or Summarize Results

```typescript
pi.on("tool_result", async (event, ctx) => {
  // event.toolName, event.toolCallId
  // event.content, event.details, event.isError

  // Transform result
  if (event.toolName === "bash" && !event.isError) {
    const summarized = await summarizeOutput(event.content);
    return { content: summarized };
  }

  // Fetch external data
  if (event.toolName === "my_tool") {
    const enriched = await enrichWithExternalData(event.content);
    return { details: enriched };
  }
});
```

#### `input` – Transform or Handle User Input

```typescript
pi.on("input", async (event, ctx) => {
  // event.text: raw input (before skill/template expansion)
  // event.images: attached images (if any)
  // event.source: "interactive" | "rpc" | "extension"

  // Transform input
  if (event.text.startsWith("?brief ")) {
    return { action: "transform", text: `Be concise: ${event.text.slice(7)}` };
  }

  // Handle without LLM
  if (event.text === "ping") {
    ctx.ui.notify("pong", "info");
    return { action: "handled" };
  }

  // Let pass through
  return { action: "continue" };
});
```

### Event Handler Pattern

```typescript
export default function (pi: ExtensionAPI) {
  // Always use async handlers (even if you don't await anything)
  pi.on("event_name", async (event, ctx) => {
    try {
      // Handle event
    } catch (error) {
      // Log errors; don't throw (prevents other handlers from running)
      console.error("Extension error:", error);
      ctx.ui.notify(`Error: ${error.message}`, "error");
    }
  });
}
```

---

## 5. Registering Custom Tools

### Minimal Tool

```typescript
import { Type } from "typebox";

pi.registerTool({
  name: "my_tool",
  label: "My Tool",
  description: "What this tool does",
  parameters: Type.Object({
    input: Type.String({ description: "Input text" }),
  }),
  async execute(toolCallId, params, signal, onUpdate, ctx) {
    return {
      content: [{ type: "text", text: `Result: ${params.input}` }],
      details: {},
    };
  },
});
```

### Complete Tool with Options

```typescript
import { Type } from "typebox";
import { StringEnum } from "@earendil-works/pi-ai";

pi.registerTool({
  name: "advanced_tool",
  label: "Advanced Tool",
  description: "Performs complex operations",
  
  // Include in system prompt with one-line summary
  promptSnippet: "Transform or analyze data according to mode",
  
  // Add tool-specific guidelines (use "my_tool" not "this tool")
  promptGuidelines: [
    "Use advanced_tool when the user asks for data transformation.",
    "Prefer advanced_tool for batch operations over single operations.",
  ],
  
  parameters: Type.Object({
    mode: StringEnum(["analyze", "transform", "validate"] as const, {
      description: "Operation mode"
    }),
    data: Type.String({ description: "Input data" }),
    options: Type.Optional(Type.Object({
      strict: Type.Boolean({ description: "Strict validation" }),
    })),
  }),

  // Optional: Compatibility shim for schema changes
  prepareArguments(args) {
    // Fold legacy fields into modern shape
    return args;
  },

  async execute(toolCallId, params, signal, onUpdate, ctx) {
    // Stream progress updates
    onUpdate?.({
      content: [{ type: "text", text: "Processing..." }]
    });

    // Check abort signal
    if (signal?.aborted) throw new Error("aborted");

    // Do work
    const result = await performWork(params, signal);

    return {
      content: [{ type: "text", text: result.output }],
      details: { mode: params.mode, itemsProcessed: result.count },
    };
  },

  // Optional: Custom rendering (advanced)
  renderCall(args, theme, context) {
    // Return TUI component for tool call display
    return new Text(`${args.mode}: ${args.data}`, 0, 0);
  },

  renderResult(result, { expanded }, theme, context) {
    // Return TUI component for result display
    const details = result.details as any;
    return new Text(`Processed ${details.itemsProcessed} items`, 0, 0);
  },
});
```

### Tool Parameter Schema Best Practices

```typescript
import { Type } from "typebox";
import { StringEnum } from "@earendil-works/pi-ai";

// ✅ Use StringEnum for fixed choices
const modeParam = StringEnum(["read", "write", "append"] as const, {
  description: "File mode"
});

// ✅ Mark optional parameters
const optionalParam = Type.Optional(
  Type.String({ description: "Optional input" })
);

// ✅ Provide clear descriptions
const pathParam = Type.String({
  description: "Absolute or relative path to file",
  examples: ["/home/user/file.txt", "./local.txt"],
});

// ✅ Use numeric ranges for bounded values
const limitParam = Type.Number({
  description: "Maximum results",
  minimum: 1,
  maximum: 1000,
});

// ✅ Combine for complex tools
const params = Type.Object({
  mode: modeParam,
  path: pathParam,
  limit: Type.Optional(limitParam),
  force: Type.Optional(Type.Boolean({ description: "Override checks" })),
});
```

### Tool Execution Best Practices

```typescript
async execute(toolCallId, params, signal, onUpdate, ctx) {
  // 1. Check abort signal immediately
  if (signal?.aborted) throw new Error("aborted");

  // 2. Validate parameters (though schema should pre-validate)
  if (!params.path) throw new Error("path is required");

  // 3. Stream progress for long operations
  onUpdate?.({
    content: [{ type: "text", text: "Starting operation..." }]
  });

  try {
    // 4. Respect abort signal throughout
    const result = await someAsyncWork(params, signal);

    // 5. Return properly formatted result
    return {
      content: [{ type: "text", text: result.output }],
      details: { /* metadata */ },
      // Don't set isError unless true
    };
  } catch (error) {
    // 6. Return errors with isError: true
    if (signal?.aborted) throw new Error("aborted");
    
    return {
      content: [{ type: "text", text: `Error: ${error.message}` }],
      details: { error: error.message },
      isError: true,
    };
  }
}
```

---

## 6. Registering Commands

### Basic Command

```typescript
pi.registerCommand("mycommand", {
  description: "What this command does",
  handler: async (args, ctx) => {
    ctx.ui.notify(`You said: ${args}`, "info");
  },
});
```

### Command with User Interaction

```typescript
pi.registerCommand("configure", {
  description: "Configure the extension",
  handler: async (args, ctx) => {
    const mode = await ctx.ui.select(
      "Choose mode:",
      ["development", "production"]
    );
    
    const confirmed = await ctx.ui.confirm(
      "Apply settings?",
      `Switch to ${mode}?`
    );
    
    if (confirmed) {
      ctx.ui.notify(`Configured: ${mode}`, "success");
    }
  },
});
```

### Command with Session Control

```typescript
pi.registerCommand("fork-session", {
  description: "Fork current session",
  handler: async (args, ctx) => {
    const sessionFile = ctx.sessionManager.getSessionFile();
    
    // Wait for agent to finish
    await ctx.waitForIdle();
    
    // Create new session
    const result = await ctx.newSession({
      parentSession: sessionFile,
      setup: async (sm) => {
        sm.appendMessage({
          role: "user",
          content: [{ type: "text", text: "Continue here..." }],
          timestamp: Date.now(),
        });
      },
      withSession: async (newCtx) => {
        // Use only the new context here
        await newCtx.sendUserMessage("Starting fresh fork");
      },
    });

    if (!result.cancelled) {
      ctx.ui.notify("Fork created successfully", "info");
    }
  },
});
```

### Command Pattern

```typescript
pi.registerCommand("name", {
  description: "User-facing help text",
  handler: async (args, ctx) => {
    // args: everything after /name
    // ctx: ExtensionCommandContext (includes session control)

    try {
      // Do work
    } catch (error) {
      ctx.ui.notify(`Error: ${error.message}`, "error");
    }
  },
});
```

---

## 7. State Management

### Session-Based State (Recommended)

Store state in tool result details so it's preserved in session history and correctly branches:

```typescript
interface MyState {
  todos: string[];
  count: number;
}

let state: MyState = { todos: [], count: 0 };

// Reconstruct state from session
function reconstructState(ctx: ExtensionContext) {
  state = { todos: [], count: 0 };

  for (const entry of ctx.sessionManager.getBranch()) {
    if (entry.type !== "message") continue;
    const msg = entry.message;
    
    // Find tool results from your tool
    if (msg.role === "toolResult" && msg.toolName === "my_tool") {
      const details = msg.details as MyState | undefined;
      if (details) state = details;
    }
  }
}

// Restore on session events
pi.on("session_start", async (_event, ctx) => {
  reconstructState(ctx);
});

pi.on("session_tree", async (_event, ctx) => {
  reconstructState(ctx);
});

// Return state in tool results
pi.registerTool({
  name: "my_tool",
  // ...
  async execute(_id, params, _signal, _onUpdate, _ctx) {
    // Mutate state
    state.todos.push(params.text);
    state.count++;

    return {
      content: [{ type: "text", text: `Added: ${params.text}` }],
      details: { ...state }, // Store state in result
    };
  },
});
```

### In-Memory Configuration

Store extension config in a file, load on `session_start`:

```typescript
import { join } from "node:path";
import { CONFIG_DIR_NAME } from "@earendil-works/pi-coding-agent";

let config: MyConfig = { /* defaults */ };

pi.on("session_start", async (_event, ctx) => {
  const configPath = join(ctx.cwd, CONFIG_DIR_NAME, "my-extension.json");
  try {
    const raw = await fs.promises.readFile(configPath, "utf-8");
    config = JSON.parse(raw);
  } catch {
    // Use defaults if file doesn't exist
  }
});
```

### Avoiding State Loss

```typescript
// ❌ BAD: State lost on reload/fork/switch
let globalState = { /* ... */ };

// ✅ GOOD: Reconstructed from session
pi.on("session_start", async (_event, ctx) => {
  reconstructFromSessionHistory(ctx);
});

pi.on("session_tree", async (_event, ctx) => {
  reconstructFromSessionHistory(ctx);
});
```

---

## 8. Error Handling

### Handler Error Pattern

```typescript
pi.on("event_name", async (event, ctx) => {
  try {
    // Do work
  } catch (error) {
    // Don't rethrow; log and notify
    console.error("Extension error:", error);
    ctx.ui.notify(`Error: ${error.message}`, "error");
    // Return nothing to let other handlers continue
  }
});
```

### Tool Execution Error Pattern

```typescript
async execute(toolCallId, params, signal, onUpdate, ctx) {
  try {
    const result = await doWork(params);
    return { content: [...], details: result };
  } catch (error) {
    // Check if aborted (user interrupted)
    if (signal?.aborted) throw new Error("aborted");
    
    // Return as tool error
    return {
      content: [{ type: "text", text: `Error: ${error.message}` }],
      details: { error: error.message },
      isError: true,
    };
  }
}
```

### Resource Cleanup on Error

```typescript
pi.on("session_shutdown", async (event, ctx) => {
  // Always cleanup, even if initialization failed
  try {
    await resource?.close();
  } catch (cleanupError) {
    console.error("Cleanup error:", cleanupError);
  }
});
```

---

## 9. Context Usage

### Available Context Methods

```typescript
pi.on("some_event", async (event, ctx) => {
  // UI interaction
  ctx.ui.notify("message", "info" | "success" | "error" | "warn");
  const choice = await ctx.ui.select("title", ["opt1", "opt2"]);
  const confirmed = await ctx.ui.confirm("title", "question");
  const input = await ctx.ui.input("title", "placeholder?");

  // Status and widgets
  ctx.ui.setStatus("ext-name", "Processing...");
  ctx.ui.setWidget("ext-name", ["Line 1", "Line 2"]);
  ctx.ui.setTitle("Custom Title");

  // Session access
  const entries = ctx.sessionManager.getEntries();
  const branch = ctx.sessionManager.getBranch();
  const leafId = ctx.sessionManager.getLeafId();

  // Mode detection
  if (ctx.mode === "tui") { /* interactive */ }
  if (ctx.hasUI) { /* can prompt */ }

  // Abort signal
  if (ctx.signal?.aborted) throw new Error("aborted");

  // System prompt
  const prompt = ctx.getSystemPrompt();

  // Control flow
  ctx.isIdle();
  ctx.hasPendingMessages();
  ctx.shutdown();
});
```

### Guard TUI-Only Features

```typescript
pi.registerCommand("interactive", {
  handler: async (args, ctx) => {
    // Only in TUI mode
    if (ctx.mode !== "tui") {
      ctx.ui.notify("Interactive mode required", "error");
      return;
    }

    await ctx.ui.custom((tui, theme, kb, done) => {
      // Custom TUI component
      return new MyComponent(done);
    });
  },
});
```

---

## 10. Dynamic Tool Registration

Tools can be registered after startup (not just in factory):

```typescript
pi.on("session_start", async (event, ctx) => {
  // Discover available tools at runtime
  const tools = await discoverTools(ctx.cwd);

  for (const tool of tools) {
    pi.registerTool({
      name: tool.name,
      description: tool.description,
      parameters: tool.schema,
      async execute(id, params, signal, onUpdate, ctx) {
        return tool.execute(params, signal);
      },
    });
  }
});

// Enable/disable tools at runtime
pi.on("model_select", async (event, ctx) => {
  const activateFor = {
    "gpt-4": ["expensive_tool", "gpu_tool"],
    "gpt-3.5-turbo": ["lightweight_tool"],
  };

  const toActivate = activateFor[event.model.id] ?? [];
  pi.setActiveTools(toActivate);
});
```

---

## 11. Documentation

### README.md Template

```markdown
# Pi Extension Name

Brief description of what the extension does.

## Features

- Feature 1
- Feature 2
- Feature 3

## Installation

\`\`\`bash
pi install npm:@org/extension-name
\`\`\`

## Usage

### Custom Tools

- **my_tool**: Description
  \`\`\`
  LLM can call: my_tool(mode: "analyze|transform", data: string)
  \`\`\`

### Commands

- **/mycommand**: Description
  \`\`\`bash
  /mycommand [args]
  \`\`\`

## Configuration

Create `.pi/extension-config.json`:

\`\`\`json
{
  "setting1": "value",
  "setting2": true
}
\`\`\`

## Examples

\`\`\`typescript
// The extension automatically:
// - Does X on session start
// - Blocks dangerous operations
// - Transforms results
\`\`\`

## Development

\`\`\`bash
npm install
npm run check      # TypeScript check
npm run build      # Build if needed
\`\`\`

Test locally:

\`\`\`bash
cd /some/project
pi -e /path/to/extension
\`\`\`

## License

MIT
```

### Code Comments

```typescript
/**
 * Fetches remote configuration during startup.
 * 
 * @throws Error if network unavailable
 * @returns Promise resolving to configuration object
 */
async function fetchConfig(): Promise<Config> {
  // Implementation
}

/**
 * Reconstructs extension state from session history.
 * Called on session_start and session_tree.
 */
function reconstructState(ctx: ExtensionContext): void {
  // Implementation
}
```

---

## 12. Testing

### Unit Test Pattern

```typescript
// test/tools.test.ts
import { test } from "node:test";
import assert from "node:assert";

test("my_tool transforms input correctly", async () => {
  const result = await myToolExecute({ input: "test" });
  assert.strictEqual(result.content[0].text, "expected output");
});
```

### Manual Testing

```bash
# Test locally before publishing
cd /path/to/test/project
pi -e /path/to/extension

# Try all features:
# - Commands: /mycommand
# - Tools: Ask LLM to use them
# - Events: Verify behavior
# - Edge cases: Test error handling
```

---

## 13. Publishing to npm

### Pre-Publish Checklist

- [ ] TypeScript passes `npm run check` or `tsc --noEmit`
- [ ] README.md with clear usage instructions
- [ ] All tools and commands documented
- [ ] Error handling implemented
- [ ] `session_shutdown` cleanup implemented
- [ ] Tested locally with `pi -e ./extension`
- [ ] package.json has proper metadata
- [ ] Keywords include `pi-extension` or `pi-package`
- [ ] License file included
- [ ] `.npmignore` excludes unnecessary files

### .npmignore

```
src/
examples/
test/
*.test.ts
tsconfig.json
.github/
.gitignore
README.dev.md
```

### Publish Steps

```bash
# Build/check
npm run check

# Test
npm run test

# Bump version
npm version minor  # or patch, major

# Publish
npm publish

# Tag in git
git tag v1.2.3
git push origin v1.2.3
```

---

## 14. Publishing to Git

### Structure for Git Distribution

```
repo/
├── package.json        # Declares resources
├── src/
│   └── index.ts
├── skills/            # Optional
├── prompts/           # Optional
├── themes/            # Optional
├── README.md
├── LICENSE
└── .gitignore
```

### Git Install

```bash
# Users install via:
pi install git:github.com/yourorg/repo@v1.0.0
pi install ssh://git@github.com/yourorg/repo@v1.0.0

# Update refs
pi update npm:@yourorg/repo
```

---

## 15. Common Patterns

### Permission Gate

Block dangerous operations:

```typescript
pi.on("tool_call", async (event, ctx) => {
  if (isToolCallEventType("bash", event)) {
    if (event.input.command.includes("sudo") ||
        event.input.command.includes("rm -rf")) {
      const ok = await ctx.ui.confirm(
        "Dangerous Operation",
        `Allow: ${event.input.command}?`
      );
      if (!ok) return { block: true, reason: "User denied" };
    }
  }
});
```

### Path Protection

Prevent writing to sensitive directories:

```typescript
pi.on("tool_call", async (event, ctx) => {
  if (isToolCallEventType("write", event)) {
    const banned = [".env", ".git", "node_modules"];
    if (banned.some(p => event.input.path.includes(p))) {
      return { block: true, reason: "Protected path" };
    }
  }
});
```

### Result Summarization

Compress verbose outputs:

```typescript
pi.on("tool_result", async (event, ctx) => {
  if (event.toolName === "bash" && event.content[0]?.text?.length > 5000) {
    const summarized = await summarizeOutput(event.content[0].text);
    return { content: [{ type: "text", text: summarized }] };
  }
});
```

### Custom LLM Routing

Dynamically choose model for specific operations:

```typescript
pi.on("before_agent_start", async (event, ctx) => {
  if (event.prompt.includes("analyze")) {
    // Switch to reasoning model for analysis
    return {
      systemPrompt: event.systemPrompt + "\nUse detailed reasoning for this task."
    };
  }
});
```

---

## 16. Performance Considerations

### Avoid N+1 Queries

```typescript
// ❌ BAD: Multiple fetches in loop
for (const item of items) {
  const data = await fetchData(item.id);
}

// ✅ GOOD: Batch fetch
const allData = await fetchDataBatch(items.map(i => i.id));
```

### Cache When Appropriate

```typescript
let cachedConfig: Config | null = null;

pi.on("session_start", async (event, ctx) => {
  cachedConfig = await loadConfig(ctx.cwd);
});

pi.on("tool_call", async (event, ctx) => {
  // Reuse cached config
  if (cachedConfig) {
    // Use cache
  }
});
```

### Minimize System Prompt Mutations

```typescript
// ❌ BAD: Multiple appends
pi.on("before_agent_start", async (event, ctx) => {
  return {
    systemPrompt: event.systemPrompt + "\nAdditional 1"
  };
});

pi.on("before_agent_start", async (event, ctx) => {
  return {
    systemPrompt: event.systemPrompt + "\nAdditional 2"
  };
});

// ✅ GOOD: Combine in one handler or early registration
```

---

## 17. Version Compatibility

### Declare Dependencies Properly

```json
{
  "peerDependencies": {
    "@earendil-works/pi-coding-agent": "*",
    "@earendil-works/pi-tui": "*",
    "typebox": "*"
  }
}
```

### Check API Availability at Runtime

```typescript
export default function (pi: ExtensionAPI) {
  // Graceful degradation
  if (typeof pi.registerCommand === "function") {
    pi.registerCommand("feature", { /* ... */ });
  }
}
```

---

## Summary Checklist

### Before Publishing

- [ ] Clear, single responsibility
- [ ] Proper file structure
- [ ] package.json with `pi` manifest
- [ ] All peer dependencies correct
- [ ] Comprehensive README
- [ ] Error handling throughout
- [ ] Resource cleanup in `session_shutdown`
- [ ] TypeScript types
- [ ] Tested locally with `pi -e ./`
- [ ] No console spam; use `ctx.ui.notify()`
- [ ] State management via tool details
- [ ] Event handlers are idempotent
- [ ] Graceful degradation for missing features

### After Publishing

- [ ] Tag release in git
- [ ] Update gallery image/video (npm)
- [ ] Announce in appropriate channels
- [ ] Monitor issues and PRs
- [ ] Keep documentation updated
- [ ] Test against new pi versions
- [ ] Respond to user feedback

---

## Additional Resources

- **Extension Documentation**: See Pi extension docs in the main documentation
- **Examples**: Explore working examples (todo, gondolin, pirate, etc.)
- **API Reference**: Full ExtensionAPI and event types
- **Session Format**: Understanding state persistence
- **Custom UI**: Building interactive components

