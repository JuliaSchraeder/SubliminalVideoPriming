import pandas as pd

# Load the three files
freespeech_features = pd.read_csv('W:/Fmri_Forschung/Allerlei/JuliaS/GitHub/SubliminalVideoPriming/data/speech/emocon_freespeech_features.csv')
emocon_to_bids = pd.read_excel('Desktop/EmoCon_to_Bids.xlsx')
id_to_emocon = pd.read_excel('Desktop/ID_to_EmoCon.xlsx')

# Merge the ID_to_EmoCon and EmoCon_to_Bids dataframes
id_to_bids = pd.merge(id_to_emocon, emocon_to_bids, left_on='Name', right_on='EmoCon_ID')

# Drop unnecessary columns
id_to_bids = id_to_bids[['ID', 'Bids-Nummer']]

# Rename columns for clarity
id_to_bids.columns = ['participant_id', 'bids_number']

# Merge with the freespeech features dataframe
freespeech_features_with_bids = pd.merge(freespeech_features, id_to_bids, on='participant_id', how='left')

# Save the updated dataframe to a new CSV file
freespeech_features_with_bids.to_csv('W:/Fmri_Forschung/Allerlei/JuliaS/GitHub/SubliminalVideoPriming/data/speech/freespeech_features_with_bids.csv', index=False)

print("The file has been saved successfully.")
