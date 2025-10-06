"""Deterministic calculator application connector."""
from __future__ import annotations

import operator
import re
from typing import Callable, Dict


class CalculatorApp:
    """Evaluate simple arithmetic expressions from natural language prompts."""

    name = "calculator_app"

    _OPERATIONS: Dict[str, Callable[[float, float], float]] = {
        "add": operator.add,
        "plus": operator.add,
        "+": operator.add,
        "subtract": operator.sub,
        "minus": operator.sub,
        "-": operator.sub,
        "multiply": operator.mul,
        "times": operator.mul,
        "*": operator.mul,
        "divide": operator.truediv,
        "divided": operator.truediv,
        "/": operator.truediv,
    }

    _PATTERN = re.compile(r"(-?\d+(?:\.\d+)?)\s*(add|plus|\+|subtract|minus|-|multiply|times|\*|divide|divided|/)\s*(-?\d+(?:\.\d+)?)",
                          re.IGNORECASE)

    def invoke(self, message: str) -> str:
        match = self._PATTERN.search(message)
        if not match:
            return "I could not parse the calculation request. Try formats like '5 plus 3'."

        left, op_token, right = match.groups()
        operation = self._OPERATIONS.get(op_token.lower())
        if operation is None:
            return "Unsupported operation requested."

        try:
            left_value = float(left)
            right_value = float(right)
            result = operation(left_value, right_value)
        except ZeroDivisionError:
            return "Division by zero is undefined."

        if result.is_integer():
            formatted = str(int(result))
        else:
            formatted = f"{result:.4f}"
        return f"The result is {formatted}."

