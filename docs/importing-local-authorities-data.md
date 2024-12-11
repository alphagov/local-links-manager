# Importing Local Authorities data

Import all local authorities from `data/local-authorities.csv`:

`bundle exec rake import:local_authorities:import_all`

Then import services and interactions:

`bundle exec rake import:service_interactions:import_all`

## Blank CSVs

Sometimes a local authority will ask for a blank CSV they can fill in which contains all the links supported for a particular level. You can get a blank CSV by running one of these tasks locally:

`bundle exec rake export:blank_csv[county]`

`bundle exec rake export:blank_csv[district]`

`bundle exec rake export:blank_csv[unitary]`
