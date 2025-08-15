import pandas as pd
import os
import csv

# Function to detect delimiter
def detect_delimiter(file_path):
    with open(file_path, 'r', newline='') as csvfile:
        sample = csvfile.read(1024)
        sniffer = csv.Sniffer()
        try:
            dialect = sniffer.sniff(sample)
            return dialect.delimiter
        except csv.Error:
            return ','  # Default to comma if delimiter detection fails

# Define the directory containing the CSV files and the Excel file with group information
directory = 'W:/Fmri_Forschung/Allerlei/JuliaS/GitHub/SubliminalVideoPriming/data/behav_data'
group_info_path = 'W:/Fmri_Forschung/Allerlei/JuliaS/GitHub/SubliminalVideoPriming/data/Info_ID_Age_Gender_BDI_BVAQ_STAI_CERQ_DERS_TMT_WMS_HDS_DigitSpan.xlsx'
output_csv = 'W:/Fmri_Forschung/Allerlei/JuliaS/GitHub/SubliminalVideoPriming/data/ratings_by_condition_and_participant.csv'

# Read the group and sex information from the Excel file using openpyxl engine
group_info_df = pd.read_excel(group_info_path, usecols=['Bids-Nummer', 'Alter', 'Gender_f1_m2', 'Group_MDD1_HC2'], engine='openpyxl')
group_info_df.columns = ['participantID', 'age', 'sex', 'group']  # Rename columns for consistency

# Ensure the 'group' column is treated as strings
group_info_df['group'] = group_info_df['group'].astype(str)

# Update the group information to replace group indicators with MDD and HC
group_info_df['group'] = group_info_df['group'].replace({'Patientin': 'MDD', 'Patient': 'MDD', 'MDD1': 'MDD', 'HC2': 'HC'})

# Initialize an empty list to store DataFrames
df_list = []
rt_list = []
accuracy_list = []

# Custom function to compare key_resp.keys and corrAnsTar
def is_correct(row):
    try:
        if row['key_resp.keys'] != 'None' and float(row['key_resp.keys']) == row['corrAnsTar']:
            return 1
        else:
            return 0
    except ValueError:
        return 0

# Loop through each file in the directory
for filename in os.listdir(directory):
    if filename.endswith('.csv'):
        try:
            file_path = os.path.join(directory, filename)
            # Detect the delimiter used in the CSV file
            delimiter = detect_delimiter(file_path)
            
            # Read the CSV file with the detected delimiter, skipping the first 2 rows (practice trials)
            df_participant = pd.read_csv(file_path, delimiter=delimiter, skiprows=[1, 2], error_bad_lines=False, warn_bad_lines=True)
            
            # Extract participant ID from the first 7 letters of the filename
            participant_id = filename[:7]
            df_participant['participantID'] = participant_id
            
            # Create a new condition based on combinations of primerEmotion and targetEmotion
            df_participant['condition'] = df_participant.apply(
                lambda row: f"{row['primeEmotion']}_{row['targetEmotion']}", axis=1
            )
            
            # Filter out rows where no response was given
            df_participant_filtered = df_participant[df_participant['key_resp.keys'] != 'None'].copy()
            
            # Debug: Print some rows to inspect data before calculating correctness
            print(f"Data for participant {participant_id} before calculating correctness:")
            print(df_participant_filtered[['key_resp.keys', 'corrAnsTar']].head())
            
            # Calculate mean RT
            mean_rt = df_participant_filtered.groupby('condition')['key_resp.rt'].mean().reset_index()
            mean_rt['participantID'] = participant_id
            rt_list.append(mean_rt)
            
            # Calculate correct responses using custom function
            df_participant_filtered['correct'] = df_participant_filtered.apply(is_correct, axis=1)
            
            # Debug: Print some rows to inspect data after calculating correctness
            print(f"Data for participant {participant_id} after calculating correctness:")
            print(df_participant_filtered[['key_resp.keys', 'corrAnsTar', 'correct']].head())
            
            # Calculate mean accuracy as the percentage of correct responses
            mean_accuracy = df_participant_filtered.groupby('condition')['correct'].mean().reset_index()
            mean_accuracy['correct'] = mean_accuracy['correct'] * 100  # Convert to percentage
            mean_accuracy['participantID'] = participant_id
            accuracy_list.append(mean_accuracy)
            
            # Append the DataFrame to the list
            df_list.append(df_participant)
        except Exception as e:
            print(f"Error reading {filename}: {e}")

# Concatenate all DataFrames into a single DataFrame
df = pd.concat(df_list, ignore_index=True)

# Merge with group and sex information
df = df.merge(group_info_df, on='participantID', how='left')

# Group by participant ID, age, sex, group, condition, and Rating, then count occurrences
rating_counts = df.groupby(['participantID', 'age', 'sex', 'group', 'condition', 'Rating']).size().reset_index(name='Count')

# Pivot the table to get the counts in a more readable format
rating_pivot = rating_counts.pivot_table(index=['participantID', 'age', 'sex', 'group', 'condition'], columns='Rating', values='Count', fill_value=0)

# Concatenate all mean RT DataFrames into a single DataFrame
mean_rt_df = pd.concat(rt_list, ignore_index=True)

# Concatenate all mean accuracy DataFrames into a single DataFrame
mean_accuracy_df = pd.concat(accuracy_list, ignore_index=True)

# Merge mean RT and mean accuracy with the rating pivot table
final_df = rating_pivot.reset_index().merge(mean_rt_df, on=['participantID', 'condition'], how='left').merge(mean_accuracy_df, on=['participantID', 'condition'], how='left', suffixes=('_mean_rt', '_mean_accuracy'))

# Save the final DataFrame to a CSV file in the data folder
final_df.to_csv(output_csv, index=False)

# Display the final DataFrame
print("Ratings by Condition and Participant:")
print(final_df)
print(f"\nThe result has been saved to {output_csv}")