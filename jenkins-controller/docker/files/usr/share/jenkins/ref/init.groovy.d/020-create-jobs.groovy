import jenkins.model.*
import org.jenkinsci.plugins.workflow.job.*
import java.util.logging.Logger

final String SCRIPT_NAME = "[020-create-jobs]"
final String PIPELINE_FILENAME = "pipeline.groovy"

println(">>> ${SCRIPT_NAME} executed")
def logger = Logger.getLogger("")


def jenkins = Jenkins.instance
def pipelinesDir = new File(System.getenv('PIPELINES_FOLDER_PATH') ?: '/var/jenkins_home/pipelines')

if (!pipelinesDir.exists()) {
    logger.warning("${SCRIPT_NAME} Pipelines directory not found: ${pipelinesDir}")
    println "Pipelines directory not found"
    return
}

// Recursively find all pipeline.groovy files in subfolders of pipelinesDir
pipelinesDir.eachDir { subDir ->
    def pipelineFile = new File(subDir, PIPELINE_FILENAME)
    if (pipelineFile.exists()) {
        try {
            def jobName = subDir.name
            if (!jenkins.getItem(jobName)) {
                def pipelineScript = pipelineFile.text
                def pipeline = jenkins.createProject(WorkflowJob, jobName)
                pipeline.definition = new org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition(
                    pipelineScript,
                    true // sandbox mode
                )
                pipeline.save()
                logger.info("${SCRIPT_NAME} Created Job: ${jobName}")
                println "Created Job: ${jobName}"
            } else {
                logger.info("${SCRIPT_NAME} Job ${jobName} already exists")
                println "Job ${jobName} already exists"
            }
        } catch (Exception e) {
            logger.severe("${SCRIPT_NAME} Failed to create job from ${pipelineFile.name}: ${e.message}")
            println ">>> ${SCRIPT_NAME} Failed to create job from ${pipelineFile.name}: ${e.message}"
        }
    }
}