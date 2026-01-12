<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use Illuminate\Http\Request;
use App\Models\FcmToken;
use App\Models\InvoiceModel;
use App\Helpers\FirebaseService;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    // Ambil semua notifikasi user login
    public function index()
    {
        $notifications = Notification::where('user_id', Auth::id())
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $notifications
        ]);
    }

    // Trigger manual notifikasi (status/pembayaran)
    public function trigger(Request $request, FirebaseService $firebaseService)
    {
        if ($request->header('X-Internal-Api-Key') !== env('INTERNAL_API_KEY')) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        try {
            $invoice_id = $request->input('id_invoice');
            $allowedStatus = ['pending','paying','accepted','done','canceled'];
            $status = in_array($request->input('status'), $allowedStatus)
                ? $request->input('status')
                : 'paying';

            if (!$invoice_id) {
                return response()->json([
                    'success' => false,
                    'error'   => 'Parameter id_invoice wajib dikirim.'
                ], 400);
            }

            $invoice = InvoiceModel::where('id_invoice', $invoice_id)->first();
            if (!$invoice) {
                return response()->json([
                    'success' => false,
                    'error'   => 'Invoice tidak ditemukan.'
                ], 404);
            }

            $user_id = $invoice->id_pengguna;

            $tokens = FcmToken::where('user_id', $user_id)
                ->pluck('fcm_token')
                ->filter()
                ->unique()
                ->values()
                ->toArray();

            if (empty($tokens)) {
                return response()->json([
                    'success' => false,
                    'error'   => 'Token FCM user tidak ditemukan.'
                ], 404);
            }

            $title = "Status Pesanan #{$invoice->id_invoice} berubah ke {$status}";
            $body  = ($status === 'paying')
                ? "Segera bayar tagihan sebesar Rp " . number_format($invoice->total, 0, ',', '.')
                : "Status pesanan Anda berubah menjadi: {$status}";

            $dataPayload = [
                'invoice_id' => $invoice->id_invoice,
                'status'     => $status,
                'unique'     => now()->timestamp,
            ];

            $channel = ($status === 'paying') ? 'payment_channel' : 'payment_channel';

            $result = $firebaseService->sendToDevices($tokens, $title, $body, $dataPayload, $channel);

            return response()->json([
                'success' => true,
                'message' => 'Status invoice berhasil diperbarui dan notifikasi diproses.',
                'report'  => $result,
            ]);


        } catch (\Throwable $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // Notifikasi janji temu
    public function appointment(Request $request, FirebaseService $firebaseService)
    {
        if ($request->header('X-Internal-Api-Key') !== env('INTERNAL_API_KEY')) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        try {
            $request->validate([
                'id_invoice' => 'required|integer',
                'appointment_datetime' => 'required|string',
            ]);

            $invoiceId = $request->id_invoice;
            $appointment = $request->appointment_datetime;

            $invoice = InvoiceModel::where('id_invoice', $invoiceId)->first();
            if (!$invoice) {
                return response()->json([
                    'success' => false,
                    'error' => 'Invoice tidak ditemukan.'
                ], 404);
            }

            // Update appointment_datetime
            $invoice->appointment_datetime = $appointment;
            $invoice->save();

            $userId = $invoice->id_pengguna;
            $tokens = FcmToken::where('user_id', $userId)
                ->pluck('fcm_token')
                ->filter()
                ->unique()
                ->values()
                ->toArray();

            if (empty($tokens)) {
                return response()->json([
                    'success' => false,
                    'error' => 'Token FCM user tidak ditemukan.'
                ], 404);
            }

            $title = "Jadwal Kunjungan Ditentukan";
            $body  = "Kunjungan dijadwalkan pada: " . $appointment;

            $dataPayload = [
                'invoice_id' => $invoiceId,
                'appointment_datetime' => $appointment,
                'status' => 'appointment',
                'unique' => now()->timestamp,
            ];

            $result = $firebaseService->sendToDevices(
                $tokens,
                $title,
                $body,
                $dataPayload,
                'appointment_channel_v2'
            );

            return response()->json([
                'success' => true,
                'message' => 'Status invoice berhasil diperbarui dan notifikasi diproses.',
                'report'  => $result,
            ]);


        } catch (\Throwable $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage()
            ], 500);
        }
    }

    
    
    // Tandai notifikasi sebagai sudah dibaca
    public function markAsRead($id)
    {
        $notification = Notification::where('user_id', Auth::id())
            ->where('id', $id)
            ->firstOrFail();

        $notification->update(['is_read' => 1]);

        return response()->json(['success' => true]);
    }
}
