module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      def supports_delete_with_limit?
        false
      end
    end
    
    class MysqlAdapter
      def supports_delete_with_limit?
        true
      end
    end
  end
end

module UltimateDestroyer
  module Model
    def self.included(base)
      base.extend ClassMethods
      base.class_inheritable_accessor :destroy_amount
      base.destroy_amount = 500
    end
  
    module ClassMethods
      def destroy_all(conditions = nil)
        return super unless connection.supports_delete_with_limit?
        until (records = find(:all, :conditions => conditions, :limit => destroy_amount)).blank?
          records.each { |record| record.destroy }
        end
      end
      
      def delete_all(conditions = nil)
        return super unless connection.supports_delete_with_limit?
        
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
    end
    
    module InstanceMethods
      def destroy_all(conditions = nil)
        return super unless connection.supports_delete_with_limit?
        until (records = find(:all, :conditions => conditions, :limit => destroy_amount)).blank?
          records.each { |record| record.destroy }
        end
        
        reset_target!
      end
    end
  end
end
