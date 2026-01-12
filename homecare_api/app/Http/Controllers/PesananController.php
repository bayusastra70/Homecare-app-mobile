<?php

namespace App\Http\Controllers;

use App\Models\InvoiceModel;
use App\Models\LayananModel;
use App\Models\FcmToken;
use App\Models\ObatLayananModel;
use App\Models\PesananModel;
use App\Models\RiwayatModel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use App\Helpers\FirebaseService;
use Illuminate\Support\Facades\Log;




class PesananController extends Controller
{
    protected $firebase;

    public function __construct(FirebaseService $firebase)
    {
    $this->firebase = $firebase;
    }
    
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
            ]);

            $idLayanan = $request->id_layanan;
            $jumlah = $request->jumlah;

            $biayaObat = $this->getBiayaObat($idLayanan, $jumlah);
            $biayaLayanan = $request->harga * $jumlah;

            $invoice = InvoiceModel::create([
                'id_pengguna' => auth()->id(),
                'id_layanan' => $idLayanan,
                'status' => 'pending',
                'biaya_lain' => 0,
                'biaya_obat' => $biayaObat,
                'total' => $biayaLayanan + $biayaObat,
            ]);

            $order = PesananModel::create([
                'id_invoice' => $invoice->id_invoice,
                'id_layanan' => $idLayanan,
                'nama_layanan' => $request->nama_layanan,
                'jumlah' => $jumlah,
                'harga' => $request->harga,
                'bukti_pembayaran' => null,
            ]);

            /**
             * === Kirim Notifikasi ke User ===
             */
            $tokens = FcmToken::where('user_id', auth()->id())
            ->pluck('fcm_token')
            ->toArray();
            if (!empty($tokens)) {
                $title = "Pesanan #{$order->id_invoice} berhasil dibuat";
                $body  = "Tunggu pesanan diterima yaa";

                // kirim multicast
                $this->firebase->sendToDevices(
                    $tokens,
                    $title,
                    $body,
                    ['status' => 'order_created', 'invoice_id' => $invoice->id_invoice]
                );
            }

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
    


public function updateOrderToPayment($id_invoice)
{
    $invoice = InvoiceModel::findOrFail($id_invoice);
    $invoice->status = 'paying';
    $invoice->save();

    // Ambil FCM token user
    $tokens = FcmToken::where('user_id', $invoice->id_pengguna)
        ->pluck('fcm_token')
        ->filter()
        ->unique()
        ->values()
        ->toArray();

    if (!empty($tokens)) {
        $title = "Pesanan #{$invoice->id_invoice} menunggu pembayaran";
        $body  = "Segera lakukan pembayaran sebesar Rp " . number_format($invoice->total, 0, ',', '.');

        // Tambahkan payload notification supaya Android menampilkan tray
        $messageData = [
            'status'     => 'paying',
            'invoice_id' => $invoice->id_invoice,
            'title'      => $title,
            'body'       => $body,
            'unique'     => now()->timestamp,
        ];

        $this->firebase->sendToDevices($tokens, $title, $body, $messageData);
    }

    return response()->json([
        'success'      => true,
        'message'      => 'Status pesanan diubah menjadi payment dan notifikasi sudah dikirim.',
        'tokens_count' => count($tokens)
    ]);
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
    
    public function uploadBukti(Request $request, $idPesanan)
{
    try {

        // validasi file
        $request->validate([
            'bukti_pembayaran' => 'required|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        // cek pesanan exist
        $pesanan = PesananModel::find($idPesanan);

        if (!$pesanan) {
            return response()->json([
                'error' => 'Pesanan tidak ditemukan'
            ], 404);
        }

        $file = $request->file('bukti_pembayaran');

        if (!$file) {
            return response()->json([
                'error' => 'File tidak diterima server'
            ], 400);
        }

        $folder = $_SERVER['DOCUMENT_ROOT'] . '/assets/img/bukti-pembayaran';


        // generate filename
        $filename = md5(uniqid()) . '.' . $file->getClientOriginalExtension();

        // simpan file langsung ke public_html/storage/bukti_pembayaran
        $file->move($folder, $filename);

        // update pesanan
        $pesanan->update([
            'bukti_pembayaran' => $filename,
        ]);

        return response()->json([
            'message' => 'Upload berhasil',
            'filename' => $filename,
            'url' => url('/assets/img/bukti-pembayaran/' . $filename)
        ], 200);

    } catch (\Exception $e) {

        return response()->json([
            'error' => $e->getMessage(),
            'line' => $e->getLine(),
            'file' => $e->getFile(),
        ], 500);
    }
} 

public function getRiwayatPesanan(Request $request)
{
    $user = $request->user();

    if (!$user) {
        return response()->json([
            'success' => false,
            'message' => 'User tidak ditemukan / token invalid'
        ], 401);
    }

    $userId = (int) ($user->id_pengguna ?? $user->id);

    // JOIN riwayat + invoice (ambil status & appointment_datetime)
    $riwayat = RiwayatModel::where('riwayat.id_pengguna', $userId)
        ->join('invoice', 'riwayat.id_invoice', '=', 'invoice.id_invoice')
        ->orderBy('riwayat.id_riwayat', 'DESC')
        ->get([
            'riwayat.id_riwayat',
            'riwayat.id_invoice',
            'riwayat.kondisi',
            'riwayat.riwayat_penyakit',
            'riwayat.alergi',

            // ambil data tambahan dari invoice
            'invoice.status',
            'invoice.appointment_datetime'
        ]);

    return response()->json([
        'success' => true,
        'data' => $riwayat
    ]);
}


}
