# Visual Soft Object (fMRI study)

This repository contains code for running an fMRI passive viewing task with cloth animations, along with a localizer task for identifying physics-related regions of interest (ROIs).


## 🖥️ System Requirements

This project has been tested and is supported on the following configurations:

- Matlab R2021a
- Psychtoolbox 3.0.17
---

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
For cloth run: Run RunEventDesign.m
For block run: Run RunBlockDesign.m
```
   




