from sqlalchemy import Float, String
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


class Base(DeclarativeBase):
    pass


class AirlineRaw(Base):
    __tablename__ = "airlines_raw"
    __table_args__ = {"schema": "bronze"}

    iata_code: Mapped[str] = mapped_column(String(10), primary_key=True)

    airline: Mapped[str] = mapped_column(String(255))


class AirportRaw(Base):
    __tablename__ = "airports_raw"
    __table_args__ = {"schema": "bronze"}

    iata_code: Mapped[str] = mapped_column(String(10), primary_key=True)

    airport: Mapped[str] = mapped_column(String(255))

    city: Mapped[str] = mapped_column(String(255))

    state: Mapped[str] = mapped_column(String(50))

    country: Mapped[str] = mapped_column(String(50))

    latitude: Mapped[Float] = mapped_column(Float())

    longitude: Mapped[Float] = mapped_column(Float())
