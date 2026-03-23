---
description: Python development standards for FastAPI backend — coding patterns, testing, and file structure. Applies to all Python files.
applyTo: "**/*.py"
---

# GitHub Copilot Instructions — Python

These instructions define how GitHub Copilot should assist with this project. The goal is to ensure consistent, high-quality code generation aligned with our conventions, stack, and best practices.

## 🧠 Context

- **Project Type**: Web API (力量训练智能 APP 后端)
- **Language**: Python 3.14
- **Framework / Libraries**: FastAPI / Pydantic / uvicorn
- **Architecture**: Clean layered (routers → services → models)

## 🔧 General Guidelines

- Use Pythonic patterns (PEP8, PEP257).
- Prefer named functions and class-based structures over inline lambdas.
- Use type hints where applicable (`typing` module).
- Follow black or isort for formatting and import order.
- Use meaningful naming; avoid cryptic variables.
- Emphasize simplicity, readability, and DRY principles.

## 📁 File Structure

Use this structure as a guide when creating or updating files:

```text
backend/
  app/
    main.py          # FastAPI app entry
    models.py        # Pydantic schemas
    planner.py       # Plan generation / adjustment algorithms
    voice_parser.py  # Voice command intent parsing
    exercise_seed.py # Preset exercise data
```

## 🧶 Patterns

### ✅ Patterns to Follow

- Validate data using Pydantic models.
- Use custom exceptions and centralized error handling.
- Use environment variables via `dotenv` or `os.environ`.
- Write modular, reusable code organized by concerns.
- Favor async endpoints for I/O-bound services.
- Document functions and classes with docstrings.

### 🚫 Patterns to Avoid

- Don't use wildcard imports (`from module import *`).
- Avoid global state unless encapsulated in a singleton or config manager.
- Don't hardcode secrets or config values—use `.env`.
- Don't expose internal stack traces in production environments.
- Avoid business logic inside views/routes.

## 🧪 Testing Guidelines

- Use `pytest` for unit and integration tests.
- Mock external services with `unittest.mock` or `pytest-mock`.
- Use fixtures to set up and tear down test data.
- Aim for high coverage on core logic and low-level utilities.
- Test both happy paths and edge cases.

## 🔁 Iteration & Review

- Review Copilot output before committing.
- Use linters (flake8, pylint) and formatters (black, isort) as part of the review pipeline.
- Refactor output to follow project conventions.

## 📚 References

- [PEP 8 – Style Guide](https://peps.python.org/pep-0008/)
- [FastAPI Docs](https://fastapi.tiangolo.com/)
- [Pydantic Docs](https://docs.pydantic.dev/)
- [Pytest Docs](https://docs.pytest.org/en/stable/)
