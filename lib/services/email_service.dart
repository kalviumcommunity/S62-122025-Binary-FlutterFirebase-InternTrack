// lib\services\email_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailService {
  // Replace with your SendGrid API key
final String _sendGridApiKey = dotenv.env['SENDGRID_API_KEY']!;
final String _senderEmail = dotenv.env['SENDGRID_SENDER_EMAIL']!;
final String _senderName = dotenv.env['SENDGRID_SENDER_NAME']!;

  static const String _sendGridEndpoint = 'https://api.sendgrid.com/v3/mail/send';
  

  Future<bool> sendMentorInvitation({
    required String mentorEmail,
    required String studentName,
    required String studentEmail,
  }) async {
    try {
      final emailBody = {
        'personalizations': [
          {
            'to': [
              {'email': mentorEmail}
            ],
            'subject': 'You\'ve been invited to mentor on InternTrack'
          }
        ],
        'from': {
          'email':  _senderEmail,
          'name': _senderName
        },
        'content': [
          {
            'type': 'text/html',
            'value': '''
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: linear-gradient(135deg, #3B82F6 0%, #60A5FA 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
    .content { background: #f8f8f8; padding: 30px; border-radius: 0 0 10px 10px; }
    .button { display: inline-block; background: linear-gradient(135deg, #3B82F6 0%, #60A5FA 100%); color: white; padding: 12px 30px; text-decoration: none; border-radius: 8px; margin: 20px 0; }
    .footer { text-align: center; margin-top: 20px; color: #666; font-size: 14px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🎓 InternTrack</h1>
      <p>Mentorship Invitation</p>
    </div>
    <div class="content">
      <h2>Hello!</h2>
      <p><strong>$studentName</strong> ($studentEmail) has invited you to be their mentor on InternTrack.</p>
      
      <p>InternTrack is a unified platform where students track their internship applications and receive structured mentorship feedback.</p>
      
      <h3>What you can do as a mentor:</h3>
      <ul>
        <li>View your student's internship applications</li>
        <li>Provide structured feedback and guidance</li>
        <li>Help them improve their career journey</li>
      </ul>
      
      <p><strong>To get started:</strong></p>
      <ol>
        <li>Download the InternTrack app from your app store</li>
        <li>Sign up using this email address: <strong>$mentorEmail</strong></li>
        <li>You'll be automatically connected with $studentName</li>
      </ol>
      
      <div style="text-align: center;">
        <p style="color: #3B82F6; font-weight: bold;">Download InternTrack</p>
        <p>Search for "InternTrack" in your app store</p>
      </div>
      
      <p>We look forward to having you onboard!</p>
    </div>
    <div class="footer">
      <p>© 2025 InternTrack. All rights reserved.</p>
      <p>This is an automated message. Please do not reply to this email.</p>
    </div>
  </div>
</body>
</html>
            '''
          }
        ]
      };

      final response = await http.post(
        Uri.parse(_sendGridEndpoint),
        headers: {
          'Authorization': 'Bearer $_sendGridApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(emailBody),
      );

      return response.statusCode == 202;
    } catch (e) {
      print('Email service error: $e');
      return false;
    }
  }
}