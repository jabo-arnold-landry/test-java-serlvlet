import re

def get_file_content(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

def extract_node_by_class(html_str, search_string):
    start_idx = html_str.find(search_string)
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

def build_omni_dashboard():
    dashboard = get_file_content(r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\dashboard.jsp')

    # MANAGER TABS
    # overstay alert block
    overstay_alert = extract_node_by_class(dashboard, '<div class="row mb-5">')
    if '<a href=' in overstay_alert:
        m = re.search(r'<div class="col-md-4 text-md-end[^>]*>.*?</div>', overstay_alert, re.DOTALL)
        if m: overstay_alert = overstay_alert[:m.start()] + overstay_alert[m.end():]

    # live monitoring block
    live_monitoring = extract_node_by_class(dashboard[dashboard.find('Live Traffic Monitor'):], '<div class="card')
    live_monitoring = live_monitoring.replace('class="col-xl-7"', 'class="col-xl-12"').replace('end="4"', '')
    
    # governance queue block
    governance_queue = extract_node_by_class(dashboard[dashboard.find('Approval Pipeline'):], '<div class="card')
    governance_queue = governance_queue.replace('class="col-xl-5"', 'class="col-xl-12"').replace('end="4"', '')
    # Since modals are outside the card, we must extract them too!
    modals_start = dashboard.find('<!-- MODALS -->')
    modals_end = dashboard.find('<!-- END MODALS -->')
    if modals_start != -1 and modals_end != -1:
        modals = dashboard[modals_start:modals_end+len('<!-- END MODALS -->')]
        governance_queue += '\n' + modals
    
    # reports block
    reports = extract_node_by_class(dashboard[dashboard.find('Governance Dashboard'):], '<div class="row align-items-center">')

    # Security logs (from history.jsp)
    history_html = get_file_content(r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\history.jsp')
    audit_logs = extract_node_by_class(history_html, '<div class="card border-0 shadow-sm rounded-5 overflow-hidden">')

    manager_css = """
                    <div class="col-xl-12 mb-4">
                        <style>
                          .nav-pills .nav-link { color: #475569; transition: all 0.3s ease; border: 1px solid transparent; }
                          .nav-pills .nav-link.active { background-color: #0f172a; color: #fff; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); }
                          .nav-pills .nav-link:hover:not(.active) { background-color: #f8fafc; color: #0f172a; border-color: #e2e8f0; }
                        </style>

                        <ul class="nav nav-pills nav-fill bg-white p-2 border border-slate-100 shadow-sm rounded-pill" id="managerTabs" role="tablist">
                          <li class="nav-item" role="presentation"><button class="nav-link active fw-bold px-4 py-3 rounded-pill" id="gov-tab" data-bs-toggle="pill" data-bs-target="#gov" type="button" role="tab"><i class="bi bi-window-stack me-2"></i>Governance Overview</button></li>
                          <li class="nav-item" role="presentation"><button class="nav-link fw-bold px-4 py-3 rounded-pill" id="approval-tab" data-bs-toggle="pill" data-bs-target="#approval" type="button" role="tab"><i class="bi bi-file-earmark-check me-2"></i>Approval Pipeline</button></li>
                          <li class="nav-item" role="presentation"><button class="nav-link fw-bold px-4 py-3 rounded-pill" id="traffic-tab" data-bs-toggle="pill" data-bs-target="#traffic" type="button" role="tab"><i class="bi bi-broadcast me-2"></i>Live Traffic</button></li>
                          <li class="nav-item" role="presentation"><button class="nav-link fw-bold px-4 py-3 rounded-pill" id="audit-tab" data-bs-toggle="pill" data-bs-target="#audit" type="button" role="tab"><i class="bi bi-clock-history me-2"></i>Security Logs</button></li>
                        </ul>
                    </div>
    """
    
    manager_tabs = f"""
                    <c:when test="${{isManager}}">
                    <!-- 2. MANAGER: GOVERNANCE & MONITORING -->
                    {overstay_alert}
                    {manager_css}
                    <div class="tab-content" id="managerTabsContent">
                      <div class="tab-pane fade show active" id="gov" role="tabpanel">{reports}</div>
                      <div class="tab-pane fade" id="approval" role="tabpanel">{governance_queue}</div>
                      <div class="tab-pane fade" id="traffic" role="tabpanel">{live_monitoring}</div>
                      <div class="tab-pane fade" id="audit" role="tabpanel">{audit_logs}</div>
                    </div>
                    </c:when>
    """

    # TECHNICIAN TABS (same as before)
    notif_html = get_file_content(r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\notifications.jsp')
    notif_block = extract_node_by_class(notif_html, '<div class="notification-feed">')
    visit_log_html = get_file_content(r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\visit-log.jsp')
    assign_block = extract_node_by_class(visit_log_html, '<div class="card border-0 shadow-sm rounded-5 overflow-hidden mb-5">')
    if not assign_block: assign_block = extract_node_by_class(visit_log_html, '<div class="card border-0 shadow-sm rounded-4">')
    active_html = get_file_content(r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\active.jsp')
    active_block = extract_node_by_class(active_html, '<div class="card border-0 shadow-sm rounded-5 overflow-hidden">')
    incident_html = get_file_content(r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\report-incident.jsp')
    incident_block = extract_node_by_class(incident_html, '<div class="card border-0 shadow-sm rounded-5 overflow-hidden">')
    export_btn = '''<div class="d-flex justify-content-end mb-3 mt-2"><a href="${pageContext.request.contextPath}/visitor-portal/history/export-pdf" class="btn btn-white border border-light text-slate-600 px-4 py-2 rounded-4 shadow-sm fw-bold"><i class="bi bi-download me-2"></i>EXPORT LOGS</a></div>'''
    
    tech_css = manager_css.replace('managerTabs', 'techTabs').replace('gov-tab', 'tech-overview-tab').replace('#gov', '#tech-overview').replace('Governance Overview', 'Dashboard').replace('approval-tab', 'tech-assignments-tab').replace('#approval', '#tech-assignments').replace('Approval Pipeline', 'My Assignments').replace('traffic-tab', 'tech-active-tab').replace('#traffic', '#tech-active').replace('Live Traffic', 'Active Escorts').replace('audit-tab', 'tech-incident-tab').replace('#audit', '#tech-incident').replace('Security Logs', 'Report Incident').replace('<li class="nav-item" role="presentation"><button class="nav-link fw-bold px-4 py-3 rounded-pill" id="audit-tab"', '<li class="nav-item" role="presentation"><button class="nav-link fw-bold px-4 py-3 rounded-pill" id="tech-history-tab" data-bs-toggle="pill" data-bs-target="#tech-history" type="button" role="tab"><i class="bi bi-clock-history me-2"></i>Visit Archive</button></li>\x00')
    tech_css = tech_css.split('\x00')[0]
    
    tech_tabs = f"""
                    <c:otherwise>
                    <!-- 3. TECHNICIAN: OPERATIONAL TERMINAL -->
                    <c:set var="isTech" value="${{currentUser.role == 'TECHNICIAN'}}" />
                    {tech_css}
                    <div class="tab-content" id="techTabsContent">
                      <div class="tab-pane fade show active" id="tech-overview" role="tabpanel">{notif_block}</div>
                      <div class="tab-pane fade" id="tech-assignments" role="tabpanel">{assign_block}</div>
                      <div class="tab-pane fade" id="tech-active" role="tabpanel">{active_block}</div>
                      <div class="tab-pane fade" id="tech-incident" role="tabpanel">{incident_block}</div>
                      <div class="tab-pane fade" id="tech-history" role="tabpanel">{export_btn}{audit_logs}</div>
                    </div>
                    </c:otherwise>
    """

    # We now replace the blocks in the dashboard string!
    m1 = re.search(r'<c:when test="\$?\{isManager\}">.*?</c:when>\s*', dashboard, re.DOTALL)
    if not m1: 
        print("M1 failed")
        return
    manager_start = m1.start()

    m2 = re.search(r'<c:otherwise>.*?</c:otherwise>\s*(?=</c:choose>)', dashboard[m1.end():], re.DOTALL)
    if not m2:
        print("M2 failed")
        return
    tech_end = m1.end() + m2.end()

    stitched = dashboard[:manager_start] + manager_tabs + tech_tabs + dashboard[tech_end:]
    
    with open(r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\dashboard.jsp', 'w', encoding='utf-8') as f:
        f.write(stitched)

build_omni_dashboard()
print("Perfect reconstruction successful!")
