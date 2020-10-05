# - Try to find Compare
# Once done, this will define
#
#  COMPARE_FOUND - system has compare
#  COMPARE_MODULE_DIRS - the compare include directories
#  COMPARE_LIBRARIES - link these to use compare

INCLUDE( FindPackageHandleStandardArgs )

IF( DEFINED ENV{COMPARE_DIR} )
  SET( COMPARE_DIR "$ENV{COMPARE_DIR}" )
ENDIF()


FIND_PATH(COMPARE_MODULE_DIR
  compare.mod
  HINTS ${COMPARE_DIR}/include
  )

FIND_LIBRARY( COMPARE_LIBRARY
  NAMES compare
  HINTS ${COMPARE_DIR}/lib
)

FIND_PACKAGE_HANDLE_STANDARD_ARGS( COMPARE DEFAULT_MSG
  COMPARE_MODULE_DIR
  COMPARE_LIBRARY
  )

IF( COMPARE_FOUND )
  SET( COMPARE_MODULE_DIRS ${COMPARE_MODULE_DIR} )
  SET( COMPARE_LIBRARIES ${COMPARE_LIBRARY} )

  MARK_AS_ADVANCED(
    COMPARE_LIBRARY
    COMPARE_MODULE_DIR
    COMPARE_DIR
  )
ELSE()
  SET( COMPARE_DIR "" CACHE STRING
    "An optional hint to a directory for finding `compare`"
  )
ENDIF()
