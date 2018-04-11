function [ bidsnifti, bidsnifti_name, bidsnifti_dir ] = rename_nii2bids( nifti, bids )
%function [ bidsnifti, bidsnifti_name, bidsnifti_dir ] = rename_nii2bids( nifti, bids )
% 
% This function takes the full path to a NIfTI MRI file as input ("nifti") 
% and returns the corresponding full path to a BIDS-formatted NIfTI ("bidsnifti").
% The function also returns the BIDS name ("bidsnifti_name") and BIDS directory 
% ("bidsnifti_dir") of the NIfTI BIDS file. The name (and directory tree structure)
% of the NIfTI in BIDS format are determined by the fields specified in the 
% input structure "bids" (see below).
% 
% 
% Input:
% 
% nifti             (string), full path to original NIfTI file, 
%                   including file extension (*.nii or *.nii.gz)
% 
% bids              (struct), with fields:
% 
% - dir            	(string) top-level directory of the BIDS dataset. 
%                   NOTE: This needs to be an existing directory.
% 
% - participant_label (string), to complete the mandatory string sub-<participant_label>.
%                  	  For example, bids.participant_label = 'meguk001';
% 
% - modality_label 	(string), to complete the mandatory string _<modality_label>.
%                  	For example, bids.modality_label = 'T1w';
% 
% - [ses_label]    	(string), to complete the optional label [_ses-<label>]. 
%                   For example, bids.ses_label = '001'; 
%                   Or, for example, bids.ses_label = 'predrug';
%                   NOTE: This determines the BIDS tree structure for the directory 
%                   in which the NIfTI file will be stored.
%                   For example, <dir>/sub-<participant_label>/ses-<label>/anat/
%                   Or, for no session, <dir>/sub-<participant_label>/anat/
% 
% - [acq_label]    	(string), to complete the optional label [_acq-<label>]. 
% 
% - [ce_label]    	(string), to complete the optional label [_ce-<label>]. 
% 
% - [rec_label]    	(string), to complete the optional label [_rec-<label>]. 
% 
% - [run_index]    	(string), to complete the optional label [_run-<index>].
%                   For example, bids.run_index = '01';
% 
% - [mod_label]     (string), to complete the optional label [_mod-<label>].
% 
% 
% Output:
% 
% bidsnifti_name	(string), name of the NIfTI file in BIDS format.
% 
% bidsnifti_dir  	(string), full path to the BIDS directory in which the NIfTI file 
%                   should be stored. 
%                  	NOTE: The top-level directory of the BIDS dataset is specified
%                  	in "bids.dir". The directory tree is determined by the field 
%                   "bids.ses_label".

% Written by Lorenzo Magazzini, Feb 2018 (magazzinil@gmail.com)


%check extension of original NIfTI file
gz_ext = '.gz';
[~, nifti_name, nifti_ext] = fileparts(nifti);
if strcmp(nifti_ext, gz_ext) %check if .gz (compressed)
    if ~strcmp(nifti_name(end-3:end),'.nii') %check if .nii.gz
        error(sprintf('unknown nifti file format ''%s%s''', nifti_name(end-3:end), gz_ext))
    end
elseif strcmp(nifti_ext,'.nii') %check if .nii (remove '.gz' label)
    gz_ext = '';
else
    error(sprintf('unknown nifti file format ''%s''', nifti_ext))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% mandatory fields %%%%%%%%%%%%%%%%%%%%%%%%%%%%


%bids_dir
if ~isfield(bids,'dir') || isempty(bids.dir) || ~exist(bids.dir,'dir')
    error('please specify a valid directory for field ''dir''')
else
    bids_dir = bids.dir;
    fprintf('the top-level directory for this BIDS dataset is %s\n', bids_dir)
end

%participant_label
if ~isfield(bids,'participant_label') || isempty(bids.participant_label)
    error('the field ''participant_label'' is mandatory')
else
    bids_participant_label = ['sub-' bids.participant_label];
end

%modality_label
if ~isfield(bids,'modality_label') || isempty(bids.modality_label)
    error('the field ''modality_label'' is mandatory')
else
    bids_modality_label = ['_' bids.modality_label];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% optional fields %%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%ses_label (determines bidsnifti_dir, see below)
if ~isfield(bids,'ses_label') || isempty(bids.ses_label)
    bids_ses_label = '';
else
    bids_ses_label = ['_ses-' bids.ses_label];
end

%acq_label
if ~isfield(bids,'acq_label') || isempty(bids.acq_label)
    bids_acq_label = '';
else
    bids_acq_label = ['_acq-' bids.acq_label];
end

%ce_label
if ~isfield(bids,'ce_label') || isempty(bids.ce_label)
    bids_ce_label = '';
else
    bids_ce_label = ['_ce-' bids.ce_label];
end

%rec_label
if ~isfield(bids,'rec_label') || isempty(bids.rec_label)
    bids_rec_label = '';
else
    bids_rec_label = ['_rec-' bids.rec_label];
end

%run_index
if ~isfield(bids,'run_index') || isempty(bids.run_index)
    bids_run_index = '';
else
    bids_run_index = ['_run-' bids.run_index];
end

%mod_label
if ~isfield(bids,'mod_label') || isempty(bids.mod_label)
    bids_mod_label = '';
else
    bids_mod_label = ['_mod-' bids.mod_label];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% bids dataset path & name %%%%%%%%%%%%%%%%%%%%


%directory tree structure depends on whether session folder is required
if isempty(bids_ses_label)
    bidsnifti_dir = fullfile(bids_dir, bids_participant_label, 'anat');
else
    bidsnifti_dir = fullfile(bids_dir, bids_participant_label, bids_ses_label(2:end), 'anat');
end

%name of NIfTI file
bidsnifti_name = [bids_participant_label bids_ses_label bids_acq_label bids_ce_label bids_rec_label bids_run_index bids_mod_label bids_modality_label '.nii' gz_ext];

%full path to NIfTI file within BIDS dataset
bidsnifti = fullfile(bidsnifti_dir, bidsnifti_name);

