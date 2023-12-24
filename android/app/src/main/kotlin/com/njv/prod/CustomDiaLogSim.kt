package com.njv.prod

import android.app.Activity
import android.app.Dialog
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.Window
import android.widget.Button
import android.widget.CheckBox
import android.widget.LinearLayout

//class CustomDiaLogSim(a: Activity) : Dialog(a), View.OnClickListener {
//
//    var c: Activity
//    var d: Dialog? = null
//
//    lateinit var llActionSim1: LinearLayout
//    lateinit var llActionSim2: LinearLayout
//
//        var  abc: Abc
//        get() {
//            return abc
//        }
//        set(value) {
//            abc = value
//        }
//
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        requestWindowFeature(Window.FEATURE_NO_TITLE)
//        setContentView(R.layout.custom_dialog_sim)
//        llActionSim1 = findViewById(R.id.llActionSim1)
//        llActionSim2 = findViewById(R.id.llActionSim2)
//
//        llActionSim1.setOnClickListener(this)
//        llActionSim2.setOnClickListener(this)
//    }
//
//    override fun onClick(v: View) {
//        when (v.getId()) {
//            R.id.llActionSim1 -> abc.onClickSim1()
//            R.id.llActionSim2 -> dismiss()
//            else -> {}
//        }
//        dismiss()
//    }
//
//    init {
//        // TODO Auto-generated constructor stub
//        c = a
//    }
//
//    interface Abc {
//        fun onClickSim1()
//    }
//}

class ViewDialog {
    fun showDialog(activity: Activity?, callbackSim1: (() -> Unit), callbackSim2: (() -> Unit), callbackCheckbox: ((Boolean) -> Unit)) {
        val dialog = activity?.let { Dialog(it) }
        dialog?.requestWindowFeature(Window.FEATURE_NO_TITLE)
        dialog?.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        dialog?.setCancelable(false)
        dialog?.setCanceledOnTouchOutside(true);
        dialog?.setContentView(R.layout.custom_dialog_sim)
        val llActionSim1: LinearLayout = dialog?.findViewById(R.id.llActionSim1) as LinearLayout
        val llActionSim2: LinearLayout = dialog?.findViewById(R.id.llActionSim2) as LinearLayout
//        val llCheckBox: LinearLayout = dialog?.findViewById(R.id.llCheckbox_Layout) as LinearLayout
//        val checkBox: CheckBox = dialog?.findViewById(R.id.check_box_dual_sim) as CheckBox
        llActionSim1.setOnClickListener {
            callbackSim1.invoke()
            dialog.dismiss()
        }
        llActionSim2.setOnClickListener {
            callbackSim2.invoke()
            dialog.dismiss()
        }
//        llCheckBox.setOnClickListener {
//            callbackCheckbox.invoke()
//            dialog.dismiss()
//        }
//        checkBox.setOnCheckedChangeListener { buttonView, isChecked ->
//            callbackCheckbox.invoke(isChecked)
//        }
        dialog.show()
    }
}