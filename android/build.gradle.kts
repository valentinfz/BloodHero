import org.gradle.api.tasks.Delete
import org.gradle.api.tasks.compile.JavaCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

buildDir = File(rootDir, "../build")

subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    project.buildDir = File(rootProject.buildDir, project.name)
    tasks.withType<JavaCompile>().configureEach {
        options.compilerArgs.add("-Xlint:-options")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
