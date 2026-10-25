//
//  Supabase.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 24.10.26.
//

import Supabase

let supabase = SupabaseClient(
    supabaseURL: AppConfig.supabaseURL,
    supabaseKey: AppConfig.supabasePublishableKey
)
