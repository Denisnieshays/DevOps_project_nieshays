import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from api import app

def test_app_exists():
	assert app is not None
