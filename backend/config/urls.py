from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),

    # Auth endpoints (register, login, refresh, me)
    path('api/auth/', include('users.urls')),

    # Case endpoints
    path('api/', include('hso_cases.urls')),
    path('api/', include('chw_cases.urls')),
    path('api/', include('clinical_cases.urls')),
]
         