from django.urls import path, re_path
from . import views  
from AppLogin import gen_homepage


app_name = 'userhome'
urlpatterns = [
    # re_path(r'home^$', views.index, name = 'home'),
    # capture the keywords using regex
    re_path("view_project/(?P<proj_id>.+?$)", views.view_project, name = "view_project"),
    re_path("newproject/(?P<state>.+?$)", views.new_project, name = "new_project"),
    re_path("project_editmsg", views.proj_editmsg, name = "proj_editmsg"),
    re_path("home", gen_homepage.render_homepage, name = "home"),
    re_path("donation/(?P<proj_title>.+?$)", views.donation, name = "donation"),
]