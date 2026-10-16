"""Create DB Session"""
import os
import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

SQLALCHEMY_DATABASE_URL = os.getenv(
	"DATABASE_URL",
	"postgresql://username:password@localhost:5432/vector")

engine = create_engine(SQLALCHEMY_DATABASE_URL, echo=True)
SessionLocal = sessionmaker(bind=engine)
Base = sqlalchemy.orm.declarative_base()
