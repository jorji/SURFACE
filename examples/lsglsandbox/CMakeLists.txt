SET(SRCS
  main.cc
  easywsclient.cpp
  jpge.cpp
  )

INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/include)
ADD_DEFINITIONS(-D__STDC_CONSTANT_MACROS)

ADD_EXECUTABLE(lsglsandbox ${SRCS})
ADD_SANITIZERS(lsglsandbox)

IF (WIN32)
TARGET_LINK_LIBRARIES(lsglsandbox LSGLES)
ELSE()
TARGET_LINK_LIBRARIES(lsglsandbox LSGLES dl)
ENDIF()

# --
INSTALL(TARGETS lsglsandbox DESTINATION bin)
INSTALL(FILES default.frag DESTINATION bin)
# --
