# Visual Soft Object (fMRI study)

This repository contains code for running an fMRI passive-viewing experiment using cloth animations, as well as a localizer task for identifying physics-related regions of interest (ROIs). The code was used in the paper:

“Computational Modeling Reveals Dissociable Physics-Based and Statistical Object Representations in the Human Brain During Spontaneous Visual Processing.”


## 🖥️ System Requirements

This project has been tested with the following configurations:

| Operating System | MATLAB | Psychtoolbox |
|---|---|---|
| Ubuntu 20.04.4 LTS | R2021a | 3.0.18 |
| macOS Sequoia | R2021b | 3.0.18.13 |

## ⚙️ Running

1. Download the repository.
```bash
git clone https://github.com/CNCLgithub/cloth_fmri_exp.git
cd cloth_fmri_exp
```
2. Get the display parameters.
```bash
Run generate_cond_files.m
```

4. Run the experiment.
```bash
Run main.m
```
   




