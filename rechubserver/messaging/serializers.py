'''
Serialize message model to pass data using django rest.
'''


from rest_framework import serializers

from . import models

class RecommendationSerializer(serializers.ModelSerializer):
	id = serializers.CharField(source='hash_id', read_only=True)
	sender_id = serializers.CharField(source='sender.hash_id', read_only=True)
	sender_name = serializers.CharField(source='sender.username', read_only=True)
	thread_id = serializers.CharField(source='thread.hash_id', read_only=True)

	class Meta:
		model = models.Recommendation
		fields = ('id', 'date', 'description', 'url', 'sender_id', 'sender_name', 'thread_id')



class RecListSerializer(serializers.ListSerializer):
	child = RecommendationSerializer()
	many = True
	allow_null = True


class MessageThreadSerializer(serializers.ModelSerializer):
	id = serializers.CharField(source='hash_id', read_only=True)
	unread_count = serializers.IntegerField(read_only=True)
	last_recommendation = RecommendationSerializer(read_only=True, many=False)
	title = serializers.CharField(default="New", read_only=True)

	class Meta:
		model = models.MessageThread
		fields = ('id', 'title', 'last_recommendation', 'unread_count')


class MessageThreadListSerializer(serializers.ListSerializer):
	child = MessageThreadSerializer()
	many = True
	allow_null = True
