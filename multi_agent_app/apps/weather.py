"""Weather application connector using a static data set."""
from __future__ import annotations

from datetime import date
from typing import Dict


class WeatherApp:
    """Return weather information for supported cities."""

    name = "weather_app"

    _FORECASTS: Dict[str, Dict[str, str]] = {
        "new york": {
            "summary": "Partly cloudy with a light breeze.",
            "temperature": "22°C",
        },
        "san francisco": {
            "summary": "Foggy morning clearing to sunshine in the afternoon.",
            "temperature": "18°C",
        },
        "london": {
            "summary": "Overcast with scattered showers.",
            "temperature": "16°C",
        },
    }

    def invoke(self, message: str) -> str:
        lowered = message.lower()
        for city, forecast in self._FORECASTS.items():
            if city in lowered:
                today = date.today().strftime("%B %d, %Y")
                return (
                    f"Weather for {city.title()} on {today}: {forecast['summary']} "
                    f"The temperature is around {forecast['temperature']}."
                )
        supported = ", ".join(city.title() for city in self._FORECASTS)
        return f"I can provide forecasts for: {supported}. Please mention one of these cities."

