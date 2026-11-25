"""Print the next unrated old ernie questions, one compact JSON object per line.

Usage: old_questions.py <items.jsonl> <ratings.jsonl> <repo-key> <n>
"""
import json
import os
import sys

CONTEXT_LIMIT = 300


def load_questions(items_path):
    questions = {}
    with open(items_path) as items_file:
        for line in items_file:
            line = line.strip()
            if not line:
                continue
            entry = json.loads(line)
            if entry.get("t") != "question":
                continue
            question_id = entry.get("id")
            if entry.get("op") == "add":
                questions[question_id] = {
                    "ref": question_id,
                    "ts": entry.get("ts", "")[:10],
                    "question": entry.get("text", ""),
                    "choices": entry.get("choices", []),
                    "recommended": entry.get("recommended", ""),
                    "context": entry.get("context", "")[:CONTEXT_LIMIT],
                    "answer": None,
                    "status": "open",
                }
                continue
            if question_id not in questions:
                continue
            if entry.get("op") == "answer":
                questions[question_id]["answer"] = entry.get("text", "")
                questions[question_id]["status"] = "answered"
            elif entry.get("op") == "set" and entry.get("status"):
                questions[question_id]["status"] = entry["status"]
    return questions


def load_rated_refs(ratings_path, repo_key):
    if not os.path.exists(ratings_path):
        return set()
    rated_refs = set()
    with open(ratings_path) as ratings_file:
        for line in ratings_file:
            line = line.strip()
            if not line:
                continue
            rating = json.loads(line)
            if rating.get("repo") == repo_key and rating.get("source") == "ernie":
                rated_refs.add(rating.get("ref"))
    return rated_refs


def main():
    if len(sys.argv) != 5:
        sys.exit(__doc__.strip())
    items_path, ratings_path, repo_key, batch_size = sys.argv[1:]
    questions = load_questions(items_path)
    rated_refs = load_rated_refs(ratings_path, repo_key)
    answered = [
        question
        for question in questions.values()
        if question["status"] == "answered" and question["ref"] not in rated_refs
    ]
    for question in answered[: int(batch_size)]:
        print(json.dumps(question, ensure_ascii=False))
    print(f"# remaining after this batch: {max(len(answered) - int(batch_size), 0)}", file=sys.stderr)


if __name__ == "__main__":
    main()
