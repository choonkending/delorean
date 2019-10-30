{-# LANGUAGE OverloadedStrings #-}
module Drive
  where

import Control.Lens ((.~), (<&>), (^..), (^?), (&), ix, views, _Just)
import Data.Text (Text)
import Network.Google (MonadGoogle, AllowScopes, HasScope, newLogger, LogLevel(Debug), runResourceT, runGoogle, send, download)
import Network.Google.Drive (driveReadOnlyScope, filesList, filesGet, flSpaces, FilesList)
import Network.Google.Drive.Types (fName, flFiles, fId)
import Network.Google.Env (envScopes, newEnv, envLogger)
import System.IO (stdout)

-- This reads your credentials from ~/.config/gcloud/application_default_credentials.json
getFiles :: IO ()
getFiles = do
  lgr <- newLogger Debug stdout
  env <- newEnv <&> (envLogger .~ lgr) . (envScopes .~ driveReadOnlyScope)
  response <- runResourceT (runGoogle env sendRequestToGetFiles)
  -- print response
  print fileId


sendRequestToGetFiles :: (MonadGoogle s m, HasScope s FilesList) => m ()
sendRequestToGetFiles = do
 listResult <- send (filesList & (flSpaces .~ "drive"))
 let Just fileId = listResult ^? flFiles . ix 0 . fId . _Just
 getResult <- download $ filesGet fileId
 pure ()

