# Technical Report for Manager
## Smart Power & Cooling Management System (SPCMS)

**Report Date:** March 18, 2026  
**Project:** SPCMS - Smart Power & Cooling Management System  
**Target Audience:** Manager (Operations Manager Role)  
**Compliance:** Project documentation for management oversight & decision-making

---

## Executive Summary

The Smart Power & Cooling Management System (SPCMS) provides real-time monitoring, incident tracking, and automated reporting of critical infrastructure including UPS systems and cooling units. This report is intended for management oversight, enabling data-driven decisions on operational efficiency, downtime management, and infrastructure planning.

---

## 1. System Overview for Managers

### 1.1 What is SPCMS?
SPCMS is a web-based management platform that:
- **Monitors** real-time operational metrics (UPS load, cooling temperatures)
- **Tracks** incidents and downtime with automated calculations
- **Generates** daily operational reports with Key Performance Indicators (KPIs)
- **Manages** visitor approvals and shift-based operations
- **Alerts** teams to threshold breaches in real-time

### 1.2 Key Users & Roles
| Role | Responsibility |
|------|-----------------|
| **IT Administrator** | System deployment, configuration, user management, security |
| **Manager** | Report generation, incident approval, operational oversight (YOUR ROLE) |
| **Technician** | Monitoring, maintenance logging, incident resolution |
| **Operator/Viewer** | Read-only dashboard access |

---

## 2. Your Access & Permissions (Manager Role)

### 2.1 What Can You Do?
✅ **View & Generate Reports**
- Daily consolidated reports with KPIs (load averages, temperatures, incident counts)
- Downtime trends (comparing current vs. previous periods)
- Equipment-specific reports (UPS, cooling metrics)
- CSV export for further analysis

✅ **Incident & Downtime Management**
- Monitor active incidents in real-time
- Approve/reject visitor access (security compliance)
- Review Mean Time To Repair (MTTR) and Mean Time Between Failures (MTBF)

✅ **Operational Insights**
- Dashboard showing today's key metrics
- Historical trend analysis (last 7, 30 days)
- Equipment utilization and load patterns

❌ **What You Cannot Do**
- Modify user roles or permissions (Admin only)
- Delete system users (Admin only)
- Edit security settings or system configuration
- Access IT infrastructure logs (Admin only)

### 2.2 Login Credentials
```
URL: http://localhost:8080/spcms/login
Username: manager
Password: manager123
```
**⚠️ Change your password after first login!**

---

## 3. Key Features for Managers

### 3.1 Dashboard
**Access:** Click "Dashboard" in main navigation after login

**Displays:**
- Today's average UPS load percentage
- Today's temperature averages (room conditions)
- Active incidents count
- Alert summary (critical, warning, info levels)
- Visitor count (current active)

**Quick Actions:**
- Click "Daily Report" to generate today's full report
- Click "Shift Reports" to view shift-based summaries
- Click "Incidents" to review open/resolved incidents

### 3.2 Daily Reports & Analytics
**Access:** Navigate → Reports → Daily Report

**Shows:**
| Metric | Meaning | Business Use |
|--------|---------|-------------|
| **Avg Daily Load (%)** | Average UPS utilization | Capacity planning, peak-load identification |
| **Highest Temp Recorded** | Peak cooling room temperature | HVAC efficiency, temperature compliance |
| **Total Incidents** | Equipment failures logged today | Operational reliability, SLA tracking |
| **Total Downtime (min)** | Sum of all incident durations | Business impact, recovery time analysis |
| **MTTR (Mean Time To Repair)** | Avg minutes to resolve incidents | Team efficiency, response capability |
| **MTBF (Mean Time Between Failures)** | Avg hours between consecutive failures | Equipment reliability, replacement planning |
| **Total UPS Alarms** | Cooling system alerts triggered | Preventive maintenance trigger |
| **Total Visitors** | Active visitor count | Security compliance, occupancy tracking |

### 3.3 Downtime Trends
**Access:** Reports → Downtime Trend

**Analysis:**
- Compares downtime last week vs. this week
- Shows percentage increase/decrease
- Helps identify patterns and seasonal issues
- Use to schedule maintenance during low-impact windows

### 3.4 Shift Reports
**Access:** Shift Reports (left navigation)

**Purpose:** Operationally critical—captures shift-by-shift operational state

**Fields:**
- Shift date and type (Morning/Afternoon/Night)
- Average load percentage during shift
- Downtime events logged
- Handover notes from technicians
- Shift staff responsible (accountability)

---

## 4. Incident & Downtime Management

### 4.1 How Downtime is Tracked
1. **Technician logs incident** (equipment failure, power loss, etc.)
2. **System records:** Start time, affected equipment, root cause
3. **Technician resolves & marks complete** (logs resolution time)
4. **Downtime calculated:** End time - Start time = duration in minutes
5. **Reports aggregate:** Daily/Shift reports sum total downtime for the period

### 4.2 Managing Incidents (Your Workflow)
**Access:** Incidents (left navigation)

**As Manager, you can:**
- View all incidents (open, resolved, by date range)
- Filter by equipment type (UPS, Cooling, Equipment)
- Review MTTR calculation (automatic)
- Escalate urgent incidents to IT Admin
- Generate incident reports for upper management

**Action Items:**
- Review unresolved incidents daily
- Follow up on high-downtime incidents
- Identify systemic issues (e.g., recurring failures)

### 4.3 SLA & Compliance Tracking
**Using MTTR Metrics:**
- If SLA target is "resolve within 2 hours" → MTTR should be ≤ 120 minutes
- Use historical MTTR to assess team performance
- Trend increasing MTTR → training or staffing needs

---

## 5. Visitor Approval & Security Compliance

### 5.1 Your Role in Visitor Management
**Access:** Visitors (left navigation) → Pending Approvals

**Workflow:**
1. **Technician requests visitor access** (logs check-in)
2. **System generates approval request** (visitor shown in pending list)
3. **You review & approve/reject** (security gate)
4. **Visitor cleared or denied** (audit trail created)

**Compliance Importance:**
- No unauthorized personnel access data center
- Creates accountability & security audit trail
- Required for industry compliance (SOC 2, ISO 27001)

---

## 6. Report Generation & Export

### 6.1 Generating Custom Reports
**Steps:**
1. Navigate → Reports → Report Range
2. Select start date and end date
3. Click "Generate"
4. View metrics for selected period
5. Use browser "Print" or "Save as PDF" for documentation

### 6.2 CSV Export (UPS Reports)
**Access:** Reports → UPS Report → Export to CSV

**Use Cases:**
- Share with finance for capacity budgeting
- Archive for compliance audits (SoC 2, ISO audits)
- Import into Excel/BI tools (Power BI, Tableau) for custom dashboards
- Historical trending analysis

---

## 7. Key Performance Indicators (KPIs) for Management

### 7.1 Operational Efficiency
| KPI | Target | How to Monitor |
|-----|--------|----------------|
| **MTTR (Mean Time To Repair)** | < 60 min | Dashboard → Daily Report |
| **MTBF (Mean Time Between Failures)** | > 168 hrs (1 week) | Dashboard → Daily Report |
| **Availability** | > 99.5% | Calculated: (Total Hours - Downtime Hours) / Total Hours |
| **Incident Count (Daily)** | < 5 | Dashboard → Active Incidents |

### 7.2 Capacity & Utilization
| KPI | Target | How to Monitor |
|-----|--------|----------------|
| **Avg UPS Load** | 40-70% | Dashboard → Avg Daily Load % |
| **Peak Load** | < 85% | Reports → Downtime Trends → Load Trend |
| **Temperature** | 18-24°C | Dashboard → Room Temperature |

### 7.3 Compliance & Security
| KPI | Target | How to Monitor |
|-----|--------|----------------|
| **Visitor Approvals** | 100% logged | Visitors → Approval History |
| **Incident Documentation** | All logged within 24 hrs | Incidents → Review date-added field |
| **Report Generation** | Monthly for compliance | Reports → Generate on schedule |

---

## 8. Common Workflows for Managers

### 8.1 Daily Operations Check (5-10 minutes)
```
1. Log in: http://localhost:8080/spcms/login
2. Review Dashboard (any new alerts?)
3. Check Incidents (any unresolved?)
4. Review Visitor Approvals (approve/deny)
5. Note: Escalate critical issues to IT Admin
```

### 8.2 Weekly Report Generation
```
1. Navigate: Reports → Daily Report (select this week's date)
2. Screenshot or PDF for upper management
3. Compare metrics to SLA targets
4. Document any incidents requiring follow-up
```

### 8.3 Monthly Management Meeting Prep
```
1. Generate full month report: Reports → Report Range (month start to end)
2. Calculate metrics:
   - Avg MTTR = Sum of daily MTTRs / Days in month
   - Uptime % = (Hours - Total Downtime) / Total Hours
   - Incident trend = Compare to previous month
3. Identify top 3 issues requiring attention
4. Present trends & recommendations to leadership
```

### 8.4 Incident Post-Mortem
```
1. Navigate: Incidents (find incident by date)
2. Review:
   - Timeline (log start & resolution times)
   - Equipment affected
   - Root cause
   - Time to repair (MTTR component)
3. Action: Document lessons learned
4. Follow-up: Assign preventive maintenance if needed
```

---

## 9. Troubleshooting & Support

### 9.1 Common Issues & Solutions
| Problem | Solution |
|---------|----------|
| "Access Denied" on Reports | Verify you're logged in as Manager role; contact IT Admin to confirm role assignment |
| Reports show "0" incidents | Correct - system only tracks logged incidents; ensure technicians log all downtime events |
| Can't approve visitors | Check if incident visitor requires equipment check-in first; coordinate with technician |
| Report dates seem incorrect | System uses database timestamps (UTC or server timezone); confirm with IT Admin if needed |

### 9.2 Data Not Appearing?
1. **Dashboard empty:** Check if monitoring logs are being recorded (technicians must log incidents)
2. **No reports available:** Generate using Reports → Generate → select date
3. **Old data missing:** Contact IT Admin to verify backup/archive procedures

### 9.3 Contact IT Administrator
- **For access issues:** Provide your username and the endpoint you can't access
- **For data questions:** Provide date range and equipment type of concern
- **For system errors:** Screenshot error message and provide steps to reproduce

---

## 10. Best Practices for Managers

### 10.1 Regular Operations
✅ **DO:**
- Review dashboard daily (alerts, incident count)
- Generate weekly reports for compliance records
- Approve visitor access promptly (within 4 hours)
- Follow up on unresolved incidents
- Document critical decisions in incident notes

❌ **DON'T:**
- Ignore MTTR increasing trends (may signal staffing/training needs)
- Approve visitors without verification (security risk)
- Skip monthly reporting (compliance requirement)
- Share manager/admin credentials (password security)

### 10.2 Data-Driven Decision Making
**Example Scenario:**
```
MTTR trending up: 45 min → 90 min → 120 min over 3 weeks
Action: Review root causes
  - Are incidents more complex? → Schedule training
  - Is response time slow? → Check staffing levels
  - Is escalation process broken? → Improve runbooks
```

---

## 11. Compliance & Auditing

### 11.1 Report for External Audits
When auditors require evidence of operational oversight:
1. Export monthly consolidated reports (CSV)
2. Provide incident log with dates/durations
3. Show MTTR/MTBF trending (demonstrates continuous improvement)
4. Document visitor approval audit trail

### 11.2 SLA Compliance Evidence
- **Uptime claims:** Use MTBF & MTTR calculations
- **Response time:** Document incident log start-to-resolve
- **Availability %:** Calculate using dowtime metrics
- **Escalation process:** Show incident approval workflow

---

## 12. Quick Reference: Your Dashboard

| Section | Action | Frequency |
|---------|--------|-----------|
| **Dashboard** | Quick metrics check | Daily |
| **Reports** | Generate compliance report | Weekly |
| **Downtime Trend** | Analyze patterns | Bi-weekly |
| **Incidents** | Follow up on unresolved | Daily |
| **Visitors** | Approve/deny requests | As needed (target: <4 hrs) |
| **Shift Reports** | Review operational handover | Daily |

---

## 13. Conclusion

As the designated Manager in SPCMS, you have the tools and authority to:
- **Monitor** infrastructure health in real-time
- **Manage** incident response and downtime tracking
- **Report** on SLAs and operational metrics
- **Control** visitor access (security compliance)
- **Optimize** operations through data-driven insights

**Your primary responsibility:** Ensure operational reliability and compliance through active monitoring and informed decision-making.

For technical questions beyond this guide's scope, contact the IT Administrator or development team.

---

**Document Version:** 1.0  
**Last Updated:** March 18, 2026  
**Audience:** Manager / Operations Lead  
**Classification:** Internal - Operational Control Document
