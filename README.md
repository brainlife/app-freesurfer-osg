<h1 align="center">FreeSurfer on OSG</h1>

<p align="center">
  A FreeSurfer recon-all subject directory from a T1-weighted image, computed as a Pegasus workflow on the Open Science Grid.
</p>

<p align="center">
  <a href="https://github.com/brainlife/abcd-spec"><img src="https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg" alt="ABCD Spec v1.1"></a>
  <a href="https://doi.org/10.25663/brainlife.app.268"><img src="https://img.shields.io/badge/Brainlife-brainlife.app.268-blue.svg" alt="Run on brainlife.io"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-lightgrey.svg" alt="MIT license"></a>
</p>

## 🧠 At a glance

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

> **Runs FreeSurfer recon-all on a T1-weighted image (optionally with a T2w) as a Pegasus workflow on the Open Science Grid, producing a FreeSurfer subject directory.**

Uses ABCD start/status/stop hooks to submit a Pegasus workflow to the Open Science Grid that runs recon-all with the selected FreeSurfer version and options (hires, notalcheck, cw256, debug, optional hippocampal subfields). Use it to offload FreeSurfer reconstruction to OSG resources; it needs a FreeSurfer license and only runs where OSG submission is configured.

| | |
|---|---|
| 📥 **Inputs** | `neuro/anat/t1w` · `neuro/anat/t2w` (optional) |
| 📤 **Outputs** | `neuro/freesurfer` |
| 🔗 **Run it** | [doi.org/10.25663/brainlife.app.268](https://doi.org/10.25663/brainlife.app.268) |

#### 📥 Inputs

| Input | Datatype | Required | Description |
|---|---|---|---|
| `t1` | `neuro/anat/t1w` | yes | Whole-head T1-weighted image to reconstruct. Submillimetre images need the hires parameter; a field of view over 256 mm needs cw256. |
| `t2` | `neuro/anat/t2w` | no | Optional T2-weighted image of the same subject, passed to recon-all to refine the pial surface. |

#### 📤 Outputs

| Output | Datatype | Description |
|---|---|---|
| `freesurfer` | `neuro/freesurfer` | FreeSurfer subject directory (mri, surf, label, stats, scripts) produced by recon-all. |

<details>
<summary><b>⚙️ Parameters</b> (6)</summary>

| Parameter | Type | Default | Description |
|---|---|---|---|
| `version` | enum | `6.0.1` | Freesurfer version to use Options: `6.0.0`, `6.0.1`. |
| `hires` | boolean | `false` | Check this flag if your input t1 has voxel sizes less than 1mm3 (submillimeter resolution) like HCP 7T. (HCP 3T is 1.25mm). The processing will take a significantly longer time. See https://surfer.nmr.mgh.harvard.edu/fswiki/SubmillimeterRecon |
| `notalcheck` | boolean | `false` | If you are seeing "ERROR: Talairach failed", you might be able to work around this by setting this option so that freesurfer will skip this process. If you set this option, you will need to make sure that your image is well aligned to the 3 primary axis. |
| `cw256` | boolean | `false` | If a scan has a field-of-view (FOV) greater than 256, check this to force the FOV to 256. You often need to do this for image with sub 1mm voxel size (like HCP 7T) |
| `hippocampal` | boolean | `false` | (only for >7) Generate an automated segmentation of the hippocampal subfields based on a statistical atlas built primarily upon ultra-high resolution (~0.1 mm isotropic) ex vivo MRI data. This new method can take advantage high-resolution, dedicated images when available (typically, but not necessarily, T2 weighted), and solves a number of limitations of the in vivo atlas that was distributed with FreeSurfer 5.1-5.3, namely |
| `debug` | boolean | `false` | Turn on copious amount of freesurfer log |

</details>

<!-- brainlife-app:end -->

## 🏷️ Versions on brainlife.io

| Version | Branch | Run it | Status |
|---|---|---|---|
| Freesurfer on OSG (Pegasus workflow) | [`master`](https://github.com/brainlife/app-freesurfer-osg/tree/master) | [doi:10.25663/brainlife.app.268](https://doi.org/10.25663/brainlife.app.268) | current |
| Freesurfer on OSG (fsurf) | [`master`](https://github.com/brainlife/app-freesurfer-osg/tree/master) | [doi:10.25663/bl.app.49](https://doi.org/10.25663/bl.app.49) | deprecated |

OSG no longer supports the *fsurf* service; this Pegasus workflow replaces it.

## 🔬 How it works

This is a [Pegasus](https://pegasus.isi.edu/) workflow for running FreeSurfer on the [Open Science Grid](https://osg-htc.org/) (OSG). Instead of a single `main` script, the App uses ABCD `start`, `status` and `stop` hooks (see `package.json`):

- `start.sh` writes the inputs and recon-all options into a workflow description (`run.yml`), generates the workflow with `workflow-generator.py` for the selected FreeSurfer version, and plans and submits it with `pegasus-plan`.
- `status.sh` reports progress with `pegasus-status` and, when the workflow succeeds, unpacks the outputs into `freesurfer/`.
- `stop.sh` removes the running workflow with `pegasus-remove`.

The workflow splits recon-all into steps (`scripts/autorecon1.sh`, `autorecon2.sh`, `autorecon3.sh`, …) and uses multicore jobs where appropriate.

## 🚀 Running the App

### ☁️ On brainlife.io

Open the App at [doi.org/10.25663/brainlife.app.268](https://doi.org/10.25663/brainlife.app.268), choose a T1-weighted dataset (and optionally a T2-weighted one) from your project, set the options and press **Execute**. The App only runs on resources where OSG submission is configured. The FreeSurfer subject directory is archived to your project as a `neuro/freesurfer` dataset.

Options:

- `version`: FreeSurfer 6.0.0 or 6.0.1 (default).
- `hires`: for T1 images with voxels smaller than 1 mm³ (submillimetre data such as HCP 7T; HCP 3T is 1.25 mm). Processing takes much longer. See [SubmillimeterRecon](https://surfer.nmr.mgh.harvard.edu/fswiki/SubmillimeterRecon).
- `notalcheck`: skip the Talairach check (see Troubleshooting).
- `cw256`: force the field of view to 256 when it is larger; often needed for submillimetre data.
- `hippocampal`: segment the hippocampal subfields.
- `debug`: verbose FreeSurfer logs.

### On OSG Connect, outside brainlife.io

You can also run the workflow directly from an [OSG Connect](https://osgconnect.net/) account; anybody with a U.S. research affiliation can get access. You need your own [FreeSurfer license](https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall#License): name it `license.txt` and put it in the directory you submit the workflow from, so that Pegasus sends it with the jobs.

Describe what to process in a YAML file. Only the sample name and `input` are required, and several samples can be listed:

```yaml
samplename:
    input: /some/path/to/input-mgz-or-nii
    T2: /optional/path/to/T2
    autorecon-options:
```

`example-run.yml` processes the two test images in `tests/`:

```yaml
THP0001:
    input: tests/sub-THP0001_ses-THP0001UCI1_run-01_T1w.nii.gz
    T2: tests/sub-THP0001_ses-THP0001UCI1_run-01_T2w.nii.gz
    autorecon-options: -cw256

sample-001:
    input: /cvmfs/singularity.opensciencegrid.org/opensciencegrid/osgvo-freesurfer:latest/opt/freesurfer-6.0.1/subjects/sample-001.mgz
```

Check out this repository in your OSG Connect `$HOME`, put `license.txt` in the top-level directory and submit:

```bash
./submit.sh --inputs-def example-run.yml
```

`submit.sh` also takes `--cores`, `--skip-recon`, `--single-job` (all processing in one job per subject), `--serial-job`, `--hemi {rh,lh}` and `--debug`; run `./submit.sh --help` for details. Once the workflow is running, check it with `pegasus-status [wfdir]`. Outputs are staged to `/local-scratch/$USER/workflows/outputs/`.

### Through the brainlife.io hooks

To run the brainlife.io hooks yourself on an OSG submit host, export your license as `FREESURFER_LICENSE`, create `config.json` (see `config.json.sample`) and call `./start.sh`, then `./status.sh` until it reports completion:

```json
{
    "t1": "/input/t1/t1.nii.gz",
    "t2": "/input/t2/t2.nii.gz",
    "version": "6.0.1",
    "hippocampal": false,
    "notalcheck": false,
    "hires": false,
    "cw256": false,
    "debug": false
}
```

## 📦 Outputs

`freesurfer/output/` is a standard FreeSurfer subject directory:

```text
freesurfer/output/
├── label/     cortical labels and annotations
├── mri/       volumes: T1, brainmask, aseg, aparc+aseg, …
├── scripts/   recon-all logs
├── stats/     aseg.stats, lh/rh.aparc.stats, …
└── surf/      white, pial, inflated and sphere surfaces
```

## 🩺 Troubleshooting

- **`ERROR: Talairach failed`**: set `notalcheck` to skip the Talairach check, and make sure the image is well aligned to the three primary axes.
- **`Please set FREESURFER_LICENSE in .bashrc`**: the hooks need your FreeSurfer license in the `FREESURFER_LICENSE` environment variable.
- **Questions about OSG Connect**: contact [OSG Connect Support](https://osgconnect.net).

## 📚 Citing

> [!TIP]
> If you use this App in your work, please cite the App, the software it builds on and brainlife.io (below). GitHub's **Cite this repository** button gives the App citation in APA and BibTeX.

- Fischl B. FreeSurfer. *NeuroImage* 62(2):774–781 (2012). [doi:10.1016/j.neuroimage.2012.01.021](https://doi.org/10.1016/j.neuroimage.2012.01.021)
- Freesurfer on OSG. brainlife.io App. [doi:10.25663/brainlife.app.268](https://doi.org/10.25663/brainlife.app.268)
- Hayashi S, Caron BA, Heinsfeld AS, et al. brainlife.io: a decentralized and open-source cloud platform to support neuroscience research. *Nature Methods* 21:809–813 (2024). [doi:10.1038/s41592-024-02237-2](https://doi.org/10.1038/s41592-024-02237-2)
- Avesani P, McPherson B, Hayashi S, et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. *Scientific Data* 6:69 (2019). [doi:10.1038/s41597-019-0073-y](https://doi.org/10.1038/s41597-019-0073-y)

## 👥 Authors

- Soichi Hayashi

This is a community-driven effort: feel free to fork the repository and open pull requests with improvements you want to share.

## 💰 Funding

[![Wellcome-226486/Z/22/Z](https://img.shields.io/badge/Wellcome-226486%2FZ%2F22%2FZ-purple.svg)](https://wellcome.org/)
[![NIH-NINDS-U24NS140384](https://img.shields.io/badge/NIH_NINDS-U24NS140384-green.svg)](https://reporter.nih.gov/project-details/11261037)
[![NIH-NINDS-UM1NS132207](https://img.shields.io/badge/NIH_NINDS-UM1NS132207-green.svg)](https://reporter.nih.gov/project-details/11411328)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://reporter.nih.gov/project-details/10262925)
[![NIH-NIBIB-R01EB030896](https://img.shields.io/badge/NIH_NIBIB-R01EB030896-green.svg)](https://reporter.nih.gov/project-details/10428625)
[![NIH-NIMH-R01MH126699](https://img.shields.io/badge/NIH_NIMH-R01MH126699-green.svg)](https://reporter.nih.gov/project-details/10460628)
[![NIH-NIDCD-R01DC020088](https://img.shields.io/badge/NIH_NIDCD-R01DC020088-green.svg)](https://reporter.nih.gov/project-details/11140284)
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-2203524](https://img.shields.io/badge/NSF_BCS-2203524-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2203524)
[![NSF-IIS-1636893](https://img.shields.io/badge/NSF_IIS-1636893-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-OAC-2148729](https://img.shields.io/badge/NSF_OAC-2148729-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148729)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NSF-IIS-2148700](https://img.shields.io/badge/NSF_IIS-2148700-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148700)
[![NSF-OAC-1916518](https://img.shields.io/badge/NSF_OAC-1916518-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1916518)

<sub>brainlife.io is publicly funded, and acknowledging that support helps keep it running. This App was developed with support from Wellcome, the U.S. National Institutes of Health (including the BRAIN Initiative BRAIN CONNECTS program: The Axonal Projectome EXchange, U24NS140384, and the Center for Mesoscale Connectomics, UM1NS132207) and the U.S. National Science Foundation.</sub>

## ⚖️ License

This repository does not include a license file. FreeSurfer is distributed under its own [license](https://surfer.nmr.mgh.harvard.edu/fswiki/FreeSurferSoftwareLicense).
