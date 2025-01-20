import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_hello_route(client):
    response = client.get('/')
    assert response.status_code == 200
    assert b'This is my cool state of the art app!' in response.data

def test_health_route(client):
    response = client.get('/health')
    assert response.status_code == 200
    assert b'OK' in response.data