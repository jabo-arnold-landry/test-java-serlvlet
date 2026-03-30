import re

def get_file_content(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

def extract_node_by_class(html_str, search_str):
    start_idx = html_str.find(search_str)
    if start_idx == -1: return ""
    count = 0
    i = start_idx
    while i < len(html_str):
        if html_str.startswith('<div', i) or html_str.startswith('<DIV', i):
            count += 1
            i += 4
        elif html_str.startswith('</div', i) or html_str.startswith('</DIV', i):
            count -= 1
            if count == 0:
                return html_str[start_idx:i+6]
            i += 5
        elif html_str.startswith('<!--', i):
            end_comment = html_str.find('-->', i)
            i = end_comment + 3 if end_comment != -1 else i + 4
        else:
            i += 1
    return ""

# Tab 1: Notifications
notif_html = get_file_content(r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\notifications.jsp')
notif_block = extract_node_by_class(notif_html, '<div class="notification-feed">')

# Tab 2: Assignments (visit-log.jsp, first card)
visit_log_html = get_file_content(r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\visit-log.jsp')
# Since it has two cards, we just find the table card (the first one)
assign_block = extract_node_by_class(visit_log_html, '<div class="card border-0 shadow-sm rounded-5 overflow-hidden mb-5">')
if not assign_block:
    assign_block = extract_node_by_class(visit_log_html, '<div class="card border-0 shadow-sm rounded-4">') # alternative

# Tab 3: Active Escorts (active.jsp card)
active_html = get_file_content(r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\active.jsp')
active_block = extract_node_by_class(active_html, '<div class="card border-0 shadow-sm rounded-5 overflow-hidden">')

# Tab 4: Report Incident (report-incident.jsp card)
incident_html = get_file_content(r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\report-incident.jsp')
incident_block = extract_node_by_class(incident_html, '<div class="card border-0 shadow-sm rounded-5 overflow-hidden">')

# Tab 5: History (history.jsp card + export button)
history_html = get_file_content(r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\history.jsp')
history_block = extract_node_by_class(history_html, '<div class="card border-0 shadow-sm rounded-5 overflow-hidden">')
export_btn = '''<div class="d-flex justify-content-end mb-3 mt-2">
                    <a href="${pageContext.request.contextPath}/visitor-portal/history/export-pdf" class="btn btn-white border border-light text-slate-600 px-4 py-2 rounded-4 shadow-sm fw-bold">
                        <i class="bi bi-download me-2"></i>EXPORT LOGS
                    </a>
                </div>'''

# Nav Pills UI
nav_pills = '''
<div class="col-xl-12 mb-4">
    <style>
        .nav-pills .nav-link { color: #475569; transition: all 0.3s ease; border: 1px solid transparent; }
        .nav-pills .nav-link.active { background-color: #0f172a; color: #fff; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); }
        .nav-pills .nav-link:hover:not(.active) { background-color: #f8fafc; color: #0f172a; border-color: #e2e8f0; }
    </style>
    <ul class="nav nav-pills nav-fill bg-white p-2 border border-slate-100 shadow-sm rounded-pill" id="techTabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active fw-bold px-4 py-3 rounded-pill" id="tech-overview-tab" data-bs-toggle="pill" data-bs-target="#tech-overview" type="button" role="tab"><i class="bi bi-speedometer2 me-2"></i>Dashboard</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link fw-bold px-4 py-3 rounded-pill" id="tech-assignments-tab" data-bs-toggle="pill" data-bs-target="#tech-assignments" type="button" role="tab"><i class="bi bi-list-task me-2"></i>My Assignments</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link fw-bold px-4 py-3 rounded-pill" id="tech-active-tab" data-bs-toggle="pill" data-bs-target="#tech-active" type="button" role="tab"><i class="bi bi-person-badge me-2"></i>Active Escorts</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link fw-bold px-4 py-3 rounded-pill" id="tech-incident-tab" data-bs-toggle="pill" data-bs-target="#tech-incident" type="button" role="tab"><i class="bi bi-exclamation-octagon text-danger me-2"></i>Report Incident</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link fw-bold px-4 py-3 rounded-pill" id="tech-history-tab" data-bs-toggle="pill" data-bs-target="#tech-history" type="button" role="tab"><i class="bi bi-clock-history me-2"></i>Visit Archive</button>
        </li>
    </ul>
</div>
'''

tab_content = f'''
<div class="col-xl-12">
    <div class="tab-content" id="techTabsContent">
        <div class="tab-pane fade show active" id="tech-overview" role="tabpanel">
            {notif_block}
        </div>
        <div class="tab-pane fade" id="tech-assignments" role="tabpanel">
            {assign_block}
        </div>
        <div class="tab-pane fade" id="tech-active" role="tabpanel">
            {active_block}
        </div>
        <div class="tab-pane fade" id="tech-incident" role="tabpanel">
            {incident_block}
        </div>
        <div class="tab-pane fade" id="tech-history" role="tabpanel">
            {export_btn}
            {history_block}
        </div>
    </div>
</div>
'''

clean_tech_block = f'''<c:otherwise>
                    <!-- 3. TECHNICIAN: OPERATIONAL TERMINAL -->
                    <c:set var="isTech" value="${{currentUser.role == 'TECHNICIAN'}}" />
                    {nav_pills}
                    {tab_content}
                </c:otherwise>'''

with open(r'c:\Users\user\Desktop\test-java-serlvlet\generated_tech_tabs.html', 'w', encoding='utf-8') as f:
    f.write(clean_tech_block)

print("generated_tech_tabs.html created!")
