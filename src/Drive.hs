module Drive
  where

import Control.Lens ((.~), (<&>), (^.), views)
import Data.Text (Text)
import Network.Google (newLogger, LogLevel(Debug), runResourceT, runGoogle, send)
import Network.Google.Drive (driveReadOnlyScope, filesList)
import Network.Google.Drive.Types (fName, flFiles)
import Network.Google.Env (envScopes, newEnv, envLogger)
import System.IO (stdout)

-- This reads your credentials from ~/.config/gcloud/application_default_credentials.json
getFiles :: IO ()
getFiles = do
  lgr <- newLogger Debug stdout
  env <- newEnv <&> (envLogger .~ lgr) . (envScopes .~ driveReadOnlyScope)
  response <- runResourceT (runGoogle env $ send filesList)
  print (response ^. flFiles . fName)
