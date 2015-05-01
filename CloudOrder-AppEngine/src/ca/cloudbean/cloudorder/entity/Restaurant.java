package ca.cloudbean.cloudorder.entity;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import com.google.appengine.api.datastore.Key;

@Entity
public class Restaurant {

	  /*
	   * Primary key for a Restaurant.
	   */
	  @Id
	  @GeneratedValue(strategy = GenerationType.AUTO)
	  private String restaurantId;
	  
	  /*
	   * Restaurant Name
	   */
	  private String name;
	  
	  /*
	   * Timestamp indicating when this device registered with the application.
	   */
	  private long createTimestamp;
	  
	  /*
	   * Restaurant brand
	   */
	  private String brand;

	public String getRestaurantId() {
		return restaurantId;
	}

	public void setRestaurantId(String restaurantId) {
		this.restaurantId = restaurantId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public long getCreateTimestamp() {
		return createTimestamp;
	}

	public void setCreateTimestamp(long createTimestamp) {
		this.createTimestamp = createTimestamp;
	}

	public String getBrand() {
		return brand;
	}

	public void setBrand(String brand) {
		this.brand = brand;
	}
}
