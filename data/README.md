# Data Layout

Business code should read canonical database tables or files under `data/canonical`.
Raw crawler/OCR/PDF outputs stay out of application runtime paths.

- `raw/`: original crawler output, PDFs, OCR dumps, downloaded exam files.
- `staging/`: cleaned intermediate data, still allowed to be incomplete or noisy.
- `canonical/`: reviewed import-ready JSON/CSV that matches database schema.
- `exports/`: backups, evaluation sets, and manual review exports.

The intended flow is `raw -> staging -> canonical -> database -> serving APIs`.
