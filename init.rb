require 'ultimate_destroyer'

ActiveRecord::Base.send(:include, UltimateDestroyer::Model)
# ActiveRecord::Associations::AssociationCollection.send(:include, UltimateDestroyer::Association)
