from django.db import models
from django.contrib.auth.models import AbstractUser

from rechubserver import utilities


# Create your models here.


# customizable user model. current behavior: default extended with hash_id
class User(AbstractUser):
	hash_id = models.CharField(max_length=32, default=utilities.get_hash, unique=True)
