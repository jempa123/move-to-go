module FruitToLime
    class Note
        include SerializeHelper
        attr_accessor :id, :text, :integration_id, :classification, :date

        attr_reader :organization, :created_by, :person, :deal

        def initialize(opt = nil)
            if !opt.nil?
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s, val) if val != nil
                end
            end
        end

        def serialize_variables
            [ :id, :text, :integration_id, :classification ].map {
                |p| {
                    :id => p,
                    :type => :string
                }
            } +
                [
                 { :id => :date, :type => :date },
                 { :id => :created_by, :type => :coworker_reference },
                 { :id => :organization, :type => :organization_reference },
                 { :id => :person, :type => :person_reference }
                ]
        end

        def get_import_rows
            (serialize_variables+[
                {:id=>:organization, :type=>:organization_reference},
                {:id=>:person, :type=>:person_reference}
                ]).map do |p|
                map_to_row p
            end
        end

        def serialize_name
            "Note"
        end

        def organization=(org)
            @organization = OrganizationReference.from_organization(org)
        end

        def created_by=(coworker)
            @created_by = CoworkerReference.from_coworker(coworker)
        end

        def person=(person)
            @person = PersonReference.from_person(person)
        end

        def deal=(deal)
            @deal = DealReference.from_deal(deal)
        end

        def validate
            error = String.new

            if @text.nil? || @text.empty?
                error = "Text is required for note\n"
            end

            if @created_by.nil?
                error = "#{error}Created_by is required for note\n"
            end

            if @organization.nil? && @deal.nil? && @person.nil?
                error = "#{error}Organization, deal or person is required for note\n"
            end

            return error
        end
    end
end
