import pandas as pd

# Manually read and parse the speech features file
with open('/mnt/data/freespeech_features_with_bids.csv', 'r') as file:
    lines = file.readlines()

# Extract the header and data
header = lines[0].strip().split(';')
data = [line.strip().split(';') for line in lines[1:]]

# Create the dataframe
speech_features_with_bids = pd.DataFrame(data, columns=header)

# Load the demographic info file
demographic_info = pd.read_excel('/mnt/data/Info_ID_Age_Gender_BDI_BVAQ_STAI_CERQ_DERS_TMT_WMS_HDS_DigitSpan.xlsx')

# Rename the column in demographic_info to match the column name in speech_features_with_bids
demographic_info.rename(columns={'Bids-Nummer': 'bids_number'}, inplace=True)

# Merge the two dataframes on the 'bids_number' column
combined_df = pd.merge(speech_features_with_bids, demographic_info, on='bids_number', how='left')

# Save the combined dataframe to a new CSV file
combined_df.to_csv('/mnt/data/combined_speech_demographic_info.csv', index=False)

print("The combined file has been saved successfully.")

