{-# LANGUAGE OverloadedStrings #-}
module Drive
  where

import Control.Lens ((.~), (<&>), (^..), (^?), (&), ix, views, _Just)
import Control.Monad.Trans.Resource (liftResourceT)
import Data.ByteString (ByteString)
import Data.Text (Text)
import Network.Google (MonadGoogle, AllowScopes, HasScope, newLogger, LogLevel(Debug), runResourceT, runGoogle, send, download)
import Network.Google.Drive (driveReadOnlyScope, filesList, filesGet, flSpaces, FilesList)
import Network.Google.Drive.Types (fName, flFiles, fId)
import Network.Google.Env (envScopes, newEnv, envLogger)
import System.IO (stdout)
import Data.Conduit.Combinators (sinkFile)
import Conduit (ConduitM, MonadIO, MonadResource, ResourceT, runConduit, transPipe, (.|))

-- This reads your credentials from ~/.config/gcloud/application_default_credentials.json
getFiles :: IO ()
getFiles = do
  lgr <- newLogger Debug stdout
  env <- newEnv <&> (envLogger .~ lgr) . (envScopes .~ driveReadOnlyScope)
  response <- runResourceT (runGoogle env sendRequestToGetFiles)
  print response


sendRequestToGetFiles :: (MonadGoogle s m, HasScope s FilesList, MonadResource m) => m ()
sendRequestToGetFiles = do
 listResult <- send (filesList & (flSpaces .~ "drive"))
 let Just fileId = listResult ^? flFiles . ix 0 . fId . _Just
 resultStream <- download (filesGet fileId)
 let downloadConduit = transformConduit resultStream .| sinkFile "test.pdf"
 runConduit downloadConduit
 pure ()

transformConduit :: (MonadResource m) => ConduitM () ByteString (ResourceT IO) () -> ConduitM () ByteString m ()
transformConduit = transPipe liftResourceT
