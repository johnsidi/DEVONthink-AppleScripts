--https://johnsidi.com/convert-devonthink-tags-to-mediawiki-categories/
--2016-11-16 tested successfully
--http://organognosi.blogspot.com
--2011-06-18

tell application "DEVONthink Pro"
	set thisSelection to the selection
	if thisSelection is {} then error "Please select something"
	if (length of thisSelection) is greater than 1 then error "Please select only one item"
	set the clipboard to ""
	set newCategories to ""
	repeat with thisItem in thisSelection
		set tagsItem to tags of thisItem
		repeat with eachTag in tagsItem
			set tagForCategory to eachTag
			if tagForCategory is in {"Linked with MediaWiki"} then
				set newCategories to newCategories
			else
				set newCategories to "[[category:" & tagForCategory & "]] "
				set the clipboard to (the clipboard) & newCategories
			end if
		end repeat
	end repeat
end tell
