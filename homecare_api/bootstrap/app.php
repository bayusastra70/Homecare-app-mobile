<?php

use Illuminate\Http\Request;
use App\Http\Middleware\InvalidToken;
use Illuminate\Foundation\Application;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__ . '/../routes/web.php',
        api: __DIR__ . '/../routes/api.php',
        commands: __DIR__ . '/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        //
    })
    ->withExceptions(function (Exceptions $exceptions) {
        $exceptions->stopIgnoring(AuthenticationException::class);

        $exceptions->render(function (AuthenticationException $exception, Request $request) {

            return response()->json([
                'code' => '401',
                'status' => 'UNAUTHORIZED',
                'message' => 'Token tidak ditemukan atau token tidak valid.'
            ], 401);
        });
    })->create();
