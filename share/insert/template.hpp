/* http://d.hatena.ne.jp/higepon/20080731/1217491155 */
/* http://www.02.246.ne.jp/~torutk/cxx/emacs/mode_extension.html */

/* %file% - %bdsec% */
#ifndef %include-guard%
#define %include-guard%

#include <iosfwd>

%namespace-open%

class %file-without-ext% {
public:
    /// Default constructor
    %file-without-ext%();
    /// Destructor
    ~%file-without-ext%();
    /// Copy constructor
    %file-without-ext%(const %file-without-ext%& rhs);
    /// Assignment operator
    %file-without-ext%& operator=(const %file-without-ext%& rhs);
};

/// stream output operator
std::ostream& operator<<(std::ostream& lhs, const %file-without-ext%& rhs);

%namespace-close%
#endif /* %include-guard% */
