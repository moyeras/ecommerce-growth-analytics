from pathlib import Path
from getpass import getpass
import base64

from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization

keys_dir = Path.home() / ".dbt" / "keys"
keys_dir.mkdir(parents=True, exist_ok=True)

passphrase = getpass("Create private key passphrase, write it down: ").encode("utf-8")

private_key = rsa.generate_private_key(
    public_exponent=65537,
    key_size=2048
)

private_key_pem = private_key.private_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PrivateFormat.PKCS8,
    encryption_algorithm=serialization.BestAvailableEncryption(passphrase)
)

public_key_der = private_key.public_key().public_bytes(
    encoding=serialization.Encoding.DER,
    format=serialization.PublicFormat.SubjectPublicKeyInfo
)

public_key_snowflake = base64.b64encode(public_key_der).decode("utf-8")

private_key_path = keys_dir / "rsa_key.p8"
public_key_path = keys_dir / "rsa_key_snowflake_public.txt"

private_key_path.write_bytes(private_key_pem)
public_key_path.write_text(public_key_snowflake, encoding="utf-8")

print("Private key saved to:")
print(private_key_path)
print()
print("Snowflake public key saved to:")
print(public_key_path)
print()
print("Copy the public key text into Snowflake ALTER USER command.")