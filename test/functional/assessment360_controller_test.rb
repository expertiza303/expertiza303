require File.dirname(__FILE__) + '/../test_helper'
require 'assessment360_controller'

# Re-raise errors caught by the controller.
class Assessment360Controller; def rescue_action(e) raise e end; end

class Assessment360Controller < ActionController::TestCase
  fixtures :participants, :response_maps, :score_caches
  fixtures :courses, :users, :assignments
  fixtures :system_settings, :permissions, :roles_permissions
  @settings = SystemSettings.find(:first)

  def setup
      @controller = Assessment360Controller.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new

      @request.session[:user] = User.find(users(:instructor1).id )
      roleid = User.find(users(:instructor3).id).role_id
      Role.rebuild_cache

      Role.find(roleid).cache[:credentials]
      @request.session[:credentials] = Role.find(roleid).cache[:credentials]
      # Work around a bug that causes session[:credentials] to become a YAML Object
      @request.session[:credentials] = nil if @request.session[:credentials].is_a? YAML::Object
      @settings = SystemSettings.find(:first)
      AuthController.set_current_role(roleid,@request.session)
      #   @request.session[:user] = User.find_by_name("suadmin")
  end

  def test_teammate_review_average
     average = (score_caches(:sc3_1).scores + score_caches(:sc3_2).score + score_caches(:sc3).score)/3
     get :one_student_all_reviews, {
                                       :assingnment_id => assignments(:assignment7).id,
                                       :student_id => users(:student1).id,
                                   }
      assert_redirected_to :controller => 'assessment360_controller', :action => 'one_student_all_reviews'
      assert_equal(average, 90)
    end
    def test_meta_review_average
     average = (score_caches(:sc4_1).scores + score_caches(:sc4_2).score + score_caches(:sc4).score)/3
     get :one_student_all_reviews, {
                                       :assingnment_id => assignments(:assignment7).id,
                                       :student_id => users(:student1).id,
                                   }
      assert_redirected_to :controller => 'assessment360_controller', :action => 'one_student_all_reviews'
      assert_equal(average, 100)
  end
end

