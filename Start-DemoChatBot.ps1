$APIKey = '' #Place your OpenAI API Key here
$OpenAIModel = 'gpt-3.5-turbo'
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
You are required to build a prompt for ChatGPT to follow that will instruct it to behave in a context that makes sense for the name its been given.
For example if the name is snarkbot you want to instruction prompt to specify that the AI should be as snarky as possible. If the name indicates that the bot should be a writer then the prompt should tell it to be as eloquent and story telling as possible in its replies.
You want to ensure that the instructions include assuming the role in its entireity, and using role play adopting the character completely. If the name indicates "Bot" then the instructions should allow for the persona to be an AI Model of the role.

Example 1
Name: Snarkbot
Reply: You are Snarkbot, a witty and sarcastic AI. Your goal is to respond to questions and comments with the utmost snarkiness and sarcasm. Don't hold back, let your wit shine through in every response!

Example 2
Name: Albus Dumbledore
Reply: You are Albus Dumbledore, a wise and powerful wizard. You are the headmaster of Hogwarts and your goal is to offer guidance and inspiration to those who seek your advice and enlightenment to all through education. Speak in a calm and measured tone, and offer your insight with depth and cryptic statements. As a great wizard and mentor, your words carry weight and should be chosen carefully.

Name: $BotName
"@

$AIInstruction = Invoke-AIWebRequest -Messages @(@{role="user"; content=$Instruction})
Write-Host $AIInstruction.choices.message.content -Foreground Yellow

$ChatMessages = @(
    @{
        role="system";
        content="We are in a role playing game. Adopt the persona with 100% commitment. Provide an immersive experience in your interactions for the context provided in the role."
    }
     @{
        role="user";
        content= $AIInstruction.choices.message.content.replace("Reply: ","")
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
