module User exposing
  ( Model
  , create_new_guest_with_empty_cart
  , set_shopping_cart_to
  )

import ShoppingList



type Model
  = User ShoppingCart UserId
  | Guest ShoppingCart

type alias UserId = String
type alias ShoppingCart = ShoppingList.Model



create_new_guest_with_empty_cart : Model
create_new_guest_with_empty_cart = Guest ShoppingList.empty



set_id_to : UserId -> Model -> Model
set_id_to userId user =
  let shoppingCart = get_shopping_cart_from user
  in User shoppingCart userId



set_shopping_cart_to : ShoppingCart -> Model -> Model
set_shopping_cart_to newCart user =
  case user of
    User _ userId -> User newCart userId
    Guest _ -> Guest newCart



get_shopping_cart_from : Model -> ShoppingCart
get_shopping_cart_from user =
  case user of
    Guest shoppingCart -> shoppingCart
    User shoppingCart _ -> shoppingCart


