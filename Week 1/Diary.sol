// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Diary {
    /// @notice Mood state: Good, Normal, Bad
    enum Mood { Good, Normal, Bad }

    /// @notice Data structure for a single diary entry
    struct DiaryEntry {
        string   title;
        string   content;
        Mood     mood;
        uint256  timestamp;
    }

    /// @notice Mapping from user address to their list of diary entries
    mapping(address => DiaryEntry[]) private diaries;

    /// @notice Emitted when a new diary entry is created
    event NewEntry(
        address indexed user,
        uint256 indexed id,
        string   title,
        Mood     mood,
        uint256  timestamp
    );

    /// @notice Add a new diary entry for the caller
    /// @param _title   The title of the entry
    /// @param _content The content/body of the entry
    /// @param _mood    The mood associated with the entry
    function writeEntry(
        string calldata _title,
        string calldata _content,
        Mood             _mood
    ) external {
        diaries[msg.sender].push(DiaryEntry({
            title:     _title,
            content:   _content,
            mood:      _mood,
            timestamp: block.timestamp
        }));
        uint256 id = diaries[msg.sender].length - 1;
        emit NewEntry(msg.sender, id, _title, _mood, block.timestamp);
    }

    /// @notice Return the total number of entries the caller has written
    function getMyEntryCount() external view returns (uint256) {
        return diaries[msg.sender].length;
    }

    /// @notice Return all diary entries written by the caller
    function getMyEntries() external view returns (DiaryEntry[] memory) {
        return diaries[msg.sender];
    }

    /// @notice Return entries filtered by a specific mood
    /// @param _mood The mood to filter by
    function getEntriesByMood(Mood _mood)
        external
        view
        returns (DiaryEntry[] memory)
    {
        DiaryEntry[] storage all = diaries[msg.sender];
        uint256 count;
        // 1) Count how many entries match the mood
        for (uint256 i; i < all.length; i++) {
            if (all[i].mood == _mood) {
                count++;
            }
        }
        // 2) Allocate an array of the right size
        DiaryEntry[] memory filtered = new DiaryEntry[](count);
        uint256 idx;
        // 3) Copy matching entries into the new array
        for (uint256 i; i < all.length; i++) {
            if (all[i].mood == _mood) {
                filtered[idx++] = all[i];
            }
        }
        return filtered;
    }

    /// @notice Return entries whose timestamps fall within [_start, _end]
    /// @param _start Earliest timestamp (inclusive)
    /// @param _end   Latest timestamp (inclusive)
    function getEntriesByDateRange(uint256 _start, uint256 _end)
        external
        view
        returns (DiaryEntry[] memory)
    {
        DiaryEntry[] storage all = diaries[msg.sender];
        uint256 count;
        // 1) Count entries within the date range
        for (uint256 i = 0; i < all.length; i++) {
            if (all[i].timestamp >= _start && all[i].timestamp <= _end) {
                count++;
            }
        }
        // 2) Allocate result array
        DiaryEntry[] memory result = new DiaryEntry[](count);
        uint256 idx;
        // 3) Copy entries into result
        for (uint256 i = 0; i < all.length; i++) {
            if (all[i].timestamp >= _start && all[i].timestamp <= _end) {
                result[idx++] = all[i];
            }
        }
        return result;
    }

    /// @dev Internal helper: simple substring search
    /// @param what  The keyword to look for
    /// @param where The string to search within
    function _contains(string memory what, string memory where) private pure returns (bool) {
        bytes memory a = bytes(where);
        bytes memory b = bytes(what);
        if (b.length > a.length) return false;
        for (uint256 i = 0; i <= a.length - b.length; i++) {
            bool match_ = true;
            for (uint256 j = 0; j < b.length; j++) {
                if (a[i + j] != b[j]) {
                    match_ = false;
                    break;
                }
            }
            if (match_) return true;
        }
        return false;
    }

    /// @notice Return entries whose title contains the given keyword
    /// @param _keyword The substring to search for in titles
    function searchByTitle(string calldata _keyword)
        external
        view
        returns (DiaryEntry[] memory)
    {
        DiaryEntry[] storage all = diaries[msg.sender];
        uint256 count;
        // 1) Count entries whose title contains the keyword
        for (uint256 i = 0; i < all.length; i++) {
            if (_contains(_keyword, all[i].title)) {
                count++;
            }
        }
        // 2) Allocate result array
        DiaryEntry[] memory result = new DiaryEntry[](count);
        uint256 idx;
        // 3) Copy matching entries into result
        for (uint256 i = 0; i < all.length; i++) {
            if (_contains(_keyword, all[i].title)) {
                result[idx++] = all[i];
            }
        }
        return result;
    }
}
