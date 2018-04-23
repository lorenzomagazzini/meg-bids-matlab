
clear

basepath = '/cubric/collab/meg-partnership/cardiff/';

rawdataset_dir = fullfile(basepath, '/exampledata/raw/example001');
rawdataset_name = 'example001_nback.ds';
rawdataset = fullfile(rawdataset_dir, rawdataset_name)

bids = struct;
bids.dir = fullfile(basepath, '/exampledata/bids');
bids.participant_label = '001';
bids.task_label = 'nback';

[bidsdataset] = rename_meg2bids(rawdataset, bids)

[bidsdataset_dir, bidsdataset_name, bidsdataset_ext] = write_meg2bids(rawdataset, bidsdataset)


orignifti_dir = fullfile(basepath, '/exampledata/raw/example001');
orignifti_name = 'example001.nii';
orignifti = fullfile(orignifti_dir, orignifti_name);

bids = struct;
bids.dir = fullfile(basepath, '/exampledata/bids');
bids.participant_label = '001';
bids.modality_label = 'T1w';

[bidsnifti] = rename_nii2bids(orignifti, bids);

[bidsnifti_dir, bidsnifti_name, bidsnifti_ext] = write_nii2bids(orignifti, bidsnifti);

