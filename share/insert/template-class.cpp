#include "%file-without-ext%.hpp"

/**
 * %file% - %bdesc%
 *
 * Copyright (c) %cyear% %name% <%mail%>
 * 
 *
 */
#include <ostream>

%namespace-open%
 /**
  * Default constructor
  */
 %file-without-ext%::%file-without-ext%() {
 }
 
 /**
  * Default destructor
  */
 %file-without-ext%::~%file-without-ext%() {
 }
 
 /**
  * Copy constructor
  */
 %file-without-ext%::%file-without-ext%(const %file-without-ext%& rhs) {
 }
 
 /**
  * Assignment operator
  */
 %file-without-ext%& %file-without-ext%::operator=(const %file-without-ext%& rhs) {
     if (this != &rhs) {
         // TODO: implement copy
     }
     return *this;
 }
 
 /**
  * stream output operator
  */
 friend std::ostream& operator<<(std::ostream& lhs, const %file-without-ext%& rhs);

%namespace-close%
