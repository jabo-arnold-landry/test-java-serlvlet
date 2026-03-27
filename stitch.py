import re

with open(r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\dashboard.jsp', 'r', encoding='utf-8') as f:
    text = f.read()

# Find the exact end of the Manager block. 
match_manager = re.search(r'<c:when test="\$?\{isManager\}">.*?</c:when>\s*', text, re.DOTALL)
idx_tech_start = match_manager.end()

with open(r'c:\Users\user\Desktop\test-java-serlvlet\generated_tech_tabs.html', 'r', encoding='utf-8') as f:
    tech_tabs = f.read()

with open(r'c:\Users\user\Desktop\test-java-serlvlet\tail_backup.html', 'r', encoding='utf-8') as f:
    tail = f.read()

# Assemble!
new_text = text[:idx_tech_start] + tech_tabs + '\n' + tail

with open(r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\dashboard.jsp', 'w', encoding='utf-8') as f:
    f.write(new_text)

print('Dashboard stitched together successfully!')
