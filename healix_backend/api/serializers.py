from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from .models import User, StudentProfile, DoctorProfile

# --- Serializer for User Signup ---
class UserSerializer(serializers.ModelSerializer):
    # We add a write_only full_name field to accept it from the frontend
    full_name = serializers.CharField(write_only=True)

    class Meta:
        model = User
        # The fields now reflect the database schema: first_name and last_name
        fields = ['id', 'username', 'email', 'password', 'role', 'full_name', 'first_name', 'last_name']
        extra_kwargs = {
            'password': {'write_only': True},
            # Make first_name and last_name read-only as we will set them in the create method
            'first_name': {'read_only': True},
            'last_name': {'read_only': True},
        }

    def create(self, validated_data):
        # This method is called when a new user signs up
        
        # Split the incoming full_name into first and last names
        full_name = validated_data.get('full_name', '')
        first_name = full_name.split(' ')[0]
        last_name = ' '.join(full_name.split(' ')[1:]) if ' ' in full_name else ''

        # Create the main User object using the correct fields
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=first_name, # Use the split first_name
            last_name=last_name,   # Use the split last_name
            role=validated_data['role'],
            is_active=False # User is inactive until their email is verified
        )

        # Now, create the corresponding profile based on the selected role
        if validated_data['role'] == 'student':
            # For a student, the username (Student ID) is used as the roll number
            StudentProfile.objects.create(user=user, roll_number=user.username)
        elif validated_data['role'] == 'doctor':
            DoctorProfile.objects.create(user=user)
        # Add a similar block for 'staff' if you create a StaffProfile model

        return user

# --- Serializer for Secure Login ---
class MyTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        # Add custom claims to the token (data you want to be easily accessible on the frontend)
        token['username'] = user.username
        token['role'] = user.role
        return token

    def validate(self, attrs):
        # Default validation first
        data = super().validate(attrs)
        
        # Add our custom security check
        if not self.user.is_email_verified:
            raise serializers.ValidationError({
                'detail': 'Email not verified. Please check your email for an OTP to activate your account.'
            })
            
        return data

