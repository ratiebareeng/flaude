/// Domain layer barrel file
///
/// This file exports all domain layer components including entities, 
/// repository interfaces, and use cases for easy importing throughout the app.
/// The domain layer represents the core business logic and is framework-independent.
library;

// Core business entities
export 'entities/entities.dart';

// Repository contracts/interfaces
export 'repositories/repositories.dart';

// Use cases will be exported here when implemented
// export 'usecases/usecases.dart';