<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LayananModel extends Model
{
    protected $table = 'layanan';
    protected $primaryKey = 'id_layanan';
    public $timestamps = false;
    protected $guarded = ['id_layanan'];

    public function invoice(){
        return $this->belongsTo(InvoiceModel::class,'id_invoice','id_invoice');
    }
}
