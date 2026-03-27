import sys
import re

file_path = r'c:\Users\user\Desktop\test-java-serlvlet\src\main\webapp\WEB-INF\jsp\visitor-portal\dashboard.jsp'
with open(file_path, 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Tech start
match_manager = re.search(r'<c:when test="\$?\{isManager\}">.*?</c:when>\s*<c:otherwise>', text, re.DOTALL)
idx_tech_start = match_manager.end() - len('<c:otherwise>')

# 2. Tech end
idx_outer_choose_end = text.rfind('</c:choose>')
idx_tech_end = text.rfind('</c:otherwise>', idx_tech_start, idx_outer_choose_end)

print(f"Tech block boundaries: {idx_tech_start} to {idx_tech_end}")

# 3. Extract the tabs!
match_tabs_start = re.search(r'<div class="col-xl-12 mb-4">\s*<style>\s*\.nav-pills', text[idx_tech_start:idx_tech_end])
if not match_tabs_start:
    print('Failed to find tabs start inside tech block!')
    exit(1)

tabs_start_global = idx_tech_start + match_tabs_start.start()
print("Tabs UI found at:", tabs_start_global)

def find_matching_closing_div(html, start_idx):
    count = 0
    i = start_idx
    while i < len(html):
        # We need to only match exact tags
        if html.startswith('<div', i) or html.startswith('<DIV', i):
            count += 1
            i += 4
        elif html.startswith('</div', i) or html.startswith('</DIV', i):
            count -= 1
            if count == 0:
                return i + 6
            i += 5
        else:
            i += 1
    return -1

tabs_end_global = find_matching_closing_div(text, tabs_start_global)

match_tab_content = re.search(r'<div class="col-xl-12">\s*<div class="tab-content" id="techTabsContent">', text[tabs_end_global:])
content_start_global = tabs_end_global + match_tab_content.start()
content_end_global = find_matching_closing_div(text, content_start_global)

if tabs_end_global == -1 or content_end_global == -1:
    print('Failed to match divs!')
    exit(1)

extracted_nav = text[tabs_start_global : tabs_end_global]
extracted_content = text[content_start_global : content_end_global]

# Check if tabs_end_global actually grabbed the </div>
print("Nav end string:", text[tabs_end_global-6 : tabs_end_global])
print("Content end string:", text[content_end_global-6 : content_end_global])

clean_tech_block = f'''<c:otherwise>
                    <!-- 3. TECHNICIAN: OPERATIONAL TERMINAL -->
                    <c:set var="isTech" value="${{currentUser.role == 'TECHNICIAN'}}" />
                    {extracted_nav}
                    {extracted_content}
                </c:otherwise>'''

new_text = text[:idx_tech_start] + clean_tech_block + text[idx_tech_end + len('</c:otherwise>'):]

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_text)

print("Technician Tabs perfectly extracted and dashboard block cleaned successfully!!!")
