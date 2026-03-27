import sys
import re

with open(r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\dashboard.jsp', 'r', encoding='utf-8') as f:
    text = f.read()

match_manager = re.search(r'<c:when test="\$?\{isManager\}">.*?</c:when>\s*', text, re.DOTALL)
if match_manager:
    idx = match_manager.end()
    text = text[:idx]
    
    stack = []
    for i, line in enumerate(text.split('\n')):
        if '<c:choose' in line: stack.append(('choose', i+1))
        if '</c:choose' in line:
            if stack and stack[-1][0] == 'choose': stack.pop()
            else: print(f'Mismatched </c:choose> at {i+1}')
        if '<c:otherwise' in line: stack.append(('otherwise', i+1))
        if '</c:otherwise' in line:
            if stack and stack[-1][0] == 'otherwise': stack.pop()
            else: print(f'Mismatched </c:otherwise> at {i+1}')
        if '<c:if' in line: stack.append(('if', i+1))
        if '</c:if' in line:
            if stack and stack[-1][0] == 'if': stack.pop()
            else: print(f'Mismatched </c:if> at {i+1}')
            
    print('Unclosed tags:', stack)
else:
    print('Manager block not found.')
