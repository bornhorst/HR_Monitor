package ece.ryan.myapplication;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

public class DatabaseManager {

    private static final String TAG = "DatabaseManager";

    private DatabaseReference mDatabaseReference;

    public DatabaseManager() {

        mDatabaseReference = FirebaseDatabase.getInstance().getReference();
    }


}
