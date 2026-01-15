#!/bin/bash
# OmniFocus & OmniOutliner CLI Helper (JavaScript/OmniAutomation version)
# Usage: omni.sh <command> [args]

case "$1" in
  # ==================== OMNIFOCUS ====================
  folders)
    osascript -l JavaScript -e '
    const of = Application("OmniFocus");
    const doc = of.defaultDocument;
    doc.folders().map(f => f.name()).join(", ");
    '
    ;;
  
  projects)
    FOLDER="$2"
    if [ -z "$FOLDER" ]; then
      osascript -l JavaScript -e '
      const of = Application("OmniFocus");
      const doc = of.defaultDocument;
      doc.flattenedProjects.whose({status: "active"})().map(p => "📁 " + p.name()).join("\n");
      '
    else
      osascript -l JavaScript -e "
      const of = Application('OmniFocus');
      const doc = of.defaultDocument;
      const folder = doc.folders.whose({name: '$FOLDER'})()[0];
      folder.projects().map(p => '📁 ' + p.name()).join('\n');
      "
    fi
    ;;
  
  inbox)
    osascript -l JavaScript -e '
    const of = Application("OmniFocus");
    const doc = of.defaultDocument;
    const inbox = doc.inboxTasks().filter(t => !t.completed() && !t.dropped());
    if (inbox.length === 0) { "📥 Inbox vacío"; }
    else { inbox.map(t => "• " + t.name()).join("\n"); }
    '
    ;;
  
  flagged)
    osascript -l JavaScript -e '
    const of = Application("OmniFocus");
    const doc = of.defaultDocument;
    const tasks = doc.flattenedTasks.whose({flagged: true, completed: false})()
      .filter(t => !t.dropped() && !t.effectivelyDropped());
    if (tasks.length === 0) { "No hay tareas con bandera"; }
    else { tasks.map(t => "🚩 " + t.name()).join("\n"); }
    '
    ;;
  
  due-today)
    osascript -l JavaScript -e '
    const of = Application("OmniFocus");
    const doc = of.defaultDocument;
    const today = new Date();
    today.setHours(0,0,0,0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    const tasks = doc.flattenedTasks.whose({completed: false})()
      .filter(t => !t.dropped() && !t.effectivelyDropped());
    const due = tasks.filter(t => {
      const d = t.dueDate();
      return d && d >= today && d < tomorrow;
    });
    
    if (due.length === 0) { "No hay tareas para hoy en OmniFocus"; }
    else { due.map(t => "📅 " + t.name()).join("\n"); }
    '
    ;;
  
  due-week)
    osascript -l JavaScript -e '
    const of = Application("OmniFocus");
    const doc = of.defaultDocument;
    const today = new Date();
    today.setHours(0,0,0,0);
    const weekEnd = new Date(today);
    weekEnd.setDate(weekEnd.getDate() + 7);
    
    const tasks = doc.flattenedTasks.whose({completed: false})()
      .filter(t => !t.dropped() && !t.effectivelyDropped());
    const due = tasks.filter(t => {
      const d = t.dueDate();
      return d && d >= today && d < weekEnd;
    });
    
    if (due.length === 0) { "No hay tareas para esta semana"; }
    else { 
      due.map(t => {
        const d = t.dueDate();
        const dateStr = (d.getMonth()+1) + "/" + d.getDate();
        return "📅 " + t.name() + " [" + dateStr + "]";
      }).join("\n"); 
    }
    '
    ;;
  
  overdue)
    osascript -l JavaScript -e '
    const of = Application("OmniFocus");
    const doc = of.defaultDocument;
    const now = new Date();
    
    const tasks = doc.flattenedTasks.whose({completed: false})()
      .filter(t => !t.dropped() && !t.effectivelyDropped());
    const overdue = tasks.filter(t => {
      const d = t.dueDate();
      return d && d < now;
    });
    
    if (overdue.length === 0) { "✨ No hay tareas vencidas"; }
    else { overdue.map(t => "⚠️ " + t.name()).join("\n"); }
    '
    ;;
  
  available)
    osascript -l JavaScript -e '
    const of = Application("OmniFocus");
    const doc = of.defaultDocument;
    const tasks = doc.flattenedTasks.whose({effectivelyAvailable: true, completed: false})()
      .filter(t => !t.dropped() && !t.effectivelyDropped());
    tasks.slice(0, 20).map(t => "✓ " + t.name()).join("\n");
    '
    ;;
  
  add-inbox)
    TASK="$2"
    osascript -l JavaScript -e "
    const of = Application('OmniFocus');
    const doc = of.defaultDocument;
    const task = of.InboxTask({name: '$TASK'});
    doc.inboxTasks.push(task);
    '✅ Añadido al inbox: $TASK';
    "
    ;;
  
  add-task)
    TASK="$2"
    PROJECT="$3"
    osascript -l JavaScript -e "
    const of = Application('OmniFocus');
    const doc = of.defaultDocument;
    const proj = doc.flattenedProjects.whose({name: '$PROJECT'})()[0];
    const task = of.Task({name: '$TASK'});
    proj.tasks.push(task);
    '✅ Añadido a $PROJECT: $TASK';
    "
    ;;
  
  complete)
    TASK="$2"
    osascript -l JavaScript -e "
    const of = Application('OmniFocus');
    const doc = of.defaultDocument;
    const task = doc.flattenedTasks.whose({name: '$TASK'})()[0];
    task.completed = true;
    '✅ Completado: $TASK';
    "
    ;;

  search)
    QUERY="$2"
    osascript -l JavaScript -e "
    const of = Application('OmniFocus');
    const doc = of.defaultDocument;
    const query = '$QUERY'.toLowerCase();
    const tasks = doc.flattenedTasks.whose({completed: false})()
      .filter(t => !t.dropped() && !t.effectivelyDropped());
    const matches = tasks.filter(t => t.name().toLowerCase().includes(query));
    if (matches.length === 0) { 'No se encontraron tareas con: $QUERY'; }
    else { matches.slice(0, 15).map(t => '🔍 ' + t.name()).join('\n'); }
    "
    ;;
  
  # ==================== OMNIOUTLINER ====================
  oo-docs)
    osascript -l JavaScript -e '
    const oo = Application("OmniOutliner");
    oo.documents().map(d => d.name()).join("\n") || "No hay documentos abiertos";
    '
    ;;
  
  oo-read)
    DOC="$2"
    osascript -l JavaScript -e "
    const oo = Application('OmniOutliner');
    const doc = oo.documents.whose({name: '$DOC'})()[0];
    doc.rows().map(r => r.topic()).join('\n');
    "
    ;;
  
  # ==================== SUMMARY ====================
  summary)
    echo "📊 RESUMEN OMNIFOCUS"
    echo "===================="
    echo ""
    echo "📥 INBOX:"
    $0 inbox
    echo ""
    echo "🚩 FLAGGED:"
    $0 flagged
    echo ""
    echo "📅 DUE TODAY:"
    $0 due-today
    echo ""
    echo "⚠️ OVERDUE:"
    $0 overdue
    ;;
  
  # ==================== HELP ====================
  *)
    echo "🐙 Omni CLI Helper (JS Engine)"
    echo ""
    echo "📋 OMNIFOCUS:"
    echo "  folders              - List all folders"
    echo "  projects [folder]    - List projects"
    echo "  inbox                - Show inbox items"
    echo "  flagged              - Show flagged tasks"
    echo "  due-today            - Tasks due today"
    echo "  due-week             - Tasks due this week"
    echo "  overdue              - Overdue tasks"
    echo "  available            - Available tasks (max 20)"
    echo "  search \"query\"       - Search tasks"
    echo "  add-inbox \"Task\"     - Add to inbox"
    echo "  add-task \"Task\" \"Project\" - Add to project"
    echo "  complete \"Task\"      - Mark complete"
    echo "  summary              - Full summary"
    echo ""
    echo "📝 OMNIOUTLINER:"
    echo "  oo-docs              - List open documents"
    echo "  oo-read \"Doc.ooutline\" - Read document"
    ;;
esac
