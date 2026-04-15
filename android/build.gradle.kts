allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android")
            if (android != null) {
                try {
                    val namespaceMethod = android.javaClass.getMethod("getNamespace")
                    val currentNamespace = namespaceMethod.invoke(android) as? String
                    if (currentNamespace.isNullOrEmpty()) {
                        val setNamespaceMethod = android.javaClass.getMethod("setNamespace", String::class.java)
                        setNamespaceMethod.invoke(android, project.group.toString())
                    }
                } catch (e: Exception) {
                    // Ignore - namespace might not be supported
                }

                if (project.name == "isar_flutter_libs") {
                    try {
                        val compileSdk = 33
                        val setCompileSdkMethod = android.javaClass.methods.firstOrNull {
                            it.name == "setCompileSdk" && it.parameterCount == 1
                        }
                        val setCompileSdkVersionMethod = android.javaClass.methods.firstOrNull {
                            it.name == "setCompileSdkVersion" && it.parameterCount == 1
                        }
                        val compileSdkVersionMethod = android.javaClass.methods.firstOrNull {
                            it.name == "compileSdkVersion" && it.parameterCount == 1
                        }

                        when {
                            setCompileSdkMethod != null -> {
                                setCompileSdkMethod.invoke(android, compileSdk)
                            }
                            setCompileSdkVersionMethod != null -> {
                                setCompileSdkVersionMethod.invoke(android, compileSdk)
                            }
                            compileSdkVersionMethod != null -> {
                                compileSdkVersionMethod.invoke(android, compileSdk)
                            }
                            else -> {
                                println("Warning: Could not set compileSdk for ${project.path}; no compatible method found.")
                            }
                        }
                    } catch (e: Exception) {
                        println("Warning: Failed to set compileSdk for ${project.path}: ${e.message}")
                    }
                }
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
