import sys
import re

dashboard_path = r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\dashboard.jsp'
notif_path = r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\notifications.jsp'

with open(dashboard_path, 'r', encoding='utf-8') as f:
    dashboard_str = f.read()
with open(notif_path, 'r', encoding='utf-8') as f:
    notif_lines = f.read().split('\n')

# 1. Grab rich notifications (lines 35-89)
rich_notifs = "\n".join(notif_lines[34:90])

# We replace the content of `id="tech-overview"` with `rich_notifs`
# The tech-overview tab starts at `id="tech-overview" role="tabpanel">`
# and ends right before `<!-- Tab 2: Assignments -->`
m_overview = re.search(r'(id="tech-overview"[^>]*>)(.*?)(<!-- Tab 2: Assignments -->)', dashboard_str, re.DOTALL)
if m_overview:
    dashboard_str = dashboard_str[:m_overview.start(2)] + "\n" + rich_notifs + "\n                          </div>\n\n                          " + dashboard_str[m_overview.start(3):]

# 2. Add 'isTech' variable if not present
is_tech_var = """
                    <!-- 3. TECHNICIAN: OPERATIONAL TERMINAL -->
                    <c:set var="isTech" value="${currentUser.role == 'TECHNICIAN'}" />
"""
dashboard_str = dashboard_str.replace("<!-- 3. TECHNICIAN: OPERATIONAL TERMINAL -->", is_tech_var.strip())

# 3. Add EXPORT LOGS button to history tab
# We find: `<div class="tab-pane fade" id="tech-history" role="tabpanel">`
# And inject the header button
export_btn = """<div class="d-flex justify-content-end mb-3 mt-2">
                    <a href="${pageContext.request.contextPath}/visitor-portal/history/export-pdf" class="btn btn-white border border-light text-slate-600 px-4 py-2 rounded-4 shadow-sm fw-bold">
                        <i class="bi bi-download me-2"></i>EXPORT LOGS
                    </a>
                </div>"""

m_history = re.search(r'(<div class="tab-pane fade" id="tech-history" role="tabpanel">)', dashboard_str)
if m_history:
    dashboard_str = dashboard_str[:m_history.end(1)] + "\n" + export_btn + dashboard_str[m_history.end(1):]


with open(dashboard_path, 'w', encoding='utf-8') as f:
    f.write(dashboard_str)

print("Restored ALL missed functionalities!")

