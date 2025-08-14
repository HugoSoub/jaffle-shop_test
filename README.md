# 🏢​ – Data Engineering exercice

- This project is technical evaluation, based on the official [`jaffle-shop`](https://github.com/dbt-labs/jaffle-shop).
- My doc for explain my job : https://docs.google.com/document/d/1ecU3pr6IcKysFwhdk9d1Di1unPHwDQ-jO_z3p5Evzso/edit?usp=sharing
- For part two, all files are located in the path: `.\models\mdpi`
- The profiles.yml file is located in the `.\profiles folder`.
## 📦 1. Technical Architecture

### 🐋 Docker
- **Postgres 16** is run via `docker-compose` and serves as the local dbt warehouse.
- **Port 5433** (instead of 5432) to avoid conflicts with any existing local Postgres installations.
- **Adminer** (bonus) allows exploring the database through a web UI.

### 🐍 UV
- `uv` replaces `requirements.txt` for faster and more reliable Python dependency management.
- Versions are pinned in `pyproject.toml` to ensure reproducibility.

### 🔑 Key Dependencies
- **`psycopg[binary]>=3.1`**: PostgreSQL driver for Python.
  → `[binary]` option ensures fast installation and better performance.
- **`python-dotenv>=1.1.1`**: Loads environment variables from a `.env` file.
  → Prevents storing sensitive credentials directly in the code.

### 🏙️ `.env` and `.env.example`
- **`.env.example`**: Versioned template file listing all required environment variables with sample values.
- **`.env`**: Local (unversioned) file containing the actual values.
- The dbt `profiles.yml` reads these variables via `env_var()` to connect to Postgres.

---

## ⚙️ 2. Requirements
- **Docker** and **Docker Compose** installed.
- **Python 3.11** installed.
- **[uv](https://docs.astral.sh/uv/)** installed globally:
<pre> pip install uv </pre>

---

## 🚀 3. Installation & Setup

### 1) 🗂️ Clone the repository
<pre>
git clone https://github.com/HugoSoub/jaffle-shop_test.git
cd jaffle-shop_test
</pre>

### 2) ▶️ Start Postgres with Docker
<pre>
docker compose up -d
docker compose ps
</pre>

- Postgres: `localhost:5433`, user `dbt`, password `dbt`, database `jaffle_shop`
- Adminer (bonus): http://localhost:8080
  - `System`: PostgreSQL
  - `Server`: postgres or localhost:5433
  - `Username`: dbt
  - `Password`: dbt
  - `Database`: jaffle_shop

### 3) 🖥️ Set up the Python environment with uv
<pre>
uv init --python 3.11
uv sync
</pre>

### 4) ✏️ Configure environment variables

1) Copy `.env.example` to `.env`
<pre>cp .env.example .env</pre>

2) Adjust the values if needed.

### 5) 📜 Set the dbt profile path

<pre>
export DBT_PROFILES_DIR="$PWD/profiles"    # macOS/Linux
$env:DBT_PROFILES_DIR = "$PWD\profiles"    # Windows PowerShell
set DBT_PROFILES_DIR = "$PWD\profiles"     # Anaconda prompt
</pre>

If there is an error during the command during the dbt test at the profiles.yml file path, write the entire path. Example:
<pre>
set DBT_PROFILES_DIR=E:\Dev\MDPI\jaffle-shop_test\profiles
</pre>

### 6) 🧪 Test the connection

<pre>
uv run dbt debug
</pre>

### 7) ⏳Load data & run dbt
<pre>
uv run dbt deps
uv run dbt seed --full-refresh
uv run dbt build
</pre>

---
## 🎁 4. Bonus

### 💾 SQL Linting (SQLFluff + dbt)

This project uses SQLFluff to lint dbt SQL models.
- Config file: .sqlfluff (templater = dbt, dialect = postgres, profiles_dir=profiles)
- Ignores build & venv dirs (e.g. target/, .venv/)
Run locally:
<pre>
# Lint the whole project
python -m sqlfluff lint

# Lint only my models
python -m sqlfluff lint models/mdpi

# Auto-fix safe issues (indent, commas, spacing)
python -m sqlfluff fix models/mdpi
</pre>

We also run SQLFluff automatically before each commit to block non-conforming SQL.

### 1) 🖥️ Install & enable hooks:
<pre>
pip install pre-commit
pre-commit install
</pre>

### 2) ▶️ First start on all files (optional)
<pre>
pre-commit run --all-files
</pre>

---:

## 🛠 5. Useful Commands

| Action                              | Command |
|-------------------------------------|---------|
| Start Postgres                      | `$ docker compose up -d` |
| Stop Postgres                       | `$ docker compose down` |
| Stop & remove volumes (full reset)  | `$ docker compose down -v` |
| Reload seeds                        | `$ uv run dbt seed --full-refresh` |
| Build all models & run tests        | `$ uv run dbt build` |
| Run only tests                      | `$ uv run dbt test` |
| Test sqlfluff                       | `python -m sqlfluff lint models/`|

---

## 📌 Notes / infos

- `No fork` of the jaffle-shop repo: this project is based on a clone with its Git history removed.
- `Python 3.11` chosen for stability and compatibility with dbt 1.8. (https://devguide.python.org/versions/)
- Sensitive credentials must never be committed: always use `.env`.
- Remove subfolders named `static` in `.github` folder, which are no longer needed for our exercise.
- Update package.yml
  - Before :
  <pre>
  packages:
    - package: dbt-labs/dbt_utils
      version: 1.1.1
    - package: godatadriven/dbt_date
      version: 0.10.0
    - git: "https://github.com/dbt-labs/dbt-audit-helper.git"
      revision: main
  </pre>
  - After:
  <pre>
  packages:
    - package: dbt-labs/dbt_utils
      version: "1.3.0"
    - package: godatadriven/dbt_date
      version: "0.16.1"
    - git: "https://github.com/dbt-labs/dbt-audit-helper.git"
      revision: b8f3a3348ce0ff8afc3aa4b9ade2123b00772473
  </pre>
- Respect the logic of one yml file per sql file in the models folder as for staging and marts.
- I formatted all the .yml files in the models folder to update them with the new dbt standards found in their documentation, which removes the warnings during the build.
