{-# LANGUAGE OverloadedStrings #-}

module Main where

import Hakyll
import Text.Pandoc
import Data.Monoid (mappend)
import qualified Data.Map as M

postCtx :: Context String
postCtx = dateField "date" "%B %e, %Y" `mappend` defaultContext

static :: Rules ()
static = do
  match "img/*" $ do
    route idRoute
    compile $ copyFileCompiler
  match "css/*" $ do
    route idRoute
    compile compressCssCompiler
  match "js/*" $ do
    route idRoute
    compile $ copyFileCompiler

pages_html :: Rules ()
pages_html = do
  match "pages/*.html" $ do
    route $ setExtension "html"
    compile $ getResourceBody
      >>= loadAndApplyTemplate "templates/page.html"    postCtx
      >>= relativizeUrls

pages_md :: Rules ()
pages_md = do
  match "pages/*.md" $ do
    route $ setExtension "html"
    compile $ compiler
      >>= loadAndApplyTemplate "templates/page.html"    postCtx
      >>= relativizeUrls

index :: Rules ()
index = do
  match "index.html" $ do
    route idRoute
    compile $ do
      getResourceBody
        >>= loadAndApplyTemplate "templates/page.html" defaultContext
        >>= relativizeUrls

templates :: Rules ()
templates = match "templates/*" $ compile templateCompiler

compiler :: Compiler (Item String)
compiler = pandocCompilerWith defaultHakyllReaderOptions pandocOptions

pandocOptions :: WriterOptions
pandocOptions = defaultHakyllWriterOptions{ writerHTMLMathMethod = MathJax "" }

cfg :: Configuration
cfg = defaultConfiguration { previewHost = "0.0.0.0" }

main :: IO ()
main = hakyllWith cfg $ static >> pages_html >> pages_md >> index >> templates
