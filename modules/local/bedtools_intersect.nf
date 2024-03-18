// adapted from nf-core
process BEDTOOLS_INTERSECT {
    tag "$meta.id"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bedtools:2.31.1--hf5e1c6e_0' :
        'biocontainers/bedtools:2.31.1--hf5e1c6e_0' }"

    input:
    val caller
    tuple val(meta), path(intervals1)
    tuple val(meta2), path(intervals2)
    
    output:
    tuple val(meta), path("*.${extension}"), emit: intersect
    path  "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    //Extension of the output file. It is set by the user via "ext.suffix" in the config. Corresponds to the file format which depends on arguments (e. g., ".bed", ".bam", ".txt", etc.).
    extension = task.ext.suffix ?: "${intervals1.extension}"
    if ("$intervals1" == "${prefix}.${extension}" ||
        "$intervals2" == "${prefix}.${extension}")
        error "Input and output names are the same, use \"task.ext.prefix\" to disambiguate!"
    """
    bedtools \\
        intersect \\
        -a $intervals1 \\
        -b $intervals2 \\
        $args \\
        > ${caller}_${prefix}_annotations.${extension}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bedtools: \$(bedtools --version | sed -e "s/bedtools v//g")
    END_VERSIONS
    """
}