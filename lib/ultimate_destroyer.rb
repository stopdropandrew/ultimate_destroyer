module UltimateDestroyer
  module Model
    def self.included(base)
      base.extend ClassMethods
      
      base.class_inheritable_accessor :destroy_amount
      base.destroy_amount = 500

      class << base # this is fucking stupid
        alias_method_chain :destroy_all, :no_mercy
        alias_method_chain :delete_all, :no_mercy
      end
    end
  
    module ClassMethods
      
    
      def destroy_all_with_no_mercy(conditions = nil)
        until (records = find(:all, :conditions => conditions, :limit => destroy_amount)).blank?
          records.each { |record| record.destroy }
        end
      end

      def destroy_all!(conditions = nil) # this is to work with acts_as_paranoid
        until (records = find_with_deleted(:all, :conditions => conditions, :limit => destroy_amount)).blank?
          records.each { |record| record.destroy! }
        end
      end
      
      def delete_all_with_no_mercy(conditions = nil)
        sql = "DELETE FROM #{quoted_table_name} "
        add_conditions!(sql, conditions, scope(:find))
        sql += " LIMIT #{destroy_amount}"
        
        rows_deleted = 0
        just_deleted = 0
        while (just_deleted = connection.delete(sql, "#{name} Delete #{destroy_amount}")) == destroy_amount
          rows_deleted += just_deleted
        end
        rows_deleted += just_deleted
      end
      
    end
  end
  
  module Association
    def self.included(base)
      base.send(:include, InstanceMethods)
      
      base.send(:alias_method_chain, :destroy_all, :no_mercy)
    end
    
    module InstanceMethods
      def destroy_all_with_no_mercy(conditions = nil)
        until (records = find(:all, :conditions => conditions, :limit => destroy_amount)).blank?
          records.each { |record| record.destroy }
        end
        
        reset_target!
      end

      def destroy_all!(conditions = nil) # this is to work with acts_as_paranoid
        until (records = find_with_deleted(:all, :conditions => conditions, :limit => destroy_amount)).blank?
          records.each { |record| record.destroy! }
        end
        
        reset_target!
      end
    end
  end
end
