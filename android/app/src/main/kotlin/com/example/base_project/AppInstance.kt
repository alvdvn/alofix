package com.njv.prod


object AppInstance {
   lateinit var preferencesHelper : SharedPreferencesHelper

//   const val baseURL :String = "alonjv-stable.njv.vn"
//   const val postCallLogUrl :String = "https://"+ baseURL + "/api/calllogs"
   const val baseURL :String = "alo.njv.vn"
   const val callLogURL :String = "https://"+ baseURL + "/api/calllogs"

}