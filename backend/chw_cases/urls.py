from rest_framework.routers import DefaultRouter
from django.urls import path, include
from .views import CHWCaseViewSet

router = DefaultRouter()
router.register(r'chw_cases', CHWCaseViewSet, basename='chw_case')

urlpatterns = [
    path('', include(router.urls)),
]
   