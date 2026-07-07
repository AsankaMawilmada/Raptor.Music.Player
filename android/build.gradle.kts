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
}
subprojects {
    project.evaluationDependsOn(":app")
}

// on_audio_query_android predates Android Gradle Plugin's requirement that
// every module declare a `namespace`, and instead only sets a `package`
// attribute in its AndroidManifest.xml (which AGP no longer reads for this
// purpose). Backfill the namespace the moment the library plugin is applied
// (rather than in afterEvaluate, which is too late under AGP 9's stricter
// project-evaluation lifecycle).
subprojects {
    if (name == "on_audio_query_android") {
        plugins.withId("com.android.library") {
            extensions.configure(com.android.build.gradle.LibraryExtension::class.java) {
                namespace = "com.lucasjosino.on_audio_query"
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
        plugins.withId("kotlin-android") {
            extensions.configure(org.jetbrains.kotlin.gradle.dsl.KotlinAndroidProjectExtension::class.java) {
                compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                }
            }
        }
        // Its own build.gradle sets compileSdkVersion 33 explicitly further
        // down the same script, which would clobber anything set at
        // plugin-apply time above - so bump this one afterEvaluate instead.
        afterEvaluate {
            extensions.configure(com.android.build.gradle.LibraryExtension::class.java) {
                compileSdk = 36
            }
        }
    }

    // audiotags ships pinned to compileSdk 31, which is now below the
    // minimum several transitive androidx dependencies require. Its own
    // build.gradle sets compileSdkVersion explicitly, so bump it back up
    // afterEvaluate (after that script has already run) rather than at
    // plugin-apply time, which its own script would just overwrite again.
    if (name == "audiotags") {
        afterEvaluate {
            extensions.configure(com.android.build.gradle.LibraryExtension::class.java) {
                compileSdk = 36
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
