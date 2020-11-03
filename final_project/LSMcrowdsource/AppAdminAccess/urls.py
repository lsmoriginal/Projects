from django.urls import path, re_path
from . import views  


app_name = 'adminaccess'
urlpatterns = [
    re_path(r'^$', views.adminpage, name = 'adminpage'),
    re_path("edit_user/(?P<user_id>.+?$)", views.edit_user, name = "edit_user"),
    re_path("edit_user_update/(?P<uid>.+?)/(?P<update>.+?$)", views.edit_user, name = "edit_user_update"),

    re_path("edit_proj/(?P<proj_id>.+?$)", views.edit_proj, name = "edit_proj"), # just render the blank page
    re_path("edit_proj_update/(?P<proj_id>.+?)/(?P<update>.+?$)", views.edit_proj, name = "edit_proj_update"),

    re_path("edit_donation/(?P<u_id>.+?)/(?P<proj_id>.+?)/(?P<d_time>.+?$)", views.edit_donation, name = "edit_donation"),
    re_path("edit_donation_update/(?P<u_id>.+?)/(?P<proj_id>.+?)/(?P<d_time>.+?)/(?P<update>.+?$)", views.edit_donation, name = "edit_donation_update"),

    re_path('del_donate/(?P<u_id>.+?)/(?P<proj_id>.+?)/(?P<d_time>.+?$)', views.del_donate, name = "del_donate"),
    re_path('del_proj/(?P<proj_id>.+?$)', views.del_proj, name = "del_proj"),
    re_path('del_user/(?P<uid>.+?$)', views.del_user, name = "del_user"),


]