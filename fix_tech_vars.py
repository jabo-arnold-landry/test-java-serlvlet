import sys
import re

dashboard_path = r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\dashboard.jsp'

with open(dashboard_path, 'r', encoding='utf-8') as f:
    dashboard_str = f.read()

# Isolate the Tech block
start_marker = r'<!-- 3\. TECHNICIAN: OPERATIONAL TERMINAL -->'
m = re.search(f'({start_marker}.*?)</c:otherwise>', dashboard_str, re.DOTALL)
if m:
    tech_block = m.group(1)
    
    # Fix Assignments empty check
    tech_block = tech_block.replace('empty awaitingCheckIn', 'empty techAssignments')
    
    # Fix Active Escorts checks
    tech_block = tech_block.replace('empty activeVisitors', 'empty techEscorts')
    tech_block = tech_block.replace('items="${activeVisitors}"', 'items="${techEscorts}"')
    
    # Fix Incident Reports dropdown link
    tech_block = tech_block.replace('items="${activeEscorts}"', 'items="${techEscorts}"')
    
    # Replace the block
    new_dashboard_str = dashboard_str[:m.start(1)] + tech_block + dashboard_str[m.end(1):]
    
    with open(dashboard_path, 'w', encoding='utf-8') as f:
        f.write(new_dashboard_str)
    print("Variables fixed!")
else:
    print("Failed to find Tech block")
