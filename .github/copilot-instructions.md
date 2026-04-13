# GitHub Copilot Instructions
WARNING! Never create any fallback system unless specifically told. No stupid fake fallbacks.
Always create a Try Catch system with appropriate error messages for proper debugging. Use those error messages to resolve issues yourself.


Keep all code simple, easy and modular. Use multiple files if needed. Never create large files. Keep functions small and single purpose. Each file will have a specific purpose of a single domain. Write the absolute minimal code to achieve that purpose with concise comments.


Use meaningful names for files, functions, and variables. Avoid abbreviations unless they are widely understood. Use comments to explain complex logic. Follow proper code smell rules


Before making a new file always make a file and folder structure plan instead of randomly creating disorganized mess. You must have a clear plan of how files and folders will be organized for the new file and how it will integrate with the current system modularly and can be used anywhere however we want.

Use flutter chrome debug. dont use shared prefs, use the Isar db user settings.

NEVER USE cat, ls, touch, grep or ANY TERMINAL COMMAND TO EDIT FILES! ONLY USE TOOL CALLS LIKE READ/WRITE/CREATE TO MODIFY FILES, OTHERWISE CODE WILL NEVER RUN! dont use any terminal commands

BANNED terminal commands cat, ls, touch, grep, sed. 
Use proper tool calls instead. like Read / Write/ Create/ lint / fetch url, etc.
