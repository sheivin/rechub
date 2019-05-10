'''
Manage loading threads, recommendations
'''


from django.http import JsonResponse, HttpResponse
from django.contrib.auth.decorators import login_required
from django.db.models import Count, Q
from django.views.decorators.csrf import csrf_exempt

from . import models
from . import serializers
from userauth import models as userauth_models

# Load recommendation threads
@login_required
def load_rectable(request):
	threads = models.MessageThread.objects.filter(clients=request.user).annotate(
		unread_count = Count('receipts', filter=Q(receipts__recipient=request.user))
	)

	thread_data = serializers.MessageThreadListSerializer(threads).data
	return JsonResponse({ 'threads': thread_data })

# Load recommendations from thread
@login_required
def load_recommendations(request):
	thread = models.MessageThread.objects.get(hash_id=request.GET['id'])
	if not request.user in thread.clients.all():
		return HttpResponse(status=403)

	query = [Q(thread=thread)]
	if 'before' in request.GET:
		query.append(Q(date__lt=int(request.GET['before'])))

	recommendations = models.Recommendation.objects.filter(*query).order_by('-id')
	recommendations_data = serializers.RecListSerializer(recommendations[:30]).data
	thread.mark_read(request.user)
	
	return JsonResponse({ "recommendations": recommendations_data, "end": recommendations.count() <= 30 })

# Add user to recommendation channel. Create one if one with 'title' does not exist
@login_required
@csrf_exempt
def add_recchannel(request):
	title = request.POST['title'].strip()
	if models.MessageThread.objects.filter(title=title).exists():
		thread = models.MessageThread.objects.get(title=title)
	else:
		thread = models.MessageThread(title=title)
		thread.save()

	if not request.user in thread.clients.all():
		thread.clients.add(request.user)

	return HttpResponse(status=200)
