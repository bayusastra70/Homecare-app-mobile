<?php

namespace App\Http\Controllers;

use App\Models\Desa;
use App\Models\Kabupaten;
use App\Models\Kecamatan;
use Illuminate\Http\Request;

class RegionController extends Controller
{
    public function getKabupaten()
    {
        $kabupaten = Kabupaten::where('id_provinsi', 51)->get();

        if ($kabupaten->isEmpty()) {
            return response()->json([
                'code' => 404,
                'message' => 'Kabupaten not found',
                'data' => []
            ], 404);
        }

        return response()->json([
            'code' => 200,
            'message' => 'OK',
            'data' => $kabupaten
        ]);
    }

    public function getKecamatan($kab_id)
    {
        $kecamatan = Kecamatan::where('id_kabupaten', $kab_id)->get();

        if ($kecamatan->isEmpty()) {
            return response()->json([
                'code' => 404,
                'message' => 'Kecamatan not found',
                'data' => []
            ], 404);
        }

        return response()->json([
            'code' => 200,
            'message' => 'OK',
            'data' => $kecamatan
        ], 200);
    }

    public function getDesa($kec_id)
    {
        $desa = Desa::where('id_kecamatan', $kec_id)->get();

        if ($desa->isEmpty()) {
            return response()->json([
                'code' => 404,
                'message' => 'Desa not found',
                'data' => []
            ], 404);
        }

        return response()->json([
            'code' => 200,
            'message' => 'OK',
            'data' => $desa
        ], 200);
    }

    public function getKabupatenName($kab_id)
    {
        $kabupaten = Kabupaten::where('id_kabupaten', $kab_id)->first();

        if (!$kabupaten) {
            return response()->json([
                'code' => 404,
                'message' => 'Kabupaten not found',
                'data' => []
            ], 404);
        }

        return $kabupaten->nama;
    }

    public function getKecamatanName($kec_id)
    {
        $kecamatan = Kecamatan::where('id_kecamatan', $kec_id)->first();

        if (!$kecamatan) {
            return response()->json([
                'code' => 404,
                'message' => 'Kecamatan not found',
                'data' => []
            ], 404);
        }

        return $kecamatan->nama;
    }

    public function getDesaName($desa_id)
    {
        $desa = Desa::where('id_desa', $desa_id)->first();

        if (!$desa) {
            return response()->json([
                'code' => 404,
                'message' => 'Desa not found',
                'data' => []
            ], 404);
        }

        return $desa->nama;
    }
}
