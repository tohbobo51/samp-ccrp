#define GOV:: gov_

enum eGovLevel {
    GOV::Staff,
    GOV::Council,
    GOV::DeputyMayor,
    GOV::Mayor,
    GOV::MaxLevel
}

new GOV::Title[GOV::MaxLevel][Faction::MAX_NAME] = {
    "Staff",
    "Council",
    "Deputy Mayor",
    "Mayor"
};

new Float:GOV::InfoCheckpoint[] = {362.6769,173.7072,1008.3828};

