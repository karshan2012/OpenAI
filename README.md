# OpenAI Multi-Agent Q&A App

This repository contains a lightweight, multi-agent conversational application that mimics ChatGPT-style question answering. The system coordinates several specialist agents and connects to two embedded applications: a calculator and a weather service.

## Features

- **Router Agent** decides which specialist should respond to each user question.
- **Knowledge Base Q&A Agent** answers general questions with responses sourced from a JSON knowledge base.
- **Calculator Application** evaluates simple arithmetic expressions expressed in natural language.
- **Weather Application** returns static forecasts for a curated list of cities.
- **Command Line Interface** offering an interactive chat experience, including conversation reset support and reasoning trace visualization.

## Getting Started

Create a virtual environment and install any preferred tooling if desired. The project has no external dependencies and only relies on Python's standard library.

```bash
python -m venv .venv
source .venv/bin/activate
```

Run the interactive assistant:

```bash
python main.py
```

Type `exit` to leave the conversation or `reset` to clear the dialogue history.

## Project Structure

```
multi_agent_app/
├── agents/
│   ├── app_agent.py
│   ├── base.py
│   ├── qa_agent.py
│   └── router_agent.py
├── apps/
│   ├── calculator.py
│   └── weather.py
├── data/
│   └── knowledge_base.json
├── knowledge_base.py
├── orchestrator.py
└── utils.py
main.py
```

## Extending the System

- Add new knowledge base entries by editing `multi_agent_app/data/knowledge_base.json`.
- Introduce additional application connectors by implementing the `AppConnector` protocol and registering them within `MultiAgentChatGPT`.
- Replace the heuristic router with a more advanced classifier to improve dispatch accuracy.

## License

This project is provided for demonstration purposes without a specific license.

