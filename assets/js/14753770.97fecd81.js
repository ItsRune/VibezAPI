"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[309],{3905:(e,n,r)=>{r.d(n,{Zo:()=>u,kt:()=>f});var t=r(67294);function a(e,n,r){return n in e?Object.defineProperty(e,n,{value:r,enumerable:!0,configurable:!0,writable:!0}):e[n]=r,e}function i(e,n){var r=Object.keys(e);if(Object.getOwnPropertySymbols){var t=Object.getOwnPropertySymbols(e);n&&(t=t.filter((function(n){return Object.getOwnPropertyDescriptor(e,n).enumerable}))),r.push.apply(r,t)}return r}function s(e){for(var n=1;n<arguments.length;n++){var r=null!=arguments[n]?arguments[n]:{};n%2?i(Object(r),!0).forEach((function(n){a(e,n,r[n])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(r)):i(Object(r)).forEach((function(n){Object.defineProperty(e,n,Object.getOwnPropertyDescriptor(r,n))}))}return e}function l(e,n){if(null==e)return{};var r,t,a=function(e,n){if(null==e)return{};var r,t,a={},i=Object.keys(e);for(t=0;t<i.length;t++)r=i[t],n.indexOf(r)>=0||(a[r]=e[r]);return a}(e,n);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);for(t=0;t<i.length;t++)r=i[t],n.indexOf(r)>=0||Object.prototype.propertyIsEnumerable.call(e,r)&&(a[r]=e[r])}return a}var o=t.createContext({}),c=function(e){var n=t.useContext(o),r=n;return e&&(r="function"==typeof e?e(n):s(s({},n),e)),r},u=function(e){var n=c(e.components);return t.createElement(o.Provider,{value:n},e.children)},m="mdxType",d={inlineCode:"code",wrapper:function(e){var n=e.children;return t.createElement(t.Fragment,{},n)}},p=t.forwardRef((function(e,n){var r=e.components,a=e.mdxType,i=e.originalType,o=e.parentName,u=l(e,["components","mdxType","originalType","parentName"]),m=c(r),p=a,f=m["".concat(o,".").concat(p)]||m[p]||d[p]||i;return r?t.createElement(f,s(s({ref:n},u),{},{components:r})):t.createElement(f,s({ref:n},u))}));function f(e,n){var r=arguments,a=n&&n.mdxType;if("string"==typeof e||a){var i=r.length,s=new Array(i);s[0]=p;var l={};for(var o in n)hasOwnProperty.call(n,o)&&(l[o]=n[o]);l.originalType=e,l[m]="string"==typeof e?e:a,s[1]=l;for(var c=2;c<i;c++)s[c]=r[c];return t.createElement.apply(null,s)}return t.createElement.apply(null,r)}p.displayName="MDXCreateElement"},87609:(e,n,r)=>{r.r(n),r.d(n,{assets:()=>o,contentTitle:()=>s,default:()=>d,frontMatter:()=>i,metadata:()=>l,toc:()=>c});var t=r(87462),a=(r(67294),r(3905));const i={"sidebar-position":9},s=void 0,l={unversionedId:"Examples/Ranking",id:"Examples/Ranking",title:"Ranking",description:"Implementing in-game services",source:"@site/docs/Examples/Ranking.md",sourceDirName:"Examples",slug:"/Examples/Ranking",permalink:"/VibezAPI/docs/Examples/Ranking",draft:!1,editUrl:"https://github.com/ItsRune/VibezAPI/edit/master/docs/Examples/Ranking.md",tags:[],version:"current",frontMatter:{"sidebar-position":9},sidebar:"defaultSidebar",previous:{title:"Nitro Boosters",permalink:"/VibezAPI/docs/Examples/Nitro Boosters"},next:{title:"Webhooks",permalink:"/VibezAPI/docs/Examples/Webhooks"}},o={},c=[{value:"Implementing in-game services",id:"implementing-in-game-services",level:2},{value:"SetRank",id:"setrank",level:3},{value:"Promotions/Demotions/Firing Staff",id:"promotionsdemotionsfiring-staff",level:3},{value:"Setting a rank using a custom admin",id:"setting-a-rank-using-a-custom-admin",level:3}],u={toc:c},m="wrapper";function d(e){let{components:n,...r}=e;return(0,a.kt)(m,(0,t.Z)({},u,r,{components:n,mdxType:"MDXLayout"}),(0,a.kt)("h2",{id:"implementing-in-game-services"},"Implementing in-game services"),(0,a.kt)("blockquote",null,(0,a.kt)("p",{parentName:"blockquote"},"In game services include ranking commands, ranking UI and the activity tracker."),(0,a.kt)("ol",{parentName:"blockquote"},(0,a.kt)("li",{parentName:"ol"},'Create a new script in "ServerScriptServices" called "VibezServices"'),(0,a.kt)("li",{parentName:"ol"},"Insert the below code into the script"),(0,a.kt)("li",{parentName:"ol"},"Adjust the settings based on your needs"))),(0,a.kt)("h1",{id:"the-script"},"The script"),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre",className:"language-lua"},'local myKey = "YOUR_API_KEY_HERE"\nlocal VibezRankingAPI = require(14946453963)\nlocal Wrapper = VibezRankingAPI(myKey, {\n    -- Activity\n    activityTrackingEnabled = true;\n    toggleTrackingOfAFKActivity = false;\n    rankToStartTrackingActivityFor = 220;\n\n    -- UI OR Commands\n    isChatCommandsEnabled = true;\n    isUIEnabled = true;\n\n    minRankToUseCommandsAndUI = 255;\n    maxRankToUseCommandsAndUI = 255;\n\n    -- Commands Only\n    commandPrefix = "!";\n\n    -- Utility\n    overrideGroupCheckForStudio = true;\n    ignoreWarnings = false;\n    nameOfGameForLogging = "Main Game";\n}):waitUntilLoaded()\n')),(0,a.kt)("h3",{id:"setrank"},"SetRank"),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre",className:"language-lua"},'local Vibez = require(14946453963)("API Key"):waitUntilLoaded()\n\nlocal function gradePlayerApplication(Player: Player, application: {any})\n    local score = 0\n\n    -- Computation for score\n\n    if score >= application.minScore then\n        Vibez:SetRank(Player.UserId, application.Rank)\n    end\nend\n')),(0,a.kt)("h3",{id:"promotionsdemotionsfiring-staff"},"Promotions/Demotions/Firing Staff"),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre",className:"language-lua"},'local Vibez = require(14946453963)("API Key"):waitUntilLoaded()\n\nlocal function promotePlayer(Player: Player)\n    Vibez:Promote(Player.UserId)\nend\n\nlocal function demotePlayer(Player: Player)\n    Vibez:Demote(Player.UserId)\nend\n\nlocal function firePlayer(Player: Player)\n    Vibez:Fire(Player.UserId)\nend\n')),(0,a.kt)("h3",{id:"setting-a-rank-using-a-custom-admin"},"Setting a rank using a custom admin"),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre",className:"language-lua"},'--// Services \\\\--\nlocal Players = game:GetService("Players")\n\n--// Variables \\\\--\nlocal Prefix = "!"\nlocal Vibez = require(14946453963)("API Key"):waitUntilLoaded()\n\n--// Functions \\\\--\nlocal function findPlayers(Player: Player, Argument: string)\n    local args = string.split(string.lower(tostring(Argument)), ",")\n    local found = {}\n\n    for _, info in pairs(args) do\n        local result = nil\n        if info == "me" then\n            result = Player\n        elseif info == "all" then\n            result = Players:GetPlayers()\n        elseif info == "others" then\n            result = Players:GetPlayers()\n            table.remove(result, table.find(result, Player))\n        else\n            result = Players:FindFirstChild(info)\n        end\n\n        if typeof(result) == "Instance" then\n            table.insert(found, result)\n        elseif typeof(result) == "table" then\n            table.insert(found, table.unpack(result))\n        end\n    end\n\n    return found\nend\n\nlocal function onPlayerAdded(Player: Player)\n    Player.Chatted:Connect(function(Message: string)\n        -- Permission check\n        -- Make your own permission system\n\n        -- Prefix check\n        if string.sub(string.lower(Message), 1, #Prefix) ~= Prefix then\n            return\n        end\n\n        local command = string.split(string.lower(Message), " ")[1]\n\n        -- Inefficient, but it works\n        if command == "promote" then\n            local users = findPlayers(Player, string.split(Message, " ")[2])\n\n            for _, user in pairs(users) do\n                Vibez:PromoteWithCaller(user.UserId, tonumber(string.split(Message, " ")[2]), Player.UserId, Player.Name)\n            end\n        elseif command == "demote" then\n            local users = findPlayers(Player, string.split(Message, " ")[2])\n\n            for _, user in pairs(users) do\n                Vibez:DemoteWithCaller(user.UserId, tonumber(string.split(Message, " ")[2]), Player.UserId, Player.Name)\n            end\n        elseif command == "fire" then\n            local users = findPlayers(Player, string.split(Message, " ")[2])\n\n            for _, user in pairs(users) do\n                Vibez:FireWithCaller(user.UserId, tonumber(string.split(Message, " ")[2]), Player.UserId, Player.Name)\n            end\n        elseif command == "setrank" then\n            local users = findPlayers(Player, string.split(Message, " ")[2])\n\n            for _, user in pairs(users) do\n                Vibez:SetRankWithCaller(user.UserId, tonumber(string.split(Message, " ")[2]), Player.UserId, Player.Name)\n            end\n        end\n    end)\nend\n')))}d.isMDXComponent=!0}}]);