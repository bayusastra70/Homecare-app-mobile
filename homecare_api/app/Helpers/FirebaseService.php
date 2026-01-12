<?php

namespace App\Helpers;

use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\AndroidConfig;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Factory;

class FirebaseService
{
    protected $messaging;

    public function __construct()
    {
        $factory = (new Factory)
            ->withServiceAccount(base_path(config('services.fcm.credentials')));

        $this->messaging = $factory->createMessaging();
    }

    /**
     * Kirim notifikasi ke satu device
     */
   public function sendToDevice(string $fcmToken, string $title, string $body, array $data = [], string $channel = 'payment_channel'): array
{
    try {
        $androidConfig = AndroidConfig::fromArray([
            'priority' => 'high',
            'notification' => [
                'channel_id' => $channel,
                'sound' => 'default',
                'tag' => 'notif_' . uniqid(),
            ],
        ]);

        $notification = [
            'title' => $title,
            'body'  => $body,
        ];

        // Data tambahan (tidak boleh duplikasi title/body)
        $payload = array_merge($data, [
            'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
        ]);

        $message = CloudMessage::withTarget('token', $fcmToken)
            ->withNotification($notification)
            ->withData($payload)
            ->withAndroidConfig($androidConfig);

        $this->messaging->send($message);

        Log::info("FCM OK → $fcmToken", [
            'notification' => $notification,
            'data' => $payload
        ]);

        return ['success' => true];
    } catch (\Throwable $e) {
        Log::error("FCM ERROR → " . $e->getMessage());
        return ['success' => false];
    }
}

    /**
     * Kirim notifikasi ke banyak device
     */
    public function sendToDevices(array $fcmTokens, string $title, string $body, array $data = [], string $channel = 'payment_channel'): array
{
    try {
        $payload = array_merge($data, [
            'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
        ]);

        $notification = [
            'title' => $title,
            'body'  => $body,
        ];

        $androidConfig = AndroidConfig::fromArray([
            'priority' => 'high',
            'notification' => [
                'channel_id' => $channel,
                'sound' => 'default',
                'tag' => 'notif_' . uniqid(),
            ],
        ]);

        $message = CloudMessage::new()
            ->withNotification($notification)
            ->withData($payload)
            ->withAndroidConfig($androidConfig);

        $report = $this->messaging->sendMulticast($message, $fcmTokens);

        return [
            'success'        => $report->failures()->count() === 0,
            'success_count'  => $report->successes()->count(),
            'failure_count'  => $report->failures()->count(),
        ];

    } catch (\Throwable $e) {
        Log::error("FCM error (sendToDevices): " . $e->getMessage());
        return ['success' => false, 'error' => $e->getMessage()];
    }
}


    /**
     * Kirim notifikasi ke topic
     */
    public function sendToTopic(string $topic, string $title, string $body, array $data = [], string $channel = 'payment_channel'): array
    {
        try {
            // Kirim semuanya melalui DATA PAYLOAD
            $payload = array_merge($data, [
                'title' => $title,
                'body'  => $body,
                'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
            ]);

            $androidConfig = AndroidConfig::fromArray([
                'priority' => 'high',
                'notification' => [
                    'channel_id' => $channel,
                    'sound' => 'default',
                ],
            ]);

            $message = CloudMessage::withTarget('topic', $topic)
                ->withData($payload)
                ->withAndroidConfig($androidConfig);

            $this->messaging->send($message);

            Log::info("FCM sent to topic: $topic", [
                'payload' => $payload,
            ]);

            return ['success' => true, 'message' => 'Sent'];
        } catch (\Throwable $e) {
            Log::error("FCM error (sendToTopic): " . $e->getMessage());
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }
}

