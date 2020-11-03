from django.urls import path, re_path
from . import views  

# from AppLogin import gen_homepage


app_name = 'projectsearch'
urlpatterns = [
    re_path("home", views.gen_homepage, name = "home"),
    re_path("search_proj/(?P<status>.+?$)", views.search_proj, name = "search_proj"),
]