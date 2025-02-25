dnl Note [How we configure the bundled windows toolchain]
dnl ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
dnl As per Note [tooldir: How GHC finds mingw on Windows], when using the
dnl bundled windows toolchain, the GHC settings file must refer to the
dnl toolchain through a path relative to $tooldir (binary distributions on
dnl Windows should work without configure, so the paths must be relative to the
dnl installation). However, hadrian expects the configured toolchain to use
dnl full paths to the executable.
dnl
dnl This is how the bundled windows toolchain is configured, to define the
dnl toolchain with paths to the executables, while still writing into GHC
dnl settings the paths relative to $tooldir:
dnl
dnl * If using the bundled toolchain, FP_SETUP_WINDOWS_TOOLCHAIN will be invoked
dnl
dnl * FP_SETUP_WINDOWS_TOOLCHAIN will set the toolchain variables to paths
dnl   to the bundled toolchain (e.g. CFLAGS=/full/path/to/mingw/bin/gcc)
dnl
dnl * Later on, in FP_SETTINGS, we substitute occurrences of the path to the
dnl   mingw tooldir by $tooldir (see SUBST_TOOLDIR).
dnl   The reason is the Settings* variants of toolchain variables are used by the bindist configure to
dnl   create the settings file, which needs the windows bundled toolchain to be relative to $tooldir.
dnl
dnl * Finally, hadrian will also substitute the mingw prefix by $tooldir before writing the toolchain to the settings file (see generateSettings)
dnl
dnl The ghc-toolchain program isn't concerned with any of these complications:
dnl it is passed either the full paths to the toolchain executables, or the bundled
dnl mingw path is set first on $PATH before invoking it. And ghc-toolchain
dnl will, as always, output target files with full paths to the executables.
dnl
dnl Hadrian accounts for this as it does for the toolchain executables
dnl configured by configure -- in fact, hadrian doesn't need to know whether
dnl the toolchain description file was generated by configure or by
dnl ghc-toolchain.

# SUBST_TOOLDIR
# ----------------------------------
# $1 - the variable where to search for occurrences of the path to the
#      inplace mingw, and update by substituting said occurrences by
#      the value of $mingw_install_prefix, where the mingw toolchain will be at
#      install time
#
# See Note [How we configure the bundled windows toolchain]
AC_DEFUN([SUBST_TOOLDIR],
[
    dnl and Note [How we configure the bundled windows toolchain]
    $1=`echo "$$1" | sed 's%'"$mingw_prefix"'%'"$mingw_install_prefix"'%g'`
])

# FP_SETTINGS
# ----------------------------------
# Set the variables used in the settings file
AC_DEFUN([FP_SETTINGS],
[
    SettingsUseDistroMINGW="$EnableDistroToolchain"

    SettingsCCompilerCommand="$CC"
    SettingsCCompilerFlags="$CONF_CC_OPTS_STAGE2"
    SettingsCxxCompilerCommand="$CXX"
    SettingsCxxCompilerFlags="$CONF_CXX_OPTS_STAGE2"
    SettingsCPPCommand="$CPPCmd"
    SettingsCPPFlags="$CONF_CPP_OPTS_STAGE2"
    SettingsHaskellCPPCommand="$HaskellCPPCmd"
    SettingsHaskellCPPFlags="$HaskellCPPArgs"
    SettingsJavaScriptCPPCommand="$JavaScriptCPPCmd"
    SettingsJavaScriptCPPFlags="$JavaScriptCPPArgs"
    SettingsCmmCPPCommand="$CmmCPPCmd"
    SettingsCmmCPPFlags="$CmmCPPArgs"
    SettingsCCompilerLinkFlags="$CONF_GCC_LINKER_OPTS_STAGE2"
    SettingsArCommand="$ArCmd"
    SettingsRanlibCommand="$RanlibCmd"
    SettingsMergeObjectsCommand="$MergeObjsCmd"
    SettingsMergeObjectsFlags="$MergeObjsArgs"

    AS_CASE(
      ["$CmmCPPSupportsG0"],
      [True], [SettingsCmmCPPSupportsG0=YES],
      [False], [SettingsCmmCPPSupportsG0=NO],
      [AC_MSG_ERROR(Unknown CPPSupportsG0 value $CmmCPPSupportsG0)]
    )

    if test -z "$WindresCmd"; then
        SettingsWindresCommand="/bin/false"
    else
        SettingsWindresCommand="$WindresCmd"
    fi

    # LLVM backend tools
    SettingsLlcCommand="$LlcCmd"
    SettingsOptCommand="$OptCmd"
    SettingsLlvmAsCommand="$LlvmAsCmd"
    SettingsLlvmAsFlags="$LlvmAsCmd"

    if test "$EnableDistroToolchain" = "YES"; then
        # If the user specified --enable-distro-toolchain then we just use the
        # executable names, not paths.
        SettingsCCompilerCommand="$(basename $SettingsCCompilerCommand)"
        SettingsHaskellCPPCommand="$(basename $SettingsHaskellCPPCommand)"
        SettingsCmmCPPCommand="$(basename $SettingsCmmCPPCommand)"
        SettingsJavaScriptCPPCommand="$(basename $SettingsJavaScriptCPPCommand)"
        SettingsLdCommand="$(basename $SettingsLdCommand)"
        SettingsMergeObjectsCommand="$(basename $SettingsMergeObjectsCommand)"
        SettingsArCommand="$(basename $SettingsArCommand)"
        SettingsWindresCommand="$(basename $SettingsWindresCommand)"
        SettingsLlcCommand="$(basename $SettingsLlcCommand)"
        SettingsOptCommand="$(basename $SettingsOptCommand)"
        SettingsLlvmAsCommand="$(basename $SettingsLlvmAsCommand)"
    fi

    if test "$windows" = YES -a "$EnableDistroToolchain" = "NO"; then
        # Handle the Windows toolchain installed in FP_SETUP_WINDOWS_TOOLCHAIN.
        # We need to issue a substitution to use $tooldir,
        # See Note [tooldir: How GHC finds mingw on Windows]
        SUBST_TOOLDIR([SettingsCCompilerCommand])
        SUBST_TOOLDIR([SettingsCCompilerFlags])
        SUBST_TOOLDIR([SettingsCxxCompilerCommand])
        SUBST_TOOLDIR([SettingsCxxCompilerFlags])
        SUBST_TOOLDIR([SettingsCCompilerLinkFlags])
        SUBST_TOOLDIR([SettingsCPPCommand])
        SUBST_TOOLDIR([SettingsCPPFlags])
        SUBST_TOOLDIR([SettingsHaskellCPPCommand])
        SUBST_TOOLDIR([SettingsHaskellCPPFlags])
        SUBST_TOOLDIR([SettingsCmmCPPCommand])
        SUBST_TOOLDIR([SettingsCmmCPPFlags])
        SUBST_TOOLDIR([SettingsJavaScriptCPPCommand])
        SUBST_TOOLDIR([SettingsJavaScriptCPPFlags])
        SUBST_TOOLDIR([SettingsMergeObjectsCommand])
        SUBST_TOOLDIR([SettingsMergeObjectsFlags])
        SUBST_TOOLDIR([SettingsArCommand])
        SUBST_TOOLDIR([SettingsRanlibCommand])
        SUBST_TOOLDIR([SettingsWindresCommand])
        SUBST_TOOLDIR([SettingsLlcCommand])
        SUBST_TOOLDIR([SettingsOptCommand])
        SUBST_TOOLDIR([SettingsLlvmAsCommand])
        SUBST_TOOLDIR([SettingsLlvmAsFlags])
    fi

    # Mac-only tools
    if test -z "$OtoolCmd"; then
        OtoolCmd="otool"
    fi
    SettingsOtoolCommand="$OtoolCmd"

    if test -z "$InstallNameToolCmd"; then
        InstallNameToolCmd="install_name_tool"
    fi
    SettingsInstallNameToolCommand="$InstallNameToolCmd"

    SettingsCCompilerSupportsNoPie="$CONF_GCC_SUPPORTS_NO_PIE"

    AC_SUBST(SettingsCCompilerCommand)
    AC_SUBST(SettingsCxxCompilerCommand)
    AC_SUBST(SettingsCPPCommand)
    AC_SUBST(SettingsCPPFlags)
    AC_SUBST(SettingsHaskellCPPCommand)
    AC_SUBST(SettingsHaskellCPPFlags)
    AC_SUBST(SettingsCmmCPPCommand)
    AC_SUBST(SettingsCmmCPPFlags)
    AC_SUBST(SettingsCmmCPPSupportsG0)
    AC_SUBST(SettingsJavaScriptCPPCommand)
    AC_SUBST(SettingsJavaScriptCPPFlags)
    AC_SUBST(SettingsCCompilerFlags)
    AC_SUBST(SettingsCxxCompilerFlags)
    AC_SUBST(SettingsCCompilerLinkFlags)
    AC_SUBST(SettingsCCompilerSupportsNoPie)
    AC_SUBST(SettingsMergeObjectsCommand)
    AC_SUBST(SettingsMergeObjectsFlags)
    AC_SUBST(SettingsArCommand)
    AC_SUBST(SettingsRanlibCommand)
    AC_SUBST(SettingsOtoolCommand)
    AC_SUBST(SettingsInstallNameToolCommand)
    AC_SUBST(SettingsWindresCommand)
    AC_SUBST(SettingsLlcCommand)
    AC_SUBST(SettingsOptCommand)
    AC_SUBST(SettingsLlvmAsCommand)
    AC_SUBST(SettingsLlvmAsFlags)
    AC_SUBST(SettingsUseDistroMINGW)
])
