#!/usr/bin/env python3
"""Split monolithic impl/phaseN-impl.md files into per-task directories.

Usage: python split-impl.py <plan-dir>

Splits each impl/phaseN-impl.md into:
  impl/phaseN/context.md  — Everything before ## Tasks + everything after last task
  impl/phaseN/taskN.md    — Each ### Task N: section

After splitting, deletes the monolithic file and updates state.yaml artifacts.
"""

import re
import sys
from pathlib import Path


def extract_task_id_suffix(section: str) -> str:
    """Extract task number/suffix from a task section.

    Looks for **ID:** `phaseN-taskX` pattern first, falls back to heading.
    """
    # Reason: task IDs like phase1-task3b have letter suffixes
    id_match = re.search(r'\*\*ID:\*\*\s*`\w+-task([^`]+)`', section)
    if id_match:
        return id_match.group(1)

    heading_match = re.search(r'^###\s+Task\s+(\S+?):', section, re.MULTILINE)
    if heading_match:
        raw = heading_match.group(1)
        # Strip leading phase prefix if present (e.g., "1.3" -> "3")
        if '.' in raw:
            raw = raw.split('.')[-1]
        return raw

    return None


def split_impl_file(impl_path: Path, phase_name: str) -> dict:
    """Split a single phaseN-impl.md into context.md + per-task files.

    Returns dict of created files for reporting.
    """
    content = impl_path.read_text()
    lines = content.split('\n')

    # Find ## Tasks heading
    tasks_heading_idx = None
    for i, line in enumerate(lines):
        if re.match(r'^##\s+Tasks\s*$', line):
            tasks_heading_idx = i
            break

    if tasks_heading_idx is None:
        print(f"  WARNING: No '## Tasks' heading found in {impl_path.name}, skipping")
        return {}

    # Pre-tasks content -> context.md (everything before ## Tasks)
    pre_tasks = '\n'.join(lines[:tasks_heading_idx]).rstrip()

    # Parse task sections (### Task N: ...)
    task_sections = []
    current_task_start = None
    post_tasks_start = None

    for i in range(tasks_heading_idx + 1, len(lines)):
        line = lines[i]

        if re.match(r'^###\s+Task\s+\S+:', line):
            if current_task_start is not None:
                task_sections.append((current_task_start, i))
            current_task_start = i
        elif re.match(r'^##\s+', line) and current_task_start is not None:
            # New h2 heading after tasks = post-task content
            task_sections.append((current_task_start, i))
            current_task_start = None
            post_tasks_start = i
            break

    # Handle last task if no post-task h2 found
    if current_task_start is not None:
        task_sections.append((current_task_start, len(lines)))

    # Post-tasks content (phase validation, confidence score, etc.)
    post_tasks = ''
    if post_tasks_start is not None:
        post_tasks = '\n'.join(lines[post_tasks_start:]).rstrip()

    # Create output directory
    out_dir = impl_path.parent / phase_name
    out_dir.mkdir(exist_ok=True)

    created_files = {}

    # Write context.md
    context_content = pre_tasks
    if post_tasks:
        context_content += '\n\n' + post_tasks
    context_path = out_dir / 'context.md'
    context_path.write_text(context_content.strip() + '\n')
    created_files['context'] = context_path
    print(f"  Created: {context_path.relative_to(impl_path.parent.parent)}")

    # Write per-task files
    for start, end in task_sections:
        section = '\n'.join(lines[start:end]).strip()
        suffix = extract_task_id_suffix(section)
        if suffix is None:
            print(f"  WARNING: Could not extract task ID from section starting at line {start + 1}")
            continue

        task_path = out_dir / f'task{suffix}.md'
        task_path.write_text(section + '\n')
        created_files[f'task{suffix}'] = task_path
        print(f"  Created: {task_path.relative_to(impl_path.parent.parent)}")

    return created_files


def update_state_yaml(state_path: Path, old_files: list, new_dirs: list):
    """Update state.yaml artifacts.impl_plans from file paths to directory paths."""
    if not state_path.exists():
        return

    content = state_path.read_text()

    for old_file, new_dir in zip(old_files, new_dirs):
        # Replace impl/phaseN-impl.md with impl/phaseN/
        content = content.replace(f'- {old_file}', f'- {new_dir}')
        # Also handle with quotes
        content = content.replace(f"- '{old_file}'", f"- '{new_dir}'")
        content = content.replace(f'- "{old_file}"', f'- "{new_dir}"')

    state_path.write_text(content)
    print(f"\nUpdated: {state_path.name}")


def main():
    if len(sys.argv) < 2 or sys.argv[1] in ('-h', '--help'):
        print("Usage: python split-impl.py <plan-dir>")
        print()
        print("Splits monolithic impl/phaseN-impl.md files into per-task directories.")
        print()
        print("Before: impl/phase1-impl.md (1600+ lines)")
        print("After:  impl/phase1/context.md + impl/phase1/task1.md + ...")
        sys.exit(0 if '--help' in sys.argv else 1)

    plan_dir = Path(sys.argv[1])
    impl_dir = plan_dir / 'impl'

    if not impl_dir.exists():
        print(f"Error: {impl_dir} does not exist")
        sys.exit(1)

    # Find monolithic impl files
    impl_files = sorted(impl_dir.glob('phase*-impl.md'))
    if not impl_files:
        print(f"No phaseN-impl.md files found in {impl_dir}")
        sys.exit(0)

    old_artifact_paths = []
    new_artifact_paths = []

    for impl_path in impl_files:
        phase_match = re.match(r'(phase\d+)-impl\.md', impl_path.name)
        if not phase_match:
            continue

        phase_name = phase_match.group(1)
        print(f"\nSplitting: {impl_path.name}")

        created = split_impl_file(impl_path, phase_name)
        if created:
            old_artifact_paths.append(f'impl/{impl_path.name}')
            new_artifact_paths.append(f'impl/{phase_name}/')

            # Delete monolithic file
            impl_path.unlink()
            print(f"  Deleted: {impl_path.name}")

    # Update state.yaml
    state_path = plan_dir / 'state.yaml'
    if old_artifact_paths:
        update_state_yaml(state_path, old_artifact_paths, new_artifact_paths)

    print(f"\nDone. Split {len(old_artifact_paths)} file(s).")


if __name__ == '__main__':
    main()
