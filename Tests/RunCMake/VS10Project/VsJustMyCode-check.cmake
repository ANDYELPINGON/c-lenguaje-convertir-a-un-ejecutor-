macro(VsJustMyCode_check tgt jmc_expect)
  set(vcProjectFile "${RunCMake_TEST_BINARY_DIR}/${tgt}.vcxproj")
  if(NOT EXISTS "${vcProjectFile}")
    set(RunCMake_TEST_FAILED "Project file ${tgt}.vcxproj does not exist.")
    return()
  endif()

  set(HAVE_JMC 0)

  file(STRINGS "${vcProjectFile}" lines)
  foreach(line IN LISTS lines)
    if(line MATCHES "^ *<SupportJustMyCode>([^<>]*)</SupportJustMyCode>")
      set(jmc_actual "${CMAKE_MATCH_1}")
      if(NOT "${jmc_actual}" STREQUAL "${jmc_expect}")
        set(RunCMake_TEST_FAILED "Project file ${tgt}.vcxproj has <SupportJustMyCode> '${jmc_actual}', not '${jmc_expect}'.")
        return()
      endif()
      set(HAVE_JMC 1)
      break()
    endif()
  endforeach()

  if(NOT HAVE_JMC AND NOT "${jmc_expect}" STREQUAL "")
    set(RunCMake_TEST_FAILED "Project file ${tgt}.vcxproj does not have a <SupportJustMyCode> property group.")
    return()
  endif()
endmacro()

VsJustMyCode_check(JMC-default-C "")
VsJustMyCode_check(JMC-default-CXX "")
VsJustMyCode_check(JMC-ON-C true)
VsJustMyCode_check(JMC-ON-CXX true)
VsJustMyCode_check(JMC-OFF-C "")
VsJustMyCode_check(JMC-OFF-CXX "")
VsJustMyCode_check(JMC-TGT-ON-C true)
VsJustMyCode_check(JMC-TGT-ON-CXX true)
VsJustMyCode_check(JMC-TGT-OFF-C "")
VsJustMyCode_check(JMC-TGT-OFF-CXX "")
