<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Kabupaten extends Model
{
    protected $table = 'dd_kabupaten';
    protected $primaryKey = 'id_kabupaten';

    public $timestamps = false;

    protected $guarded = ['id_kabupaten'];
}
