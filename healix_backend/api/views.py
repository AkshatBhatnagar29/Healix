# from django.core.mail import send_mail
# from django.utils import timezone
# from rest_framework import status, generics
# from rest_framework.response import Response
# from rest_framework.views import APIView
# from rest_framework_simplejwt.views import TokenObtainPairView
# from .models import User
# from .serializers import UserSerializer, MyTokenObtainPairSerializer
# import random
# from datetime import timedelta

# # --- Helper function to generate and send OTP ---
# def send_otp_email(user):
#     otp = random.randint(100000, 999999)
#     otp_expiry = timezone.now() + timedelta(minutes=10)
    
#     user.otp_code = str(otp)
#     user.otp_expiry = otp_expiry
#     user.save()

#     subject = 'Your Healix Verification Code'
#     message = f'Your one-time password (OTP) for Healix account verification is: {otp}\nThis code will expire in 10 minutes.'
#     from_email = 'your-email@gmail.com' # Configure this in settings.py
    
#     try:
#         send_mail(subject, message, from_email, [user.email])
#     except Exception as e:
#         # In a real app, you would log this error
#         print(f"Error sending email: {e}")


# # --- API Endpoint for User Signup ---
# class SignupView(generics.CreateAPIView):
#     queryset = User.objects.all()
#     serializer_class = UserSerializer

#     def perform_create(self, serializer):
#         # Create the user but mark them as inactive until verified
#         user = serializer.save(is_active=False)
#         send_otp_email(user) # Send the verification OTP


# # --- API Endpoint for OTP Verification ---
# class VerifyOtpView(APIView):
#     def post(self, request):
#         data = request.data
#         try:
#             user = User.objects.get(username=data['username'])
#         except User.DoesNotExist:
#             return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

#         # Check if OTP is correct and not expired
#         if user.otp_code == data.get('otp') and timezone.now() < user.otp_expiry:
#             user.is_active = True
#             user.is_email_verified = True
#             user.otp_code = None
#             user.otp_expiry = None
#             user.save()
#             return Response({'message': 'Email verified successfully. You can now log in.'}, status=status.HTTP_200_OK)
        
#         return Response({'error': 'Invalid or expired OTP.'}, status=status.HTTP_400_BAD_REQUEST)


# # --- Custom Login View using our secure serializer ---
# class MyTokenObtainPairView(TokenObtainPairView):
#     serializer_class = MyTokenObtainPairSerializer
from django.core.mail import send_mail
from django.utils import timezone
from rest_framework import status, generics
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView
from .models import User
from .serializers import UserSerializer, MyTokenObtainPairSerializer
import random
from datetime import timedelta
from django.conf import settings

from django.contrib.auth import authenticate
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

@api_view(['POST'])
def login_view(request):
    username = request.data.get('username')
    password = request.data.get('password')

    # This is the crucial part
    user = authenticate(username=username, password=password)

    username = request.data.get('username')
    password = request.data.get('password')

    print(f"--- Backend Received ---")
    print(f"Username: '{username}'")
    print(f"Password: '{password}'")
    print(f"------------------------")

    user = authenticate(username=username, password=password)

    if user is not None:
        # User is valid, active, and password is correct
        # You would generate and return a token here
        return Response({'message': 'Login Successful!'}, status=status.HTTP_200_OK)
    else:
        # Authentication failed
        return Response({'error': 'Invalid Credentials'}, status=status.HTTP_400_BAD_REQUEST)


# --- Helper function to generate and send OTP ---
def send_otp_email(user):
    # Generate 6-digit OTP
    otp = random.randint(100000, 999999)
    otp_expiry = timezone.now() + timedelta(minutes=10)

    # Save OTP and expiry to user
    user.otp_code = str(otp)
    user.otp_expiry = otp_expiry
    user.save()

    # Email content
    subject = 'Your Healix Verification Code'
    message = f'Your OTP for Healix account verification is: {otp}\nThis code expires in 10 minutes.'
    from_email = settings.DEFAULT_FROM_EMAIL  # Use settings instead of hardcoding
    recipient_list = [user.email]

    try:
        send_mail(subject, message, from_email, recipient_list)
        print(f"OTP {otp} sent to {user.email}")
    except Exception as e:
        print(f"Error sending OTP to {user.email}: {e}")

# --- Signup API ---
class SignupView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def perform_create(self, serializer):
        # Create inactive user
        user = serializer.save(is_active=False)
        send_otp_email(user)  # Send OTP after user is saved

# --- OTP Verification API ---
class VerifyOtpView(APIView):
    def post(self, request):
        username = request.data.get('username')
        otp = request.data.get('otp')

        if not username or not otp:
            return Response({'error': 'Username and OTP are required'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(username=username)
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

        if user.otp_code == otp and timezone.now() < user.otp_expiry:
            user.is_active = True
            user.is_email_verified = True
            user.otp_code = None
            user.otp_expiry = None
            user.save()
            return Response({'message': 'Email verified successfully!'}, status=status.HTTP_200_OK)
        else:
            return Response({'error': 'Invalid or expired OTP'}, status=status.HTTP_400_BAD_REQUEST)

# --- Custom Login API ---
class MyTokenObtainPairView(TokenObtainPairView):
    serializer_class = MyTokenObtainPairSerializer
