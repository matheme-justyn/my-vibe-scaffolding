專案自己的 agents 放這裡

這個目錄保留給專案特定的 AI agents。

Template 提供的 agents 在 `.scaffolding/agents/`

## 技能載入順序

1. `.agents/skills/` (專案自己的，最高優先)
2. `.scaffolding/agents/skills/` (Template 提供的)
3. `~/.config/opencode/skills/` (使用者安裝的 Superpowers)

