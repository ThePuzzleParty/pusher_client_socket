# Fix Private Channel Authorization Bug in pusher_client_socket

## Overview
**Critical Bug**: The package never makes HTTP POST requests to authorize private channels. The authHeaders callback is never invoked, making private channels completely non-functional.

**Your Task**: Fix the authorization flow so that private/presence channels properly authenticate with the Laravel backend.

## Step 1: Understand the Bug

The package accepts these parameters but never uses them:
- `authEndPoint` - The URL to POST authorization requests to
- `authHeaders` - Callback that returns headers for the auth request

When subscribing to a private channel, the package should:
1. Get the socket ID from the connection
2. Make an HTTP POST to the authEndPoint
3. Include the channel_name and socket_id in the request body
4. Use the authHeaders for the request
5. Get the auth signature from the response
6. Use that signature to subscribe to the channel

Currently, steps 2-5 are missing entirely.

## Step 2: Locate the Files to Fix

Find and examine these files:
```bash
# Main files to check:
lib/src/pusher_client_socket.dart     # Main client class
lib/src/channel/private_channel.dart  # Private channel implementation
lib/src/channel/presence_channel.dart # Presence channel implementation
lib/src/pusher_auth.dart              # Auth configuration (if exists)
```

## Step 3: Find the Private Channel Authorization Point

Look for code that handles private channel subscription. It likely looks something like:

```dart
class PrivateChannel extends Channel {
  @override
  void subscribe() {
    // BUG: This probably just subscribes without authorizing
    _client.subscribe(name);
    
    // MISSING: Should be calling authorization first
  }
}
```

## Step 4: Implement the Authorization Fix

### Step 4.1: Add HTTP dependency if not present

Check `pubspec.yaml` and add if missing:
```yaml
dependencies:
  http: ^1.1.0  # Add this if not present
```

### Step 4.2: Import required packages

In the file where you're fixing the authorization:
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
```

### Step 4.3: Implement the Authorization Method

Add this method to the PrivateChannel class (or wherever subscription happens):

```dart
Future<String> _authorizeChannel(String channelName, String socketId) async {
  final authEndpoint = _client.authEndPoint;  // Or however it's accessed
  final authHeadersCallback = _client.authHeaders;  // Or however it's accessed
  
  if (authEndpoint == null || authEndpoint.isEmpty) {
    throw Exception('Auth endpoint is required for private channels');
  }
  
  // Log for debugging
  print('🔐 [pusher_client_socket] Starting authorization for channel: $channelName');
  print('🔐 [pusher_client_socket] Socket ID: $socketId');
  print('🔐 [pusher_client_socket] Auth endpoint: $authEndpoint');
  
  // Get headers from callback
  final headers = authHeadersCallback != null 
    ? await authHeadersCallback() 
    : <String, String>{};
    
  // Ensure Content-Type is set
  if (!headers.containsKey('Content-Type')) {
    headers['Content-Type'] = 'application/json';
  }
  
  print('🔐 [pusher_client_socket] Auth headers: $headers');
  
  try {
    // Make the authorization request
    final response = await http.post(
      Uri.parse(authEndpoint),
      headers: headers,
      body: jsonEncode({
        'socket_id': socketId,
        'channel_name': channelName,
      }),
    );
    
    print('🔐 [pusher_client_socket] Auth response status: ${response.statusCode}');
    print('🔐 [pusher_client_socket] Auth response body: ${response.body}');
    
    if (response.statusCode != 200) {
      throw Exception('Authorization failed: ${response.statusCode} - ${response.body}');
    }
    
    // Parse the auth response
    final authData = jsonDecode(response.body);
    
    // Pusher/Reverb returns auth in this format: {"auth": "key:signature"}
    if (authData['auth'] != null) {
      return authData['auth'];
    } else {
      throw Exception('Invalid auth response format');
    }
  } catch (e) {
    print('🔐 [pusher_client_socket] Authorization error: $e');
    rethrow;
  }
}
```

### Step 4.4: Modify the Subscribe Method

Find where private channels subscribe and modify it:

```dart
@override
void subscribe() async {
  // Get socket ID (this should already exist in the client)
  final socketId = _client.socketId;  // Or however socket ID is accessed
  
  if (socketId == null || socketId.isEmpty) {
    print('⚠️ [pusher_client_socket] Cannot authorize: no socket ID yet');
    // Maybe retry after connection is established
    return;
  }
  
  try {
    // Authorize first
    final auth = await _authorizeChannel(name, socketId);
    
    // Now subscribe with the auth signature
    _client.subscribeWithAuth(name, auth);  // Or however the client subscribes
    
    print('✅ [pusher_client_socket] Successfully subscribed to private channel: $name');
  } catch (e) {
    print('❌ [pusher_client_socket] Failed to subscribe to private channel: $e');
    // Handle error - maybe emit error event
  }
}
```

### Step 4.5: Handle Presence Channels Similarly

Presence channels also need authorization. Apply the same fix to `PresenceChannel` class:

```dart
class PresenceChannel extends PrivateChannel {
  // Presence channels use the same authorization as private channels
  // They just have additional presence features
  
  @override
  void subscribe() async {
    // Use the same authorization logic from PrivateChannel
    await super.subscribe();
    
    // Add presence-specific logic here if needed
  }
}
```

## Step 5: Add Proper Error Handling

Ensure errors are properly propagated:

```dart
class PrivateChannel extends Channel {
  final _errorController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get onError => _errorController.stream;
  
  @override
  void subscribe() async {
    try {
      // ... authorization code ...
    } catch (e) {
      _errorController.add(e);
      // Also log for debugging
      print('❌ [pusher_client_socket] Subscription error: $e');
    }
  }
}
```

## Step 6: Test Your Fix

Create a test file `test/private_channel_auth_test.dart`:

```dart
import 'package:test/test.dart';
import 'package:pusher_client_socket/pusher_client_socket.dart';

void main() {
  test('Private channel authorization is called', () async {
    bool authCallbackInvoked = false;
    
    final client = PusherClient(
      'test-key',
      PusherOptions(
        host: 'example.com',
        authEndPoint: 'https://example.com/broadcasting/auth',
        authHeaders: () async {
          authCallbackInvoked = true;  // This should be set to true
          return {
            'Authorization': 'Bearer test-token',
          };
        },
      ),
    );
    
    // Simulate connection
    // ... connect client ...
    
    // Try to subscribe to private channel
    await client.subscribe('private-test-channel');
    
    // Verify auth callback was invoked
    expect(authCallbackInvoked, true, reason: 'Auth callback should be invoked');
  });
}
```

## Step 7: Update Package Version

In `pubspec.yaml`, increment the version:
```yaml
name: pusher_client_socket
description: Fixed version with working private channel authorization
version: 0.0.8  # Increment from 0.0.7
```

## Step 8: Update CHANGELOG.md

Add to the top of `CHANGELOG.md`:
```markdown
## 0.0.8

* CRITICAL FIX: Private and presence channels now properly authorize via HTTP POST
* Added authorization logging for debugging
* Fixed authHeaders callback never being invoked
* Added proper error handling for authorization failures
```

## Step 9: Commit Your Changes

```bash
git add .
git commit -m "fix: implement private channel authorization for Laravel Reverb

- Add HTTP POST authorization for private/presence channels
- Fix authHeaders callback never being invoked  
- Add comprehensive error handling and logging
- Test with Laravel Reverb/Pusher protocol"

git push origin fix/private-channel-authorization
```

## IMPORTANT NOTES

1. **Find the actual implementation**: The package structure might be different than shown above. Use your IDE's search to find:
   - Where `authEndPoint` is stored
   - Where `authHeaders` is stored
   - Where private channel subscription happens
   - How the socket ID is accessed

2. **Socket ID timing**: The socket ID is only available after connection. You might need to:
   - Wait for connection before authorizing
   - Queue subscriptions until connected
   - Retry authorization if no socket ID yet

3. **Async handling**: Dart requires proper async/await handling. Make sure:
   - Methods that do authorization are marked `async`
   - Use `await` for HTTP calls
   - Handle Future returns properly

4. **Laravel Reverb specifics**:
   - Channel name format: `private-party.1`, `presence-party.1`
   - Auth response format: `{"auth": "key:signature"}`
   - Headers must include: `Authorization`, `Content-Type`, `Accept`

5. **Testing**: After fixing, test with:
   - A real Laravel Reverb server
   - Both private and presence channels
   - Various auth scenarios (success, failure, timeout)

## Success Criteria

You'll know the fix works when:
1. ✅ The console shows `🔐 [pusher_client_socket] Starting authorization...` logs
2. ✅ Laravel backend logs show incoming POST requests to `/api/v1/broadcasting/auth`
3. ✅ Private channels successfully subscribe after authorization
4. ✅ Events are received on private channels
5. ✅ The authHeaders callback is actually invoked

## If You Get Stuck

1. Search for how other Pusher client libraries handle auth:
   - Look at pusher-js (JavaScript)
   - Look at pusher_channels_flutter
   - Check Pusher protocol documentation

2. Key search terms in the codebase:
   - "subscribe"
   - "private"
   - "auth"
   - "socket"
   - "channel"

3. The fix MUST happen where private channels subscribe, not in the general connection flow

Remember: The bug is that authorization is NEVER attempted. Your job is to add the authorization step before private channel subscription.
