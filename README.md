db-validate
===========

A rake task that runs your ActiveRecord validations on existing database records. Useful for checking if production data conforms to changed validations.

I often ran into situations were I would have to change validations when production data already exists. I'd write migrations to make the data conform to the changed validation requirements, but didn't have an easy way to check whether I was succesful. This rake task loads all ActiveRecord objects from your db, calling `valid?` on each of them.

Usage
=====

```rake db:validate```

Dependencies
============

db-validate needs ruby-progressbar to show a progressbar during validation.
Add `gem 'ruby-progressbar'` to your gemfile.

ToDo
====

- [ ] Make db-validate a proper Gem
- [ ] Nicer interactive prompts, like Rails
- [ ] Options for automatically destroying invalid records, writing log files, etc.
- [ ] Cluster invalid records by their validation errors

Collaborators
=============

- [Christian Ikas](https://github.com/chris1900)