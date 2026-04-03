# Cortex Code Hands-On Lab: From Snowsight to CLI

**Duration:** 90 minutes  
**Level:** Intermediate  
**Prerequisites:** Snowflake account with Cortex Code enabled, Cortex Code CLI installed (`cortex --version` to verify)

---

## Lab Overview

In this lab you will use **Cortex Code** in two environments to accelerate your development workflow:

| Part | Environment | What You'll Do | Time |
|------|-------------|----------------|------|
| **1** | Snowsight (Web IDE) | Debug and extend a Python notebook that builds an ML model on sales data | 40 min |
| **2** | Cortex Code CLI (Terminal) | Build a custom skill, hook, and project rules file | 50 min |

---

## Part 1: Cortex Code in Snowsight (40 min)

### Context

Your team has a Python notebook that loads sales data, engineers features, and trains a model to predict whether a customer will churn. Unfortunately, the notebook has several bugs and is missing key sections. You'll use Cortex Code in Snowsight to fix and extend it.

### Setup (5 min)

1. Log into Snowsight
2. Navigate to **Projects > Notebooks**
3. Import the provided notebook: `sales_churn_model.ipynb`
4. Select the **Python 3 (Anaconda)** kernel and attach a warehouse

### Exercise 1: Fix the Bugs (15 min)

The notebook has **5 intentional errors**. Use Cortex Code to find and fix them.

**How to use Cortex Code in Snowsight:**
- Open the Cortex Code panel (AI assistant icon in the notebook toolbar)
- Select the broken cell and ask Cortex Code to help debug it
- You can also highlight specific code and ask for explanations

**Bugs to find:**
1. **Cell 2** - Data loading: A SQL query has a syntax error
2. **Cell 4** - Feature engineering: A column reference uses the wrong name
3. **Cell 5** - Train/test split: The target variable is leaked into the features
4. **Cell 6** - Model training: Wrong scikit-learn import path
5. **Cell 7** - Evaluation: Metrics function called with arguments in the wrong order

> **Tip:** Try asking Cortex Code: *"Review this cell for errors and suggest fixes"*

### Exercise 2: Add New Features (10 min)

With the bugs fixed, extend the notebook using Cortex Code:

1. **Add a feature importance visualization** - Ask Cortex Code to add a cell that plots the top 10 most important features using a horizontal bar chart
2. **Add cross-validation** - Ask Cortex Code to replace the single train/test split with 5-fold cross-validation and print the mean and standard deviation of accuracy scores
3. **Add Experiments** - Ask it to add experiments for the built model.

> **Tip:** Try asking: *"Add a cell after cell 7 that shows feature importance as a horizontal bar chart"*

### Exercise 3: Write Results to Snowflake (10 min)

Ask Cortex Code to help you add a final cell that:
1. Creates a predictions DataFrame with customer ID, actual label, and predicted label
2. Writes the predictions to a new Snowflake table called `CHURN_PREDICTIONS`
3. Logs the model's accuracy, precision, and recall as a comment on the table

> **Tip:** Use the `#` syntax to reference tables: *"Write predictions to #MY_DB.MY_SCHEMA.CHURN_PREDICTIONS"*

---

## Part 2: Cortex Code CLI (50 min)

### Context

Now you'll switch to the terminal and use Cortex Code CLI to build extensibility components: a **custom skill**, a **hook**, and **project rules**.

### Setup (5 min)

1. Open your terminal
2. Navigate to your project directory:
   ```bash
   cd ~/cortex-code-lab
   ```
3. Start Cortex Code:
   ```bash
   cortex
   ```
4. Verify your connection:
   ```
   /status
   ```

5. Show Available Commands:
   ```
   /help
   ```

### Exercise 4: Build a Custom Skill - Model Reviewer (20 min)

You've been given a starter skill template (`model-reviewer`). Your goal is to customize it so that Cortex Code can review any ML model notebook and suggest improvements.

#### Step 1: Copy the template into your project

```bash
mkdir -p .cortex/skills/model-reviewer
cp ~/cortex-code-lab/skill-template/model-reviewer/SKILL.md .cortex/skills/model-reviewer/SKILL.md
```

#### Step 2: Review the template

```bash
cat .cortex/skills/model-reviewer/SKILL.md
```

The template provides the basic structure. Your job is to **edit and improve** the skill so it gives the best possible model review.

#### Step 3: Customize the skill

Open the skill file and enhance it. Consider adding:

- **Feature engineering suggestions** - Should the reviewer suggest new feature ideas?
- **Hyperparameter tuning advice** - Should it check for default hyperparameters and suggest tuning?
- **Data quality checks** - Should it flag potential data leakage, class imbalance, or missing value handling?
- **Model selection guidance** - Should it suggest alternative algorithms based on the data characteristics?
- **Production readiness checks** - Should it verify logging, error handling, and serialization?
- **Evaluation criteria** - Should it recommend additional metrics beyond accuracy?

> **Tip:** Use `$skill-development` to get help building your skill:
> ```
> $skill-development audit .cortex/skills/model-reviewer/SKILL.md
> ```

#### Step 4: Test your skill

Run your skill against the notebook from Part 1:

```
$model-reviewer Review @sales_churn_model.ipynb
```

Evaluate the quality of the review. Iterate on your SKILL.md to improve the output.

#### Competition

At the end of this exercise, each participant will run their skill against the same notebook. The group will vote on which skill produces the most actionable and thorough review.

**Scoring criteria:**
- Actionability (are suggestions specific and implementable?)
- Coverage (does it catch a wide range of potential improvements?)
- Prioritization (does it help the user focus on what matters most?)
- Clarity (is the output well-organized and easy to follow?)

### Exercise 5: Create a Hook (10 min)

Hooks add deterministic guardrails to Cortex Code. You'll create a `PreToolUse` hook that validates SQL queries before they are executed.

#### Step 1: Create the hook script

```bash
mkdir -p cortex/hooks
```

Copy the provided hook script:
```bash
cp ~/cortex-code-lab/hook/validate-sql.sh cortex/hooks/validate-sql.sh
chmod +x cortex/hooks/validate-sql.sh
```
Example in my environment:
```bash
cp ~/Desktop/Agent_projects/COCO_HOL/lab/part2_cli/hook/validate-sql.sh ~/.snowflake/cortex/hooks/validate-sql.sh

```

#### Step 2: Review the hook script

```bash
cat .snowflake/cortex/hooks/validate-sql.sh
```

This hook intercepts `snowflake_sql_execute` calls and blocks any SQL that contains `DROP`, `DELETE`, or `TRUNCATE` without a `WHERE` clause.

#### Step 3: Configure the hook

Create the project-level settings file:

```bash
cat > .snowflake/cortex/settings.json << 'EOF'
{
  "cortexAgentConnectionName": "SnowHouse",
  "theme": "dark",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "snowflake_sql_execute",
        "hooks": [
          {
            "type": "command",
            "command": "/Users/cescobarrood/.snowflake/cortex/hooks/validate-sql.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
EOF
```

#### Step 4: Test the hook

Create a table to be tested:
```
/sql create table drop_me as select * from analytics.sales.drop_me
```

Start a new Cortex Code session and try running dangerous SQL:

```
Can you drop the table analytics.sales.drop_me
```

The hook should block the operation and explain why.

Now try a safe query:
```
/sql SELECT COUNT(*) FROM my_table
```

This should execute normally.

#### Bonus: Extend the hook

Try adding additional validation rules:
- Block `SELECT *` on large tables (suggest adding a `LIMIT`)
- Warn when running queries without a warehouse set
- Log all executed SQL to a local audit file

### Exercise 6: Define Project Rules with AGENTS.md (15 min)

`AGENTS.md` is loaded automatically at the start of every Cortex Code session in your project. It provides persistent project context and rules.

#### Step 1: Create AGENTS.md

Copy the provided template:
```bash
cp ~/cortex-code-lab/project-setup/AGENTS.md ./AGENTS.md
```

#### Step 2: Review the template

```bash
cat AGENTS.md
```

#### Step 3: Customize the rules

Edit `AGENTS.md` to add rules specific to your team's workflow. Consider:

- **SQL conventions** - e.g., "Always use `QUALIFY ROW_NUMBER()` for deduplication, never use subqueries"
- **Naming conventions** - e.g., "All staging tables must be prefixed with `STG_`"
- **Safety rules** - e.g., "Never execute DDL on production schemas without confirmation"
- **Model conventions** - e.g., "Always log model metrics to the MODEL_REGISTRY table"
- **Code style** - e.g., "Use type hints in all Python functions"

#### Step 4: Test your rules

Start a new session (the rules load on session start):

```
/new
```

Then ask Cortex Code to do something that should trigger a rule:

```
Write a SQL query to deduplicate the customers table
```

Verify that Cortex Code follows your rules (e.g., uses `QUALIFY` instead of subqueries).

---

## Wrap-Up (5 min)

### What You Built Today

| Component | Location | Purpose |
|-----------|----------|---------|
| Fixed notebook | Snowsight | Debugged and extended an ML pipeline |
| Custom skill | `.cortex/skills/model-reviewer/` | Reusable ML model review instructions |
| Hook script | `.cortex/hooks/validate-sql.sh` | SQL safety guardrails |
| AGENTS.md | `./AGENTS.md` | Persistent project rules |

### Key Takeaways

1. **Cortex Code in Snowsight** accelerates notebook development by helping you debug, generate, and explain code inline
2. **Skills** let you encode team expertise into reusable instruction sets that anyone can invoke with `$skill-name`
3. **Hooks** add deterministic guardrails - they run your code, not AI, so behavior is predictable
4. **AGENTS.md** provides session-persistent context so Cortex Code always knows your project's conventions

### Next Steps

- Share your skill with your team by committing `.cortex/skills/` to your repo
- Explore bundled skills: `$semantic-view`, `$machine-learning`, `$data-governance`
- Try background agents: `Run a background agent to refactor all test files`
- Connect external tools via MCP: `cortex mcp add github -- npx @modelcontextprotocol/server-github`

### Quick Reference

| Action | Syntax |
|--------|--------|
| Include file | `@path/to/file` |
| Reference table | `#DB.SCHEMA.TABLE` |
| Invoke skill | `$skill-name` |
| Run shell command | `!git status` |
| Execute SQL | `/sql SELECT 1` |
| Switch mode | `Shift+Tab` |
| Plan mode | `Ctrl+P` |
| Help | `?` |
