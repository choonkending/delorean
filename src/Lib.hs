module Lib
  where

import Control.Lens ((.~), (<&>))
import Data.Text (Text)
import Network.Google (newLogger, LogLevel(Debug), runResourceT, runGoogle, send)
import Network.Google.Drive (driveReadOnlyScope, filesList)
import Network.Google.Env (envScopes, newEnv, envLogger)
import System.IO (stdout)
import Control.Monad.IO.Class (liftIO)

getFiles :: IO ()
getFiles = do
  lgr <- newLogger Debug stdout
  env <- newEnv <&> (envLogger .~ lgr) . (envScopes .~ driveReadOnlyScope)
  runResourceT . runGoogle env $
    send (filesList) >>= liftIO . print
