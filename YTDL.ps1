if (!(Get-Command Start-ThreadJob -ErrorAction SilentlyContinue)) {Install-Module -Name ThreadJob -Scope CurrentUser -Force}   

$link = Read-Host -Prompt "Provide the Link "

$directory = Read-Host -Prompt "Provide the directory to save"
if (!$directory) {$directory = "~/Downloads"}

$cookies = Read-Host -Prompt "Do you want to use Cookies? (Y/N (Y is Default))"
if (!$cookies) {$cookies = "Y"}

$audioOnly = Read-Host -Prompt "Do you want audio only? (Y/N (N is Default))"
if (!$audioOnly) {$audioOnly = "N"}

$outsideOfYouTube = Read-Host -Prompt "Is the Video/Audio not from YouTube? (Y/N (N is Default))"
if (!$outsideOfYouTube) {$outsideOfYouTube = "N"}

# Define result mapping
function EvaluateCombination { 
    $key = "$cookies,$audioOnly,$outsideOfYouTube"
    $Results = @{
        "Y,N,N" = "YouTube Video, with Cookies"
        "Y,Y,N" = "YouTube Audio, with Cookies"
		"N,N,N" = "YouTube Video, no Cookies"
		"N,Y,N" = "YouTube Audio, no Cookies"
		"Y,N,Y" = "General Video, with Cookies"
		"Y,Y,Y" = "General Audio, with Cookies"
		"N,N,Y" = "General Video, no Cookies"
		"N,Y,Y" = "General Audio, no Cookies"
    }
    
    return @{
        Result = $Results[$key]
        Combination = $key
    }
}

function PotServer {
	try {
		Push-Location ~/bgutil-ytdlp-pot-provider/Server
		node build/main.js
	} 
	finally {Pop-Location}
}

function YT-DLP-DownloadCommand {
	switch ($outcome.Result) {
		"YouTube Video, with Cookies" {
			yt-dlp -v --add-metadata -P "$Directory" "$Link" --% --cookies "~/Downloads/cookies.txt" --windows-filenames --continue -f "bv*+mergeall[format_id*='251']/bv*+ba" --audio-multistreams -S quality,vcodec:av1:vp9:h264,acodec:opus:aac --embed-chapters --embed-thumbnail --embed-subs --compat-options no-live-chat --concat-playlist never --sub-lang all --convert-subs ass --merge-output-format mkv --extractor-args "youtube:player-client=default,mweb,web_safari,tv_embedded" --extractor-args "youtubepot-bgutilhttp:base_url=http://127.0.0.1:4416"
		}
		
		"YouTube Audio, with Cookies" {
			yt-dlp -v --add-metadata -P "$directory" "$link" --% --cookies "~/Downloads/cookies.txt" --windows-filenames --continue -x --embed-thumbnail --embed-thumbnail --concat-playlist never --embed-chapters --extractor-args "youtube:player-client=default,mweb,web_safari,tv_embedded" --extractor-args "youtubepot-bgutilhttp:base_url=http://127.0.0.1:4416"
		}
		
		"YouTube Video, no Cookies" {
			yt-dlp -v --add-metadata -P "$Directory" "$Link" --% --windows-filenames --continue -f "bv*+mergeall[format_id*='251']/bv*+ba" --audio-multistreams -S quality,vcodec:av1:vp9:h264,acodec:opus:aac --embed-chapters --embed-thumbnail --embed-subs --compat-options no-live-chat --concat-playlist never --sub-lang all --convert-subs ass --merge-output-format mkv --extractor-args "youtube:player-client=default,mweb,web_safari,tv_embedded" --extractor-args "youtubepot-bgutilhttp:base_url=http://127.0.0.1:4416"
		}
		
		"YouTube Audio, no Cookies" {
			yt-dlp -v --add-metadata -P "$directory" "$link" --% --windows-filenames --continue -x  --embed-thumbnail --embed-thumbnail --concat-playlist never --embed-chapters --extractor-args "youtube:player-client=default,mweb,web_safari,tv_embedded" --extractor-args "youtubepot-bgutilhttp:base_url=http://127.0.0.1:4416"
		}
	
		"General Video, with Cookies" {
			yt-dlp -v --add-metadata --paths "$directory" "$link" --% --cookies "~/Downloads/cookies.txt" --windows-filenames --continue -f "bv*+mergeall/bv*+ba" --audio-multistreams -S quality,vcodec:av1:vp9:h264,acodec:opus:aac  --embed-chapters --embed-thumbnail --embed-subs --convert-subs ass --compat-options no-live-chat --concat-playlist never --sub-lang all --merge-output-format mkv --remux-video mkv
		}
		
		"General Video, no Cookies" {
			yt-dlp -v --add-metadata -P "$directory" "$link" --% --windows-filenames --continue -f "bv*+mergeall/bv*+ba" --audio-multistreams -S quality,vcodec:av1:h264,acodec:opus:aac --embed-chapters --embed-thumbnail --embed-subs --convert-subs ass --compat-options no-live-chat --concat-playlist never --sub-lang all --merge-output-format mkv --remux-video mkv
		}
		
		"General Audio, with Cookies" {
			yt-dlp -v --add-metadata -P "$directory" "$link" --% --cookies "~/Downloads/cookies.txt" --windows-filenames --continue -x --embed-thumbnail --embed-thumbnail --concat-playlist never --embed-chapters
		}
		
		"General Audio, no Cookies" {
			yt-dlp -v --add-metadata -P "$directory" "$link" --% --windows-filenames --continue -x --embed-thumbnail --embed-thumbnail --concat-playlist never --embed-chapters
		}
	}
}

# Evaluate combinations
$outcome = EvaluateCombination

#Debuging Hashmap
#Write-Host "Outcome: $($outcome.Result)"
#Write-Host "Combo:   $($outcome.Combination)"

# Start PotServer as a background job
$POT = Start-ThreadJob -ScriptBlock ${function:PotServer}

# Wait for server to be ready
do { Start-Sleep -Seconds 1 } until (Test-NetConnection -ComputerName 127.0.0.1 -Port 4416)   

YT-DLP-DownloadCommand

# Automatically stops PotServer job after YT-DLP-DownloadCommand finishes
Stop-Job   -Job $POT -ErrorAction SilentlyContinue
Remove-Job -Job $POT -ErrorAction SilentlyContinue