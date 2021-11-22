# Local-links-manager

Admin interface for managing Local Authorities' links including all their services and interactions.

For example, [this service](https://www.gov.uk/garden-waste-disposal) uses Local Links Manager to determine the URL of the garden waste disposal page on the Local Authority website which corresponds to the postcode a user has entered.

This app maps RESTful URLs onto a persistence layer. It doesn't face public users.

## Nomenclature

- **SNAC** - Standard Names And Code - The old identifier code for locations. This is being phased out in favour of GSS codes.
- **GSS**  - Government Statistical Service - The new identifier code for locations.
- **LGSL** - Local Government Services List
- **LGIL** - Local Government Interactions List

Both LGSL and LGIL codes are used for the lookups for each Local Authority and its service interactions.

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions][conventions].

You can use the [GOV.UK Docker environment][govuk-docker] to run the application and its tests with all the necessary dependencies. Follow the [usage instructions][docker-usage] to get started.

Running the bare application without any test data isn't very useful, you can replicate the app's Postgres database [using GOV.UK Docker][replicate-db].

**Use GOV.UK Docker to run any commands that follow.**

[conventions]: https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html
[govuk-docker]: https://github.com/alphagov/govuk-docker
[docker-usage]: https://github.com/alphagov/govuk-docker#usage
[replicate-db]: https://github.com/alphagov/govuk-docker/blob/master/docs/how-tos.md#how-to-replicate-data-locally

### Running the test suite

```
$ bundle exec rake
```

## Further documentation

- [Enable or create a service](/docs/enable-or-create-service.md)
- [Deleting a local transaction link](/docs/deleting-a-link.md)
- [Importing Local Authorities data](/docs/importing-local-authorities-data.md)
- [Exporting Local Authority links to services](/docs/exporting-local-authority-links.md)
- [Checking links](/docs/checking-links.md)
- [Example API output](/docs/example-api-output.md)

## Licence

[MIT License](LICENCE)
