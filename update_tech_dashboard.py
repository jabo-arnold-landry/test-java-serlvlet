import sys

# Files to read
dashboard_path = r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\dashboard.jsp'
visit_log_path = r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\visit-log.jsp'
active_path = r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\active.jsp'
history_path = r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\history.jsp'
incident_path = r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\report-incident.jsp'

# Read files
with open(dashboard_path, 'r', encoding='utf-8') as f:
    dashboard_lines = f.read().split('\n')
with open(visit_log_path, 'r', encoding='utf-8') as f:
    visit_log_lines = f.read().split('\n')
with open(active_path, 'r', encoding='utf-8') as f:
    active_lines = f.read().split('\n')
with open(history_path, 'r', encoding='utf-8') as f:
    history_lines = f.read().split('\n')
with open(incident_path, 'r', encoding='utf-8') as f:
    incident_lines = f.read().split('\n')

# The `isTechnician` (c:otherwise) block in dashboard.jsp starts at line 664 (index 663)
# Ends at line 742 (index 741)
# 663:                 <c:otherwise>
# 664:                     <!-- 3. TECHNICIAN: OPERATIONAL TERMINAL -->
# ...
# 742:                 </c:otherwise>

# 1. Tech Dashboard (Notifications) from dashboard.jsp lines 666-700
tech_overview = "\n".join(dashboard_lines[665:700])

# 2. Tech Assignments (from visit_log_lines). Let's extract between "<!-- Main Log Section -->" (line 50) and before "<!-- Secondary Section"
# Or let's just extract lines 50 to 169
assignments = "\n".join(visit_log_lines[50:169])
# We need to change `awaitingCheckIn` to `techAssignments`
assignments = assignments.replace('items="${awaitingCheckIn}"', 'items="${techAssignments}"')

# 3. Active Escorts (from active_lines). Let's extract the main table from `active.jsp`
# active.jsp has the card between line 31 and line 214 (end of card)
# Let's use string find
active_content = "\n".join(active_lines)
active_start = active_content.find('<div class="card border-0 shadow-sm rounded-5 overflow-hidden mb-4">')
active_end = active_content.find('<!-- COMPREHENSIVE ACTIONS BAR -->')
if active_end == -1: active_end = active_content.find('</c:forEach>') + len('</c:forEach>') + 100 # rough
active_html = active_content[active_start:active_end]
# We only want the table part
# Wait, actually active.jsp lines 40 to 184 is the card
active_html = "\n".join(active_lines[40:185])
# Wait, let's just make it simple. We can use the Active Escorts table block we know works.

# 4. History (from history_lines).
# history.jsp lines 40 to 127
history_html = "\n".join(history_lines[40:128])

# 5. Incident Report HTML (from incident_lines)
# report-incident.jsp lines 66 to 137
incident_form = "\n".join(incident_lines[65:138])

# We need to construct the tabs UI now!
tabs_html = f"""
                    <!-- 3. TECHNICIAN: OPERATIONAL TERMINAL -->
                    <div class="col-xl-12 mb-4">
                        <style>
                          .nav-pills .nav-link {{ color: #475569; transition: all 0.3s ease; border: 1px solid transparent; }}
                          .nav-pills .nav-link.active {{ background-color: #0f172a; color: #fff; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); }}
                          .nav-pills .nav-link:hover:not(.active) {{ background-color: #f8fafc; color: #0f172a; border-color: #e2e8f0; }}
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

                    <div class="col-xl-12">
                        <div class="tab-content" id="techTabsContent">
                          <!-- Tab 1: Overview -->
                          <div class="tab-pane fade show active" id="tech-overview" role="tabpanel">
{tech_overview}
                          </div>

                          <!-- Tab 2: Assignments -->
                          <div class="tab-pane fade" id="tech-assignments" role="tabpanel">
{assignments}
                          </div>

                          <!-- Tab 3: Active Escorts -->
                          <div class="tab-pane fade" id="tech-active" role="tabpanel">
{active_html}
                          </div>

                          <!-- Tab 4: Report Incident -->
                          <div class="tab-pane fade" id="tech-incident" role="tabpanel">
                              <div class="card glass-card shadow-sm rounded-5 border-0 p-5 mt-2">
{incident_form}
                              </div>
                          </div>

                          <!-- Tab 5: History -->
                          <div class="tab-pane fade" id="tech-history" role="tabpanel">
{history_html}
                          </div>
                        </div>
                    </div>
"""

# Find the start and end of the block in dashboard.jsp
# From `<c:otherwise>` to `</c:otherwise>`
dashboard_str = "\n".join(dashboard_lines)

otherwise_start = dashboard_str.rfind('<c:otherwise>')
otherwise_end = dashboard_str.find('</c:otherwise>', otherwise_start)

new_dashboard_str = dashboard_str[:otherwise_start + len('<c:otherwise>')] + '\n' + tabs_html + '\n' + dashboard_str[otherwise_end:]

with open(dashboard_path, 'w', encoding='utf-8') as f:
    f.write(new_dashboard_str)

print('Success: Rebuilt Technician Dashboard')
