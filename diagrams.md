# Komo App - NoSQL Database Schema

## Entity Relationship Diagram

```mermaid
erDiagram
    USERS {
        string id PK
        string name
        string email
        string photoUrl
        string role
        datetime createdAt
        datetime updatedAt
    }
    
    PROJECTS {
        string id PK
        string name
        string description
        string color
        int taskCount
        int completedTasks
        array memberIds
        array memberAvatars
        datetime dueDate
        datetime createdAt
        datetime updatedAt
    }
    
    TASKS {
        string id PK
        string projectId FK
        string columnId
        string title
        string description
        array tags
        int totalSubtasks
        int completedSubtasks
        int commentCount
        string assigneeId FK
        string assigneeName
        string assigneePhotoUrl
        string leftBorderColor
        datetime dueDate
        datetime createdAt
        datetime updatedAt
    }
    
    SUBTASKS {
        string id PK
        string taskId FK
        string title
        boolean isCompleted
        int order
        datetime createdAt
        datetime updatedAt
    }
    
    COMMENTS {
        string id PK
        string taskId FK
        string authorId FK
        string authorName
        string authorPhotoUrl
        string text
        datetime createdAt
    }
    
    KANBAN_COLUMNS {
        string id PK
        string projectId FK
        string title
        int taskCount
        int order
    }
    
    NOTIFICATIONS {
        string id PK
        string userId FK
        string title
        string message
        string type
        boolean isRead
        string relatedTaskId
        string relatedProjectId
        datetime createdAt
    }
    
    PENDING_INVITES {
        string id PK
        string projectId FK
        string email
        string invitedById FK
        datetime invitedAt
        string status
    }
    
    USERS ||--o{ PROJECTS : "creates/owns"
    PROJECTS ||--o{ TASKS : "contains"
    PROJECTS ||--o{ KANBAN_COLUMNS : "has"
    PROJECTS ||--o{ PENDING_INVITES : "has"
    TASKS ||--o{ SUBTASKS : "contains"
    TASKS ||--o{ COMMENTS : "has"
    USERS ||--o{ TASKS : "assigned_to"
    USERS ||--o{ COMMENTS : "writes"
    USERS ||--o{ NOTIFICATIONS : "receives"
    USERS ||--o{ PENDING_INVITES : "invites"
```

## Collections Overview

| Collection | Description |
|------------|-------------|
| **USERS** | App users with profile info and role |
| **PROJECTS** | Projects with embedded member references and progress tracking |
| **TASKS** | Tasks within projects, linked to kanban columns and assignees |
| **SUBTASKS** | Checklist items nested under tasks |
| **COMMENTS** | Discussion threads on tasks |
| **KANBAN_COLUMNS** | Column definitions (À faire, En cours, Terminé) |
| **NOTIFICATIONS** | User notifications (task assigned, comments, deadlines, etc.) |
| **PENDING_INVITES** | Project invitation tracking |

## NoSQL Design Notes

For a document database like **Firestore** or **MongoDB**, consider these embedding strategies:

- **Subtasks** → Can be embedded directly in the Task document as an array
- **Comments** → Could be embedded in Tasks if count is low, or kept as a subcollection for scalability
- **Kanban Columns** → Can be embedded in Project as they're typically 3-5 fixed columns
- **Tags** → Already stored as arrays within Tasks (denormalized)
- **Member info** → Denormalized `assigneeName` and `assigneePhotoUrl` in Tasks for read performance

## Notification Types

| Type | Description |
|------|-------------|
| `taskAssigned` | When a task is assigned to a user |
| `taskCompleted` | When a task is marked as done |
| `comment` | New comment on a task |
| `mention` | User mentioned in a comment |
| `deadline` | Task deadline approaching |
| `projectInvite` | Invited to join a project |
