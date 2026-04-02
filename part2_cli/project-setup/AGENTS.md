# Cortex Code Lab Project

This is a sales analytics project focused on customer churn prediction using Snowflake and Python.

## Tech Stack
- Snowflake (data warehouse)
- Python 3.11+ with scikit-learn, pandas, numpy
- Cortex Code CLI for development

## Database
- Database: `ANALYTICS`
- Schema: `SALES`
- Key tables: `CUSTOMERS`, `PURCHASE_SUMMARY`, `ENGAGEMENT`

## Commands
```bash
# Run the churn model notebook
python3 sales_churn_model.py

# Run tests
pytest tests/ -v
```

## Rules
- All SQL must use fully qualified table names (DATABASE.SCHEMA.TABLE)
- Use QUALIFY ROW_NUMBER() for deduplication, never subqueries with GROUP BY
- Never execute DROP, TRUNCATE, or DELETE without WHERE on production schemas
- All Python functions must include type hints
- Model artifacts must be logged with metrics before being considered complete
- Feature names must use UPPER_SNAKE_CASE to match Snowflake column conventions
