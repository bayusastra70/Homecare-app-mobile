<?php

namespace App\Http\Controllers;

use App\Models\FcmToken;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class FcmTokenController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'fcm_token' => 'required|string',
            'device_id' => 'required|string',
        ]);

        $userId = Auth::user()->id_pengguna;
        
        FcmToken::where('device_id', $request->device_id)
        ->where('user_id', '!=', $userId)
        ->delete();
        
        // Update atau buat token baru berdasarkan user_id + device_id
        FcmToken::updateOrCreate(
            [
                'user_id'   => $userId,
                'device_id' => $request->device_id,
            ],
            [
                'fcm_token' => $request->fcm_token,
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'Token berhasil diperbarui'
        ]);
    }
}
