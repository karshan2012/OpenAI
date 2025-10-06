.PHONY: install fmt lint test run seed

install:
pip install -e .[test]

fmt:
ruff check --fix || true

lint:
ruff check

run:
uvicorn src.main:app --reload

test:
pytest

seed:
python -m src.db.seed
