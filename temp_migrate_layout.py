import os
import re

dirs = [
    r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal',
    r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\users'
]
count = 0

for d in dirs:
    if os.path.exists(d):
        for f in os.listdir(d):
            if f.endswith('.jsp'):
                p = os.path.join(d, f)
                with open(p, 'r', encoding='utf-8') as file: content = file.read()
                orig = content
                
                content = content.replace('../common/visitor-header.jsp', '../common/styles.jsp')
                content = content.replace('<body class="visitor-app">', '<body>')
                content = re.sub(r'<jsp:include page="\.\./common/visitor-sidebar\.jsp">\s*<jsp:param[^>]*/>\s*</jsp:include>', '<jsp:include page="../common/sidebar.jsp"/>\n    <jsp:include page="../common/topbar.jsp"/>', content)
                content = re.sub(r'<jsp:include page="\.\./common/visitor-sidebar\.jsp"/>', '<jsp:include page="../common/sidebar.jsp"/>\n    <jsp:include page="../common/topbar.jsp"/>', content)
                content = re.sub(r'<div class="vp-content-area"[^>]*>', '<div class="main-content">', content)
                
                if content != orig:
                    with open(p, 'w', encoding='utf-8') as file: file.write(content)
                    print(f'Updated {f}')
                    count += 1

print(f'Total updated: {count}')
