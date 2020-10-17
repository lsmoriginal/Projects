
from django.urls import path
from . import views

urlpatterns = [
    path("", views.index, name='index'),
    path('yoshao', views.shaomin, name='shao'),
    path("<str:name>", views.greet, name = "greet"),
]