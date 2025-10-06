import json

from src.services.auth import create_access_token


def test_create_message_stream(client):
    token, _ = create_access_token("1")
    response = client.post(
        "/v1/chats",
        json={"title": "Test"},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 201
    chat_id = response.json()["id"]

    with client.stream(
        "POST",
        f"/v1/chats/{chat_id}/messages",
        json={
            "message": "Hello",
            "model": "gpt-4o-mini",
            "temperature": 0.2,
            "tools_enabled": False,
        },
        headers={"Authorization": f"Bearer {token}"},
    ) as stream:
        events = []
        for line in stream.iter_lines():
            if line.startswith("event:"):
                event = line.split(":", 1)[1].strip()
            elif line.startswith("data:"):
                data = line.split(":", 1)[1].strip()
                events.append((event, json.loads(data)))

    event_types = [evt for evt, _ in events]
    assert "token" in event_types
    assert events[-1][0] == "done"
