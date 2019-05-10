'''
Defining views for user authentication.
'''

from django.contrib.auth import login, logout, authenticate
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt

from . import serializers
from . import models

import json
from rest_framework import status


@csrf_exempt
def auth_login(request):
	"""Login attempt
	 - check username and password
	 - return serialized data
	"""

	username = request.POST['username']
	password = request.POST['password']
	user = authenticate(username=username, password=password)

	if user_details:
		login(request, user)
		serializer = serializers.UserSerializer(user)
		return JsonResponse(serializer.data)

	# user lacks valid authentication
	return HttpResponse(status=401)

@csrf_exempt
def signup(request):
	"""Signup attempt
	 - check if username exists
	 - if not, create and authenticate new user
	"""

	if models.User.objects.filter(username=request.POST['username'])
		.exists():
		return HttpResponse(status=403)
	else:
		# creating new user
		new_user = models.User(username=request.POST['username'])
		new_user.set_password(request.POST['password'])
		new_user.save()
		login(request, new_user)
		
		serializer = serializers.UserSerializer(new_user)
		return JsonResponse(serializer.data)

def auth_logout(request):
	"""Logout attempt
	 - clear session
	"""

	logout(request)
	return HttpResponse(status=200)
