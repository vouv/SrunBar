//
//  model.swift
//  SrunBar
//
//  Created by vouv on 2021/1/1.
//  Copyright © 2021 Vouv. All rights reserved.
//

import Cocoa

struct RespChallenge {
    let challenge : String
    
    let clientIP : String
    let onlineIP : String
    
    let res : String
    let ecode : Int
    let error : String
    let errorMsg : String
    
    
    let srunVersion : String
    let expire : String
    let st : Int
}

struct RespLogin {
    let checkout_date : String
    let online_ip : String
    let srun_ver : String
    let ServicesIntfServerIP : String
    let ecode : String
    let ServerFlag : String
    let client_ip : String
    let ServicesIntfServerPort : String
    let res : String
    let sysver : String
    let username : String
    let suc_msg : String
    let access_token : String
    let error : String
    let remain_times : String
    let wallet_balance : Float
    let error_msg : String
    let real_name : String
    let remain_flux : String
}


struct RespInfo {
    let ServerFlag : Int64
    let add_time : Int64
    let all_bytes : Int64
    let bytes_in : Int64
    let bytes_out : Int64
    let checkout_date : Int64
    let domain : String
    let error : String
    let group_id : String
    let keepalive_time : Int64
    let online_ip : String
    let products_name : String
    let real_name : String
    let remain_bytes : Int64
    let remain_seconds : Int64
    let sum_bytes : Int64
    let sum_seconds : Int64
    let user_balance : Float64
    let user_charge : Float64
    let user_mac : String
    let user_name : String
    let wallet_balance : Float64
}
