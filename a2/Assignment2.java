import java.sql.*;
import java.util.Date;
import java.util.Arrays;
import java.util.List;

public class Assignment2 {

   // A connection to the database
   Connection connection;

   // Can use if you wish: seat letters
   List<String> seatLetters = Arrays.asList("A", "B", "C", "D", "E", "F");

   Assignment2() throws SQLException {
      try {
         Class.forName("org.postgresql.Driver");
      } catch (ClassNotFoundException e) {
         e.printStackTrace();
      }
   }

  /**
   * Connects and sets the search path.
   *
   * Establishes a connection to be used for this session, assigning it to
   * the instance variable 'connection'.  In addition, sets the search
   * path to 'air_travel, public'.
   *
   * @param  url       the url for the database
   * @param  username  the username to connect to the database
   * @param  password  the password to connect to the database
   * @return           true if connecting is successful, false otherwise
   */
   public boolean connectDB(String URL, String username, String password) {
      // Implement this method!
      try {
        connection = DriverManager.getConnection(URL, username, password);
        connection.prepareStatement("SET search_path TO air_travel, public;").executeUpdate();
      } catch (SQLException se) {
        return false;
      }
      //System.out.println("Connection established!");
      return true;
   }

  /**
   * Closes the database connection.
   *
   * @return true if the closing was successful, false otherwise
   */
   public boolean disconnectDB() {
      // Implement this method!
      if (connection != null){
        try{
            connection.close();
        } catch (SQLException se) {
            return false;
        }
        //System.out.println("Connection disconnected!");
        return true;
      }
      return false;
   }
   
   /* ======================= Airline-related methods ======================= */

   /**
    * Attempts to book a flight for a passenger in a particular seat class. 
    * Does so by inserting a row into the Booking table.
    *
    * Read handout for information on how seats are booked.
    * Returns false if seat can't be booked, or if passenger or flight cannot be found.
    *
    * 
    * @param  passID     id of the passenger
    * @param  flightID   id of the flight
    * @param  seatClass  the class of the seat (economy, business, or first) 
    * @return            true if the booking was successful, false otherwise. 
    */
   public boolean bookSeat(int passID, int flightID, String seatClass) {
      // Implement this method!
      getPrice(flightID, seatClass);


      return false;
   }

   /**
    * Attempts to upgrade overbooked economy passengers to business class
    * or first class (in that order until each seat class is filled).
    * Does so by altering the database records for the bookings such that the
    * seat and seat_class are updated if an upgrade can be processed.
    *
    * Upgrades should happen in order of earliest booking timestamp first.
    *
    * If economy passengers left over without a seat (i.e. more than 10 overbooked passengers or not enough higher class seats), 
    * remove their bookings from the database.
    * 
    * @param  flightID  The flight to upgrade passengers in.
    * @return           the number of passengers upgraded, or -1 if an error occured.
    */
   public int upgrade(int flightID) {
      // Implement this method!
      return -1;
   }


   /* ----------------------- Helper functions below  ------------------------- */

    // A helpful function for adding a timestamp to new bookings.
    // Example of setting a timestamp in a PreparedStatement:
    // ps.setTimestamp(1, getCurrentTimeStamp());

    /**
    * Returns a SQL Timestamp object of the current time.
    * 
    * @return           Timestamp of current time.
    */
   private java.sql.Timestamp getCurrentTimeStamp() {
      java.util.Date now = new java.util.Date();
      return new java.sql.Timestamp(now.getTime());
   }

   // Add more helper functions below if desired.
   private int getBookingID() {
      PreparedStatement pStatement;
      ResultSet rs;
      String queryString;
      int BookingID = -1;
      try {
        queryString = "SELECT MAX(id) as max_id FROM Booking";
        pStatement = connection.prepareStatement(queryString);
        rs = pStatement.executeQuery();
        while (rs.next()) {
            BookingID = rs.getInt("max_id") + 1;
            System.out.println("New BookingID is: " + BookingID);
        }
        return BookingID;
      } catch (SQLException se) {
        System.err.println("SQL Exception." + "<Message>: " + se.getMessage());
      }
      return -1;
   }

   private int getPrice(int flightID, String seatClass) {
      PreparedStatement pStatement;
      ResultSet rs;
      String queryString;
      int price = -1;

      try {
        queryString = "SELECT "+seatClass+ " AS book_price FROM price WHERE flight_id=?;";
        pStatement = connection.prepareStatement(queryString);
        pStatement.setString(1, seatClass);
        //pStatement.setString(2, Integer.toString(flightID));
        rs = pStatement.executeQuery();
        if (rs.next()) {
            price = rs.getInt("ticket");
            System.out.println("Price is: " + price);
        }
        return price;
      } catch (SQLException se) {
        System.err.println("SQL Exception." + "<Message>: " + se.getMessage());
      }
      return -1;
   }
  
  /* ----------------------- Main method below  ------------------------- */

   public static void main(String[] args) {
      // You can put testing code in here. It will not affect our autotester.
      System.out.println("Running the code!");
      int BookingID;
      int price;
      String seatClass = "first";
      try {
        Assignment2 a2 = new Assignment2();
        a2.connectDB("jdbc:postgresql://localhost:5432/csc343h-meitian1", "meitian1", "");
        BookingID = a2.getBookingID();
        a2.bookSeat(1, 1, seatClass);
        a2.disconnectDB();
      } catch (SQLException se) {
        System.out.println("failed to establish connection in main");
      }

      try {
        Assignment2 a2 = new Assignment2();
        a2.disconnectDB();
      } catch (SQLException se) {
        System.out.println("failed to disconnect connection in main");
      }
   }

}
