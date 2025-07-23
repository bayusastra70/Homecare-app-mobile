<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Desa extends Model
{
    protected $table = 'dd_desa';
    protected $primaryKey = 'id_desa';

    public $timestamps = false;

    protected $guarded = ['id_desa'];
}
