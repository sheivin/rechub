'''
Functions and ability for new socket connections.
'''


from asgiref.sync import async_to_sync
from channels.generic.websocket import JsonWebsocketConsumer
from channels.db import database_sync_to_async
from channels.layers import get_channel_layer

from messaging import models as messaging_models
from userauth import models as user_models
from . import serializers

class ChatConsumer(JsonWebsocketConsumer):

	def connect(self):
		if self.scope["user"].is_authenticated:
			self.accept()

			for thread in messaging_models.MessageThread.objects.filter(clients=self.scope["user"]).values('id'):
				async_to_sync(self.channel_layer.group_add)(thread.hash_id, self.channel_name)

			self.scope['session']['channel_name'] = self.channel_name
			self.scope['session'].save()

	def disconnect(self, close_code):
		if self.scope["user"].is_authenticated:
			if 'channel_name' in self.scope['session']:
				del self.scope['session']['channel_name']
				self.scope['session'].save()
			async_to_sync(self.channel_layer.group_discard)(self.scope["user"].hash_id, self.channel_name)

	# recommendation is sent in json format
	def receive_json(self, content):
		if 'read' in content:
			thread = messaging_models.MessageThread.objects.get(hash_id=str(content['read']),clients=self.scope["user"])
			thread.mark_read(self.scope["user"])
		elif 'message' in content:
			message = content['message']
			thread = messaging_models.MessageThread.objects.get(hash_id=message['id'],clients=self.scope["user"])
			new_recommendation = thread.add_message_text(message['text'],self.scope["user"])
			async_to_sync(self.channel_layer.group_send)(
				thread.hash_id, {
					"type": "chat.message",
					"message": serializers.RecommendationSerializer(new_recommendation).data,
				}
			)

	def chat_message(self, event):
		message = event['message']
		self.send_json(content=message)
