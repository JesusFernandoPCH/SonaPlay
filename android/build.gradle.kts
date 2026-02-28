allprojects {
    repositories {
        google()
        mavenCentral()
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
    
    // Configuración para forzar Java 17 en todos los subproyectos
    afterEvaluate {
        if (project.hasProperty("android")) {
            project.extensions.configure<com.android.build.gradle.BaseExtension> {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
                if (namespace == null) {
                    namespace = "com.sonaplay.${project.name.replace("-", ".")}"
                }
            }
            
            // Patch for AGP 8.x: Remove legacy package attribute from AndroidManifest.xml
            // We do this immediately in afterEvaluate to avoid early validation failures
            val manifestFile = project.file("src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                val content = manifestFile.readText()
                val pattern = Regex("""\s*package\s*=\s*["'][^"']*["']""")
                if (content.contains(pattern)) {
                    manifestFile.writeText(content.replace(pattern, ""))
                    project.logger.lifecycle("SonaPlay Build: Immediately stripped legacy package from ${project.name} manifest")
                }
            }

            // Nueva sintaxis para Kotlin Gradle Plugin 2.0+
            project.tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile>().configureEach {
                compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}