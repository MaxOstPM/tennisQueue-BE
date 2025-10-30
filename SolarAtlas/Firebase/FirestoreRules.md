# Firestore Security Rules

Solar Atlas stores public solar news items in a single `news` collection. The collection is populated by trusted tooling only; the client app must never attempt to write to it. These rules keep the dataset public while blocking any mutation attempts and prevent the project from becoming a dumping ground for personally identifiable information (PII).

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Public read-only access to the news feed. The payload must never contain PII.
    match /news/{document=**} {
      allow read: if true;
      allow write: if false;
    }

    // Deny all other collections by default.
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## Operational Notes

- The ingestion pipeline must sanitize payloads before they are published to Firestore and strip fields that could contain PII.
- Keep the collection schema limited to publicly shareable metadata (title, summary, source URL, published timestamp).
- Run the Firebase emulator suite as part of CI when rules change to ensure the policy remains read-only.
