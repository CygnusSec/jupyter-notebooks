"""Pre-create admin user for JupyterHub with NativeAuthenticator."""
import os
import sys

def create_admin():
    admin_user = os.environ.get('ADMIN_USERS', 'admin').split(',')[0].strip()
    admin_pass = os.environ.get('ADMIN_PASSWORD', '')

    if not admin_pass:
        print("ADMIN_PASSWORD not set, skipping admin creation")
        return

    # Import after jupyterhub is available
    from nativeauthenticator import NativeAuthenticator
    from jupyterhub.orm import Base, User
    from sqlalchemy import create_engine
    from sqlalchemy.orm import Session

    db_url = 'sqlite:////srv/jupyterhub/jupyterhub.sqlite'
    engine = create_engine(db_url)
    Base.metadata.create_all(engine)

    auth = NativeAuthenticator(db=None)

    with Session(engine) as session:
        # Check if user already exists
        existing = session.query(User).filter_by(name=admin_user).first()
        if existing:
            print(f"Admin user '{admin_user}' already exists, skipping")
            return

    # Use the authenticator's add_user method
    import bcrypt
    encoded_password = bcrypt.hashpw(admin_pass.encode(), bcrypt.gensalt())

    with Session(engine) as session:
        from nativeauthenticator.orm import UserInfo
        user_info = UserInfo(
            username=admin_user,
            password=encoded_password,
            is_authorized=True,
        )
        session.add(user_info)
        session.commit()
        print(f"Admin user '{admin_user}' created successfully")

if __name__ == '__main__':
    create_admin()
