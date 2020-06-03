# Train Smart Instead of Hard with Systems and Control
**Bachelor's Thesis on System Identification using Matlab**
*Delft Center for Systems and Control, Delft University of Technology*

| Students          | Supervisors  |
|-------------------|------------- |
| Anne Brinkman     | Kim Batselier|
| Rooderick Ciggaar | Clara Menzen |
| Thami Fischer     | Manon Kok    |

## Dependencies
* Matlab
  * System Identifiaction Toolbox
  * Signals Processing Toolbox
* Git LFS (Large file transfer)

## Setup
in order to ease the use among groups of people, the `file` objects were created. These contain *strings* and *ints* that will be concatenated, such that sensor logs do not have to be loaded manually and can be swapped quickly. E.G.:

```
file.user = 'lphoo'; % Computer username
file.testrun = '5'; % testrun ID
file.freq = 100; % Frequency 4/50/100/200 Hz
file.start = '0756'; % starting time of file [hhmm]
file.end = '0910'; % ending time of file [hhmm]

file.name = strcat('COM_testrun',file.testrun,'_',string(file.freq),'HZ_',file.start,'_till_',file.end); %file name
file.path = strcat('C:\Users\',file.user,'\MATLAB Drive\Train Smart\Sensor Logs\',file.name,'.mat'); % file path on C:// drive
load(file.path); % import file
```
