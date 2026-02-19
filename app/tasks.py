import json
import os

def generate_task_list() -> None:
    
    if not os.path.exists('tasks.json'):
        with open('tasks.json', 'w') as file:
            json.dump([], file)

    return

def load_tasks() -> list:
    with open('tasks.json', 'r') as file:
        tasks = json.load(file)
    return tasks

def save_tasks(tasks: list) -> None:
    with open('tasks.json', 'w') as file:
        json.dump(tasks, file)
    return

def add_task(task: str) -> None:
    tasks = load_tasks()
    tasks.append(task)
    save_tasks(tasks)
    return

def remove_task(task: str) -> None:
    tasks = load_tasks()
    tasks.remove(task)
    save_tasks(tasks)
    return

def update_task(old_task: str, new_task: str) -> None:
    tasks = load_tasks()
    index = tasks.index(old_task)
    tasks[index] = new_task
    save_tasks(tasks)
    return