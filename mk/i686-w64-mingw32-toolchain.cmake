set(CMAKE_SYSTEM_NAME Windows)
set(_arch "i686-w64-mingw32")
#set(_arch "x86_64-w64-mingw32")
set(_flavor -win32)
#set(_flavor -posix)

set(CMAKE_C_COMPILER   ${_arch}-gcc${_flavor})
set(CMAKE_CXX_COMPILER ${_arch}-g++${_flavor})
set(CMAKE_RC_COMPILER  ${_arch}-windres)

set(CMAKE_FIND_ROOT_PATH /usr/${_arch};/opt/${_arch};${USER_FIND_ROOT_PATH})
# Don't search for executables under CMAKE_FIND_ROOT_PATH
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# Search for host libraries under CMAKE_FIND_ROOT_PATH only
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
# Search for host headers under CMAKE_FIND_ROOT_PATH only
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
