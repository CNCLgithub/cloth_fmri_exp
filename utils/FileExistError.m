function FileExistError(fpath)
    if ~isempty(dir(fpath))
        default = 'n';
        del_cur_f = 'n';
        while (strcmp(del_cur_f, 'y') ~= 1)
            del_cur_f = input(sprintf('\nFile already exists, \''y\'' to delete it \n  ==> %s \n :', fpath), 's');
            if (isempty(del_cur_f)), del_cur_f = default; end
        end
        delete(fpath);
        fprintf('\nFile deleted!\n');
    end
end