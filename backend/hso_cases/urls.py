from rest_framework.routers import DefaultRouter
from django.urls import path, include
from .views import HSOCaseViewSet

router = DefaultRouter()
router.register(r'hso_cases', HSOCaseViewSet, basename='hso_case')

urlpatterns = [
    path('', include(router.urls)),
]
            