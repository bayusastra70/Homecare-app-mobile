<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PesananModel extends Model
{
    protected $table = 'pesanan';
    protected $primaryKey = 'id_pesanan';
    public $timestamps = false;
    protected $guarded = ['id_pesanan'];

    public function invoice()
    {
        return $this->belongsTo(InvoiceModel::class, 'id_invoice', 'id_invoice');
    }

    public function layanan(){
        return $this->belongsTo(LayananModel::class,'id_layanan','id_layanan');
    }

   
}
