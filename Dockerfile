# A reviewer's one-command way to run the project without installing Python or dependencies.
#   docker build -t yottaflex-asg .
#   docker run --rm -p 8501:8501 yottaflex-asg            # the view at http://localhost:8501
#   docker run --rm yottaflex-asg pytest -q               # the tests
#   docker run --rm yottaflex-asg python scripts/verify.py  # the reproducibility proof
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    STREAMLIT_BROWSER_GATHER_USAGE_STATS=false

WORKDIR /app

# Editable install keeps the package at /app/src, so the generator finds the docs it copies into each dataset.
COPY pyproject.toml README.md ./
COPY src ./src
RUN pip install -e ".[dev,ui]"

COPY . .
RUN useradd --create-home app && chown -R app /app
USER app

EXPOSE 8501
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s \
  CMD python -c "import urllib.request as u; u.urlopen('http://localhost:8501/_stcore/health')"

CMD ["streamlit", "run", "app.py", "--server.address=0.0.0.0", "--server.port=8501", "--server.headless=true"]
