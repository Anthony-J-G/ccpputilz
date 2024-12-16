const std = @import("std");
const Version = std.SemanticVersion;


pub fn isGreater(self: Version, min: Version) bool {
    if (self.major > min.major) {
        return true;
    } else if (self.major < min.major) {
        return false;
    }
    // Only reachable if self.major == min.major
    if (self.minor > min.minor) {
        return true;
    } else if (self.minor < min.minor) {
        return false;
    }
    // Only reachable if {self.major, self.minor} == {min.major, min.minor}
    if (self.patch > min.patch) {
        return true;
    } else if (self.patch < min.patch) {
        return false;
    }
    // Only reachable if {self.major, self.minor, self.patch} == {min.major, min.minor, min.patch}    
    return false; // Computing greater, not geq
}