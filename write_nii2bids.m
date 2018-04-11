function [ bidsnifti_dir, bidsnifti_name, bidsnifti_ext ] = write_nii2bids( orignifti, bidsnifti )
%[ bidsnifti_dir, bidsnifti_name, bidsnifti_ext ] = write_nii2bids( orignifti, bidsnifti )
%   
%   This function copies a NIfTI file (full path to file specified 
%   in "orignifti") and re-writes it into a BIDS dataset (full path to 
%   file specified in "bidsnifti").
% 	The command used to copy/rename the original NIfTI to BIDS is: 
%   "cp" for .nii or .nii.gz files

% Written by Lorenzo Magazzini, Feb 2018 (magazzinil@gmail.com)


%get file parts for BIDS NIfTI file
[bidsnifti_dir, bidsnifti_name, bidsnifti_ext] = fileparts(bidsnifti);

%check the user is not expecting this function to compress the original NIfTI
[~, ~, orignifti_ext] = fileparts(bidsnifti);
if ~strcmp(orignifti_ext, bidsnifti_ext)
    error(sprintf('nifti file formats ''%s'' and ''%s'' don''t seem to match', orignifti_ext, bidsnifti_ext))
end

%check extension of NIfTI BIDS file
gz_ext = '.gz';
if strcmp(bidsnifti_ext, gz_ext) %check if .gz (compressed)
    if ~strcmp(bidsnifti_name(end-3:end),'.nii') %check if .nii.gz
        error(sprintf('unknown nifti file format ''%s%s''', bidsnifti_name(end-3:end), gz_ext))
    else
        bidsnifti_name = bidsnifti_name(1:end-4);
        bidsnifti_ext = ['.nii' gz_ext];% '.nii.gz'
    end
elseif strcmp(bidsnifti_ext,'.nii') %check if .nii (remove '.gz' label)
    gz_ext = '';
else
    error(sprintf('unknown nifti file format ''%s''', bidsnifti_ext))
end

%assume current directory should be used, if a full path is NOT specified
if isempty(bidsnifti_dir)
    bidsnifti_dir = pwd;
    warning(sprintf('the BIDS NIfTI file will be copied to the current working directory, %s', bidsnifti_dir))
else
    fprintf('the BIDS NIfTI file will be copied to %s\n', bidsnifti_dir)
end

%create directory for BIDS NIfTI file, if it doesn't exist
if exist(bidsnifti_dir,'dir')==7
    fprintf('the BIDS ''anat'' directory already exists\n')
else
    fprintf('the BIDS ''anat'' directory is being created\n')
    s = mkdir(bidsnifti_dir);
    if s~=1, error; end
end

%print the name of the BIDS NIfTI file
fprintf('the BIDS NIfTI file will be renamed %s\n', [bidsnifti_name bidsnifti_ext])

%FIX-ME:
%add option to include flags in the Linux command ("cp", "rsync", etc..)

%now copy and rename original file using cp, or something yet to be implemented...
fprintf('copying using the Linux command "cp" ...\n')
s = unix(sprintf('cp %s %s', orignifti, bidsnifti));
if s~=0, error('error using cp'); end
