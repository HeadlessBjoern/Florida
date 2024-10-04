%% Download Datafile from Eyelink Tracker
% The filename needs to be present in the variable edfFile
try
    fprintf('Receiving data file ''%s''\n', edfFile );
    status=Eyelink('ReceiveFile');
    if status > 0
        fprintf('ReceiveFile status %d\n', status);
    end
    if 2==exist(edfFile, 'file')
        movefile(edfFile,filePath);
        fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd);
    end
catch rdf
    fprintf('Problem receiving data file ''%s''\n', edfFile );
    rdf;
end