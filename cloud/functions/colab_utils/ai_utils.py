"""
AI utilities module for working with chat history and OpenAI API.
Provides functions for processing chat history and preparing context for AI models.
"""

from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional

USER_ROLE_NAME = "user"
ASSISTANT_ROLE_NAME = "assistant"

def filter_chat_history_by_time_and_limit(
    history: List[Dict[str, Any]], 
    max_interactions: int = 10,
    max_time_interval_hours: int = 24
) -> List[Dict[str, str]]:
    """
    Filter chat history by time threshold and interaction limit.
    
    Args:
        history: List of chat history items with 'role', 'content', and 'timestamp' fields
        max_interactions: Maximum number of interactions to include (default: 10)
        max_time_interval_hours: Maximum time interval in hours to consider (default: 24)
    
    Returns:
        List of filtered context items with 'role' and 'content' fields
    """
    now = datetime.now()
    threshold_timestamp = now - timedelta(hours=max_time_interval_hours)
    
    messages_counter = 0
    context = []

    for item in reversed(history):
        try:  # backward compatibility grace
            if datetime.strptime(item["timestamp"], "%Y-%m-%d %H:%M:%S.%f") < threshold_timestamp:
                break
            messages_counter += 1
        except Exception:
            break
        if messages_counter > max_interactions * 2:
            break
        context.insert(0, {
            "role": item["role"],
            "content": item["content"]
        })
    
    return context


def prepare_openai_context(
    history: List[Dict[str, Any]], 
    prompt_relay: Dict[str, str],
    max_interactions: int = 10,
    max_time_interval_hours: int = 24
) -> List[Dict[str, str]]:
    """
    Prepare context for OpenAI API from chat history.
    
    Args:
        history: List of chat history items
        prompt_relay: Current prompt to append to the last user message
        max_interactions: Maximum number of interactions to include
        max_time_interval_hours: Maximum time interval in hours to consider
    
    Returns:
        List of context messages ready for OpenAI API
    """
    context = filter_chat_history_by_time_and_limit(
        history, max_interactions, max_time_interval_hours
    )
    
    # If the last message is from user, append the prompt relay content
    if context and context[-1]["role"] == USER_ROLE_NAME:
        context[-1]["content"] += " " + prompt_relay["content"]
    
    return context


def create_openai_payload(
    context: List[Dict[str, str]],
    model: str = "gpt-4o-mini",
    system_prompt: Optional[str] = None
) -> Dict[str, Any]:
    """
    Create payload for OpenAI API request.
    
    Args:
        context: List of context messages
        model: OpenAI model to use (default: "gpt-4o-mini")
        system_prompt: Optional system prompt to prepend
    
    Returns:
        Dictionary payload ready for OpenAI API
    """
    messages = []
    
    if system_prompt:
        messages.append({
            "role": "system",
            "content": system_prompt
        })
    
    messages.extend(context)
    
    return {
        "model": model,
        "messages": messages
    }


def create_chat_history_entry(
    role: str,
    content: str,
    timestamp: Optional[str] = None
) -> Dict[str, str]:
    """
    Create a standardized chat history entry.
    
    Args:
        role: Role of the message sender ("user", "assistant", etc.)
        content: Content of the message
        timestamp: Optional timestamp, if not provided uses current time
    
    Returns:
        Dictionary with role, content, and timestamp
    """
    if timestamp is None:
        timestamp = datetime.strftime(datetime.now(), "%Y-%m-%d %H:%M:%S.%f")
    
    return {
        "role": role,
        "content": content,
        "timestamp": timestamp
    }