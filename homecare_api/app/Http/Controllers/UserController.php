<?php

namespace App\Http\Controllers;

use App\Models\Address;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Validation\ValidationException;

class UserController extends Controller
{

    private $IQtoken = 'pk.1e92a9b4535e5f6d479128da69367c8b';
    private $APIurl = 'https://us1.locationiq.com/v1/search.php';
    private $APIformat = 'json';

    public function profile(Request $request)
    {
        $user = $request->user()->load(['address.desa', 'address.kecamatan', 'address.kabupaten']);

        return response()->json([
            'code' => 200,
            'status' => 'OK',
            'data' => [
                'user' => [
                    'name' => $user->nama_lengkap,
                    'email' => $user->email,
                    'phone' => $user->no_hp ?? null,
                    'gender' => $user->jenis_kelamin,
                ],
                'address' => $user->address ? [
                    'alamat' => $user->address->alamat,
                    'desa' => $user->address->desa->nama ?? null,
                    'kecamatan' => $user->address->kecamatan->nama ?? null,
                    'kabupaten' => $user->address->kabupaten->nama ?? null,
                ] : null,
            ],
        ], 200);
    }

    public function editProfile(Request $request)
    {
        try {
            $user = $request->user();

            $validatedData = $request->validate([
                'name' => 'required|string|max:255',
                'email' => 'required|string|email|max:255',
                'phone' => 'nullable|string|max:15',
                'gender' => 'nullable|integer|in:1,2',
            ], [
                'name.required' => 'Nama lengkap wajib di isi.',
                'email.required' => 'Email wajib di isi.',
                'email.email' => 'Format email tidak valid.',
                'email.unique' => 'Email sudah terdaftar.',
                'phone.max' => 'Nomor telepon tidak boleh lebih dari 15 karakter.',
                'gender.in' => 'Jenis kelamin tidak valid.',
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'code' => 400,
                'status' => 'BAD_REQUEST',
                'errors' => $e->errors(),
            ], 400);
        }


        $user->update([
            'nama_lengkap' => $validatedData['name'],
            'email' => $validatedData['email'],
            'no_hp' => $validatedData['phone'],
            'jenis_kelamin' => $validatedData['gender'],
        ]);

        return response()->json([
            'code' => 200,
            'status' => 'OK',
            'message' => 'Profile updated successfully',
            'data' => [
                'name' => $user->nama_lengkap,
                'email' => $user->email,
                'phone' => $user->no_hp,
                'gender' => $user->jenis_kelamin,
            ],
        ], 200);
    }

    public function updateAddress(Request $request)
    {
        try {
            $request->validate([
                'id_kabupaten' => 'required|exists:dd_kabupaten,id_kabupaten',
                'id_kecamatan' => 'required|exists:dd_kecamatan,id_kecamatan',
                'id_desa' => 'required|exists:dd_desa,id_desa',
                'alamat' => 'required|string|max:255',
            ], [
                'id_kabupaten.required' => 'Kabupaten wajib di isi.',
                'id_kabupaten.exists' => 'Kabupaten tidak ditemukan.',
                'id_kecamatan.required' => 'Kecamatan wajib di isi.',
                'id_kecamatan.exists' => 'Kecamatan tidak ditemukan.',
                'id_desa.required' => 'Desa wajib di isi.',
                'id_desa.exists' => 'Desa tidak ditemukan.',
                'alamat.required' => 'Alamat wajib di isi.',
                'alamat.max' => 'Alamat tidak boleh lebih dari 255 karakter.',
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'code' => 400,
                'status' => 'BAD_REQUEST',
                'errors' => $e->errors(),
            ], 400);
        }


        $user = $request->user();

        // Dapatkan geocode dari alamat
        $regionController = new RegionController();
        $desa = $regionController->getDesaName($request->id_desa);

        $geocode = $this->get_geocode($desa);

        if (!$geocode['status']) {
            return response()->json(['message' => 'Failed to fetch geocode.', 'error' => $geocode['msg']], 400);
        }

        // Extract latitude dan longitude
        $latitude = $geocode['data'][0]['lat'] ?? null;
        $longtitude = $geocode['data'][0]['lon'] ?? null;


        // Cek apakah user sudah memiliki alamat
        if ($user->id_alamat) {
            // Perbarui alamat yang sudah ada
            $address = Address::findOrFail($user->id_alamat);
            $address->update([
                'id_desa' => $request->id_desa,
                'id_kecamatan' => $request->id_kecamatan,
                'id_kabupaten' => $request->id_kabupaten,
                'id_provinsi' => 51,
                'alamat' => $request->alamat,
                'latitude' => $latitude,
                'longtitude' => $longtitude,
            ]);
        } else {
            // Buat alamat baru
            $address = Address::create([
                'id_desa' => $request->id_desa,
                'id_kecamatan' => $request->id_kecamatan,
                'id_kabupaten' => $request->id_kabupaten,
                'id_provinsi' => 51,
                'alamat' => $request->alamat,
                'latitude' => $latitude,
                'longtitude' => $longtitude,
            ]);

            // Perbarui relasi alamat pada user
            $user->id_alamat = $address->id_alamat;
            $user->save();
        }

        return response()->json([
            'code' => 200,
            'status' => 'OK',
            'message' => 'Address has been successfully updated.',
            'data' => $address,
        ]);
    }

    private function get_geocode($desa)
    {
        $result = Http::get("https://us1.locationiq.com/v1/search?key=pk.1e92a9b4535e5f6d479128da69367c8b&q=" . $desa . ",BALI&format=json&tag=shop");

        $data = json_decode($result->body(), true);

        if (!$result) {
            return [
                'status' => false,
                'msg' => 'Failed to fetch data from LocationIQ API.'
            ];
        } else {
            return [
                'status' => true,
                'data' => $data
            ];
        }
    }
}
