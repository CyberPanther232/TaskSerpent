from flask import render_template, request, redirect, url_for
from . import app
# Import the TOON-based task handling logic
from .tasks import get_tasks, add_task_to_file, delete_task_from_file

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


