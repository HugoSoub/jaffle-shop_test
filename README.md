# 🏢​ – Data Engineering exercice

This project is technical evaluation, based on the official [`jaffle-shop`](https://github.com/dbt-labs/jaffle-shop).  

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

### 6) 🧪 Test the connection

<pre>
uv run dbt debug
</pre>

### 7) ⏳Load data & run dbt
<pre>
uv run dbt seed --full-refresh
uv run dbt build
</pre>

---

## 🛠 4. Useful Commands

| Action                              | Command |
|-------------------------------------|---------|
| Start Postgres                      | `$ docker compose up -d` |
| Stop Postgres                       | `$ docker compose down` |
| Stop & remove volumes (full reset)  | `$ docker compose down -v` |
| Reload seeds                        | `$ uv run dbt seed --full-refresh` |
| Build all models & run tests        | `$ uv run dbt build` |
| Run only tests                      | `$ uv run dbt test` |

---

## 📌 Notes / infos

- `No fork` of the jaffle-shop repo: this project is based on a clone with its Git history removed.
- `Python 3.11` chosen for stability and compatibility with dbt 1.8. (https://devguide.python.org/versions/)
- Sensitive credentials must never be committed: always use `.env`.
