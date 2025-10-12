from django.urls import path
from .views import SignupView, VerifyOtpView, MyTokenObtainPairView
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path('signup/', SignupView.as_view(), name='signup'),
    path('verify-otp/', VerifyOtpView.as_view(), name='verify-otp'),

    path('login/', MyTokenObtainPairView.as_view(), name='token_obtain_pair'),
    
    path('login/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    # JWT Authentication Endpoints
    path('token/', MyTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]
