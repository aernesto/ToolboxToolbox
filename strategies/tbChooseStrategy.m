function strategy = tbChooseStrategy(record, varargin)
% Choose a TbToolboxStrategy appropriate for the given toolbox record.
%
% strategy = tbChooseStrategy(record) chooses an implementaton of
% TbToolboxStrategy which is appropriate for obtaining and updating the
% toolbox represented by the given record struct.  For example, if the
% given record.type is "git", chooses TbGitStrategy.  Returns an instance
% of the chosen class.
%
% Uses a "short" list of recognized tooblox types, like "git".
% Alternatively, record.type may be the name of a TbToolboxStrategy
% sub-class, in which case the named class will be chosen.
%
% This function uses ToolboxToolbox shared parameters and preferences.  See
% tbParsePrefs().
%
% 2016 benjamin.heasly@gmail.com

prefs = tbParsePrefs(varargin{:});

parser = inputParser();
parser.addRequired('record', @isstruct);
parser.parse(record);
record = parser.Results.record;

strategy = [];

if ~isfield(record, 'type')
    return;
end


%% Check the short list of recognized types.
switch record.type
    case 'git'
        strategy = TbGitStrategy();
    case 'svn'
        strategy = TbSvnStrategy();
    case 'webget'
        strategy = TbWebGetStrategy();
    case 'local'
        strategy = TbLocalStrategy();
    case 'installed'
        strategy = TbInstalledStrategy();
    case 'docker'
        strategy = TbDockerStrategy();
    case 'include'
        strategy = TbIncludeStrategy();
    otherwise
        % default to "include", for easy shorthand
        strategy = TbIncludeStrategy();
end


%% Use type as class name.
if isempty(strategy) && 2 == exist(record.type, 'class')
    constructor = str2func(record.type);
    strategy = feval(constructor);
end


%% Let the strategy use preferences as of creation time.
if ~isempty(strategy)
    strategy.prefs = prefs;
end
