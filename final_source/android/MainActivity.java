/*  Android Application for I've Got Heart
    ECE 540 Final Project - Winter 2019
    By: Ryan Bentz
 */

package ece.ryan.myapplication;

import android.graphics.drawable.AnimationDrawable;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import com.google.firebase.database.ValueEventListener;


public class MainActivity extends AppCompatActivity {

    private static String TAG = "Main";
    private static int TRUE = 1;

    private DatabaseReference mDatabaseReference;
    ImageView mHeartImage;
    AnimationDrawable mBeatAnimation;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // set up database reference
        mDatabaseReference = FirebaseDatabase.getInstance().getReference();

        setupValueEventListener();

        setupBeatAnimation();
    }

    /** Initialize Firebase event listeners to be notified of when data changes in the database.
     *
     */
    private void setupValueEventListener() {
        mDatabaseReference.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                try {
                    int val;
                    // get current BPM
                    val = dataSnapshot.child("currentBPM").getValue(int.class);
                    updateTextView(R.id.currentBPM, val);

                    val = dataSnapshot.child("maxBPM").getValue(int.class);
                    updateTextView(R.id.maxBPM, val);

                    val = dataSnapshot.child("minBPM").getValue(int.class);
                    updateTextView(R.id.minBPM, val);

                    val = dataSnapshot.child("realBeat").getValue(int.class);
                    showHeartBeat(val);

                } catch (NullPointerException npe){
                    Log.d(TAG, "No data found.");
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {

            }
        });
    }

    /** Set up the drawable animation to be linked to the heart ImageView
     *
     */
    private void setupBeatAnimation ()
    {
        // Load the ImageView that will host the animation and
        // set its background to the AnimationDrawable resource
        mHeartImage = (ImageView) findViewById(R.id.heartImage);
        //mHeartImage.setBackgroundResource(R.drawable.animation);
        mHeartImage.setImageResource(R.drawable.animation);
        // Get the background that is compiled to an AnimationDrawable object
        mBeatAnimation = (AnimationDrawable) mHeartImage.getDrawable();
    }

    /** Handle the process of starting the Beat animation if ESP8266 sets the flag to true
     *
     * @param val
     */
    private void showHeartBeat(int val) {
        // If we sense the ESP8266 changed the beat flag value to TRUE, do the beat animation
        if (val == TRUE)
        {
            // start the beat animation
            mBeatAnimation.stop();      // have to call stop to "reset" the animation
            mBeatAnimation.start();
        }
    }

    private void updateTextView(int id, int val) {
        TextView v = (TextView) findViewById(id);
        v.setText(Integer.toString(val));
    }

}
