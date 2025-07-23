<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\PesananController;
use App\Models\Service;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use App\Http\Controllers\RegionController;
use App\Http\Controllers\LayananController;


Route::prefix('v1')->group(function () {
    Route::prefix('public')->group(function () {
        Route::prefix('auth')->group(function () {
            Route::post('/login', [AuthController::class, 'login'])->name('login');
            Route::post('/register', [AuthController::class, 'register'])->name('register');
        });

        // Region routes
        Route::get('/kabupaten', [RegionController::class, 'getKabupaten']);
        Route::get('/kabupaten/{kab_id}/kecamatan', [RegionController::class, 'getKecamatan']);
        Route::get('/kecamatan/{kec_id}/desa', [RegionController::class, 'getDesa']);

        // Layanan route
        Route::get('/layanan', [LayananController::class, 'getAllLayanan']);
    });

    Route::middleware(['auth:sanctum'])->group(function () {
        Route::prefix('private')->group(function () {
           // Auth routes
            Route::prefix('auth')->group(function () {
                Route::post('/refresh-token', [AuthController::class, 'refreshToken']);
                Route::post('/logout', [AuthController::class, 'logout']);
            });

            // Profile routes
            Route::get('/user/profile', [UserController::class, 'profile']);
            Route::put('/user/profile/edit', [UserController::class, 'editProfile']);
            Route::put('/user/profile/address', [UserController::class, 'updateAddress']);
          
            Route::post('/cart', [CartController::class,'createCart']);
            Route::get('/carts', [CartController::class,'getAllCart']);
            Route::put('/cart/{id}/edit', [CartController::class, 'editCart']);
            Route::delete('/cart/{id}', [CartController::class, 'deleteCart']);

            Route::post('/order', [PesananController::class,'createOrder']);
            Route::get('/orders', [PesananController::class,'getAllOrder']);
            Route::get('/order/{id_invoice}', [PesananController::class, 'getDetailOrder']);
            Route::delete('/order/{id_invoice}', [PesananController::class, 'cancelOrder']);
           
        });
    });
});

// route testing
Route::get('/test', function () {
    return response()->json(['message' => 'Hello World!']);
});

Route::get('/services', function () {
    return response()->json(['message' => Service::all()]);
});

Route::get('/php-version', function () {
    return 'PHP Version: ' . phpversion();
});
