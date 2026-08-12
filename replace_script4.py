import sys

file_path = 'lib/features/home/presentation/widgets/main_screen_byts_view.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
skip_next = False
for line in lines:
    if skip_next:
        skip_next = False
        continue
    
    if 'const SizedBox(height: 4),' in line and ('Text("Like"' in lines[lines.index(line) + 1] or 'Text("Comment"' in lines[lines.index(line) + 1] or 'Text("Reload"' in lines[lines.index(line) + 1] or 'Text("Share"' in lines[lines.index(line) + 1]):
        skip_next = True
        continue
    elif ('Text("Like"' in line or 'Text("Comment"' in line or 'Text("Reload"' in line or 'Text("Share"' in line) and 'fontStyle' in line:
        pass # Handle if we are already here
    else:
        new_lines.append(line)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(''.join(new_lines))

print("Removed labels successfully")
