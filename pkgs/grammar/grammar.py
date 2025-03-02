#!/usr/bin/env python3

import subprocess
import json
import sys
from colored import Fore, Style

def get_json(filename):
    command = ['languagetool-commandline', '--json', filename]
    
    try:
        result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        
        if result.returncode != 0:
            print(f"Error: {result.stderr}")
            return None
        
        json_output = json.loads(result.stdout)
        
        return json_output
    
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}")
        return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

def print_error(prefix, highlight, suffix):
    print_line(prefix, highlight, suffix, Fore.dark_gray, f'{Style.underline}{Fore.light_red}')

def print_recommendation(prefix, highlight, suffix):
    print_line(prefix, highlight, suffix, Fore.dark_gray, f'{Style.underline}{Fore.green}')

def print_line(prefix, highlight, suffix, text_style, highlight_style):
    print(f'{text_style}{prefix}{Style.reset}{highlight_style}{highlight}{Style.reset}{text_style}{suffix}{Style.reset}')

def parse_match(error):
    message = error["message"]
    context = error["context"]
    text = context["text"]
    offset = int(context["offset"])
    length = int(context["length"])

    end = offset + length

    prefix = text[:offset]
    problem = text[offset:end]
    suffix = text[end:]

    print(f'{Style.italic}{message}{Style.reset}')
    print_error(prefix, problem, suffix)

    for replacement in error["replacements"]:
        print_recommendation(prefix, replacement["value"], suffix)
    print('')


def process_json(errors):
    for error in errors["matches"]:
        parse_match(error)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: grammar <filename>")
        sys.exit(1)
    
    filename = sys.argv[1]
    process_json(get_json(filename))
