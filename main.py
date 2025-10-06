"""Command line interface for the multi-agent ChatGPT-like application."""
from __future__ import annotations

from pathlib import Path

from multi_agent_app.orchestrator import MultiAgentChatGPT
from multi_agent_app.utils import load_knowledge_base


def build_app() -> MultiAgentChatGPT:
    data_path = Path(__file__).parent / "multi_agent_app" / "data" / "knowledge_base.json"
    knowledge_base = load_knowledge_base(data_path)
    return MultiAgentChatGPT(knowledge_base=knowledge_base)


def interactive_loop() -> None:
    print("Multi-Agent ChatGPT Emulator. Type 'exit' to quit or 'reset' to clear history.")
    orchestrator = build_app()
    while True:
        try:
            message = input("You: ")
        except (EOFError, KeyboardInterrupt):
            print("\nExiting.")
            break

        if message.strip().lower() == "exit":
            print("Goodbye!")
            break
        if message.strip().lower() == "reset":
            orchestrator.reset()
            print("Conversation history cleared.")
            continue

        result = orchestrator.ask(message)
        print("Assistant:", result["answer"])
        print("-- Reasoning trace --")
        for step in result["reasoning"]:
            agent_name = step["agent"]
            for reason in step["reasoning"]:
                print(f"[{agent_name}] {reason}")
        print()


if __name__ == "__main__":
    interactive_loop()

