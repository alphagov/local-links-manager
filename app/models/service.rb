class Service < ActiveRecord::Base
  validates :lgsl_code, :label, :slug, presence: true, uniqueness: true
  validates :tier, inclusion: { in: %w{all county/unitary district/unitary}, allow_nil: true }

  has_many :service_interactions
  has_many :interactions, through: :service_interactions

  scope :for_tier, ->(tier) {
    case tier
    when 'county', 'district'
      where("services.tier = 'all' OR services.tier = '#{tier}/unitary'")
    when 'unitary', 'all'
      where.not(services: { tier: nil })
    else
      raise ArgumentError, "invalid tier '#{tier}'"
    end
  }

  scope :enabled, -> { where(arel_table[:enabled].eq(true)) }

  def provided_by?(authority)
    case tier
    when nil
      false
    when 'all'
      true
    else
      tiers.include? authority.tier
    end
  end

  def self.with_broken_links_count(*link_where_clauses)
    # this seems a tad complex, but then we are using arel so...

    link_where_clauses = ['1=1'] if link_where_clauses.empty?

    # 1. construct inner query to count links grouped by service_id
    #    we do this in activerecord and then grab the arel version of it so we
    #    can...
    counts = Link.
      broken.
      enabled_links.
      where(*link_where_clauses).
      joins(:service_interaction).
      group(ServiceInteraction.arel_table[:service_id]).
      select(ServiceInteraction.arel_table[:service_id], Link.arel_table[:id].count.as('broken_links_count')).
      arel
    counts_table = Arel::Table.new(:counts)

    # 2. ...join that arel query to the services table on the service_id
    counts_join = Service.
      arel_table.
      join(counts.as('counts'), Arel::Nodes::OuterJoin).
      on(Service.arel_table['id'].eq(counts_table['service_id'])).
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
      enabled.
      select([Service.arel_table[Arel.star], broken_links_count_field]).
      joins(counts_join)
  end


private

  def tiers
    tier.split('/')
  end
end
