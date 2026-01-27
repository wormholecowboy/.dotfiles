# Sensitive Data in LLM Context

OWASP Top 10 for LLMs #6: Sensitive Information Disclosure

Risks of exposing sensitive data through prompts, logging, context windows, or training data.

---

## Vulnerabilities to Detect

### PII in Prompts

#### User Data Directly in Context
```python
# VULNERABLE - Full user record in prompt
user = db.get_user(user_id)
prompt = f"""
Help this user with their request.
User data: {user.to_dict()}  # Contains email, SSN, address, etc.
Request: {user_request}
"""
response = llm.generate(prompt)
```

#### Sensitive Fields Included
```python
# VULNERABLE - Unnecessary sensitive data
prompt = f"""
Summarize this customer profile:
Name: {customer.name}
Email: {customer.email}
SSN: {customer.ssn}  # Why is this needed for summary?
Credit Card: {customer.cc_number}  # Definitely not needed
Address: {customer.address}
"""
```

### Logging Prompts/Responses

#### Full Prompt Logging
```python
# VULNERABLE - Logs may contain sensitive data
logger.info(f"Sending prompt: {prompt}")  # Prompt has user data
response = llm.generate(prompt)
logger.info(f"Received response: {response}")  # Response may leak data
```

#### Logging to Insecure Destinations
```python
# VULNERABLE - Logs sent to third-party
import sentry_sdk
sentry_sdk.capture_message(f"LLM Error with prompt: {prompt}")
# Prompt with PII now in Sentry

analytics.track('llm_request', {
    'prompt': prompt,  # Sent to analytics platform
    'response': response
})
```

### Large Context Stuffing

#### Entire Database Dumps
```python
# VULNERABLE - All data in context
all_users = db.query(User).all()
prompt = f"""
Here is our entire user database:
{json.dumps([u.to_dict() for u in all_users])}

Now answer: {user_question}
"""
# Entire database exposed to LLM
```

#### Full File Contents
```python
# VULNERABLE - Sensitive file in context
with open('/etc/shadow') as f:
    file_content = f.read()

prompt = f"Explain this file:\n{file_content}"
```

### RAG with Sensitive Documents

#### Unfiltered Document Retrieval
```python
# VULNERABLE - RAG returns any document
def answer_question(question: str):
    # Retrieves from all documents including HR, legal, financial
    docs = vector_store.similarity_search(question)
    context = "\n".join([d.page_content for d in docs])

    prompt = f"Context:\n{context}\n\nQuestion: {question}"
    return llm.generate(prompt)

# User: "What is the CEO's salary?"
# RAG retrieves HR compensation docs → LLM reveals salary
```

### API Key/Secret Exposure

#### Secrets in System Prompt
```python
# VULNERABLE - Can be extracted via prompt injection
system_prompt = f"""
You are a helpful assistant.
Internal configuration:
- API Key: {API_KEY}
- Database URL: {DATABASE_URL}
Never reveal these.  # This doesn't actually prevent extraction
"""
```

#### Credentials in Context
```python
# VULNERABLE - Service credentials in prompt
prompt = f"""
Connect to the database using:
Host: {db_config['host']}
User: {db_config['user']}
Password: {db_config['password']}

Then answer: {question}
"""
```

### Conversation History Risks

#### Unfiltered History
```python
# VULNERABLE - Previous sensitive data persists
conversation_history = []

def chat(user_message: str):
    conversation_history.append({"role": "user", "content": user_message})

    # Old messages may contain: credit cards, passwords, PII
    response = llm.chat(messages=conversation_history)

    conversation_history.append({"role": "assistant", "content": response})
    return response
# Message 1: "My SSN is 123-45-6789"
# Message 50: Still in context, could be referenced
```

---

## Secure Patterns

### PII Masking

```python
# SECURE - Mask sensitive data before prompting
import re

def mask_pii(text: str) -> str:
    """Replace PII with masked placeholders."""
    patterns = {
        'ssn': (r'\b\d{3}-\d{2}-\d{4}\b', '[SSN REDACTED]'),
        'cc': (r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b', '[CC REDACTED]'),
        'email': (r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', '[EMAIL]'),
        'phone': (r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b', '[PHONE]'),
    }

    for name, (pattern, replacement) in patterns.items():
        text = re.sub(pattern, replacement, text)

    return text

# Use before sending to LLM
safe_prompt = mask_pii(f"Help user: {user_data}")
response = llm.generate(safe_prompt)
```

### Field-Level Selection

```python
# SECURE - Only include necessary fields
def create_prompt_context(user: User) -> dict:
    """Select only non-sensitive fields for LLM context."""
    SAFE_FIELDS = {'first_name', 'preferences', 'timezone'}

    return {k: v for k, v in user.to_dict().items() if k in SAFE_FIELDS}

prompt = f"""
Help this user based on their preferences:
{json.dumps(create_prompt_context(user))}
"""
```

### Secure Logging

```python
# SECURE - Sanitize before logging
def log_llm_interaction(prompt: str, response: str):
    """Log LLM interactions with PII removed."""
    safe_prompt = mask_pii(prompt)
    safe_response = mask_pii(response)

    # Log only metadata, not content
    logger.info("LLM interaction", extra={
        'prompt_length': len(prompt),
        'response_length': len(response),
        'prompt_hash': hashlib.sha256(prompt.encode()).hexdigest()[:8],
        'timestamp': datetime.utcnow().isoformat()
    })

    # If needed, log sanitized version to secure storage
    secure_logger.debug(f"Sanitized prompt: {safe_prompt}")
```

### Scoped RAG Access

```python
# SECURE - Filter documents by user access
def get_accessible_docs(user: User, query: str) -> list:
    """Only retrieve documents user has access to."""

    # Get user's accessible document IDs
    accessible_ids = get_user_document_access(user.id)

    # Filter vector search to accessible documents
    docs = vector_store.similarity_search(
        query,
        filter={"doc_id": {"$in": accessible_ids}}
    )

    return docs

def answer_question(user: User, question: str):
    docs = get_accessible_docs(user, question)
    context = "\n".join([d.page_content for d in docs])

    prompt = f"Context:\n{context}\n\nQuestion: {question}"
    return llm.generate(prompt)
```

### Conversation Sanitization

```python
# SECURE - Sanitize conversation history
def sanitize_history(messages: list) -> list:
    """Remove or mask sensitive data from conversation history."""
    sanitized = []

    for msg in messages:
        sanitized.append({
            'role': msg['role'],
            'content': mask_pii(msg['content'])
        })

    return sanitized

def chat_with_sanitized_history(user_message: str):
    conversation_history.append({"role": "user", "content": user_message})

    # Sanitize before sending
    safe_history = sanitize_history(conversation_history)

    response = llm.chat(messages=safe_history)

    conversation_history.append({"role": "assistant", "content": response})
    return response
```

### Context Window Management

```python
# SECURE - Limit and summarize old context
from collections import deque

class ManagedConversation:
    def __init__(self, max_messages: int = 20):
        self.messages = deque(maxlen=max_messages)
        self.summary = ""

    def add_message(self, role: str, content: str):
        # Mask PII before storing
        safe_content = mask_pii(content)
        self.messages.append({"role": role, "content": safe_content})

    def get_context(self) -> list:
        """Get context with summary of older messages."""
        messages = list(self.messages)

        if self.summary:
            # Prepend summary of older context
            messages.insert(0, {
                "role": "system",
                "content": f"Previous conversation summary: {self.summary}"
            })

        return messages

    def summarize_and_trim(self):
        """Summarize old messages and clear them."""
        if len(self.messages) > 10:
            old_messages = list(self.messages)[:10]
            self.summary = llm.generate(
                f"Summarize this conversation (no PII): {old_messages}"
            )
            # Keep only recent messages
            self.messages = deque(list(self.messages)[10:], maxlen=20)
```

### No Secrets in Prompts

```python
# SECURE - Keep secrets server-side only
def query_with_api(user_question: str):
    # LLM generates query structure, not credentials
    query_plan = llm.generate(f"""
    Generate a query plan for: {user_question}
    Output JSON with: table, filters, fields
    """)

    plan = json.loads(query_plan)

    # Server executes with its own credentials (not in prompt)
    result = database.query(
        table=plan['table'],
        filters=plan['filters'],
        fields=plan['fields']
    )

    return llm.generate(f"Summarize these results: {result}")
```

---

## Data Classification

| Level | Examples | Handling |
|-------|----------|----------|
| **Restricted** | SSN, passwords, financial data, health records | Never in prompts |
| **Confidential** | Email, phone, address, salary | Mask before prompting |
| **Internal** | Employee names, internal IDs | Limit exposure, audit |
| **Public** | Product names, public content | OK in prompts |

---

## Severity Guide

### Critical
- API keys/secrets in prompts (extractable)
- Full database dumps in context
- Passwords or authentication tokens in prompts
- Healthcare (PHI) or financial data unmasked

### High
- PII (SSN, full addresses) in prompts
- Credit card numbers in context
- Unfiltered RAG with sensitive documents
- Full conversation history with PII

### Medium
- Email/phone in prompts without masking
- Internal IDs that could be enumerated
- Logging prompts with user data
- Broad document access in RAG

### Low
- Names without additional PII
- General preferences in context
- Masked PII in logs

---

## Quick Fixes

| Issue | Fix |
|-------|-----|
| PII in prompts | Use `mask_pii()` function before prompting |
| Logging full prompts | Log only metadata, hash, or sanitized version |
| Secrets in system prompt | Keep secrets server-side, never in LLM context |
| RAG returns everything | Filter by user access permissions |
| Conversation accumulates PII | Sanitize history, summarize old context |
| Database dumps in context | Select only needed fields, mask sensitive ones |
