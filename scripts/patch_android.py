import os
import re

def patch_settings():
    path = "frontend/android/settings.gradle"
    if not os.path.exists(path):
        return
    with open(path, "r") as f:
        content = f.read()

    # Force Kotlin version 1.9.24
    content = re.sub(r'(id\s+["\']org\.jetbrains\.kotlin\.android["\']\s+version\s+)["\'][^"\']+["\']', r'\g<1>"1.9.24"', content)

    # Inject maven repositories if missing
    if "pluginManagement {" in content and "google()" not in content:
        content = content.replace("repositories {", "repositories {\n        google()\n        mavenCentral()\n        gradlePluginPortal()", 1)
    
    with open(path, "w") as f:
        f.write(content)

def patch_build():
    path = "frontend/android/build.gradle"
    if not os.path.exists(path):
        return
    with open(path, "r") as f:
        content = f.read()

    # Overwrite the buildscript block completely
    buildscript_block = """buildscript {
    ext.kotlin_version = '1.9.24'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}
"""
    if "buildscript {" in content:
        content = re.sub(r'buildscript\s*\{.*?\n\}', buildscript_block, content, flags=re.DOTALL)
    else:
        content = buildscript_block + "\n" + content

    # Overwrite the allprojects repositories
    allprojects_block = """allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
"""
    if "allprojects {" in content:
        content = re.sub(r'allprojects\s*\{.*?repositories\s*\{.*?\n\s*\}', """allprojects {
    repositories {
        google()
        mavenCentral()
    }""", content, flags=re.DOTALL)
    else:
        content += "\n" + allprojects_block

    # Add the subprojects bypass to bottom
    sub_eval = """
subprojects {
    afterEvaluate { project ->
        if (project.hasProperty('android')) {
            project.android {
                compileSdkVersion 34
            }
        }
    }
}
"""
    if "subprojects {" not in content:
        content += sub_eval

    with open(path, "w") as f:
        f.write(content)

def patch_app_build():
    path = "frontend/android/app/build.gradle"
    if not os.path.exists(path):
        return
    with open(path, "r") as f:
        content = f.read()

    content = re.sub(r"compileSdk\s+\d+", "compileSdk 34", content)
    content = re.sub(r"compileSdkVersion\s+\d+", "compileSdkVersion 34", content)

    with open(path, "w") as f:
        f.write(content)

if __name__ == "__main__":
    patch_settings()
    patch_build()
    patch_app_build()
    print("Successfully patched Android Build Gradle files.")
