from django.urls import path, re_path
from . import views  


app_name = 'userhome'
urlpatterns = [
    # re_path(r'home^$', views.index, name = 'home'),
    # capture the keywords using regex
    re_path("view_project/(?P<proj_id>.+?$)", views.view_project, name = "view_project"),
]