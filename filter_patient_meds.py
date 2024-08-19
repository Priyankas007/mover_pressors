import torch
import pandas as pd
import tarfile
import os
import matplotlib.pyplot as plt

# Get only patients that were on pressor medications
patient_meds = pd.read_csv('EPIC_EMR/EMR/patient_medications.csv', low_memory=False)
pressors = ['dopamine', 'vasopressin', 'dobutamine', 'epinephrine', 'norepinephrine']
pattern = '|'.join(pressors)
pressors_df = patient_meds[patient_meds['MEDICATION_NM'].str.contains(pattern, case=False, na=False)]patient_meds = pd.read_csv('EPIC_EMR/EMR/patient_medications.csv', low_memory=False)

# Get patients that were admitted to the ICU
patient_information = pd.read_csv('EPIC_EMR/EMR/patient_information.csv')
pressors_icu_df = pd.merge(pressors_df, patient_information[['LOG_ID', 'ICU_ADMIN_FLAG', 'SURGERY_DATE']], on='LOG_ID', how='left')

# Get patients that only started on pressors after their surgery
pressors_icu_df['SURGERY_DATE'] = pd.to_datetime(pressors_icu_df['SURGERY_DATE'], format='%m/%d/%y %H:%M')
pressors_icu_df['START_DATE'] = pd.to_datetime(pressors_icu_df['START_DATE'])
pressors_icu_df_filtered = pressors_icu_df[pressors_icu_df['SURGERY_DATE'] < pressors_icu_df['START_DATE']]
pressors_icu_df_filtered = pressors_icu_df_filtered[pressors_icu_df_filtered['ICU_ADMIN_FLAG'] == 'Yes']

pressors_icu_df_filtered.to_csv('patient_medications_pressors.csv', index=False)
