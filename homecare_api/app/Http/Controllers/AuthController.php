<?php

namespace App\Http\Controllers;

use Carbon\Carbon;
use App\Models\User;
use App\Enums\TokenAbility;
use Illuminate\Http\Request;
use Laravel\Sanctum\PersonalAccessToken;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        try {
            $request->validate([
                'email' => 'required|email',
                'password' => 'required'
            ], [
                'email.required' => 'Email wajib di isi.',
                'email.email' => 'Format email tidak valid.',
                'password.required' => 'Password wajib di isi.'
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'code' => 400,
                'status' => 'BAD_REQUEST',
                'errors' => $e->errors()
            ], 400);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !$user->validateForPassportPasswordGrant($request->password)) {
            return response()->json([
                'code' => 400,
                'status' => 'BAD_REQUEST',
                'errors' => [
                    'email' => ['Email atau password salah.']
                ]
            ], 400);
        }

        $accessToken = $user->createToken('access_token', [TokenAbility::ACCESS_API->value], Carbon::now()->addMinutes(config('sanctum.ac_expiration')));
        $refreshToken = $user->createToken('refresh_token', [TokenAbility::ISSUE_ACCESS_TOKEN->value], Carbon::now()->addMinutes(config('sanctum.rt_expiration')));

        return response()->json([
            'code' => 200,
            'status' => 'OK',
            'data' => [
                'name' => $user->nama_lengkap,
                'email' => $user->email,
                'access_token' => [
                    'token' => $accessToken->plainTextToken,
                    'expires_at' => $accessToken->accessToken->expires_at,
                ],
                'refresh_token' => [
                    'token' => $refreshToken->plainTextToken,
                    'expires_at' => $refreshToken->accessToken->expires_at,
                ]
            ]
        ]);
    }

    public function register(Request $request)
    {
        try {
            $request->validate([
                'name' => 'required',
                'email' => 'required|email|unique:pengguna,email',
                'password' => 'required|min:8',
                'confirm_password' => 'required|same:password',
                'gender' => 'required|in:1,2', // 1: Laki-laki, 2: Perempuan
            ], [
                'name.required' => 'Nama lengkap wajib di isi.',
                'email.required' => 'Email wajib di isi.',
                'email.email' => 'Format email tidak valid.',
                'email.unique' => 'Email sudah terdaftar.',
                'password.required' => 'Password wajib di isi.',
                'password.min' => 'Password minimal 6 karakter.',
                'confirm_password.required' => 'Konfirmasi password wajib di isi.',
                'confirm_password.same' => 'Konfirmasi password tidak sama dengan password.',
                'gender.required' => 'Jenis kelamin wajib di isi.',
                'gender.in' => 'Jenis kelamin tidak valid.'
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'code' => 400,
                'status' => 'BAD_REQUEST',
                'errors' => $e->errors()
            ], 400);
        }


        $user = User::create([
            'id_alamat' => null,
            'nama_lengkap' => $request->name,
            'no_hp' => '',
            'jenis_kelamin' => $request->gender,
            'email' => $request->email,
            'status' => 'user',
            'password' => sha1($request->password),
            'foto' => 'default.jpg',
            'keterangan' => '',
            'code' => '',
            'active' => 1,
        ]);


        return response()->json([
            'code' => 201,
            'status' => 'CREATED',
            'data' => [
                'name' => $user->nama_lengkap,
                'email' => $user->email,
                'gender' => $user->jenis_kelamin,
            ]
        ], 201);
    }

    public function refreshToken(Request $request)
    {
        $request->validate([
            'refresh_token' => 'required',
        ]);

        // Find token in DB
        $tokenId = explode('|', $request->refresh_token)[0];
        $personalAccessToken = PersonalAccessToken::find($tokenId);

        if (!$personalAccessToken || $personalAccessToken->name !== 'refresh_token') {
            return response()->json([
                'code' => 400,
                'status' => 'BAD_REQUEST',
                'errors' => [
                    'refresh_token' => ['Refresh token tidak valid atau telah kedaluwarsa.']
                ]
            ], 400);
        }

        // Make new access token
        $user = $personalAccessToken->tokenable;
        $newAccessToken = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'code' => 200,
            'status' => 'OK',
            'data' => [
                'access_token' => $newAccessToken,
                'access_token_expired_at' => now()->addMinutes(config('sanctum.expiration'))->toIso8601String(),
            ]
        ]);
    }

    public function logout(Request $request)
    {
        $user = $request->user();

        // Periksa apakah token valid
        $accessToken = $user->tokens->where('id', $user->currentAccessToken()->id)->first();

        if (!$accessToken || $accessToken->revoked) {
            return response()->json([
                'code' => 401,
                'status' => 'UNAUTHORIZED',
                'message' => 'Token tidak valid atau sudah dicabut.'
            ], 401);
        }

        // Periksa jika token adalah refresh token
        if ($request->user()->currentAccessToken()->name === 'refresh_token') {
            return response()->json([
                'code' => 400,
                'status' => 'BAD_REQUEST',
                'message' => 'Tidak dapat logout menggunakan refresh token.'
            ], 400);
        }

        // Hapus token yang sedang digunakan
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'code' => 200,
            'status' => 'OK',
            'message' => 'Berhasil logout.'
        ]);
    }
}
