<?php

namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class InvoiceModel extends Model
{
    protected $table = 'invoice';
    protected $primaryKey = 'id_invoice';
    public $timestamps = false;
    protected $guarded = ['id_invoice'];
}
