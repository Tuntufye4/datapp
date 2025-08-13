from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    ROLE_CHOICES = [
        ('CHW', 'Community Health Worker'),
        ('CO', 'Clinical Officer'),
        ('HSO', 'Health Surveillance Officer'),
    ]
    role = models.CharField(max_length=3, choices=ROLE_CHOICES)

    def __str__(self):
        return f"{self.username} ({self.get_role_display()})"
    