from flask import render_template, request, redirect, url_for
from app import app
# Import the TOON-based task handling logic - inside functions or delay to avoid circular issues?
# But importing functions is usually fine.
import app.tasks as tasks

@app.route('/')
def index():
    t_list = tasks.get_tasks()
    return render_template('index.html', tasks=t_list)

@app.route('/embed')
def embed():
    t_list = tasks.get_tasks()
    return render_template('iframe.html', tasks=t_list)

@app.route('/add_task', methods=['POST'])
def add_task():
    task = request.form.get('task')
    source = request.form.get('source', 'index')
    
    if task:
        tasks.add_task_to_file(task)
    
    if source == 'embed':
        return redirect(url_for('embed'))
    return redirect(url_for('index'))

@app.route('/delete_task', methods=['POST'])
def delete_task():
    task = request.form.get('task')
    source = request.form.get('source', 'index')
    
    if task:
        tasks.delete_task_from_file(task)
        
    if source == 'embed':
        return redirect(url_for('embed'))
    return redirect(url_for('index'))


