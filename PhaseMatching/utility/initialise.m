function [pathnames, N_channels, pathnameChMain, tifInfo, img_ref] = initialise(FolderPath, FilenameCh1, FilenameCh2, FilenameCh3, MainCh, Phase)
    pathnames = {
                strcat(FolderPath, FilenameCh1), ...
                strcat(FolderPath, FilenameCh2), ...
                strcat(FolderPath, FilenameCh3)
                };
    N_channels = sum([ ...
                    ~isempty(FilenameCh1), ...
                    ~isempty(FilenameCh2), ...
                    ~isempty(FilenameCh3) ...
                    ]);
    pathnameChMain = pathnames{MainCh};
    tifInfo = imfinfo(pathnameChMain);
    img_ref = imread(pathnameChMain, Phase);
end