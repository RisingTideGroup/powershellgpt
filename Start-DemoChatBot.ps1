$APIKey = '' #Place your OpenAI API Key here
$OpenAIModel = 'gpt-3.5-turbo' #Swap this out for 'gpt-4' if you have access to it on your account
$Headers = @{Authorization = "Bearer $APIKey"}
$OpenAIBaseURL = "https://api.openai.com/v1"

$UserName = Read-Host -prompt "Enter your name"
$BotName = Read-Host -prompt "Enter the name of the bot"

function Invoke-AIWebRequest {
    param(
        $Messages
    )

    $OpenAIBody = @{
        model = $OpenAIModel;
        messages = $Messages
        max_tokens=1000;
        temperature = 1
        n = 1
        
    }|convertto-json 

    $AIWebRequest = Invoke-RestMethod -uri "$OpenAIBaseURL/chat/completions" -Method POST -Headers $Headers -ContentType "application/json" -Body $OpenAIBody
    return $AIWebRequest

}

$Instruction = @"
You are required to build a prompt for ChatGPT to follow that will instruct it to behave in a context that makes sense for the nmame its been given.
For example if the name is snarkbot you want to instruction prompt to specify that the AI should be as snarky as possible. If the name indicates that the bot should be a writer then the prompt should tell it to be as eloquent and story telling as possible in its replies.

Name: Snarkbot
Reply: You are Snarkbot, a witty and sarcastic AI. Your goal is to respond to questions and comments with the utmost snarkiness and sarcasm. Don't hold back, let your wit shine through in every response!

Name: $BotName
"@

$AIInstruction = Invoke-AIWebRequest -Messages @(@{role="user"; content=$Instruction})
Write-Host $AIInstruction.choices.message.content -Foreground Yellow

$ChatMessages = @(
     @{
        role="system";
        content= $AIInstruction.choices.message.content
    };
)
$InputString = Read-Host -Prompt "$UserName"
while ($InputString -notin 'quit','exit','bye','die') { 

    $Messages = $ChatMessages + @{ role="user"; content=$InputString } 
    $AIWebRequest = Invoke-AIWebRequest -Messages $Messages
    $AIRole = $AIWebRequest.choices.message.role
    $AIReply = $AIWebRequest.choices.message.content
    Write-Host "$BotName : $AIReply" -Foreground Cyan
    $ChatMessages = $ChatMessages + @{role=$AIRole; content=$AIReply}
    $InputString = Read-Host -Prompt "$UserName"
}
