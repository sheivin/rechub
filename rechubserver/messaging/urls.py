'''
url patterns for messaging endpoints
'''


from django.urls import path
from django.conf.urls import url

from . import views

urlpatterns = [
	path('load-rectable', views.load_rectable),
	path('load-recommendations', views.load_recommendations),
	path('add-group', views.add_recchannel),
]
