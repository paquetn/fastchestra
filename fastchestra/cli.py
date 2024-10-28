import os
import subprocess
import typer
from alembic.config import Config
from alembic import command

app = typer.Typer()

@app.command()
def main():
    """Welcome message and CLI introduction"""
    typer.echo("Welcome to Fastchestra CLI")
    typer.echo("Use --help to see available commands")

def setup_database():
    """Sets up the database by running alembic migrations"""
    typer.echo("Setting up database...")

    # Load alembic configuration
    alembic_cfg = Config("alembic.ini")
    command.upgrade(alembic_cfg, "head")
    typer.echo("Database setup complete")

def create_test_db():
    """Creates a test database"""
    typer.echo("Creating test database...")

    # Load alembic configuration
    subprocess.run(["bash", "scritps/db_setup.sh"])
    typer.echo("Test database created")

def run_tests():
    typer.echo("Running tests...") 

    # Running pytest with custom flags
    subprocess.run(["pytest", "--maxfail=1," "--cov=fastchestra", "--disable-warnings"])
    typer.echo("Tests complete")

def teardown_database():
    """Tears down the database by running alembic downgrade"""
    typer.echo("Tearing down database...")
    subprocess.run(["bash", "scripts/db_teardown.sh"])
    typer.echo("Database teardown complete")    
#old functions


if __name__ == "__main__":
    app()