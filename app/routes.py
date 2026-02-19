from flask import render_template, request, redirect, url_for
from . import app
import os

TASKS_FILE = 'tasks.txt'

def get_tasks():
    if not os.path.exists(TASKS_FILE):
        return []
    with open(TASKS_FILE, 'r') as f:
        return [line.strip() for line in f.readlines()]

def add_task_to_file(task):
    with open(TASKS_FILE, 'a') as f:
        f.write(task + '\n')

def delete_task_from_file(task_text):
    if not os.path.exists(TASKS_FILE):
        return
    
    current_tasks = get_tasks()
    if task_text in current_tasks:
        current_tasks.remove(task_text)
        with open(TASKS_FILE, 'w') as f:
            for t in current_tasks:
                f.write(t + '\n')

@app.route('/')
def index():
    tasks = get_tasks()
    return render_template('index.html', tasks=tasks)

@app.route('/embed')
def embed():
    tasks = get_tasks()
    return render_template('iframe.html', tasks=tasks)

@app.route('/add_task', methods=['POST'])
def add_task():
    task = request.form.get('task')
    source = request.form.get('source', 'index')
    
    if task:
        add_task_to_file(task)
    
    if source == 'embed':
        return redirect(url_for('embed'))
    return redirect(url_for('index'))

@app.route('/delete_task', methods=['POST'])
def delete_task():
    task = request.form.get('task')
    source = request.form.get('source', 'index')
    
    if task:
        delete_task_from_file(task)
        
    if source == 'embed':
        return redirect(url_for('embed'))
    return redirect(url_for('index'))


