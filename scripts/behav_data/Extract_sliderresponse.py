import pandas as pd
import os

# Define the directory containing the CSV files
directory = 'W:/Fmri_Forschung/Allerlei/JuliaS/GitHub/SubliminalVideoPriming/data/behav_data'

# Initialize an empty list to store DataFrames
df_list = []

# Loop through each file in the directory
for filename in os.listdir(directory):
    if filename.endswith('.csv'):
        try:
            # Read the CSV file with error handling
            df_participant = pd.read_csv(os.path.join(directory, filename), on_bad_lines='skip', warn_bad_lines=True)
            
            # Optionally, extract participant ID from filename or add it as a new column
            participant_id = filename.split('.')[0]  # Assuming filename is the participant ID
            df_participant['participantID'] = participant_id
            
            # Append the DataFrame to the list
            df_list.append(df_participant)
        except Exception as e:
            print(f"Error reading {filename}: {e}")

# Concatenate all DataFrames into a single DataFrame
df = pd.concat(df_list, ignore_index=True)

# Group by participant ID, primerEmotion, targetEmotion, and Rating, then count occurrences
rating_counts = df.groupby(['participantID', 'primerEmotion', 'targetEmotion', 'Rating']).size().reset_index(name='Count')

# Pivot the table to get the counts in a more readable format
rating_pivot = rating_counts.pivot_table(index=['participantID', 'primerEmotion', 'targetEmotion'], columns='Rating', values='Count', fill_value=0)

# Display the final DataFrame
import ace_tools as tools; tools.display_dataframe_to_user(name="Ratings by Condition and Participant", dataframe=rating_pivot)