#!/usr/bin/env python3
"""
Uppercase Converter for Teletype Output
Converts all lowercase characters in printf statements to uppercase
for UNIVAC 1219 teletype compatibility
"""

import re
import os
import sys

def convert_string_to_uppercase_content(content):
    """
    Convert string content to uppercase.
    Preserves format specifiers like %s, %d, %c, etc.
    Preserves escape sequences like \n, \t, etc.
    Skips filenames and paths.
    """
    # Skip if it's a filename or path
    if '.h' in content or '.c' in content or '/' in content or '\\\\' in content:
        return content
    
    # Convert to uppercase while preserving format specifiers and escape sequences
    result = ""
    i = 0
    while i < len(content):
        if content[i] == '%' and i + 1 < len(content):
            # Preserve format specifier exactly as-is
            result += content[i]
            i += 1
            # Handle the format character(s)
            while i < len(content) and content[i] in 'sdcfxXeEgGpnui-+ #0123456789.lLhz':
                result += content[i]
                i += 1
        elif content[i] == '\\' and i + 1 < len(content):
            # Preserve escape sequences exactly as-is
            result += content[i:i+2]
            i += 2
        else:
            # Convert regular characters to uppercase
            result += content[i].upper()
            i += 1
    
    return result

def process_file(filepath):
    """Process a single C file and convert all string literals to uppercase."""
    print(f"Processing {filepath}...")
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Pattern to match ALL string literals in double quotes
    # This will match any "..." string in the code
    # We'll exclude strings that are clearly filenames or special cases
    def replace_string_literal(match):
        full_match = match.group(0)
        prefix = match.group(1) if match.lastindex >= 1 else ""
        quote = '"'
        string_content = match.group(2) if match.lastindex >= 2 else match.group(1)
        
        # Skip if it's a filename (contains .h, .c, or path separators)
        if '.h' in string_content or '.c' in string_content or '/' in string_content or '\\' in string_content:
            return full_match
        
        # Convert the string content to uppercase
        result = convert_string_to_uppercase_content(string_content)
        return quote + result + quote
    
    # Pattern to match string literals (handles escaped quotes inside strings)
    pattern = r'"([^"\\]*(?:\\.[^"\\]*)*)"'
    
    # Replace all string literals
    content = re.sub(pattern, lambda m: '"' + convert_string_to_uppercase_content(m.group(1)) + '"', content)
    
    if content != original_content:
        # Backup original file
        backup_path = filepath + '.bak'
        with open(backup_path, 'w', encoding='utf-8') as f:
            f.write(original_content)
        print(f"  ✓ Backup created: {backup_path}")
        
        # Write modified content
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  ✓ Updated: {filepath}")
        return True
    else:
        print(f"  - No changes needed")
        return False

def main():
    """Main function to process all C files in the current directory."""
    print("=" * 60)
    print("UPPERCASE CONVERTER FOR TELETYPE OUTPUT")
    print("=" * 60)
    print()
    
    # Get all .c files in current directory
    c_files = [f for f in os.listdir('.') if f.endswith('.c')]
    
    if not c_files:
        print("No .c files found in current directory!")
        sys.exit(1)
    
    print(f"Found {len(c_files)} C file(s):")
    for f in c_files:
        print(f"  - {f}")
    print()
    
    # Ask for confirmation
    response = input("Convert all printf statements to uppercase? (y/n): ").strip().lower()
    if response != 'y':
        print("Operation cancelled.")
        sys.exit(0)
    
    print()
    print("-" * 60)
    
    # Process each file
    modified_count = 0
    for c_file in c_files:
        if process_file(c_file):
            modified_count += 1
    
    print("-" * 60)
    print()
    print(f"COMPLETE! Modified {modified_count} file(s).")
    print()
    print("Backup files (.bak) have been created for all modified files.")
    print("To restore original files, rename the .bak files.")
    print()

if __name__ == "__main__":
    main()
