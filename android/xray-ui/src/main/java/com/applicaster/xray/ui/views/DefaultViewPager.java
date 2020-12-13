package com.applicaster.xray.ui.views;

import android.content.Context;
import android.util.AttributeSet;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.viewpager.widget.ViewPager;

import com.applicaster.xray.ui.adapters.ViewsPagerAdapter;

public class DefaultViewPager extends ViewPager {

    public DefaultViewPager(@NonNull Context context) {
        super(context);
    }

    public DefaultViewPager(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();
        setAdapter(new ViewsPagerAdapter(this));
    }
}
