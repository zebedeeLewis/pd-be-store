module Api exposing
  ( get_items_where
  )


import Api.Query as Query
import Message



get_items_where : Query.Model -> Cmd (Message.Msg rootModel)
get_items_where query =
  Debug.todo "TODO!!!"
