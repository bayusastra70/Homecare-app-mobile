<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Kecamatan extends Model
{
    protected $table = 'dd_kecamatan';
    protected $primaryKey = 'id_kecamatan';

    public $timestamps = false;

    protected $guarded = ['id_kecamatan'];
}
