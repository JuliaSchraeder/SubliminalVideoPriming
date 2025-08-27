# Neural, Behavioral, and Speech Indicators of Mood-Congruent Bias in Major Depressive Disorder

[![DOI](https://img.shields.io/badge/DOI-10.23668/psycharchives.16330-blue)](https://doi.org/10.23668/psycharchives.16330)
[![License: CC BY 4.0](https://img.shields.io/badge/License-CC--BY--4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
[![Status: Preprint](https://img.shields.io/badge/Status-Preprint-orange.svg)](https://doi.org/10.23668/psycharchives.16330)

---

## 📖 About

This repository accompanies the preprint:

**Neural, Behavioral, and Speech Indicators of Mood-Congruent Bias in Major Depressive Disorder**  
Authors: *Julia Schräder¹²\**, Thilo Kellermann¹², Damin Kühn³, Lennard Rompelberg³, Michael T. Schaub³, Lisa Wagels¹²*  

¹ Department of Psychiatry, Psychotherapy and Psychosomatics, Faculty of Medicine, RWTH Aachen, Aachen, Germany  
² JARA-Translational Brain Medicine, Aachen, Germany  
³ Department of Computer Science, RWTH Aachen University, Germany  

Published as a preprint in *PsychArchives*.  
DOI: [10.23668/psycharchives.16330](https://doi.org/10.23668/psycharchives.16330)

The repository contains code, documentation, and supplementary material to reproduce parts of the analyses presented in the manuscript.

---

## ✨ Abstract

**Introduction:** MRI compatible EEG systems enable simultaneous EEG-fMRI data assessment, which provides high spatial and high temporal resolution of neural signaling data. Functional connectivity analyses suggest altered fronto-limbic emotion regulation in patients with major depressive disorder (MDD). 
**Methods:** Sixty patients with MDD and 66 healthy controls (HC) performed a priming task using unconsciously and consciously presented emotional facial expressions (happy, sad, neutral) performed a priming task using unconsciously and consciously presented emotional facial expressions. Effective connectivity of simultaneously recorded EEG-fMRI data between cortical (bilateral dorsolateral prefrontal cortex and fusiform gyrus) and subcortical regions (bilateral amygdala) was captured using dynamic causal modeling (DCM). Delineate stimulus-related changes in bottom-up and top-down neurophysiological networks across both EEG and fMRI data were estimated in models of unconscious and conscious processing, defined for both groups.
**Results:** Bayesian model selection favored a bottom-up processing model for both groups and input conditions (conscious and unconscious) in EEG-DCMs. Mixed top-down and bottom-up processing models best represented conscious and unconscious stimulus processing in HC fMRI-DCM, while bottom-up models were most representative for MDD fMRI data. Amygdala activity leads to higher DLPFC activity in conscious, and lower DLPFC activity in unconscious conditions in both groups. 
**Conclusion:** This study demonstrates the distinct capabilities of EEG and fMRI data through showing that EEG captures early and fast processing (bottom-up) while fMRI reflects both, bottom-up and top-down regulation. Activity reduction of DLPFC through FFA bottom-up connectivity in early processing (EEG-DCM) might inhibit later top-down emotion regulation through the DLPFC in MDD (fMRI-DCM).


---

## 📂 Repository Structure

- `scriüts/` – analysis scripts (EEG-fMRI preprocessing, statistical models, etc.)  
- `data/` – example datasets or links to external data repositories (if available)  

---

## 📑 Citation

If you use this repository or build upon it, please cite the preprint:

```bibtex
@article{Schraeder2025MoodBias,
  title   = {Neural, Behavioral, and Speech Indicators of Mood-Congruent Bias in Major Depressive Disorder},
  author  = {Schräder, Philipp and Wagels, Lisa and ...},
  year    = {2025},
  journal = {PsychArchives},
  doi     = {10.23668/psycharchives.16330}
}
