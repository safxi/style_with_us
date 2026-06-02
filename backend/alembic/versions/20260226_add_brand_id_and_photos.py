"""add brand_id to users and create brand_photos table

Revision ID: 20260226_add_brand_id_and_photos
Revises: 
Create Date: 2026-02-26 00:00:00.000000
"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = '20260226_add_brand_id_and_photos'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # add nullable brand_id column to users if it doesn't already exist
    conn = op.get_bind()
    if conn.dialect.name == 'sqlite':
        # PRAGMA returns tuples (cid,name,...) so name is index 1
        cols = [row[1] for row in conn.execute(sa.text("PRAGMA table_info('users')"))]
    else:
        cols = [c['name'] for c in conn.execute(sa.text("SELECT column_name as name FROM information_schema.columns WHERE table_name='users'"))]
    if 'brand_id' not in cols:
        op.add_column('users', sa.Column('brand_id', sa.Integer(), nullable=True))
        op.create_foreign_key('fk_users_brand', 'users', 'brands', ['brand_id'], ['id'])

    # create brand_photos table if not exists (handle prior metadata creation)
    if not conn.dialect.has_table(conn, 'brand_photos'):
        op.create_table(
            'brand_photos',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('uploader_id', sa.Integer(), sa.ForeignKey('users.id'), nullable=False, index=True),
            sa.Column('brand_id', sa.Integer(), sa.ForeignKey('brands.id'), nullable=False, index=True),
            sa.Column('product_id', sa.Integer(), sa.ForeignKey('products.id'), nullable=True, index=True),
            sa.Column('image_url', sa.String(length=512), nullable=False),
            sa.Column('created_at', sa.DateTime(), server_default=sa.func.now(), nullable=False),
        )


def downgrade():
    op.drop_table('brand_photos')
    op.drop_constraint('fk_users_brand', 'users', type_='foreignkey')
    op.drop_column('users', 'brand_id')
