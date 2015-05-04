package ca.cloudbean.cloudorder.entity;

import ca.cloudbean.cloudorder.EMF;

import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiMethod;
import com.google.api.server.spi.config.ApiNamespace;
import com.google.api.server.spi.response.CollectionResponse;
import com.google.appengine.api.datastore.Cursor;
import com.google.appengine.datanucleus.query.JPACursorHelper;

import java.util.List;

import javax.annotation.Nullable;
import javax.inject.Named;
import javax.persistence.EntityExistsException;
import javax.persistence.EntityNotFoundException;
import javax.persistence.EntityManager;
import javax.persistence.Query;

@Api(name = "restaurantendpoint", namespace = @ApiNamespace(ownerDomain = "cloudbean.ca", ownerName = "cloudbean.ca", packagePath = "cloudorder.entity"))
public class RestaurantEndpoint {

	/**
	 * This method lists all the entities inserted in datastore.
	 * It uses HTTP GET method and paging support.
	 *
	 * @return A CollectionResponse class containing the list of all entities
	 * persisted and a cursor to the next page.
	 */
	@SuppressWarnings({ "unchecked", "unused" })
	@ApiMethod(name = "listRestaurant")
	public CollectionResponse<Restaurant> listRestaurant(
			@Nullable @Named("cursor") String cursorString,
			@Nullable @Named("limit") Integer limit) {

		EntityManager mgr = null;
		Cursor cursor = null;
		List<Restaurant> execute = null;

		try {
			mgr = getEntityManager();
			Query query = mgr
					.createQuery("select from Restaurant as Restaurant");
			if (cursorString != null && cursorString != "") {
				cursor = Cursor.fromWebSafeString(cursorString);
				query.setHint(JPACursorHelper.CURSOR_HINT, cursor);
			}

			if (limit != null) {
				query.setFirstResult(0);
				query.setMaxResults(limit);
			}

			execute = (List<Restaurant>) query.getResultList();
			cursor = JPACursorHelper.getCursor(execute);
			if (cursor != null)
				cursorString = cursor.toWebSafeString();

			// Tight loop for fetching all entities from datastore and accomodate
			// for lazy fetch.
			for (Restaurant obj : execute)
				;
		} finally {
			mgr.close();
		}

		return CollectionResponse.<Restaurant> builder().setItems(execute)
				.setNextPageToken(cursorString).build();
	}

	/**
	 * This method gets the entity having primary key id. It uses HTTP GET method.
	 *
	 * @param id the primary key of the java bean.
	 * @return The entity with primary key id.
	 */
	@ApiMethod(name = "getRestaurant")
	public Restaurant getRestaurant(@Named("id") String id) {
		EntityManager mgr = getEntityManager();
		Restaurant restaurant = null;
		try {
			restaurant = mgr.find(Restaurant.class, id);
		} finally {
			mgr.close();
		}
		return restaurant;
	}

	/**
	 * This inserts a new entity into App Engine datastore. If the entity already
	 * exists in the datastore, an exception is thrown.
	 * It uses HTTP POST method.
	 *
	 * @param restaurant the entity to be inserted.
	 * @return The inserted entity.
	 */
	@ApiMethod(name = "insertRestaurant")
	public Restaurant insertRestaurant(Restaurant restaurant) {
		EntityManager mgr = getEntityManager();
		try {
			restaurant.setCreateTimestamp(new java.util.Date().getTime());
			mgr.persist(restaurant);
		} finally {
			mgr.close();
		}
		return restaurant;
	}

	/**
	 * This method is used for updating an existing entity. If the entity does not
	 * exist in the datastore, an exception is thrown.
	 * It uses HTTP PUT method.
	 *
	 * @param restaurant the entity to be updated.
	 * @return The updated entity.
	 */
	@ApiMethod(name = "updateRestaurant")
	public Restaurant updateRestaurant(Restaurant restaurant) {
		EntityManager mgr = getEntityManager();
		try {
			if (!containsRestaurant(restaurant)) {
				throw new EntityNotFoundException("Object does not exist");
			}
			mgr.persist(restaurant);
		} finally {
			mgr.close();
		}
		return restaurant;
	}

	/**
	 * This method removes the entity with primary key id.
	 * It uses HTTP DELETE method.
	 *
	 * @param id the primary key of the entity to be deleted.
	 */
	@ApiMethod(name = "removeRestaurant")
	public void removeRestaurant(@Named("id") String id) {
		EntityManager mgr = getEntityManager();
		try {
			Restaurant restaurant = mgr.find(Restaurant.class, id);
			mgr.remove(restaurant);
		} finally {
			mgr.close();
		}
	}

	private boolean containsRestaurant(Restaurant restaurant) {
		EntityManager mgr = getEntityManager();
		boolean contains = true;
		try {
			Restaurant item = mgr.find(Restaurant.class,
					restaurant.getRestaurantId());
			if (item == null) {
				contains = false;
			}
		} finally {
			mgr.close();
		}
		return contains;
	}

	private static EntityManager getEntityManager() {
		return EMF.get().createEntityManager();
	}

}
