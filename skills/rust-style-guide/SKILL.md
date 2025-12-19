---
name: rust-style-guide
description: Guide for writing Rust backend services with domain-driven layered architecture. Use when writing new code, adding features, refactoring, or setting up project structure with sea-orm.
---

# Rust Domain-Driven Layered Architecture

## Module Organization

Use folder name pattern for modules (not `mod.rs` pattern):

```
project/
├── sql/                          # All SQL for each table (creation, migrations, etc.)
│   ├── session.sql
│   └── user.sql
└── src/
    ├── main.rs
    ├── lib.rs                    # Re-exports all modules
    ├── orm/                      # Sea-ORM generated models (sibling to domain modules)
    │   ├── session.rs
    │   └── user.rs
    ├── orm.rs                    # pub mod declarations for orm/*
    ├── app/                      # App-wide utilities
    │   ├── config.rs
    │   ├── error.rs
    │   └── middleware.rs
    ├── app.rs                    # pub mod declarations for app/*
    ├── session/                  # Business domain
    │   ├── controller.rs
    │   ├── repository.rs
    │   ├── usecase.rs
    │   └── entity.rs
    └── session.rs                # pub mod declarations for session/*
```

Each `{domain}.rs` file declares its submodules:

```rust
// src/session.rs
pub mod controller;
pub mod entity;
pub mod repository;
pub mod usecase;
```

## Layer Responsibilities

| Layer | File | Purpose |
|-------|------|---------|
| Entity | `entity.rs` | Domain structs, enums. No external deps except serde. |
| Repository | `repository.rs` | Query methods using `orm::` types. Converts entity ↔ ORM. |
| Usecase | `usecase.rs` | Business logic. Orchestrates entities and repositories. |
| Controller | `controller.rs` | HTTP/gRPC handlers. Owns Request/Response types (foreign). |

The `orm/` module is **not a layer** - it's a top-level module containing Sea-ORM generated Model/ActiveModel types (CLI-generated, do not edit). Repository layer imports from `orm::` to perform database operations.

## Data Flow

```
Request → Controller → Usecase → Repository → Database
                                      ↓
Response ← Controller ← Usecase ← Repository
```

## Code Example

Each layer has its own types. Types should not leak across boundaries:

| Layer | Types | Location |
|-------|-------|----------|
| Controller | Request/Response DTOs (foreign types, like gRPC proto) | `{domain}/controller.rs` |
| Entity | Domain structs, enums | `{domain}/entity.rs` |
| Repository | Uses Sea-ORM Model, ActiveModel | imports from `orm::{table}` |

```rust
// app/state.rs - fields like DatabaseConnection already have inner Arc, so just derive Clone
#[derive(Clone)]
pub struct AppState {
    pub db: DatabaseConnection,
    pub config: Config,
}

// controller.rs - Request/Response are "foreign" types (like gRPC proto)
// Controller extracts State, transforms request → entity, entity → response
#[derive(Deserialize)]
pub struct CreateSessionRequest { pub name: String, pub duration: i32 }

#[derive(Serialize)]
pub struct SessionResponse { pub id: i32, pub name: String }

pub async fn create_session(
    State(state): State<AppState>,
    Json(req): Json<CreateSessionRequest>,
) -> Result<Json<SessionResponse>, AppError> {
    let input = entity::CreateSession { name: req.name, duration: req.duration };
    let session = usecase::create_session(state, input).await?;
    Ok(Json(SessionResponse { id: session.id, name: session.name }))
}

// entity.rs - pure domain types, no framework deps
pub struct CreateSession { pub name: String, pub duration: i32 }
pub struct Session { pub id: i32, pub name: String, pub duration: i32 }

// usecase.rs - takes AppState (cheap clone, fields have inner Arc)
pub async fn create_session(state: AppState, input: CreateSession) -> Result<Session, AppError> {
    let model = repository::create(&state.db, input).await?;
    Ok(model.into())  // orm::Model → entity::Session
}

// repository.rs - takes &impl ConnectionTrait, uses orm:: types internally
pub async fn create(db: &impl ConnectionTrait, input: CreateSession) -> Result<orm::session::Model, DbErr> {
    let active = orm::session::ActiveModel {
        name: Set(input.name),
        duration: Set(input.duration),
        ..Default::default()
    };
    active.insert(db).await
}

pub async fn find_by_id(db: &impl ConnectionTrait, id: i32) -> Result<orm::session::Model, DbErr> {
    orm::session::Entity::find_by_id(id).one(db).await?.ok_or(DbErr::RecordNotFound("...".into()))
}
```

Pattern: `Controller(State) → Usecase(AppState) → Repository(&impl ConnectionTrait)`

**Simple usecase exception:** For trivial CRUD, controller may pass request directly to usecase, and usecase may return repository Model directly.

## Sea-ORM Migration Setup

> **Ask user confirmation before adding migration setup.**

```bash
cargo install sea-orm-cli
sea-orm-cli migrate init
```

Creates `migration/` subcrate. Add to workspace:

```toml
[workspace]
members = [".", "migration"]

[dependencies.migration]
path = "./migration"
```

Run migrations: `sea-orm-cli migrate up`

## App Module

The `app` module contains shared utilities:
- `config.rs` - Configuration loading
- `error.rs` - Unified error types with `thiserror` + `IntoResponse`
- `middleware.rs` - HTTP middleware (auth, logging, cors)
- `db.rs` - Database connection setup
- `state.rs` - Shared application state

## Refactoring Checklist

1. Create directory structure with folder-name module pattern
2. Set up `app` module with config, error, middleware
3. Initialize sea-orm migration subcrate
4. For each domain:
   - Create `{domain}.rs` with module declarations
   - Extract entities to `{domain}/entity.rs`
   - Create sea-orm models in `{domain}/repository.rs`
   - Move business logic to `{domain}/usecase.rs`
   - Create API handlers in `{domain}/controller.rs`
5. Create migrations for database schema
6. Wire together in `main.rs`
7. Re-export domain modules in `lib.rs`
