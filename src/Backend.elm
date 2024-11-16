module Backend exposing (..)

import Effect.Command as Command exposing (BackendOnly, Command)
import Effect.Lamdera exposing (ClientId, SessionId)
import Effect.Subscription as Subscriptions
import Id exposing (Id, UserId)
import Lamdera
import List.Extra
import List.Nonempty exposing (Nonempty(..))
import SeqDict
import Types exposing (..)
import User


app :
    { init : ( BackendModel, Cmd BackendMsg )
    , update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
    , updateFromFrontend : String -> String -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
    , subscriptions : BackendModel -> Sub BackendMsg
    }
app =
    Effect.Lamdera.backend Lamdera.broadcast Lamdera.sendToFrontend app_


app_ :
    { init : ( BackendModel, Command BackendOnly ToFrontend BackendMsg )
    , update : BackendMsg -> BackendModel -> ( BackendModel, Command BackendOnly ToFrontend BackendMsg )
    , updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Command BackendOnly ToFrontend BackendMsg )
    , subscriptions : BackendModel -> Subscriptions.Subscription BackendOnly BackendMsg
    }
app_ =
    { init = init
    , update = update
    , updateFromFrontend = updateFromFrontend
    , subscriptions = subscriptions
    }


subscriptions : BackendModel -> Subscriptions.Subscription BackendOnly BackendMsg
subscriptions model =
    Subscriptions.batch
        [ Effect.Lamdera.onConnect Connected
        , Effect.Lamdera.onDisconnect Disconnected
        ]


init : ( BackendModel, Command BackendOnly ToFrontend BackendMsg )
init =
    ( { users = SeqDict.empty
      , sessions = SeqDict.empty
      , connections = SeqDict.empty
      , userIdCounter = 0
      }
    , Command.none
    )


update : BackendMsg -> BackendModel -> ( BackendModel, Command BackendOnly ToFrontend BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Command.none )

        Connected sessionId clientId ->
            let
                _ =
                    Debug.log "a" ()

                model2 : BackendModel
                model2 =
                    { model
                        | connections =
                            SeqDict.update
                                sessionId
                                (\maybeValue ->
                                    case maybeValue of
                                        Just value ->
                                            List.Nonempty.cons clientId value |> Just

                                        Nothing ->
                                            Nonempty clientId [] |> Just
                                )
                                model.connections
                    }
            in
            case SeqDict.get sessionId model2.sessions of
                Just userId ->
                    ( model2
                    , Command.batch
                        [ ConnectedResponse userId |> Effect.Lamdera.sendToFrontend clientId
                        , Effect.Lamdera.broadcast (UserConnected userId)
                        ]
                    )

                Nothing ->
                    let
                        userId : Id UserId
                        userId =
                            Id.fromInt model2.userIdCounter
                    in
                    ( { model2
                        | userIdCounter = model2.userIdCounter + 1
                        , users = SeqDict.insert userId User.init model.users
                        , sessions = SeqDict.insert sessionId userId model.sessions
                      }
                    , Command.batch
                        [ ConnectedResponse userId |> Effect.Lamdera.sendToFrontend clientId
                        , Effect.Lamdera.broadcast (UserConnected userId)
                        ]
                    )

        Disconnected sessionId clientId ->
            ( { model
                | connections =
                    SeqDict.update
                        sessionId
                        (Maybe.andThen
                            (\value ->
                                List.Nonempty.toList value
                                    |> List.Extra.remove clientId
                                    |> List.Nonempty.fromList
                            )
                        )
                        model.connections
              }
            , Command.none
            )


updateFromFrontend :
    SessionId
    -> ClientId
    -> ToBackend
    -> BackendModel
    -> ( BackendModel, Command BackendOnly ToFrontend BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Command.none )

        NewPositionRequest position velocity ->
            case SeqDict.get sessionId model.sessions of
                Just userId ->
                    case SeqDict.get userId model.users of
                        Just user ->
                            ( { model
                                | users =
                                    SeqDict.insert
                                        userId
                                        { user | position = position, velocity = velocity }
                                        model.users
                              }
                            , Effect.Lamdera.broadcast (UserPositionChanged userId position velocity)
                            )

                        Nothing ->
                            ( model, Command.none )

                Nothing ->
                    ( model, Command.none )
