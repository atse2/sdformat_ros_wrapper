################################################################################
#APPEND_TO_CACHED_STRING(_string _cacheDesc [items...])
# Appends items to a cached list.
MACRO (APPEND_TO_CACHED_STRING _string _cacheDesc)
  FOREACH (newItem ${ARGN})
    SET (${_string} "${${_string}} ${newItem}" CACHE INTERNAL ${_cacheDesc} FORCE)
  ENDFOREACH (newItem ${ARGN})
  #STRING(STRIP ${${_string}} ${_string})
ENDMACRO (APPEND_TO_CACHED_STRING)
                 
################################################################################
# APPEND_TO_CACHED_LIST (_list _cacheDesc [items...]
# Appends items to a cached list.
MACRO (APPEND_TO_CACHED_LIST _list _cacheDesc)
  SET (tempList ${${_list}})
  FOREACH (newItem ${ARGN})
    LIST (APPEND tempList ${newItem})
  ENDFOREACH (newItem ${newItem})
  SET (${_list} ${tempList} CACHE INTERNAL ${_cacheDesc} FORCE)
ENDMACRO(APPEND_TO_CACHED_LIST)

#################################################
# Macro to turn a list into a string (why doesn't CMake have this built-in?)
MACRO (LIST_TO_STRING _string _list)
    SET (${_string})
    FOREACH (_item ${_list})
      SET (${_string} "${${_string}} ${_item}")
    ENDFOREACH (_item)
    #STRING(STRIP ${${_string}} ${_string})
ENDMACRO (LIST_TO_STRING)

#################################################
# BUILD ERROR macro
macro (BUILD_ERROR)
  foreach (str ${ARGN})
    SET (msg "\t${str}")
    MESSAGE (STATUS ${msg})
    APPEND_TO_CACHED_LIST(build_errors "build errors" ${msg})
  endforeach ()
endmacro (BUILD_ERROR)

#################################################
# BUILD WARNING macro
macro (BUILD_WARNING)
  foreach (str ${ARGN})
    SET (msg "\t${str}" )
    MESSAGE (STATUS ${msg} )
    APPEND_TO_CACHED_LIST(build_warnings "build warning" ${msg})
  endforeach (str ${ARGN})
endmacro (BUILD_WARNING)

#################################################
macro (sdf_add_library _name)
  add_library(${_name} SHARED ${ARGN})
  target_link_libraries (${_name} ${general_libraries})
endmacro ()

#################################################
macro (sdf_add_executable _name)
  add_executable(${_name} ${ARGN})
  target_link_libraries (${_name} ${general_libraries})
endmacro ()


#################################################
macro (sdf_install_includes _subdir)
  install(FILES ${ARGN} DESTINATION ${INCLUDE_INSTALL_DIR}/${_subdir} COMPONENT headers)
endmacro()

#################################################
macro (sdf_install_library _name)
  set_target_properties(${_name} PROPERTIES SOVERSION ${SDF_MAJOR_VERSION} VERSION ${SDF_VERSION_FULL})
  install (TARGETS ${_name} DESTINATION ${LIB_INSTALL_DIR} COMPONENT shlib)
endmacro ()

#################################################
macro (sdf_install_executable _name)
  set_target_properties(${_name} PROPERTIES VERSION ${SDF_VERSION_FULL})
  install (TARGETS ${_name} DESTINATION ${BIN_INSTALL_DIR})
endmacro ()

#################################################
macro (sdf_setup_unix)
endmacro()

#################################################
macro (sdf_setup_windows)
endmacro()

#################################################
macro (sdf_setup_apple)
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-undefined -Wl,dynamic_lookup")
endmacro()

#################################################
include_directories(${PROJECT_SOURCE_DIR}/test/gtest/include)
macro (sdf_build_tests)
  # Build all the tests
  foreach(GTEST_SOURCE_file ${ARGN})
    string(REGEX REPLACE ".cc" "" BINARY_NAME ${GTEST_SOURCE_file})
    set(BINARY_NAME ${TEST_TYPE}_${BINARY_NAME})
    add_executable(${BINARY_NAME} ${GTEST_SOURCE_file})

    add_dependencies(${BINARY_NAME}
      gtest gtest_main sdformat
      ${tinyxml_libraries}
      )
  
    target_link_libraries(${BINARY_NAME}
      libgtest.a
      libgtest_main.a
      sdformat
      pthread
      ${tinyxml_libraries}
      )
  
    add_test(${BINARY_NAME} ${CMAKE_CURRENT_BINARY_DIR}/${BINARY_NAME}
      --gtest_output=xml:${CMAKE_BINARY_DIR}/test_results/${BINARY_NAME}.xml)
  
    set_tests_properties(${BINARY_NAME} PROPERTIES TIMEOUT 240)
  
    # Check that the test produced a result and create a failure if it didn't.
    # Guards against crashed and timed out tests.
    add_test(check_${BINARY_NAME} ${PROJECT_SOURCE_DIR}/tools/check_test_ran.py
             ${CMAKE_BINARY_DIR}/test_results/${BINARY_NAME}.xml)
  endforeach()
endmacro()


