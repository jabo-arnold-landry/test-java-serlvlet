import sys

file_path = r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\dashboard.jsp'
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.read().split('\n')

# The Manager block starts at line 220 (index 219)
# Ends at line 481 (index 480)

# Let's extract exactly the blocks we need by their known line numbers
# from the previous view_file.

# overstay alert block: lines 221 to 234
overstay_alert = "\n".join(lines[220:234])
# remove the VIEW ALERTS button because it points to /active
overstay_alert = overstay_alert.replace('<a href="${pageContext.request.contextPath}/visitor-portal/active" class="btn btn-danger rounded-pill px-4">VIEW ALERTS</a>', '')

# live monitoring block: lines 236 to 308
live_monitoring = "\n".join(lines[235:308])
live_monitoring = live_monitoring.replace('class="col-xl-7"', 'class="col-xl-12"')
live_monitoring = live_monitoring.replace('end="4"', '')

# governance queue block (with modals): lines 310 to 459
governance_queue = "\n".join(lines[309:459])
governance_queue = governance_queue.replace('class="col-xl-5"', 'class="col-xl-12"')
governance_queue = governance_queue.replace('end="4"', '')

# reports block: lines 461 to 480
reports = "\n".join(lines[460:480])

# CSS for tabs
css = """
                    <div class="col-xl-12 mb-4">
                        <style>
                          .nav-pills .nav-link { color: #475569; transition: all 0.3s ease; border: 1px solid transparent; }
                          .nav-pills .nav-link.active { background-color: #0f172a; color: #fff; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); }
                          .nav-pills .nav-link:hover:not(.active) { background-color: #f8fafc; color: #0f172a; border-color: #e2e8f0; }
                        </style>

                        <ul class="nav nav-pills nav-fill bg-white p-2 border border-slate-100 shadow-sm rounded-pill" id="managerTabs" role="tablist">
                          <li class="nav-item" role="presentation">
                            <button class="nav-link active fw-bold px-4 py-3 rounded-pill" id="gov-tab" data-bs-toggle="pill" data-bs-target="#gov" type="button" role="tab"><i class="bi bi-window-stack me-2"></i>Governance Overview</button>
                          </li>
                          <li class="nav-item" role="presentation">
                            <button class="nav-link fw-bold px-4 py-3 rounded-pill" id="approval-tab" data-bs-toggle="pill" data-bs-target="#approval" type="button" role="tab"><i class="bi bi-file-earmark-check me-2"></i>Approval Pipeline</button>
                          </li>
                          <li class="nav-item" role="presentation">
                            <button class="nav-link fw-bold px-4 py-3 rounded-pill" id="traffic-tab" data-bs-toggle="pill" data-bs-target="#traffic" type="button" role="tab"><i class="bi bi-broadcast me-2"></i>Live Traffic</button>
                          </li>
                          <li class="nav-item" role="presentation">
                            <button class="nav-link fw-bold px-4 py-3 rounded-pill" id="audit-tab" data-bs-toggle="pill" data-bs-target="#audit" type="button" role="tab"><i class="bi bi-clock-history me-2"></i>Security Logs</button>
                          </li>
                        </ul>
                    </div>
"""

# Audit logs table
audit_logs = """
                    <div class="col-xl-12">
                        <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4">
                            <div class="card-header bg-white p-4 border-0">
                                <div class="d-flex align-items-center justify-content-between">
                                    <h5 class="fw-bold mb-0 text-dark">Security Audit Logs</h5>
                                    <a href="${pageContext.request.contextPath}/visitor-portal/history/export-pdf" class="btn btn-sm btn-outline-secondary fw-bold rounded-pill"><i class="bi bi-download me-1"></i> PDF</a>
                                </div>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="bg-light text-muted small uppercase">
                                        <tr>
                                            <th class="px-4 py-3">Visitor Name</th>
                                            <th class="px-4 py-3">Company</th>
                                            <th class="px-4 py-3">Purpose</th>
                                            <th class="px-4 py-3">Visit Date</th>
                                            <th class="px-4 py-3">Status</th>
                                            <th class="px-4 py-3 text-end">Protocol Escort</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${empty pastVisits}">
                                                <tr><td colspan="6" class="text-center py-5 text-slate-400">No historical sessions recorded.</td></tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="v" items="${pastVisits}">
                                                    <tr>
                                                        <td class="px-4 py-3">
                                                            <div class="fw-bold text-dark">${v.visitor.fullName}</div>
                                                            <div class="small text-muted">#VR-${v.visitor.visitorId}</div>
                                                        </td>
                                                        <td class="px-4 py-3 text-muted">${v.visitor.company}</td>
                                                        <td class="px-4 py-3"><span class="badge bg-slate-100 text-slate-600 px-3 py-2 rounded-pill small">${v.visitor.purposeOfVisit}</span></td>
                                                        <td class="px-4 py-3">
                                                            <div class="text-dark fw-bold">${v.visitor.visitDate}</div>
                                                            <div class="small text-muted">${v.checkInTime.toLocalTime().toString().substring(0, 5)} - ${v.checkOutTime.toLocalTime().toString().substring(0, 5)}</div>
                                                        </td>
                                                        <td class="px-4 py-3"><span class="badge bg-slate-900 text-white rounded-pill px-3 py-2 small">CLOSED</span></td>
                                                        <td class="px-4 py-3 text-end">
                                                            <div class="small fw-bold text-dark">${v.escort.fullName}</div>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
"""

# Reconstruct the Manager Block
new_manager_block = f"""
                    <!-- 2. MANAGER: GOVERNANCE & MONITORING -->
{overstay_alert}
{css}
                    <div class="tab-content" id="managerTabsContent">
                      <!-- Tab 1: Governance Overview -->
                      <div class="tab-pane fade show active" id="gov" role="tabpanel">
{reports}
                      </div>
                      
                      <!-- Tab 2: Approval Pipeline -->
                      <div class="tab-pane fade" id="approval" role="tabpanel">
{governance_queue}
                      </div>

                      <!-- Tab 3: Live Traffic -->
                      <div class="tab-pane fade" id="traffic" role="tabpanel">
{live_monitoring}
                      </div>

                      <!-- Tab 4: Audit Logs -->
                      <div class="tab-pane fade" id="audit" role="tabpanel">
{audit_logs}
                      </div>
                    </div>
"""

lines[219:480] = [new_manager_block.strip()]

with open(file_path, 'w', encoding='utf-8') as f:
    f.write("\n".join(lines))

print('Successfully Rebuilt Dashboard JSP')
