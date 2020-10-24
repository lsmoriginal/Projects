from django.urls import path, re_path
from . import views  


app_name = 'login'
urlpatterns = [
    re_path(r'^$', views.index, name = 'login_page'),
    re_path(r'^create_account$', views.create_account, name = 'create_account'),
    re_path(r'^process_login$', views.process_login, name = 'process_login'),
    re_path(r'^registered$', views.registered, name = 'registered'),
]