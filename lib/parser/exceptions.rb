module Parser
  
  class ParsingException < Exception
  end

  class ErrorBuildingParser < Exception
  end
  
  class ErrorBufferUnderflow < ParsingException
  end

  class ErrorRaiminingData < ParsingException
  end
end