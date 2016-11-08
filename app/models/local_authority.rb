class LocalAuthority < ApplicationRecord
  after_update :reset_time_and_status, if: :homepage_url_changed?

  validates :gss, :snac, :slug, uniqueness: true
  validates :gss, :name, :snac, :tier, :slug, presence: true
  validates :homepage_url, non_blank_url: true, allow_blank: true
  validates :tier, inclusion: { in: %w(county district unitary),
    message: "%{value} is not an allowed tier" }

  has_many :links
  belongs_to :parent_local_authority, foreign_key: :parent_local_authority_id, class_name: "LocalAuthority"

  def self.provides_service(service)
    tier_field = LocalAuthority.arel_table[:tier]
    case service.tier
    when 'all'
      self
    when 'county/unitary'
      where(tier_field.not_eq('district'))
    when 'district/unitary'
      where(tier_field.not_eq('county'))
    end
  end

  def provided_services
    Service.for_tier(self.tier).enabled
  end

  def self.with_broken_links_count(*link_where_clauses)
    # this seems a tad complex, but then we are using arel so...

    link_where_clauses = ['1=1'] if link_where_clauses.empty?

    # 1. construct inner query to count links grouped by service_id
    #    we do this in activerecord and then grab the arel version of it so we
    #    can...
    counts = Link.
      enabled_links.
      with_correct_service_and_tier.
      where(*link_where_clauses).
      broken.
      group(Link.arel_table[:local_authority_id]).
      select(Link.arel_table[:local_authority_id], Link.arel_table[:id].count.as('broken_links_count')).
      arel
    counts_table = Arel::Table.new(:counts)

    # 2. ...join that arel query to the services table on the service_id
    counts_join = LocalAuthority.
      arel_table.
      join(counts.as('counts'), Arel::Nodes::OuterJoin).
      on(LocalAuthority.arel_table['id'].eq(counts_table['local_authority_id'])).
      join_sources

    # 3.  finally, drop back to activerecord to do the query and make sure
    #     to select the count in the query
    broken_links_count_field =
      Arel::Nodes::NamedFunction.new(
        'COALESCE',
        [counts_table['broken_links_count'], 0],
        'broken_links_count'
      )
    self.
      select([LocalAuthority.arel_table[Arel.star], broken_links_count_field]).
      joins(counts_join)
  end

private

  def reset_time_and_status
    self.update_columns(status: nil, link_last_checked: nil)
  end
end
