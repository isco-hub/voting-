<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        User::firstOrCreate(
            ['email' => 'admin@vote.com'],
            [
                'name' => 'Admin',
                'password' => bcrypt('password'),
                'role' => 'admin',
            ]
        );

        User::firstOrCreate(
            ['email' => 'voter1@vote.com'],
            [
                'name' => 'Voter One',
                'password' => bcrypt('password'),
                'role' => 'voter',
            ]
        );

        User::firstOrCreate(
            ['email' => 'voter2@vote.com'],
            [
                'name' => 'Voter Two',
                'password' => bcrypt('password'),
                'role' => 'voter',
            ]
        );
    }
}
