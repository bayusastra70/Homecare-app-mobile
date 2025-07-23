<?php

namespace App\Http\Controllers;

use App\Models\CartModel;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class CartController extends Controller
{
    public function createCart(Request $request){
        try {
            $request->validate([
                'id_layanan'=>'required',
                'jumlah'=>'required'
            ],[
                'id_layanan.required'=>'id layanan wajib di isi',
                'jumlah.required'=>'jumlah wajib di isi'
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'code' => 400,
                'status' => 'BAD_REQUEST',
                'errors' => $e->errors()
            ], 400);
        }

        $cart = CartModel::create([
            'id_pengguna' => auth()->id(),
            'id_layanan' => $request->id_layanan,
            'jumlah' => $request->jumlah,
        ]);

        return response()->json([
            'code' => 201,
            'status' => 'CREATED',
            'data' => $cart
        ], 201);
    }

    public function getAllCart(){
    try {
            // Fetch cart data with relationships
            $cart = CartModel::where('id_pengguna', auth()->id())
                ->with(['user', 'layanan'])
                ->get();
    
            // Check if cart is empty
            if ($cart->isEmpty()) {
                return response()->json([
                    'code' => 404,
                    'status' => 'NOT_FOUND',
                    'message' => 'Tidak ada data yang ditemukan'
                ], 404);
            }
    
            // Return success response
            return response()->json([
                'code' => 200,
                'status' => 'OK',
                'data' => $cart
            ], 200);
        } catch (ValidationException $e) {
            // Handle validation errors
            return response()->json([
                'code' => 400,
                'status' => 'BAD_REQUEST',
                'errors' => $e->errors()
            ], 400);
        }
    }

    public function editCart(Request $request, $id){
        try {
            $request->validate([
                'id_layanan' => 'required',
                'jumlah' => 'required'
            ], [
                'id_layanan.required' => 'ID layanan wajib diisi',
                'jumlah.required' => 'Jumlah wajib diisi',
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'code' => 400,
                'status' => 'BAD_REQUEST',
                'errors' => $e->errors()
            ], 400);
        }

        $cart = CartModel::with(['user', 'layanan'])->find($id);

        if (!$cart) {
            return response()->json([
                'code' => 404,
                'status' => 'NOT_FOUND',
                'message' => 'Data keranjang tidak ditemukan'
            ], 404);
        }

        $cart->update([
            'id_layanan' => $request->id_layanan,
            'jumlah' => $request->jumlah,
        ]);

        // Return success response
        return response()->json([
            'code' => 200,
            'status' => 'OK',
            'data' => $cart
        ], 200);
    }

    public function deleteCart($id)
{
    try {
        $cart = CartModel::find($id);

        if (!$cart) {
            return response()->json([
                'code' => 404,
                'status' => 'NOT_FOUND',
                'message' => 'Data keranjang tidak ditemukan'
            ], 404);
        }

        $cart->delete();
        return response()->json([
            'code' => 200,
            'status' => 'OK',
            'message' => 'Data keranjang berhasil dihapus'
        ], 200);
    } catch (ValidationException $e) {
        return response()->json([
            'code' => 400,
            'status' => 'BAD_REQUEST',
            'errors' => $e->errors()
        ], 400);
    }
}
}
