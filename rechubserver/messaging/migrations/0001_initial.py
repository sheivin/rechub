# Generated by Django 2.0.4 on 2019-05-09 18:23

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion
import rechubserver.utilities


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='MessageThread',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('hash_id', models.CharField(default=rechubserver.utilities.get_hash, max_length=32, unique=True)),
                ('name', models.CharField(max_length=64)),
                ('clients', models.ManyToManyField(blank=True, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='Recommendation',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('hash_id', models.CharField(default=rechubserver.utilities.get_hash, max_length=32, unique=True)),
                ('date', models.IntegerField(default=rechubserver.utilities.get_timestamp)),
                ('title', models.CharField(max_length=64)),
                ('description', models.CharField(max_length=1024)),
                ('sender', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL)),
                ('thread', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='recommendations', to='messaging.MessageThread')),
            ],
        ),
        migrations.CreateModel(
            name='UnreadReceipt',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('date', models.IntegerField(default=rechubserver.utilities.get_timestamp)),
                ('recipient', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='receipts', to=settings.AUTH_USER_MODEL)),
                ('recommendation', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='receipts', to='messaging.Recommendation')),
                ('thread', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='receipts', to='messaging.MessageThread')),
            ],
        ),
        migrations.AddField(
            model_name='messagethread',
            name='last_recommendation',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to='messaging.Recommendation'),
        ),
    ]