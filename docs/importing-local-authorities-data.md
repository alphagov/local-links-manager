# Creating a new Local Authority

You need to run this rake task:

`bundle exec rake local_authority:create[<gss>, <name>, <snac>, <slug>, <tier_id>, <country_name>]`

## Importing services and interactions

To import services and interactions:

`bundle exec rake import:service_interactions:import_all`
