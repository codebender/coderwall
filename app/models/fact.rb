# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `facts`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`created_at`**   | `datetime`         |
# **`id`**           | `integer`          | `not null, primary key`
# **`identity`**     | `string(255)`      |
# **`metadata`**     | `text`             |
# **`name`**         | `string(255)`      |
# **`owner`**        | `string(255)`      |
# **`relevant_on`**  | `datetime`         |
# **`tags`**         | `text`             |
# **`updated_at`**   | `datetime`         |
# **`url`**          | `string(255)`      |
#
# ### Indexes
#
# * `index_facts_on_identity`:
#     * **`identity`**
# * `index_facts_on_owner`:
#     * **`owner`**
#

class Fact < ActiveRecord::Base
  serialize :tags, Array
  serialize :metadata, Hash

  def self.append!(identity, owner, name, date, url, tags, metadata = nil)
    fact             = Fact.where(identity: identity).first || Fact.new(identity: identity)
    fact.tags        = (fact.tags.nil? ? tags : (fact.tags + tags).uniq)
    fact.owner       = owner.downcase
    fact.name        = name
    fact.url         = url
    fact.relevant_on = date
    fact.metadata    = metadata
    fact.save!
    fact
  end

  def self.add_language_to_repo!(repo_url, language)
    fact = Fact.where(url: repo_url).first
    fact.tags << language
    fact.metadata[:languages] << language
    fact.save!
  end

  def self.create_or_update!(fact)
    existing_fact = Fact.where(identity: fact.identity).first

    if existing_fact
      existing_fact.merge!(fact)
    else
      fact.save!
    end
  end

  def merge!(another_fact)
    self.tags        = (another_fact.tags.nil? ? another_fact.tags : (self.tags + another_fact.tags).uniq)
    self.owner       = another_fact.owner.downcase
    self.name        = another_fact.name
    self.url         = another_fact.url
    self.relevant_on = another_fact.relevant_on
    self.metadata.merge!(another_fact.metadata)
    self.save!
    self
  end

  def context=(val)
    @context = val
  end

  def context
    @context
  end

  def tagged?(*required_tags)
    required_tags.each do |tag|
      return false if !tags.include?(tag)
    end
    return true
  end

  def user
    service, username = self.owner.split(":")
    User.with_username(username, service)
  end
end