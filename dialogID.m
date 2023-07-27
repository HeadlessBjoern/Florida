% Create dialog box to record subject data
defAns = {'99','XX','99','X', 'X', 'X'};
while true
    prompt = {'Subject Number', 'Subject Initials', 'Subject Age', 'Subject Gender', 'EEG Cap Size', 'Ocular Dominance'};
    box = inputdlg(prompt, 'Enter Subject Information', 1,defAns);
    subject.ID = char(box(1));
    subject.initials = char(box(2));
    subject.age = char(box(3));
    subject.gender = char(box(4));
    subject.capsize = char(box(5));
    subject.ocDom = char(box(6));
    if length(subject.ID) == 2 && length(subject.initials) == 2               % Ensure response made in subject ID
        break
    end
end

% Convert subject data to numeric
subject.ID = str2num(subject.ID);
subjectID = subject.ID;
subject.age = str2num(subject.age);
