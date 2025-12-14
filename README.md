# Dragon Ledger

Dragon Ledger is a market tracking and analytics hub for MMO item prices, starting with RuneScape 3.  
This is a portfolio project focused on production-shaped backend engineering: data modeling, ingestion reliability, testing, CI, and deployment.

## Current status

- Threshold 0 complete
- App boots locally
- Landing page exists
- Items placeholder page exists

## Requirements

- Ruby (rbenv recommended)
- Bundler
- PostgreSQL

## Local setup

Run this once:

```bash
bin/setup
```

## Run the app

```bash
./bin/dev
```

Then open:

- http://localhost:3000
- http://localhost:3000/items

## Useful commands

Database:

```bash
bin/rails db:prepare
bin/rails db:migrate
```

Rails console:

```bash
bin/rails console
```

Tests (default Rails test runner for now):

```bash
bin/rails test
```

## Project notes

- No in game trading functionality
- Price data will come from official endpoints first
- Early milestones focus on ingesting and storing historical snapshots, then charting and mercher calculators

## Roadmap

### Threshold 1

- Core data model (Item, PriceSnapshot)
- Ingestion job with idempotency and tests

### Threshold 2

- Item search and item detail page
- Charts backed by stored snapshots
- Basic market metrics
