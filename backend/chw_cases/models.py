from django.db import models
from users.models import User

class Case(models.Model):
    created_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        related_name='chw_cases'   # <-- unique reverse name   
    )
    patient_name = models.CharField(max_length=200, blank=True)
    age = models.IntegerField(null=True, blank=True)
    sex = models.CharField(max_length=10, blank=True)
    disease = models.CharField(max_length=200, blank=True)
    notes = models.TextField(blank=True)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    treatment = models.TextField(blank=True)
    diagnosis = models.TextField(blank=True)
    symptoms = models.TextField(blank=True)
    address = models.TextField(blank=True)
    district = models.TextField(blank=True)   

    def __str__(self):
        return f"{self.disease} - {self.patient_name or 'anon'}"
    