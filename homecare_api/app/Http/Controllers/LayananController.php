<?php

namespace App\Http\Controllers;
use App\Models\LayananModel;

use Illuminate\Http\Request;

class LayananController extends Controller
{
     public function getAllLayanan()
{
    try {
       $layanan = LayananModel::all();

        if ($layanan->isEmpty()) {
            return response()->json([
                'code' => 404,
                'status' => 'NOT_FOUND',
                'message' => 'Data layanan tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'code' => 200,
            'status' => 'OK',
            'message' => 'Data layanan berhasil diambil',
            'data' => $layanan
        ], 200);

    } catch (\Throwable $e) {
        return response()->json([
            'code' => 500,
            'status' => 'INTERNAL_SERVER_ERROR',
            'message' => 'Terjadi kesalahan pada server',
            'error' => $e->getMessage()
        ], 500);
    }
}
}
