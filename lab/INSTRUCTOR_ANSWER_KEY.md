# Instructor Answer Key - Bug Reference

## Bug 1: SQL Syntax Error (Cell 2 - Data Loading)
**Problem:** Missing comma between `s.DAYS_SINCE_LAST_PURCHASE` and `s.TOTAL_RETURNS`
**Fix:** Add comma after `s.DAYS_SINCE_LAST_PURCHASE`
```
    s.DAYS_SINCE_LAST_PURCHASE,   -- was missing the comma
    s.TOTAL_RETURNS,
```

## Bug 2: Wrong Column Name (Cell 4 - Feature Engineering)
**Problem:** References `df["TOTAL_ORDERS"]` but the column is `TOTAL_PURCHASES`
**Fix:** Change `TOTAL_ORDERS` to `TOTAL_PURCHASES`
```python
df["PURCHASE_FREQUENCY"] = df["TOTAL_PURCHASES"] / (df["ACCOUNT_LENGTH_DAYS"] / 30)
```

## Bug 3: Data Leakage (Cell 5 - Train/Test Split)
**Problem:** `IS_CHURNED` (the target variable) is included in `feature_cols`
**Fix:** Remove `"IS_CHURNED"` from the feature_cols list
```python
feature_cols = [
    "AGE", "ACCOUNT_LENGTH_DAYS", "TOTAL_PURCHASES", "AVG_ORDER_VALUE",
    "DAYS_SINCE_LAST_PURCHASE", "TOTAL_RETURNS", "SUPPORT_TICKETS",
    "AVG_RESPONSE_SCORE", "MONTHLY_LOGINS", "PURCHASE_FREQUENCY",
    "RETURN_RATE", "ENGAGEMENT_SCORE", "CONTRACT_TYPE_ENCODED",
    "REGION_ENCODED"  # IS_CHURNED removed
]
```

## Bug 4: Wrong Import (Cell 6 - Model Training)
**Problem:** `GradientBoostingClassifier` is imported from `sklearn.linear_model` but lives in `sklearn.ensemble`
**Fix:**
```python
from sklearn.ensemble import GradientBoostingClassifier
```

## Bug 5: Argument Order (Cell 7 - Evaluation)
**Problem:** `classification_report`, `confusion_matrix`, and `roc_auc_score` are called with `(y_pred, y_test)` but should be `(y_test, y_pred)`
**Fix:**
```python
print(classification_report(y_test, y_pred))
print(confusion_matrix(y_test, y_pred))
print(f"\nROC AUC: {roc_auc_score(y_test, y_pred_proba):.4f}")
```
Note: `roc_auc_score` takes `(y_true, y_score)` so it should be `(y_test, y_pred_proba)`
