#!/bin/env ruby
#encoding: utf8

# if not already created, make a CensorRule that hides personal information
regexp = '={67}\s*\n(?:.*?#.*?: ?.*\n){3}.*={67}'
rule = CensorRule.find_by_text(regexp)
if rule.nil?
    Rails.logger.info("Creating new censor rule: /#{regexp}/")
    CensorRule.create!(:text => regexp,
                       :allow_global => true,
                       :replacement => '[redacted]',
                       :regexp => true,
                       :last_edit_editor => 'system',
                       :last_edit_comment => 'Added automatically by ipvtheme')

    CensorRule
end

rules_data = [{:text => 'Vaše evidenční údaje / Your name and address: .*$',
               :replacement => 'Vaše evidenční údaje / Your name and address: [Adresa]',
               :regexp => true,
               :public_body => PublicBody.find_by_url_name('ministerstvo_prmyslu_a_obchodu'),
               :last_edit_editor => 'system',
               :last_edit_comment => 'Added automatically by ipvtheme'}]
rules_data.each do |d|
    rule = CensorRule.find_by_text(d[:text])
    if rule.nil?
        new_rule = CensorRule.new(d)
        if new_rule.info_request || new_rule.public_body
            new_rule.save!
        end
    end
end
