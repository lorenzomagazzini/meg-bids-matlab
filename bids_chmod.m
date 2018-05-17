function [  ] = bids_chmod( bids_path, permissions, recursive, extension )
%[  ] = bids_chmod( bids_path, permissions, recursive, extension )
% 
% This function can be used to change file access permissions in a BIDS
% directory tree, for data stored on the CUBRIC system, using the Linux
% command chmod.
% 
% Input:
%   bids_path       string, path to top-level directory of BIDS dataset.
%   permissions     struct, see example below. Set permissions for each directory/file in the BIDS dataset.
%   recursive       struct, see example below. Set permissions recursively or not.
%   extension       struct, see example below. Define file extension of MEG dataset.
% 
% Example:
%     permissions = struct;
%     permissions.bids = '750';
%     permissions.sub = '750';
%     permissions.anat = '750';
%     permissions.nii = '550';
%     permissions.meg = '750';
%     permissions.ds = '550';
%     recursive = struct;
%     recursive.ds = true; %set permissions of MEG dataset directory recursively
%     extension = struct;
%     extension.ds = '.ds';

% Written by Lorenzo Magazzini (magazzinil@gmail.com)
% Updated May 2018


%%

%definitions
if isfield(permissions,'bids'),     bids_p = permissions.bids; end
if isfield(recursive,'bids'),       bids_r = recursive.bids; else  	bids_r = false; end %default
if isfield(permissions,'sub'),      sub_p = permissions.sub; end
if isfield(recursive,'sub'),        sub_r = recursive.sub; else     sub_r = false; end %default
if isfield(permissions,'ses'),      ses_p = permissions.ses; error('setting permissions at the session level is not yet implemented'); end
if isfield(recursive,'ses'),        ses_r = recursive.ses; else     ses_r = false; end %default
if isfield(permissions,'anat'),     anat_p = permissions.anat; end
if isfield(recursive,'anat'),       anat_r = recursive.anat; else   anat_r = false; end %default
if isfield(permissions,'nii'),     	nii_p = permissions.nii; end
% if isfield(recursive,'nii'),        nii_r = recursive.nii; end %no recursive option for nifti files
if isfield(permissions,'meg'),      meg_p = permissions.meg; end
if isfield(recursive,'meg'),        meg_r = recursive.meg; else     meg_r = false; end %default
if isfield(permissions,'ds'),       ds_p = permissions.ds; end
if isfield(recursive,'ds'),         ds_r = recursive.ds; else       ds_r = false; end %default
if isfield(extension,'ds'),         ds_e = extension.ds; end %MEG dataset extension


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%path to BIDS dataset
D = bids_path; %directory
P = bids_p; %permissions

%set recursive option
if bids_r == true
    R = ' -R';
    S = ' recursively';
else
    R = ''; %recursive flag
    S = ''; %recursive string
end

%change permissions at the bids directory level
s = unix(['chmod' R ' ' P ' ' D]);
if s~=0, error(sprintf('error setting permissions in %s', D)); end
fprintf('changed permissions to %s%s in %s\n', P, S, D)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%get subject directories
dir_struct = dir(fullfile(bids_path, 'sub*'));
dir_struct(~[dir_struct.isdir]) = []; %remove non-directories
meguk_id_list = {dir_struct(:).name}'; %list MEGUK IDs
nsubj = length(meguk_id_list);
clear dir_struct

%set recursive option
if sub_r == true
    R = ' -R';
    S = ' recursively';
else
    R = ''; %recursive flag
    S = ''; %recursive string
end

%loop over subject directories
for isubj = 1:nsubj
    
    %MEGUK ID
    meguk_id = meguk_id_list{isubj};
    
    %path to subject directory
    sub_dir = fullfile(bids_path, meguk_id);
    D = sub_dir; %directory
    P = sub_p; %permissions
    
    %change permissions at the subject directory level
    s = unix(['chmod' R ' ' P ' ' D]);
    if s~=0, error(sprintf('error setting permissions in %s', D)); end
    fprintf('changed permissions to %s%s in %s\n', P, S, D)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %FIX-ME:
    %set permissions for multiple /ses-*/ directories
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %path to anat directory
    anat_dir = fullfile(bids_path, meguk_id, 'anat');
    D = anat_dir; %directory
    P = anat_p; %permissions
    
    %set recursive option
    if anat_r == true
        R = ' -R';
        S = ' recursively';
    else
        R = ''; %recursive flag
        S = ''; %recursive string
    end
    
    if exist(D,'dir')
        
        %change permissions at the anat directory level
        s = unix(['chmod' R ' ' P ' ' D]);
        if s~=0, error(sprintf('error setting permissions in %s', D)); end
        fprintf('changed permissions to %s%s in %s\n', P, S, D)
        
    else
        
        warning(sprintf('skipping directory %s because it doesn''t exist', D))
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %get NIfTIs for each participant
    dir_struct = dir(fullfile(anat_dir, '*.nii*'));
    nnii = length(dir_struct);
    
    %loop over individual nifti files
    for inii = 1:nnii
        
        %define nifti filename
        nii_file = fullfile(anat_dir, dir_struct(inii).name);
        F = nii_file; %directory
        P = nii_p; %permissions
        
        %change permissions at the nifti file level
        s = unix(['chmod ' P ' ' F]);
        if s~=0, error(sprintf('error setting permissions for %s', F)); end
        fprintf('changed permissions to %s for %s\n', P, F)
        
    end
    clear dir_struct
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %path to meg directory
    meg_dir = fullfile(bids_path, meguk_id, 'meg');
    D = meg_dir; %directory
    P = meg_p; %permissions
    
    %set recursive option
    if meg_r == true
        R = ' -R';
        S = ' recursively';
    else
        R = ''; %recursive flag
        S = ''; %recursive string
    end
    
    if exist(D,'dir')
        
        %change permissions at the meg directory level
        s = unix(['chmod' R ' ' P ' ' D]);
        if s~=0, error(sprintf('error setting permissions in %s', D)); end
        fprintf('changed permissions to %s%s in %s\n', P, S, D)
        
    else
        
        warning(sprintf('skipping directory %s because it doesn''t exist', D))
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    switch ds_e %MEG dataset extension
        
        case '.ds'
            
            %get tasks for each participant
            dir_struct = dir(fullfile(meg_dir, ['*' ds_e]));
            ntask = length(dir_struct);
            
            %set recursive option
            if ds_r == true
                R = ' -R';
                S = ' recursively';
            else
                R = ''; %recursive flag
                S = ''; %recursive string
            end
            
            %loop over individual datasets
            for itask = 1:ntask
                
                %define dataset name
                ds_dir = fullfile(meg_dir, dir_struct(itask).name);
                D = ds_dir; %directory
                P = ds_p; %permissions
                
                %change permissions at the dataset .ds directory level
                s = unix(['chmod' R ' ' P ' ' D]);
                if s~=0, error(sprintf('error setting permissions in %s', D)); end
                fprintf('changed permissions to %s%s in %s\n', P, S, D)
                
            end
            clear dir_struct
            
        case '.fif'
            
            %get tasks for each participant
            dir_struct = dir(fullfile(meg_dir, ['*' ds_e]));
            ntask = length(dir_struct);
            
            %set recursive option
            if ds_r == true
                R = ' -R';
                S = ' recursively';
            else
                R = ''; %recursive flag
                S = ''; %recursive string
            end
            
            %loop over individual datasets
            for itask = 1:ntask
                
                %define dataset name
                ds_file = fullfile(meg_dir, dir_struct(itask).name);
                D = ds_file; %filepath
                P = ds_p; %permissions
                
                %change permissions at the dataset .ds directory level
                s = unix(['chmod' R ' ' P ' ' D]);
                if s~=0, error(sprintf('error setting permissions for %s', D)); end
                fprintf('changed permissions to %s%s for %s\n', P, S, D)
                
            end
            clear dir_struct
        
        otherwise
        
            error(sprintf('MEG extension ''%s'' not yet implemented. Allowed extensions are ''%s'' and ''%s''', ds_e, '.ds', '.fif'))
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end
