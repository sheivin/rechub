from django.db import models

from rechubserver import utilities


# Model for threads
class MessageThread(models.Model):
	hash_id = models.CharField(max_length=32, default=utilities.get_hash, unique=True)
	name = models.CharField(max_length=64)
	clients = models.ManyToManyField(
				'userauth.User', 
				blank=True
				)
	last_recommendation = models.ForeignKey(
							'messaging.Recommendation', 
							null=True, 
							blank=True, 
							on_delete=models.SET_NULL
							)

# Model for individual recommendation
class Recommendation(models.Model):
	hash_id = models.CharField(max_length=32, default=utilities.get_hash, unique=True)
	date = models.IntegerField(default=utilities.get_timestamp)
	title = models.CharField(max_length=64)
	description = models.CharField(max_length=1024)
	thread = models.ForeignKey(
				'messaging.MessageThread', 
				on_delete=models.CASCADE, 
				related_name='recommendations'
				)
	sender = models.ForeignKey(
				'userauth.User', 
				on_delete=models.SET_NULL, 
				null=True
				)


# Model for unread recommendation receipt
class UnreadReceipt(models.Model):
	date = models.IntegerField(default=utilities.get_timestamp)
	recommendation = models.ForeignKey(
						'messaging.Recommendation', 
						on_delete=models.CASCADE, 
						related_name='receipts'
						)
	thread = models.ForeignKey(
				'messaging.MessageThread', 
				on_delete=models.CASCADE, 
				related_name='receipts'
				)
	recipient = models.ForeignKey(
					'userauth.User', 
					on_delete=models.CASCADE, 
					related_name='receipts'
					)


