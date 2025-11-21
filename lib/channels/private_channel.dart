import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/auth_data.dart';
import '../utils/member.dart';
import 'channel.dart';

/// Represents a private channel in Pusher.
class PrivateChannel extends Channel {
  PrivateChannel({
    required super.client,
    required super.name,
  }) {
    onSubscriptionSuccess(_onSubscriptionSuccess);
    onSubscriptionCount(_onSubscriptionCount);
  }

  String? userId;

  /// The user member of the channel.
  Member? get member => userId != null ? Member(id: userId!) : null;

  AuthData? authData;

  /// Subscribes to the private channel.
  @override
  void subscribe([bool force = false]) async {
    if (!client.connected ||
        (subscribed && !force) ||
        client.socketId == null) {
      options.log(
        "SUBSCRIBE_SKIPPED",
        name,
        "connected: ${client.connected}, subscribed: $subscribed, socketId: ${client.socketId}",
      );
      return;
    }

    subscribed = false;

    options.log("SUBSCRIBE", name);

    // Enhanced logging for authorization flow
    options.log(
      "AUTH_START",
      name,
      "🔐 Starting authorization\n"
      "  Channel: $name\n"
      "  Socket ID: ${client.socketId}\n"
      "  Endpoint: ${authOptions.endpoint}",
    );

    try {
      // FIXED: Send socket_id and channel_name as query parameters instead of body
      final uri = Uri.parse(authOptions.endpoint).replace(queryParameters: {
        "channel_name": name,
        "socket_id": client.socketId!,
      });

      final headers = await authOptions.headers();

      options.log(
        "AUTH_REQUEST",
        name,
        "🔐 Making auth request\n"
        "  URL: $uri\n"
        "  Headers: $headers",
      );

      final response = await http.post(
        uri,
        headers: headers,
      );

      options.log(
        "AUTH_RESPONSE",
        name,
        "🔐 Auth response received\n"
        "  Status: ${response.statusCode}\n"
        "  Body: ${response.body}",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is! Map) {
          throw Exception(
            "Invalid auth response data [$data], expected Map got ${data.runtimeType}",
          );
        } else if (!data.containsKey("auth")) {
          throw Exception(
            "Invalid auth response data [$data], auth key is missing",
          );
        }

        authData = AuthData.fromJson(data);
        userId = authData!.channelData?.userId;

        options.log(
          "AUTH_SUCCESS",
          name,
          "✅ Authorization successful\n"
          "  Auth: ${authData!.auth}\n"
          "  User ID: $userId",
        );

        client.sendEvent("pusher:subscribe", {
          "channel": name,
          "auth": authData!.auth,
          "channel_data": authData!.channelData?.toJsonString(),
        });
      } else {
        final errorMessage = "Unable to authenticate channel $name\n"
            "  Status code: ${response.statusCode}\n"
            "  Response: ${response.body}";

        options.log("AUTH_ERROR", name, "❌ $errorMessage");

        handleEvent(
          "pusher:error",
          errorMessage,
        );
      }
    } catch (e) {
      final errorMessage = "Authorization exception for channel $name: $e";

      options.log("AUTH_EXCEPTION", name, "❌ $errorMessage");

      handleEvent(
        "pusher:error",
        errorMessage,
      );
    }
  }

  void _onSubscriptionSuccess(data) {
    options.log("SUBSCRIPTION_SUCCESS", name, "data: $data");

    subscribed = true;
  }

  int _subscriptionCount = 0;

  /// The number of subscriptions to the channel.
  int get subscriptionCount => _subscriptionCount;

  void _onSubscriptionCount(data) {
    options.log("SUBSCRIPTION_COUNT", name, "data: $data");

    _subscriptionCount = data["subscription_count"];
  }

  /// Binding for the subscription count event.
  void onSubscriptionCount(Function listener) =>
      bind("pusher:subscription_count", listener);

  /// Send an event to the channel.
  void trigger(String event, [data]) {
    options.log("TRIGGER", name, "event: $event\n  data: $data");

    if (!event.startsWith("client-")) {
      event = "client-$event";
    }

    client.sendEvent(event, data, name);
  }
}
