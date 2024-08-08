# Decision Record: Department Permissions

## Introduction

In July 2024 Places Manager was opened up to departments to allow them to
directly control their own datasets. It had long been suggested that the
same openness should be a feature of Local Links Manager, since departments
often have more information about particular services than GDS. This would form
part of a future possible three-way access system in which GDS Editors could
edit any link, departments could edit links in particular services, and local
authorities could edit links in their authority. This ADR moves towards this
by opening up the second of these three ways.

## Requirements

Each service would need to be owned by zero, one, or more than one
departments. Only editors with Local Links Managers access permission in
Signon should be allowed to view and edit those services, with GDS editors
allowed to access all services for troubleshooting and incident response.

We followed the pattern from Places Manager, which was itself based on the
style of permission in Whitehall and other publishing apps, where Signon
provides the current user's organisational slug and access can be limited
based on that. A "GDS Editor" special permission is also typical of these
apps.

## Resulting changes

- Add an "organisational_slugs" field to each service, to be filled in by
  us for existing services before departments are given access. This will
  be a simple string field, with comma separation for multiple owners.
- Add a "GDS Editor" permission. Anyone with this permission can see and
  edit links for all services. Anyone without this permission can
  only edit links in services whose organisational_slugs field contains
  the same slug as reported for them by Signon.

We will not at the moment add in an organisational drop-down, so any GDS
Editor making changes to the organisation slug will need to know the
correct one, but it is assumed that people with this permission will know
how to find that out.