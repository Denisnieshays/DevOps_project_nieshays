"""Тесты для FastAPI API"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))

from fastapi.testclient import TestClient
from api import app
from seed import INITIAL_DATA

client = TestClient(app)


def test_db_seed():
    response = client.get("/seed")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
    assert len(response.json()) >= 5

def test_get_items_return_list():
    client.get("/seed")
    response = client.get("/items")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
    assert len(response.json()) >= 1

def test_get_item_by_id():
    client.post("/items", json={"type": "x", "title": "x", "position": 200})

    response = client.get("/items/200")
    assert response.status_code == 200
    assert response.json()["position"] == 200

def test_create_item_success():
    client.delete("/items/100")
    new_item = {"title": "test-title", "type": "test-type", "position": 100}

    response = client.post("/items", json=new_item)
    assert response.status_code == 201
    assert response.json()["title"] == "test-title"
    assert response.json()["type"] == "test-type"
    assert response.json()["position"] == 100

def test_create_duplicate_item_fail():
    item = {"title": "x", "type": "X", "position": 101}
    client.post("/items", json=item)

    response = client.post("/items", json=item)
    assert response.status_code == 400

def test_update_item():
    client.post("/items", json={"title": "old", "type": "Old", "position": 300})

    updated = {"title": "new-title", "type": "New-type", "position": 300}
    response = client.put("/items/300", json=updated)
    assert response.status_code == 200
    assert response.json()["title"] == "new-title"
    assert response.json()["type"] == "New-type"

def test_delete_item():
    client.post("/items", json={"title": "x", "type": "X", "position": 400})
    response = client.delete("/items/400")
    assert response.status_code == 200

def test_delete_items_fails():
    response = client.delete("/items/99999")
    assert response.status_code == 404