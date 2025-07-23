<?php

namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class CartModel extends Model
{
    protected $table = 'cart';
    protected $primaryKey = 'id_cart';
    public $timestamps = false;
    protected $guarded = ['id_cart'];

    public function user(){
        return $this->belongsTo(User::class, 'id_pengguna','id_pengguna');
    }
    public function layanan(){
        return $this->belongsTo(LayananModel::class,'id_layanan','id_layanan');
    }

}
