function [ bidsdataset_dir, bidsdataset_name, bidsdataset_ext ] = write_meg2bids( rawdataset, bidsdataset )
%[bidsdataset_dir, bidsdataset_name, bidsdataset_ext] = write_meg2bids(rawdataset, bidsdataset)
%   
%   This function copies a raw MEG dataset (full path to file/folder specified 
%   in "rawdataset") and re-writes it as a BIDS MEG dataset (full path to 
%   file/folder specified in "bidsdataset").
% 	The command used to copy/rename the raw MEG dataset to BIDS depends on 
%   the extension of the raw MEG dataset:
%   "copyDs" for .ds directories (CTF)
%   "cp" for .fif files (Elekta/Neuromag)
%   "cp -r" for directories with no extensions (4d/BTi)

% Written by Lorenzo Magazzini, Jan 2018 (magazzinil@gmail.com)


%check raw MEG dataset
[rawdataset_ext, rawdataset_name, rawdataset_dir] = check_megextension(rawdataset);

%get file parts for BIDS MEG dataset
[bidsdataset_dir, bidsdataset_name, bidsdataset_ext] = fileparts(bidsdataset);

%assume current directory should be used, if a full path is NOT specified
if isempty(bidsdataset_dir)
    bidsdataset_dir = pwd;
    warning(sprintf('the BIDS MEG dataset will be created in the current working directory, %s', bidsdataset_dir))
else
    fprintf('the BIDS MEG dataset will be created in %s\n', bidsdataset_dir)
end

%create directory for BIDS MEG dataset, if it doesn't exist
if exist(bidsdataset_dir,'dir')==7
    fprintf('the BIDS ''meg'' directory already exists\n')
else
    fprintf('the BIDS ''meg'' directory is being created\n')
    s = mkdir(bidsdataset_dir);
    if s~=1, error; end
end

%print the name of the BIDS MEG dataset
fprintf('the BIDS MEG dataset will be renamed %s\n', [bidsdataset_name bidsdataset_ext])

%FIX-ME:
%add option to include flags in the Linux command ("copyDs", "cp", "cp -r", etc..)

%now copy and rename original dataset using newDs, cp, or something yet to be implemented...
switch rawdataset_ext
    case '.ds'
        fprintf('copying using the CTF command "copyDs" ...\n')
        s = unix(sprintf('copyDs %s %s', rawdataset, bidsdataset));
        if s~=0, error('error using copyDs'); end
    case '.fif'
        fprintf('copying using the Linux command "cp" ...\n')
        s = unix(sprintf('cp %s %s', rawdataset, bidsdataset));
        if s~=0, error('error using cp'); end
    case ''
        fprintf('copying using the Linux command "cp -r" ...\n')
        s = unix(sprintf('cp -r %s %s', rawdataset, bidsdataset));
        if s~=0, error('error using cp -r'); end
    otherwise
        error(sprintf('this function does not yet support MEG datasets with extension %s', rawdataset_ext))
end %switch
