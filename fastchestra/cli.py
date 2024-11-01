import os
import json
import subprocess
import typer
from alembic.config import Config
from alembic import command
from fastchestra.helpers import get_full_path

app = typer.Typer()

PROJECT_ENV: str = get_full_path("project", ".env")

def load_config():
    config_path: str = get_full_path("fastchestra", "config\\config.json")
    print(config_path)

    if not os.path.exists(config_path):
        typer.echo(f"Configuration file not found at {config_path}")
        return None
    
    with open(config_path, "r") as f:
        return json.load(f)

@app.command() 
def main():
    """Welcome message and CLI introduction"""
    typer.echo("Welcome to Fastchestra CLI")
    typer.echo("Use --help to see available commands")

@app.command()
def setup_database():
    """Sets up the database by running alembic migrations"""
    typer.echo("Setting up database...")

    # Load alembic configuration
    alembic_cfg = Config("alembic.ini")
    command.upgrade(alembic_cfg, "head")
    typer.echo("Database setup complete")

@app.command()
def create_test_db():
    """Creates a test database"""
    typer.echo("Creating test database...")

    # Load configuration
    config = load_config()
    
    # Path to the bash executable on Windows
    bash_path = "C:/Program Files/Git/bin/bash.exe"

    # Call the DB setup script
    env_file_path = PROJECT_ENV.replace("\\", "/")
    db_setup_script_path = get_full_path("fastchestra", "scripts/db_setup.sh").replace("\\", "/")
    subprocess.run([bash_path, db_setup_script_path, env_file_path])

    typer.echo("Test database created and migrations applied")

@app.command()
def run_tests():
    typer.echo("Running tests...") 

    # Running pytest with custom flags
    subprocess.run(["pytest", "--maxfail=1", "--cov=fastchestra", "--disable-warnings"])
    typer.echo("Tests complete")

@app.command()
def teardown_database():
    """Tears down the database by running alembic downgrade"""
    typer.echo("Tearing down database...")

    # Run bash script to tear down the database
    subprocess.run(["C:/Program Files/Git/bin/bash.exe", "scripts/db_teardown.sh"])

    # Downgrade alembic
    alembic_cfg = Config("alembic.ini")
    command.downgrade(alembic_cfg, "base")

    typer.echo("Database teardown complete")    


if __name__ == "__main__":
    app()