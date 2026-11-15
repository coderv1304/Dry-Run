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
// Some plugins still declare an old compileSdk (share_plus 7.2.2 uses 33),
// which fails AAR metadata checks because their transitive AndroidX libraries
// require API 34 or newer. Compiling a plugin against a newer SDK does not
// change its runtime behaviour or the app's targetSdk. The reflection keeps
// this root script independent of the Android Gradle Plugin classpath.
subprojects {
    afterEvaluate {
        val android = extensions.findByName("android") ?: return@afterEvaluate
        val setter = android.javaClass.methods.firstOrNull { method ->
            method.name == "setCompileSdkVersion" &&
                method.parameterTypes.size == 1 &&
                method.parameterTypes[0] == Int::class.javaPrimitiveType
        }
        setter?.invoke(android, 36)
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
