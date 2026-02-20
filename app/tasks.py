import toons
import os
import uuid
import logging
from datetime import datetime

# Set up basic logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Use absolute path to ensure we find the file correctly
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
TASKS_FILE = os.path.join(BASE_DIR, 'tasklists', 'tasks.toon')

def _ensure_file_exists():
    """Ensure tasklists directory and tasks.toon file exist with initial structure."""
    if not os.path.exists(os.path.dirname(TASKS_FILE)):
        os.makedirs(os.path.dirname(TASKS_FILE))
    
    if not os.path.exists(TASKS_FILE):
        logger.info(f"Creating new task file at {TASKS_FILE}")
        with open(TASKS_FILE, 'w') as f:
            # Initialize with empty structured list
            f.write("tasks[0]{id,description,status,created_at}:\n")

def _read_toon_data():
    """Read full TOON data structure."""
    _ensure_file_exists()
    try:
        with open(TASKS_FILE, 'r') as f:
            content = f.read()
            if not content.strip():
                return {'tasks': []}
            data = toons.loads(content)
            if data is None:
                return {'tasks': []}
            if not isinstance(data, dict):
                logger.warning(f"TOON data is not a dictionary: {type(data)}")
                return {'tasks': []}
            return data
    except Exception as e:
        logger.error(f"Error reading TOON file: {e}")
        return {'tasks': []}

def _save_toon_data(data):
    """Save full TOON data structure."""
    _ensure_file_exists()
    try:
        content = toons.dumps(data)
        with open(TASKS_FILE, 'w') as f:
            f.write(content)
            if not content.endswith('\n'):
                f.write('\n')
        logger.info("TOON data saved successfully")
    except Exception as e:
        logger.error(f"Error writing TOON file: {e}")

def get_tasks_raw():
    """Return the raw list of task dictionaries."""
    data = _read_toon_data()
    return data.get('tasks', [])

def get_tasks():
    """
    Returns the list of task objects.
    """
    return get_tasks_raw()

def add_task_to_file(task_description):
    """Adds a new task with generated metadata."""
    logger.info(f"Adding task: {task_description}")
    data = _read_toon_data()
    if 'tasks' not in data or not isinstance(data['tasks'], list):
        data['tasks'] = []
    
    new_task = {
        'id': str(uuid.uuid4())[:8],
        'description': task_description,
        'status': 'pending',
        'created_at': datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }
    
    data['tasks'].append(new_task)
    _save_toon_data(data)

def delete_task_from_file(task_description):
    """
    Removes a task by matching its description.
    """
    logger.info(f"Deleting task with description: {task_description}")
    data = _read_toon_data()
    if 'tasks' in data and isinstance(data['tasks'], list):
        # Keep tasks that DO NOT match the description
        initial_count = len(data['tasks'])
        data['tasks'] = [t for t in data['tasks'] if str(t.get('description')).strip() != str(task_description).strip()]
        
        # Only save if we actually removed something
        if len(data['tasks']) < initial_count:
            _save_toon_data(data)
            logger.info(f"Deleted {initial_count - len(data['tasks'])} task(s)")
        else:
            logger.warning(f"No task found with description: {task_description}")
