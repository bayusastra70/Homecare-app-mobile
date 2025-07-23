<?php

namespace App\Http\Controllers;

use App\Models\InvoiceModel;
use App\Models\LayananModel;
use App\Models\ObatLayananModel;
use App\Models\PesananModel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use PhpParser\Node\Expr\FuncCall;

class PesananController extends Controller
{
    private function getBiayaObat($idLayanan, $jumlahLayanan)
{
    $obatLayanan = DB::table('obat_layanan')
        ->join('obat', 'obat_layanan.id_obat', '=', 'obat.id_obat')
        ->where('obat_layanan.id_layanan', $idLayanan)
        ->select('obat.harga')
        ->get();

    $biayaObat = 0;
    
    foreach ($obatLayanan as $obat) {
        $biayaObat += $obat->harga * $jumlahLayanan;
    }

    return $biayaObat;
}


public function createOrder(Request $request)
{
    try {
        $request->validate([
            'id_layanan' => 'required',
            'nama_layanan' => 'required',
            'jumlah' => 'required|integer|min:1',
            'harga' => 'required|numeric|min:0'
        ], [
            'id_layanan.required' => 'ID layanan wajib diisi',
            'nama_layanan.required' => 'Nama layanan wajib diisi',
            'jumlah.required' => 'Jumlah wajib diisi',
            'harga.required' => 'Harga wajib diisi',
        ]);

        // Ambil id layanan dan jumlah dari request
        $idLayanan = $request->id_layanan;
        $jumlah = $request->jumlah;

        // Hitung biaya obat berdasarkan layanan
        $biayaObat = $this->getBiayaObat($idLayanan, $jumlah);
        $biayaLayanan = $request->harga * $jumlah;

        // Buat invoice terlebih dahulu
        $invoice = InvoiceModel::create([
            'id_pengguna' => auth()->id(),
            'id_layanan' => $idLayanan, // disimpan di tabel invoice
            'status' => 'pending',
            'biaya_lain' => 0,
            'biaya_obat' => $biayaObat,
            'total' => $biayaLayanan + $biayaObat,
        ]);

        // Buat pesanan berdasarkan invoice
        $order = PesananModel::create([
            'id_invoice' => $invoice->id_invoice,
            'id_layanan' => $idLayanan,
            'nama_layanan' => $request->nama_layanan,
            'jumlah' => $jumlah,
            'harga' => $request->harga,
            'bukti_pembayaran' => null,
        ]);

        return response()->json([
            'code' => 201,
            'status' => 'CREATED',
            'data' => [
                'invoice' => $invoice,
                'pesanan' => $order
            ]
        ], 201);

    } catch (ValidationException $e) {
        return response()->json([
            'code' => 400,
            'status' => 'BAD_REQUEST',
            'errors' => $e->errors()
        ], 400);
    } catch (\Exception $e) {
        return response()->json([
            'code' => 500,
            'status' => 'INTERNAL_SERVER_ERROR',
            'message' => 'Terjadi kesalahan saat membuat pesanan dan invoice',
            'error' => $e->getMessage()
        ], 500);
    }
}
    


    public function getAllOrder()
{
    try {
        $orders = PesananModel::with('invoice') 
            ->whereHas('invoice', function ($query) {
                $query->where('id_pengguna', auth()->id());
            })
            ->get();

        if ($orders->isEmpty()) {
            return response()->json([
                'code' => 404,
                'status' => 'NOT_FOUND',
                'message' => 'Data pesanan tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'code' => 200,
            'status' => 'OK',
            'data' => $orders
        ], 200);

    } catch (ValidationException $e) {
        return response()->json([
            'code' => 400,
            'status' => 'BAD_REQUEST',
            'errors' => $e->errors()
        ], 400);
    } catch (\Exception $e) {
        return response()->json([
            'code' => 500,
            'status' => 'INTERNAL_SERVER_ERROR',
            'message' => 'Terjadi kesalahan saat mengambil pesanan',
            'error' => $e->getMessage()
        ], 500);
    }
}

    public function getDetailOrder($id_invoice){
        try {
            $orders = PesananModel::where('id_invoice', $id_invoice)->with('invoice')->get();
    
            if ($orders->isEmpty()) {
                return response()->json([
                    'code' => 404,
                    'status' => 'NOT_FOUND',
                    'message' => 'Data pesanan tidak ditemukan'
                ], 404);
            }
    
            return response()->json([
                'code' => 200,
                'status' => 'OK',
                'data' => $orders
            ], 200);
        } catch (ValidationException $e) {
            return response()->json([
                'code' => 400,
                'status' => 'BAD_REQUEST',
                'errors' => $e->errors()
            ], 400);
        }
    }

    public function cancelOrder($id_invoice){
        try {
    
            $invoice = InvoiceModel::find($id_invoice);
    
            if (!$invoice) {
                return response()->json([
                    'code' => 404,
                    'status' => 'NOT_FOUND',
                    'message' => 'Data invoice tidak ditemukan'
                ], 404);
            }
    
            // Delete all related orders
            $orders = PesananModel::where('id_invoice', $id_invoice)->get();
            if ($orders->isEmpty()) {
                return response()->json([
                    'code' => 404,
                    'status' => 'NOT_FOUND',
                    'message' => 'Data pesanan tidak ditemukan'
                ], 404);
            }
    
            foreach ($orders as $order) {
                $order->delete();
            }
    
            // Delete the invoice
            $invoice->delete();
    
            return response()->json([
                'code' => 200,
                'status' => 'OK',
                'message' => 'Data pesanan dan invoice berhasil dibatalkan'
            ], 200);
        } catch (\Exception $e) {
    
            return response()->json([
                'code' => 500,
                'status' => 'INTERNAL_SERVER_ERROR',
                'message' => 'Terjadi kesalahan saat membatalkan pesanan dan invoice',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
