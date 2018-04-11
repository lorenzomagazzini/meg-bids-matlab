function [ bidsdataset, bidsdataset_name, bidsdataset_dir ] = rename_meg2bids( rawdataset, bids )
%[bidsdataset, bidsdataset_name, bidsdataset_dir] = rename_meg2bids(rawdataset, bids)
% 
% This function takes the full path to a raw MEG dataset as input ("rawdataset") 
% and returns the corresponding full path to a BIDS-formatted MEG dataset ("bidsdataset").
% The function also returns the BIDS name ("bidsdataset_name") and BIDS directory 
% ("bidsdataset_dir") of the MEG BIDS dataset. The name (and directory tree structure)
% of the MEG dataset in BIDS format are determined by the fields specified in the 
% input structure "bids" (see below).
% 
% 
% Input:
% 
% rawdataset       	(string), full path to raw MEG dataset (file/folder), 
%                   including file extension (for example, *.ds, *.fif, etc.)
% 
% bids              (struct), with fields:
% 
% - dir            	(string) top-level directory of the BIDS dataset (not the 
%                   BIDS directory of the MEG datset). 
%                   NOTE: This needs to be an existing directory.
% 
% - participant_label (string), to complete the mandatory string sub-<participant_label>.
%                  	  For example, bids.participant_label = 'meguk001';
% 
% - task_label    	(string), to complete the mandatory string _task-<task_label>.
%                  	For example, bids.task_label = 'rest';
% 
% - [ses_label]    	(string), to complete the optional label [_ses-<label>]. 
%                   For example, bids.ses_label = '001'; 
%                   Or, for example, bids.ses_label = 'predrug';
%                   NOTE: This determines the BIDS tree structure for the directory 
%                   in which the MEG dataset will be stored.
%                   For example, <dir>/sub-<participant_label>/ses-<label>/meg/
%                   Or, for no session, <dir>/sub-<participant_label>/meg/
% 
% - [acq_label]    	(string), to complete the optional label [_acq-<label>]. 
%                   NOTE: I wonder if this is actually ever used for MEG ??
% 
% - [run_index]    	(string), to complete the optional label [_run-<index>].
%                   For example, bids.run_index = '01';
%                   Or, for .fif files over 2GB, bids.run_index = '01_part-01';
% 
% - [proc_label]    (string), to complete the optional label [_proc-<label>].
%                   For example, bids.proc_label = 'tsss'; (for .fif files)
% 
% - [meg_extension] (string), to complete the mandatory string _meg.<manufacturer_specific_extension>.
%                   For example, bids.meg_extension = 'ds';
%                   NOTE: for CTF and Elekta-Neuromag MEG systems, this field can be 
%                   determined automatically from the first input variable, "rawdataset".
% 
% 
% Output:
% 
% bidsdataset_name	(string), name of the MEG dataset (file/folder) in BIDS format.
% 
% bidsdataset_dir  	(string), full path to the BIDS directory in which the MEG dataset 
%                   should be stored. 
%                  	NOTE: The top-level directory of the BIDS dataset is specified
%                  	in "bids.dir". The directory tree is determined by the field 
%                   "bids.ses_label".

% Written by Lorenzo Magazzini, Jan 2018 (magazzinil@gmail.com)


%check extension of raw MEG dataset
% [rawdataset_dir, rawdataset_name, rawdataset_ext] = fileparts(rawdataset);
% if ~ismember(rawdataset_ext, {'.ds', '.fif', ''})
%     error('please specify a raw MEG dataset with valid extension');
% end
rawdataset_ext = check_megextension(rawdataset);

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

%task_label
if ~isfield(bids,'task_label') || isempty(bids.task_label)
    error('the field ''task_label'' is mandatory')
else
    bids_task_label = ['_task-' bids.task_label];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% optional fields %%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%ses_label (determines bidsdataset_dir, see below)
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

%run_index
if ~isfield(bids,'run_index') || isempty(bids.run_index)
    bids_run_index = '';
else
    bids_run_index = ['_run-' bids.run_index];
end

%proc_label
if ~isfield(bids,'proc_label') || isempty(bids.proc_label)
    bids_proc_label = '';
else
    bids_proc_label = ['_proc-' bids.proc_label];
end

%meg_extension
if ~isfield(bids,'meg_extension') || isempty(bids.meg_extension)
    bids_meg_extension = rawdataset_ext;
else %if isfield(bids,'meg_extension') && ~isempty(bids.meg_extension)
    bids_meg_extension = bids.meg_extension;
    if ~strcmp(bids_meg_extension, rawdataset_ext), error('please specify a raw MEG dataset with valid file extension'); end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% bids dataset path & name %%%%%%%%%%%%%%%%%%%%


%directory tree structure depends on whether session folder is required
if isempty(bids_ses_label)
    bidsdataset_dir = fullfile(bids_dir, bids_participant_label, 'meg');
else
    bidsdataset_dir = fullfile(bids_dir, bids_participant_label, bids_ses_label(2:end), 'meg');
end

%name of MEG dataset (file/folder)
bidsdataset_name = [bids_participant_label bids_ses_label bids_task_label bids_acq_label bids_run_index bids_proc_label '_meg' bids_meg_extension];

%full path to the MEG dataset within the BIDS dataset
bidsdataset = fullfile(bidsdataset_dir, bidsdataset_name);

