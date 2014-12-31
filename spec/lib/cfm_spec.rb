require 'spec_helper'

RSpec.describe CFM::Markdown do
  it 'correctly renders #### as H4' do
    text = '#### my test is awesome'
    expect(CFM::Markdown.render(text)).not_to include('####')
  end

  it 'doesnt render #### as H4 if there is a space in front' do
    text = ' #### this is not correct markdown'
    expect(CFM::Markdown.render(text)).to include('####')
  end
end
