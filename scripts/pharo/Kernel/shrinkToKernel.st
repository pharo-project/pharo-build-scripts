'From Pharo1.4a of ''16 June 2011'' [Latest update: #14034] on 12 July 2011 at 7:57:28 pm'!

!ThreadSafeTranscript methodsFor: 'streaming' stamp: 'PavelKrivanek 7/12/2011 19:57'!
endEntry
  "Display all the characters since the last endEntry, and reset the
  stream "
  
  accessSemaphore critical: [
    self changed: #appendEntry.
  " World displayWorldSafely."
    stream resetContents]! !


Smalltalk shrinkToKernel.