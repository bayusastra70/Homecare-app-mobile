<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Service extends Model
{
    protected $table = 'layanan';
    protected $primaryKey = 'id_layanan';

    public $timestamps = false;
}
