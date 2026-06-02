"""Quick script to insert test users with roles into the database."""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app import models

DATABASE_URL = "sqlite:///./test.db"  # adjust to your real DB


def main():
    engine = create_engine(DATABASE_URL, echo=True)
    models.Base.metadata.create_all(engine)

    Session = sessionmaker(bind=engine)
    with Session() as session:
        existing = session.execute(models.User.__table__.select().limit(1))
        if existing.scalars().first():
            print("Users already seeded")
            return

        brand = models.User(email="brand@example.com", password_hash="<hash>", role="brand", firebase_uid="uid_brand")
        admin = models.User(email="admin@example.com", password_hash="<hash>", role="admin", firebase_uid="uid_admin")
        user = models.User(email="user@example.com", password_hash="<hash>", role="user", firebase_uid="uid_user")
        session.add_all([brand, admin, user])
        session.commit()
        print("Seeded brand, admin, and user accounts.")

        # create a sample brand entry and some products
        b = models.Brand(name="Demo Brand", logo_url="https://via.placeholder.com/64")
        session.add(b)
        session.flush()  # get id
        prod1 = models.Product(brand_id=b.id, name="T-shirt", price=29.99, currency="USD")
        prod2 = models.Product(brand_id=b.id, name="Jeans", price=59.99, currency="USD")
        session.add_all([prod1, prod2])
        session.commit()
        print("Seeded demo brand and products.")


if __name__ == "__main__":
    main()
