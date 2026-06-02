"""add firebase_uid to users

Revision ID: 20260226_add_firebase_uid
Revises: 20260226_add_brand_id_and_photos
Create Date: 2026-02-26 01:00:00.000000
"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = '20260226_add_firebase_uid'
down_revision = '20260226_add_brand_id_and_photos'
branch_labels = None
depends_on = None


def upgrade():
    conn = op.get_bind()
    # only add column if it doesn't already exist (SQLite semantics)
    if conn.dialect.name == 'sqlite':
        cols = [row[1] for row in conn.execute(sa.text("PRAGMA table_info('users')"))]
        if 'firebase_uid' not in cols:
            op.add_column('users', sa.Column('firebase_uid', sa.String(length=128), nullable=True))
            op.create_index(op.f('ix_users_firebase_uid'), 'users', ['firebase_uid'], unique=True)
    else:
        op.add_column('users', sa.Column('firebase_uid', sa.String(length=128), nullable=True))
        op.create_index(op.f('ix_users_firebase_uid'), 'users', ['firebase_uid'], unique=True)


def downgrade():
    conn = op.get_bind()
    if conn.dialect.name == 'sqlite':
        # SQLite cannot drop column easily; leave it or recreate table if needed
        pass
    else:
        op.drop_index(op.f('ix_users_firebase_uid'), table_name='users')
        op.drop_column('users', 'firebase_uid')
