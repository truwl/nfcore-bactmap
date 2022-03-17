version 1.0

workflow bactmap {
	input{
		File samplesheet
		String outdir = "./results"
		String? email
		String reference
		Boolean trim = true
		Boolean? save_trimmed_fail
		String adapter_file = "${baseDir}/assets/adapters.fas"
		Boolean? subsampling_off
		Int subsampling_depth_cutoff = 100
		String? genome_size
		Boolean? remove_recombination
		Float non_GATC_threshold = 0.5
		Boolean? rapidnj
		Boolean? fasttree
		Boolean? iqtree
		Boolean? raxmlng
		Boolean? help
		String publish_dir_mode = "copy"
		String? email_on_fail
		Boolean? plaintext_email
		Boolean? monochrome_logs
		String tracedir = "./results/pipeline_info"
		Boolean? singularity_pull_docker_container
		String max_multiqc_email_size = "25.MB"
		Boolean? skip_multiqc
		String? multiqc_config
		String? multiqc_title
		Boolean? enable_conda
		Boolean validate_params = true
		Boolean? show_hidden_params
		Int max_cpus = 4
		String max_memory = "16.GB"
		String max_time = "240.h"
		String custom_config_version = "master"
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? hostnames
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url

	}

	call make_uuid as mkuuid {}
	call touch_uuid as thuuid {
		input:
			outputbucket = mkuuid.uuid
	}
	call run_nfcoretask as nfcoretask {
		input:
			samplesheet = samplesheet,
			outdir = outdir,
			email = email,
			reference = reference,
			trim = trim,
			save_trimmed_fail = save_trimmed_fail,
			adapter_file = adapter_file,
			subsampling_off = subsampling_off,
			subsampling_depth_cutoff = subsampling_depth_cutoff,
			genome_size = genome_size,
			remove_recombination = remove_recombination,
			non_GATC_threshold = non_GATC_threshold,
			rapidnj = rapidnj,
			fasttree = fasttree,
			iqtree = iqtree,
			raxmlng = raxmlng,
			help = help,
			publish_dir_mode = publish_dir_mode,
			email_on_fail = email_on_fail,
			plaintext_email = plaintext_email,
			monochrome_logs = monochrome_logs,
			tracedir = tracedir,
			singularity_pull_docker_container = singularity_pull_docker_container,
			max_multiqc_email_size = max_multiqc_email_size,
			skip_multiqc = skip_multiqc,
			multiqc_config = multiqc_config,
			multiqc_title = multiqc_title,
			enable_conda = enable_conda,
			validate_params = validate_params,
			show_hidden_params = show_hidden_params,
			max_cpus = max_cpus,
			max_memory = max_memory,
			max_time = max_time,
			custom_config_version = custom_config_version,
			custom_config_base = custom_config_base,
			hostnames = hostnames,
			config_profile_description = config_profile_description,
			config_profile_contact = config_profile_contact,
			config_profile_url = config_profile_url,
			outputbucket = thuuid.touchedbucket
            }
		output {
			Array[File] results = nfcoretask.results
		}
	}
task make_uuid {
	meta {
		volatile: true
}

command <<<
        python <<CODE
        import uuid
        print("gs://truwl-internal-inputs/nf-bactmap/{}".format(str(uuid.uuid4())))
        CODE
>>>

  output {
    String uuid = read_string(stdout())
  }
  
  runtime {
    docker: "python:3.8.12-buster"
  }
}

task touch_uuid {
    input {
        String outputbucket
    }

    command <<<
        echo "sentinel" > sentinelfile
        gsutil cp sentinelfile ~{outputbucket}/sentinelfile
    >>>

    output {
        String touchedbucket = outputbucket
    }

    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task fetch_results {
    input {
        String outputbucket
        File execution_trace
    }
    command <<<
        cat ~{execution_trace}
        echo ~{outputbucket}
        mkdir -p ./resultsdir
        gsutil cp -R ~{outputbucket} ./resultsdir
    >>>
    output {
        Array[File] results = glob("resultsdir/*")
    }
    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task run_nfcoretask {
    input {
        String outputbucket
		File samplesheet
		String outdir = "./results"
		String? email
		String reference
		Boolean trim = true
		Boolean? save_trimmed_fail
		String adapter_file = "${baseDir}/assets/adapters.fas"
		Boolean? subsampling_off
		Int subsampling_depth_cutoff = 100
		String? genome_size
		Boolean? remove_recombination
		Float non_GATC_threshold = 0.5
		Boolean? rapidnj
		Boolean? fasttree
		Boolean? iqtree
		Boolean? raxmlng
		Boolean? help
		String publish_dir_mode = "copy"
		String? email_on_fail
		Boolean? plaintext_email
		Boolean? monochrome_logs
		String tracedir = "./results/pipeline_info"
		Boolean? singularity_pull_docker_container
		String max_multiqc_email_size = "25.MB"
		Boolean? skip_multiqc
		String? multiqc_config
		String? multiqc_title
		Boolean? enable_conda
		Boolean validate_params = true
		Boolean? show_hidden_params
		Int max_cpus = 4
		String max_memory = "16.GB"
		String max_time = "240.h"
		String custom_config_version = "master"
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? hostnames
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url

	}
	command <<<
		export NXF_VER=21.10.5
		export NXF_MODE=google
		echo ~{outputbucket}
		/nextflow -c /truwl.nf.config run /bactmap-1.0.0  -profile truwl  --input ~{samplesheet} 	~{"--samplesheet " + samplesheet}	~{"--outdir " + outdir}	~{"--email " + email}	~{"--reference " + reference}	~{true="--trim  " false="" trim}	~{true="--save_trimmed_fail  " false="" save_trimmed_fail}	~{"--adapter_file " + adapter_file}	~{true="--subsampling_off  " false="" subsampling_off}	~{"--subsampling_depth_cutoff " + subsampling_depth_cutoff}	~{"--genome_size " + genome_size}	~{true="--remove_recombination  " false="" remove_recombination}	~{"--non_GATC_threshold " + non_GATC_threshold}	~{true="--rapidnj  " false="" rapidnj}	~{true="--fasttree  " false="" fasttree}	~{true="--iqtree  " false="" iqtree}	~{true="--raxmlng  " false="" raxmlng}	~{true="--help  " false="" help}	~{"--publish_dir_mode " + publish_dir_mode}	~{"--email_on_fail " + email_on_fail}	~{true="--plaintext_email  " false="" plaintext_email}	~{true="--monochrome_logs  " false="" monochrome_logs}	~{"--tracedir " + tracedir}	~{true="--singularity_pull_docker_container  " false="" singularity_pull_docker_container}	~{"--max_multiqc_email_size " + max_multiqc_email_size}	~{true="--skip_multiqc  " false="" skip_multiqc}	~{"--multiqc_config " + multiqc_config}	~{"--multiqc_title " + multiqc_title}	~{true="--enable_conda  " false="" enable_conda}	~{true="--validate_params  " false="" validate_params}	~{true="--show_hidden_params  " false="" show_hidden_params}	~{"--max_cpus " + max_cpus}	~{"--max_memory " + max_memory}	~{"--max_time " + max_time}	~{"--custom_config_version " + custom_config_version}	~{"--custom_config_base " + custom_config_base}	~{"--hostnames " + hostnames}	~{"--config_profile_description " + config_profile_description}	~{"--config_profile_contact " + config_profile_contact}	~{"--config_profile_url " + config_profile_url}	-w ~{outputbucket}
	>>>
        
    output {
        File execution_trace = "pipeline_execution_trace.txt"
        Array[File] results = glob("results/*/*html")
    }
    runtime {
        docker: "truwl/nfcore-bactmap:1.0.0_0.1.0"
        memory: "2 GB"
        cpu: 1
    }
}
    