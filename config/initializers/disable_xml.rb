p "Disabling XML parser"
ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML) 
