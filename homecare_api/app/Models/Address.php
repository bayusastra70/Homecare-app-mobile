<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Address extends Model
{
    protected $table = 'alamat_pengguna';
    protected $primaryKey = 'id_alamat';

    public $timestamps = false;

    protected $guarded = ['id_alamat'];

    /**
     * Relasi ke tabel desa
     */
    public function desa()
    {
        return $this->belongsTo(Desa::class, 'id_desa', 'id_desa');
    }

    /**
     * Relasi ke tabel kecamatan melalui desa
     */
    public function kecamatan()
    {
        return $this->hasOneThrough(
            Kecamatan::class,
            Desa::class,
            'id_desa', // Foreign key di tabel desa
            'id_kecamatan', // Foreign key di tabel kecamatan
            'id_desa', // Local key di tabel alamat_pengguna
            'id_kecamatan' // Local key di tabel desa
        );
    }

    /**
     * Relasi ke tabel kabupaten melalui kecamatan
     */
    public function kabupaten()
    {
        return $this->hasOneThrough(
            Kabupaten::class,
            Kecamatan::class,
            'id_kecamatan', // Foreign key di tabel kecamatan
            'id_kabupaten', // Foreign key di tabel kabupaten
            'id_kecamatan', // Local key di tabel alamat_pengguna
            'id_kabupaten' // Local key di tabel kecamatan
        );
    }
}
