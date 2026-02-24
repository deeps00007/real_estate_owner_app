package com.realestate.owner.app.v1

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.net.Uri
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.io.File
import com.example.real_estate_owner_app.R
import com.example.real_estate_owner_app.MainActivity

class PropertyWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return PropertyRemoteViewsFactory(this.applicationContext, intent)
    }
}

class PropertyRemoteViewsFactory(
    private val context: Context,
    private val intent: Intent
) : RemoteViewsService.RemoteViewsFactory {

    private var propertyJsonArray: JSONArray = JSONArray()
    private lateinit var widgetData: SharedPreferences

    override fun onCreate() {
        // Initialize SharedPreferences using home_widget's internal mechanism
        widgetData = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        loadData()
    }

    override fun onDataSetChanged() {
        // Triggered when appWidgetManager.notifyAppWidgetViewDataChanged is called
        loadData()
    }

    private fun loadData() {
        val propertiesJsonString = widgetData.getString("properties_list", "[]")
        try {
            propertyJsonArray = JSONArray(propertiesJsonString)
        } catch (e: JSONException) {
            e.printStackTrace()
            propertyJsonArray = JSONArray()
        }
    }

    override fun onDestroy() {
        propertyJsonArray = JSONArray()
    }

    override fun getCount(): Int {
        return propertyJsonArray.length()
    }

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_list_item)
        
        try {
            val propertyObj = propertyJsonArray.getJSONObject(position)
            val title = propertyObj.optString("title", "No Title")
            val location = propertyObj.optString("location", "Unknown Location")
            val price = propertyObj.optString("price", "--")
            val rating = propertyObj.optString("rating", "New")
            val imagePath = propertyObj.optString("imagePath", "")
            val propertyId = propertyObj.optString("id", "")

            views.setTextViewText(R.id.widget_title, title)
            views.setTextViewText(R.id.widget_location, location)
            views.setTextViewText(R.id.widget_price, price)
            views.setTextViewText(R.id.widget_rating, "⭐ $rating")

            // Handle Image loading
            if (imagePath.isNotEmpty()) {
                val imgFile = File(imagePath)
                if (imgFile.exists()) {
                    val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
                    BitmapFactory.decodeFile(imgFile.absolutePath, options)
                    
                    val reqWidth = 300
                    val reqHeight = 300
                    var inSampleSize = 1
                    if (options.outHeight > reqHeight || options.outWidth > reqWidth) {
                        val halfHeight: Int = options.outHeight / 2
                        val halfWidth: Int = options.outWidth / 2
                        while (halfHeight / inSampleSize >= reqHeight && halfWidth / inSampleSize >= reqWidth) {
                            inSampleSize *= 2
                        }
                    }
                    
                    val finalOptions = BitmapFactory.Options().apply { this.inSampleSize = inSampleSize }
                    val bitmap = BitmapFactory.decodeFile(imgFile.absolutePath, finalOptions)
                    views.setImageViewBitmap(R.id.widget_image, bitmap)
                } else {
                     views.setImageViewBitmap(R.id.widget_image, null)
                }
            } else {
                views.setImageViewBitmap(R.id.widget_image, null)
            }

            // Set up fillInIntent for View Button
            val viewIntent = Intent().apply {
                data = Uri.parse("realestate://property/$propertyId?action=view")
            }
            views.setOnClickFillInIntent(R.id.btn_view, viewIntent)

            // Set up fillInIntent for Chat Button
            val chatIntent = Intent().apply {
                data = Uri.parse("realestate://property/$propertyId?action=chat")
            }
            views.setOnClickFillInIntent(R.id.btn_chat, chatIntent)

             // Make entire row click open details
            val rowIntent = Intent().apply {
                data = Uri.parse("realestate://property/$propertyId?action=view")
            }
            views.setOnClickFillInIntent(R.id.widget_root, rowIntent)

        } catch (e: JSONException) {
            e.printStackTrace()
        }

        return views
    }

    override fun getLoadingView(): RemoteViews? {
        // Return null to use default loading view
        return null
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun hasStableIds(): Boolean {
        return true
    }
}
