package com.applicaster.xray.example.sinks;

import android.util.Log;

import androidx.annotation.NonNull;

import com.applicaster.xray.core.Event;
import com.applicaster.xray.core.ISink;

import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import retrofit2.http.Body;
import retrofit2.http.POST;

public class ElasticSink implements ISink {

    // todo: pass from outside
    private static final String BASE_URL = "http://10.0.0.23:9200/";
    private final IElastic api;

    private static final String TAG = "ElasticSink";

    private interface IElastic {
        @POST("/xray/events") //todo: add some path parts to args (app, version)
        Call<Void> send(@Body Event event);
    }

    public ElasticSink() {
        OkHttpClient.Builder client = new OkHttpClient.Builder();
        client.readTimeout(60, TimeUnit.SECONDS);
        client.writeTimeout(60, TimeUnit.SECONDS);
        client.connectTimeout(60, TimeUnit.SECONDS);
        Executor executor = Executors.newSingleThreadExecutor();
        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl(BASE_URL)
                .client(client.build())
                .addConverterFactory(GsonConverterFactory.create())
                .callbackExecutor(executor) // separate executor
                .build();
        api = retrofit.create(IElastic.class);
    }

    @Override
    public void log(@NonNull Event event) {
        api.send(event).enqueue(new Callback<Void>() {
            @Override
            public void onResponse(@NonNull Call<Void> call, @NonNull Response<Void> response) {
                // cant log to xray to avoid loop in current filter configuration
                if(response.isSuccessful())
                    Log.d(TAG, "Sent");
                else
                    Log.e(TAG, "Send failed: " + response.message());
            }

            @Override
            public void onFailure(@NonNull Call<Void> call, @NonNull Throwable t) {
                // cant log to xray to avoid loop in current filter configuration
                Log.e(TAG, "Send failed: " + t.getMessage(), t);
            }
        });
    }
}
