<?php

namespace App\Models;

use Laravel\Sanctum\HasApiTokens;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    use HasApiTokens;

    protected $table = 'pengguna';
    protected $primaryKey = 'id_pengguna';

    public $timestamps = false;

    /**
     * Specify the attributes that can be mass-assigned.
     */
    protected $guarded = ['id_pengguna'];

    /**
     * Override to disable Laravel's default password hashing.
     */
    public function validateForPassportPasswordGrant($password)
    {
        return $this->password === sha1($password);
    }

    public function address()
    {
        return $this->belongsTo(Address::class, 'id_alamat', 'id_alamat');
    }
}
