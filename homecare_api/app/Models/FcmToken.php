<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FcmToken extends Model
{
    protected $table = 'fcm_tokens';

    protected $fillable = [
        'user_id',
        'fcm_token',
        'device_id',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id', 'id_pengguna');
    }
}
