require_relative "./base_controller"

module Api
  module V1

    class TagsController < V1::BaseController

      def index
        object_type = required_parameter(:object_type)
        account_id = @user.account_id.to_i
        account_id = params[:account_id].to_i if (params[:account_id]) 
        if (account_id)
          if (@user.account_id.to_i != account_id) && (!@user.is_super_user?)
            raise NotAuthorizedException("Cannot access tags from another account")
          end
        end
        tags = Tag.where(account_id: nil, object_type: object_type)
        tags += Tag.where(account_id: account_id, object_type: object_type) if (account_id)
        
        render text: tags.to_json
      end
      
      
      def save
        tag_hash = params[:tag]

        account_id = nil
        account_id = @user.account_id.to_i if (!@user.is_super_user?)
        
        tag = nil
        if (tag_hash[:id])
          duplicate_tags = Tag.where(code: tag_hash[:code], account_id: account_id)
          tag = Tag.find(tag_hash[:id].to_i)
          raise "Tag with same code found for account" if (duplicate_tags.length > 1) || ((duplicate_tags.length == 1) && (duplicate_tags.first.id != tag.id))
        else
          if (account_id)
            duplicate_tags = Tag.where(code: tag_hash[:code], account_id: account_id)
            raise "Tag with same code found for account" if (duplicate_tags.length > 0)

            duplicate_tags = Tag.where(code: tag_hash[:code], account_id: nil)
            raise "Public tag with same code found exists" if (duplicate_tags.length > 0)
          end
          tag = Tag.new
        end
        
        tag.account_id = account_id
        tag.code = tag_hash[:code]
        tag.name = tag_hash[:name]
        tag.object_type = tag_hash[:object_type]
        tag.save!
        
        render text: tag.to_json
      end
      
    end
    
  end
end