## High-Level Summary of Preprocessing and EDA
[DATASET-link](https://www.kaggle.com/datasets/ehtishamsadiq/uncleaned-laptop-price-dataset)

### Data Preprocessing:
1. **Backup Creation:** A backup of the original data is made to ensure data integrity before any changes.
2. **Cleaning Missing Data:** Rows with all null values are removed to ensure the dataset only contains relevant information.
3. **Renaming Columns:** Unclear or misnamed columns are renamed to improve data readability (e.g., renaming `unnamed: 0` to `ID`).
4. **Handling Duplicates:** Duplicate rows are identified and removed, ensuring no redundant data remains.

### Exploratory Data Analysis (EDA):
1. **Data Size Calculation:** The size of the dataset is determined to understand its scale.
2. **Duplicate Analysis:** Duplicates are counted based on all relevant columns to ensure uniqueness and data integrity.
3. **Data Inspection:** The dataset is examined for any anomalies or inconsistencies that could affect analysis.
4. **Feature engineering** Creating new columns like ppi and screen size.
5. **One Hot Encoding** converting category to numbers.

This process ensures that the dataset is clean, well-structured, and ready for more advanced analysis.
