# FreeSurfer workflow for Open Science Grid

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

**Runs FreeSurfer recon-all on a T1-weighted image (optionally with a T2w) as a Pegasus workflow on the Open Science Grid, producing a FreeSurfer subject directory.**

Uses ABCD start/status/stop hooks to submit a Pegasus workflow to the Open Science Grid that runs recon-all with the selected FreeSurfer version and options (hires, notalcheck, cw256, debug, optional hippocampal subfields). Use it to offload FreeSurfer reconstruction to OSG resources; it needs a FreeSurfer license and only runs where OSG submission is configured.

Run it on brainlife.io: [https://doi.org/10.25663/brainlife.app.268](https://doi.org/10.25663/brainlife.app.268)

| Input | Datatype | Required | Description |
|---|---|---|---|
| `t1` | `neuro/anat/t1w` | yes | Whole-head T1-weighted image to reconstruct. Submillimetre images need the hires parameter; a field of view over 256 mm needs cw256. |
| `t2` | `neuro/anat/t2w` | no | Optional T2-weighted image of the same subject, passed to recon-all to refine the pial surface. |

| Output | Datatype | Description |
|---|---|---|
| `freesurfer` | `neuro/freesurfer` | FreeSurfer subject directory (mri, surf, label, stats, scripts) produced by recon-all. |

| Parameter | Type | Default | Description |
|---|---|---|---|
| `version` | enum | `6.0.1` | Freesurfer version to use Options: `6.0.0`, `6.0.1`. |
| `hires` | boolean | `false` | Check this flag if your input t1 has voxel sizes less than 1mm3 (submillimeter resolution) like HCP 7T. (HCP 3T is 1.25mm). The processing will take a significantly longer time. See https://surfer.nmr.mgh.harvard.edu/fswiki/SubmillimeterRecon |
| `notalcheck` | boolean | `false` | If you are seeing "ERROR: Talairach failed", you might be able to work around this by setting this option so that freesurfer will skip this process. If you set this option, you will need to make sure that your image is well aligned to the 3 primary axis. |
| `cw256` | boolean | `false` | If a scan has a field-of-view (FOV) greater than 256, check this to force the FOV to 256. You often need to do this for image with sub 1mm voxel size (like HCP 7T) |
| `hippocampal` | boolean | `false` | (only for >7) Generate an automated segmentation of the hippocampal subfields based on a statistical atlas built primarily upon ultra-high resolution (~0.1 mm isotropic) ex vivo MRI data. This new method can take advantage high-resolution, dedicated images when available (typically, but not necessarily, T2 weighted), and solves a number of limitations of the in vivo atlas that was distributed with FreeSurfer 5.1-5.3, namely |
| `debug` | boolean | `false` | Turn on copious amount of freesurfer log |

<!-- brainlife-app:end -->

This is a Pegasus workflow for running FreeSurfer on the Open Science Grid, and replaces the *fsurf* service. The workflow is set up to take a directory with `.mgz` files as input and process each subject in parallel, using multicore jobs where appropriate.

Please run the workflow from your [OSG Connect](https://osgconnect.net/) account. Anybody with a U.S. research affiliation can get access.

You will need your own license file. See the [FreeSurfer documentation](https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall#License) for details on how to obtain the license. Once you have it, name it `license.txt` and put it in the same directory as you are submitting the workflow from, as Pegasus will pick up the file and send it with the jobs.

This is a community driven development effort - feel free to fork and submit pull requests if you have improvements you want to share with the community. Thank you!

## submit.sh usage

```
$ ./submit.sh --help
usage: submit.sh [-h] --inputs-def INPUTS_DEF [--cores NUM_CORES]
                 [--skip-recon] [--single-job] [--serial-job]
                 [--hemi {rh,lh}] [--debug]

Generate a pegasus workflow

optional arguments:
  -h, --help            show this help message and exit
  --inputs-def INPUTS_DEF
                        yaml based description of inputs
  --cores NUM_CORES     number of cores to use
  --skip-recon          Skip recon processing
  --single-job          Do all processing in a single job per subject
  --debug               Enable debugging output

```

## Specifying Inputs

What to process is specified in an YAML input file with the format:

```
samplename:
    input: /some/path/to/input-mgz-or-nii
    T2: /optional/path/to/T2
    autorecon-options: 
```

Only `samplename` and `input` is required. Multiple inputs can be provided.

An example is provided in the `example-run.yml` file:

```
THP0001:
    input: tests/sub-THP0001_ses-THP0001UCI1_run-01_T1w.nii.gz
    T2: tests/sub-THP0001_ses-THP0001UCI1_run-01_T2w.nii.gz
    autorecon-options: -cw256

sample-001:
    input: /cvmfs/singularity.opensciencegrid.org/opensciencegrid/osgvo-freesurfer:latest/opt/freesurfer-6.0.1/subjects/sample-001.mgz

```


## Submitting an Example Workflow

Check out this repository to your OSG Connect account $HOME directory. Put your `license.txt` in the top level directory and run:

```
$ ./submit.sh --inputs-def example-run.yml
```

The workflow will pick up the two samples as specified in the `example-run.yml` file, create a workflow and submit it. Once the workflow is running, you can check the status with `pegasus-status [wfdir]`. 

Outputs will be staged to `/local-scratch/$USER/workflows/outputs/`

## Getting Help

Please contact [OSG Connect Support](https://osgconnect.net) for any questions.


