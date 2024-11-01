import os

FASTCHESTRA = "fastchestra"
FASTCHESTRA_BASE_DIR = os.path.dirname(os.path.abspath(__file__)).replace("fastchestra\\fastchestra", "fastchestra")
PROJECT_BASE_DIR = os.path.dirname(os.path.abspath(__file__)).replace("fastchestra\\fastchestra", "")

def get_full_path(base_location: str, path: str) -> str:
    """
    Builds an absolute path by joining the specified base location with the relative path.
    :param base_location: The base directory identifier ('fastchestra' or other)
    :param path: Path relative to the specified base directory
    :return: Absolute path as a string
    """
    if os.path.isabs(path):
        return path
    if base_location == FASTCHESTRA:
        return os.path.join(FASTCHESTRA_BASE_DIR, path)
    else:
        return os.path.join(PROJECT_BASE_DIR, path)