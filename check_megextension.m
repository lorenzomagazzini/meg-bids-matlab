function [ rawdataset_ext, rawdataset_name, rawdataset_dir ] = check_megextension( rawdataset )
%[rawdataset_ext, rawdataset_name, rawdataset_dir] = check_megextension(rawdataset)
% 
%   This function checks a raw MEG dataset based on its extension (full path to 
%   file/folder specified in "rawdataset"). Valid extensions are:
%   .ds, for CTF directories
%   .fif, for Elekta/Neuromag files
%   no extension, for 4D/BTi directories

% Written by Lorenzo Magazzini, Jan 2018 (magazzinil@gmail.com)


%get file parts
[rawdataset_dir, rawdataset_name, rawdataset_ext] = fileparts(rawdataset);


%check extension of MEG dataset and guess corresponding MEG manufacturer
switch rawdataset_ext
    
    case '.ds'
        
        %check if the .ds MEG dataset is a directory
        if isdir(rawdataset)~=1
            error(sprintf('the input argument "rawdataset" should be a string specifying the full path to an existing MEG dataset (a CTF %s directopry)', rawdataset_ext));
        end
        
        %feedback
        fprintf('the raw MEG dataset %s looks like a CTF %s directory\n', rawdataset_name, rawdataset_ext)
        
    case '.fif'
        
        %check if the .fif MEG dataset is a file
        if exist(rawdataset,'file')~=2
            error(sprintf('the input argument "rawdataset" should be a string specifying the full path to an existing MEG dataset (an Elekta/Neuromag %s file)', rawdataset_ext));
        end
        
        %feedback
        fprintf('the raw MEG dataset %s looks like an Elekta-Neuromag %s file\n', rawdataset_name, rawdataset_ext)
        
    case ''
        
        %check if the MEG dataset is a directory (for 4D/BTi)
        if isdir(rawdataset)~=1
            error(sprintf('the input argument "rawdataset" should be a string specifying the full path to an existing MEG dataset (probably a 4D/BTi directory)'));
        end
        
        %feedback
        fprintf('the raw MEG dataset %s looks like a 4D/BTi directory with no file extension\n', rawdataset_name)
        
    otherwise
        
        %file extension not yet implemented
        error('please specify a raw MEG dataset with valid extension');
        
end %switch


