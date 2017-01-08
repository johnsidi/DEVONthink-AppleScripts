--http://www.johnsidi.com
-- 2012-09-30
--it matches exact phrases using quotes and single words
--the locked files in DEVONthink are excluded from the search
--the index is created for the active DEVONthink database
tell application "DEVONthink Pro"
	set searchWord to text returned of (display dialog "Enter the search word/phrase:" default answer "")
	set searchWordList to every word of searchWord
	set numberOfSearchWords to count searchWordList
	set the searchWordWithoutSpaces to replaceText(searchWord, " ", "_") of me
	set searchWordQuoted to "\"" & searchWord & "\""
	set resultList to search searchWordQuoted in current database locking no
	set numberResults to count resultList
	if numberResults = 0 then display dialog "No matches were found." buttons {"Cancel"}
	set numberOfDocuments to text returned of (display dialog "The found docs are " & numberResults & ", please set the numbers of docs for processing:" default answer numberResults)
	if numberResults > numberOfDocuments then set resultList to items 1 thru numberOfDocuments of resultList
	set RefType to my chooseRefType({"MediaWiki", "RTF"})
	if RefType is 1 then
		set indexLinks to "===Universal index of \"" & searchWord & "\"===
number of sources:" & numberOfDocuments & " out of " & numberResults & " matches - " & (the current date) & "
"
	else if RefType is 2 then
		set indexLinks to "<html>
<body>
<h3>Universal index of \"" & searchWord & "\"</h3>
number of sources: " & numberOfDocuments & " out of " & numberResults & " matches - " & (the current date)
	end if
	repeat with book in resultList
		set pathBook to path of book
		set referenceURL to reference URL of book
		set nameBook to name of book
		set wordInstances to ""
		tell application "Skim"
			try
				open pathBook --κολλάει εάν κάποια αρχεία δεν υπάρχου
				tell document 1
					set all_pages to count of pages -- so we only calculate it once
					if RefType is 1 then
						set bookTitle to "
====" & nameBook & "====
[" & referenceURL & "?search=" & searchWordWithoutSpaces & " " & searchWord & "] in [[@" & nameBook & "]]<br />
"
						repeat with pageNumber from 1 to all_pages --
							set DEVONthinkPageNumber to pageNumber - 1
							if numberOfSearchWords ≤ 1 then
								set pageText to (get text for page pageNumber) -- suck up the text into a string!
								ignoring hyphens
									set pageText to (every word of pageText) as list -- tokenise!
								end ignoring
								if pageText contains searchWord then -- record page number if word on page
									set wordInstances to wordInstances & "[" & referenceURL & "?page=" & DEVONthinkPageNumber & "&?search=" & searchWordWithoutSpaces & " " & pageNumber & "] "
								end if
							else
								set pageText to (get text for page pageNumber) as Unicode text -- suck up the text into a string!
								if pageText contains searchWord then
									set wordInstances to wordInstances & "[" & referenceURL & "?page=" & DEVONthinkPageNumber & "?search=" & searchWordWithoutSpaces & " " & pageNumber & "] "
								end if
							end if
						end repeat
					else if RefType is 2 then
						set bookTitle to "<h4>" & nameBook & "</h4>
<a href=" & referenceURL & "?search=" & searchWordWithoutSpaces & ">" & searchWord & "</a>: "
						repeat with pageNumber from 1 to all_pages --
							set DEVONthinkPageNumber to pageNumber - 1
							if numberOfSearchWords ≤ 1 then
								set pageText to (get text for page pageNumber) -- suck up the text into a string!
								ignoring hyphens
									set pageText to (every word of pageText) as list -- tokenise!
								end ignoring
								if pageText contains searchWord then -- record page number if word on page
									set wordInstances to wordInstances & "<a href=" & referenceURL & "?page=" & DEVONthinkPageNumber & ">" & pageNumber & "</a> "
								end if
							else
								set pageText to (get text for page pageNumber) as Unicode text -- suck up the text into a string!
								if pageText contains searchWord then
									set wordInstances to wordInstances & "<a href=" & referenceURL & "?page=" & DEVONthinkPageNumber & ">" & pageNumber & "</a> "
								end if
							end if
						end repeat
					end if
				end tell
				close document 1
			end try
		end tell
		if RefType is 1 then
			set indexLinks to indexLinks & bookTitle & wordInstances & "
"
		else if RefType is 2 then
			set indexLinks to indexLinks & bookTitle & wordInstances & "
</body>
</html>"
		else if RefType is 3 then
		end if
	end repeat
	if RefType is 1 then
		set the clipboard to indexLinks
	else if RefType is 2 then
		set the clipboard to indexLinks
		tell application "Finder"
			do shell script "pbpaste | textutil -stdin -format html -convert rtf -stdout | pbcopy -Prefer rtf"
		end tell
	end if
end tell
on chooseRefType(typeList)
	tell application "Skim"
		set theResult to choose from list typeList with prompt "Reference type:" default items {"RTF"}
		if theResult is false then return 0
		set refTypeNumber to theResult as string
		if refTypeNumber is "MediaWiki" then
			return 1
		else if refTypeNumber is "RTF" then
			return 2
		end if
	end tell
	return RefType
end chooseRefType
on replaceText(thisText, searchString, replacementString)
	set AppleScript's text item delimiters to the searchString
	set the itemList to every text item of thisText
	set AppleScript's text item delimiters to the replacementString
	set thisText to the itemList as string
	set AppleScript's text item delimiters to {""}
	return thisText
end replaceTex
