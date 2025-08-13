from rest_framework.routers import DefaultRouter
from django.urls import path, include
from .views import ClinicalCaseViewSet

router = DefaultRouter()
router.register(r'clinical_cases', ClinicalCaseViewSet, basename='clinical_case')

urlpatterns = [
    path('', include(router.urls)),
]
