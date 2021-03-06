PROJECT(SURFACE)
CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

SET(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})
FIND_PACKAGE(Sanitizers)

SET(SURFACE_VERSION 0.9.0)
SET(SURFACE_SOVERSION 0)   # shared lib

IF(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the build type: Debug Release RelWithDebInfo MinSizeRel." FORCE)
ENDIF(NOT CMAKE_BUILD_TYPE)

SET(SURFACE_BINARY_DIR ${PROJECT_BINARY_DIR})
IF(NOT LIBRARY_OUTPUT_PATH)
  SET(LIBRARY_OUTPUT_PATH ${SURFACE_BINARY_DIR})
ENDIF()
IF(NOT EXECUTABLE_OUTPUT_PATH)
  SET(EXECUTABLE_OUTPUT_PATH ${SURFACE_BINARY_DIR})
ENDIF()
LINK_DIRECTORIES(${LIBRARY_OUTPUT_PATH})

MARK_AS_ADVANCED(LIBRARY_OUTPUT_PATH)
MARK_AS_ADVANCED(EXECUTABLE_OUTPUT_PATH)
MARK_AS_ADVANCED(CMAKE_INSTALL_PREFIX)
MARK_AS_ADVANCED(CMAKE_BACKWARDS_COMPATIBILITY)

# Build options
SET(SURFACE_BUILD_UNIT_TEST OFF CACHE BOOL "Build unit test?")
SET(SURFACE_BUILD_K_CROSS_COMPILE OFF CACHE BOOL "Build for K/FX10 target with corss compiling?")
SET(SURFACE_BUILD_WITH_MPI OFF CACHE BOOL "Build with MPI support?")
SET(SURFACE_BUILD_WITH_OPENMP OFF CACHE BOOL "Build with OpenMP support?")
SET(SURFACE_BUILD_WITH_DEBUG_TRACE OFF CACHE BOOL "Build with debug trace?")
SET(SURFACE_BUILD_EXAMPLES OFF CACHE BOOL "Build examples?")

# Deprecated. to be removed.
SET(SURFACE_BUILD_SCREEN_PARALLEL OFF CACHE BOOL "[DEPRECATED] Build with screen parallel support?(Also need to enable SURFACE_BUILD_WITH_MPI option)")

# K/FX10 native environment
IF (CMAKE_SYSTEM_PROCESSOR MATCHES "s64fx")

  # Use native Fujitsu compiler
  IF (SURFACE_BUILD_WITH_MPI)
    SET(CMAKE_C_COMPILER mpifcc)
    SET(CMAKE_CXX_COMPILER mpiFCC)
  ELSE()
    SET(CMAKE_C_COMPILER fcc)
    SET(CMAKE_CXX_COMPILER FCC)
  ENDIF()

  # gcc compatible flag(-Xg)
  SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Xg")
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Xg")

  # PIC flag
  SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -KPIC")
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -KPIC")

  # OpenMP flag(-Kopenmp)
  SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Kopenmp")
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Kopenmp")

  IF (CMAKE_BUILD_TYPE MATCHES "Release")
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Kfast")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Kfast")
  ENDIF()

  # Prevent CMake from adding GNU-specific linker flags (-rdynamic)
  SET(CMAKE_C_COMPILER_ID "Fujitsu" CACHE STRING "Fujitsu C cross-compiler" FORCE)
  SET(CMAKE_CXX_COMPILER_ID "Fujitsu" CACHE STRING "Fujitsu C++ cross-compiler" FORCE)

  # FindOpenMP.cmake does not try -Kopenmp,but the package will try specific
  # flags based on the compier ID.
  SET(OMP_FLAG_Fujitsu "-Kopenmp")
ENDIF()

# K cross compiling
IF (SURFACE_BUILD_K_CROSS_COMPILE)

  # Use Fujitsu cross compiler
  IF (SURFACE_BUILD_WITH_MPI)
    SET(CMAKE_C_COMPILER mpifccpx)
    SET(CMAKE_CXX_COMPILER mpiFCCpx)
  ELSE()
    SET(CMAKE_C_COMPILER fccpx)
    SET(CMAKE_CXX_COMPILER FCCpx)
  ENDIF()

  # Prevent CMake from adding GNU-specific linker flags (-rdynamic)
  SET(CMAKE_C_COMPILER_ID "Fujitsu" CACHE STRING "Fujitsu C cross-compiler" FORCE)
  SET(CMAKE_CXX_COMPILER_ID "Fujitsu" CACHE STRING "Fujitsu C++ cross-compiler" FORCE)

  # gcc compatible flag(-Xg)
  SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Xg")
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Xg")

  # PIC flag
  SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -KPIC")
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -KPIC")

  # OpenMP flag(-Kopenmp)
  SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Kopenmp")
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Kopenmp")

  IF (CMAKE_BUILD_TYPE MATCHES "Release")
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Kfast")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Kfast")
  ENDIF()

  # FindOpenMP.cmake does not try -Kopenmp,but the package will try specific
  # flags based on the compier ID.
  SET(OMP_FLAG_Fujitsu "-Kopenmp")
  
# OpenMP setting.
ELSE() # non K cross env
  IF (CMAKE_SYSTEM_PROCESSOR MATCHES "s64fx")
  ELSE () # assume gcc + linux or macosx
    # PIC flag
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")

    IF (SURFACE_BUILD_WITH_OPENMP)
      SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fopenmp")
      SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fopenmp")
    ENDIF() 

  ENDIF()	  
ENDIF()

IF (SURFACE_BUILD_WITH_MPI)
  ADD_DEFINITIONS(-DLSGL_ENABLE_MPI=1) 
ENDIF()

IF (SURFACE_BUILD_WITH_DEBUG_TRACE)
  ADD_DEFINITIONS(-DLSGL_DEBUG_TRACE) 
ENDIF()

# Windows
IF (WIN32)
  OPTION (BUILD_SHARED_LIBS "Build Shared Libraries" ON)
  SET (LIB_TYPE SHARED)
  IF (NOT BUILD_SHARED_LIBS)
    SET (LIB_TYPE STATIC)
  ENDIF (NOT BUILD_SHARED_LIBS)
  ADD_DEFINITIONS(-D_CRT_SECURE_NO_DEPRACATE)
  ADD_DEFINITIONS(-D_CRT_SECURE_NO_WARNINGS)
  ADD_DEFINITIONS(-DLSGL_EXPORT)
  ADD_DEFINITIONS(-D__SSE2__)

  IF (SURFACE_BUILD_WITH_OPENMP)
    # VS2012 or later should have OpenMP support.
    FIND_PACKAGE(OpenMP)
    IF(OPENMP_FOUND)
      SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
      SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    ENDIF()
  ENDIF()
ENDIF()

# Modules
ADD_SUBDIRECTORY(gles gles)
ADD_SUBDIRECTORY(glsl glsl)

# examples
IF (SURFACE_BUILD_EXAMPLES)
ADD_SUBDIRECTORY(examples)
ENDIF()

# Unit tests
IF (SURFACE_BUILD_UNIT_TEST)
ADD_SUBDIRECTORY(third_party/gtest-1.7.0/)
ADD_SUBDIRECTORY(test/cctest/)
ENDIF()

