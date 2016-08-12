// This is the Debian specific preferences file for Iceweasel
// You can make any change in here, it is the purpose of this file.
// You can, with this file and all files present in the
// /etc/iceweasel/pref directory, override any preference that is
// present in /usr/lib/iceweasel/defaults/preferences directory.
// While your changes will be kept on upgrade if you modify files in
// /etc/iceweasel/pref, please note that they won't be kept if you
// do make your changes in /usr/lib/iceweasel/defaults/preferences.
//
// Note that lockPref is allowed in these preferences files if you
// don't want users to be able to override some preferences.

// Allow extensions update.
pref("extensions.update.enabled", true);

// Use LANG environment variable to choose locale
pref("intl.locale.matchOS", true);

// Disable default browser checking.
pref("browser.shell.checkDefaultBrowser", false);

// Default homepage of users.
pref("browser.startup.homepage", "linux.ime.usp.br");

// Kerberos authentication
pref("network.ntlm.send-lm-response", true);
pref("network.negotiate-auth.allow-non-fqdn", true);
pref("network.negotiate-auth.allow-proxies", true);
pref("network.negotiate-auth.trusted-uris", "http://,https://");
pref("network.negotiate-auth.delegation-uris", "http://,https://");
pref("network.negotiate-auth.using-native-gsslib", true);
