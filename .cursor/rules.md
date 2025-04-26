# Warped Speed: Project Rules

## Core Development Rules

1. **Database-First Development**
   - All content must originate from or be stored in the database
   - No hardcoded content, text, or UI elements
   - Schema changes must be documented and versioned

2. **Modularity Requirements**
   - Max 500 lines of code per module
   - Single responsibility principle for all components
   - Clear interfaces between modules

3. **Documentation Standards**
   - All new features must update relevant documentation
   - Code comments for complex logic only
   - Maintain clean separation between implementation and documentation

4. **Testing Protocol**
   - Unit tests for all business logic
   - Integration tests for database interactions
   - UI tests for critical user flows

5. **Performance Guidelines**
   - Optimize database queries
   - Cache expensive operations
   - Monitor and log performance metrics

## Prompt Engineering Rules

1. **Structured Prompts**
   - All prompts must be stored in the database
   - Context preservation through state prepending
   - Include fallback mechanisms

2. **Agent Separation**
   - Maintain distinct roles for each agent
   - Implement validation between agent outputs
   - Use consistent temperature settings per agent type

3. **Content Consistency**
   - Maintain coherent tone and style
   - Track and preserve important narrative elements
   - Validate outputs against existing lore

## Image Generation Rules

1. **Image Classification**
   - Strictly categorize all images
   - Store metadata with each image
   - Implement fallback for failed generation

2. **Performance Optimization**
   - Cache all generated images
   - Implement progressive loading
   - Preload likely-needed images

3. **Quality Control**
   - Validate image quality before display
   - Maintain consistent style
   - Provide fallbacks for failed generations

## Database Rules

1. **Schema Design**
   - Use normalization for structured data
   - Implement proper indexing
   - Document all relationships

2. **Data Integrity**
   - Enforce referential integrity
   - Implement validation at the database level
   - Regular backups and disaster recovery plan

3. **Query Optimization**
   - Monitor query performance
   - Use prepared statements
   - Implement caching where appropriate

## UI Rules

1. **Mobile-First Design**
   - All UI must work on mobile devices
   - Responsive layout for all screen sizes
   - Touch-friendly interface elements

2. **Accessibility**
   - Maintain proper contrast ratios
   - Implement keyboard navigation
   - Include screen reader compatibility

3. **Performance**
   - Minimize DOM operations
   - Optimize CSS selectors
   - Implement lazy loading for images

## Version Control

1. **Commit Practices**
   - Atomic commits for individual changes
   - Descriptive commit messages
   - Reference relevant documentation

2. **Branching Strategy**
   - Feature branches for new development
   - Hotfix branches for critical bugs
   - Release branches for version management

3. **Code Review**
   - All changes must be reviewed
   - Automated testing before merge
   - Documentation updates verified

## Phase Transitions

1. **Phase 1 Completion Criteria**
   - All core gameplay systems functional
   - Database structure fully operational
   - Unit test coverage > 80%

2. **Phase 2 Authorization**
   - Phase 1 must be fully tested and stable
   - Explicit approval required to begin Phase 2
   - No incomplete Phase 1 features during Phase 2

3. **Phase 3 Planning**
   - Begin during Phase 2 implementation
   - Document all expansion features
   - Prioritize based on user feedback from Phase 2 