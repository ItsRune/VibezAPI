"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[250],{3905:(e,n,t)=>{t.d(n,{Zo:()=>u,kt:()=>m});var a=t(67294);function r(e,n,t){return n in e?Object.defineProperty(e,n,{value:t,enumerable:!0,configurable:!0,writable:!0}):e[n]=t,e}function i(e,n){var t=Object.keys(e);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);n&&(a=a.filter((function(n){return Object.getOwnPropertyDescriptor(e,n).enumerable}))),t.push.apply(t,a)}return t}function o(e){for(var n=1;n<arguments.length;n++){var t=null!=arguments[n]?arguments[n]:{};n%2?i(Object(t),!0).forEach((function(n){r(e,n,t[n])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(t)):i(Object(t)).forEach((function(n){Object.defineProperty(e,n,Object.getOwnPropertyDescriptor(t,n))}))}return e}function l(e,n){if(null==e)return{};var t,a,r=function(e,n){if(null==e)return{};var t,a,r={},i=Object.keys(e);for(a=0;a<i.length;a++)t=i[a],n.indexOf(t)>=0||(r[t]=e[t]);return r}(e,n);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);for(a=0;a<i.length;a++)t=i[a],n.indexOf(t)>=0||Object.prototype.propertyIsEnumerable.call(e,t)&&(r[t]=e[t])}return r}var s=a.createContext({}),p=function(e){var n=a.useContext(s),t=n;return e&&(t="function"==typeof e?e(n):o(o({},n),e)),t},u=function(e){var n=p(e.components);return a.createElement(s.Provider,{value:n},e.children)},d="mdxType",c={inlineCode:"code",wrapper:function(e){var n=e.children;return a.createElement(a.Fragment,{},n)}},k=a.forwardRef((function(e,n){var t=e.components,r=e.mdxType,i=e.originalType,s=e.parentName,u=l(e,["components","mdxType","originalType","parentName"]),d=p(t),k=r,m=d["".concat(s,".").concat(k)]||d[k]||c[k]||i;return t?a.createElement(m,o(o({ref:n},u),{},{components:t})):a.createElement(m,o({ref:n},u))}));function m(e,n){var t=arguments,r=n&&n.mdxType;if("string"==typeof e||r){var i=t.length,o=new Array(i);o[0]=k;var l={};for(var s in n)hasOwnProperty.call(n,s)&&(l[s]=n[s]);l.originalType=e,l[d]="string"==typeof e?e:r,o[1]=l;for(var p=2;p<i;p++)o[p]=t[p];return a.createElement.apply(null,o)}return a.createElement.apply(null,t)}k.displayName="MDXCreateElement"},71298:(e,n,t)=>{t.r(n),t.d(n,{assets:()=>s,contentTitle:()=>o,default:()=>c,frontMatter:()=>i,metadata:()=>l,toc:()=>p});var a=t(87462),r=(t(67294),t(3905));const i={sidebar_position:1},o=void 0,l={unversionedId:"Features/Ranking",id:"Features/Ranking",title:"Ranking",description:"Let's be honest, there's nothing worse than a potential future worker doing an application and not being automatically ranked by a system, days or even weeks of them spamming the group wall (or discord DMs) begging for their rank. This is why we have the ranking API. It allows you to rank workers in game without having to do it manually.",source:"@site/docs/Features/Ranking.md",sourceDirName:"Features",slug:"/Features/Ranking",permalink:"/VibezAPI/docs/Features/Ranking",draft:!1,editUrl:"https://github.com/ItsRune/VibezAPI/edit/master/docs/Features/Ranking.md",tags:[],version:"current",sidebarPosition:1,frontMatter:{sidebar_position:1},sidebar:"defaultSidebar",previous:{title:"Chainable",permalink:"/VibezAPI/docs/Chainable"},next:{title:"Activity Tracking",permalink:"/VibezAPI/docs/Features/Activity Tracking"}},s={},p=[{value:"Usage",id:"usage",level:2},{value:"Promote",id:"promote",level:3},{value:"Demote",id:"demote",level:3},{value:"Fire",id:"fire",level:3},{value:"setRank",id:"setrank",level:3},{value:"What&#39;s this <code>whoCalled</code> parameter?",id:"whats-this-whocalled-parameter",level:2},{value:"How would I use this?",id:"how-would-i-use-this",level:3},{value:"Why isn&#39;t it working?",id:"why-isnt-it-working",level:2},{value:"Examples",id:"examples",level:2}],u={toc:p},d="wrapper";function c(e){let{components:n,...t}=e;return(0,r.kt)(d,(0,a.Z)({},u,t,{components:n,mdxType:"MDXLayout"}),(0,r.kt)("p",null,"Let's be honest, there's nothing worse than a potential future worker doing an application and not being automatically ranked by a system, days or even weeks of them spamming the group wall (or discord DMs) begging for their rank. This is why we have the ranking API. It allows you to rank workers in game without having to do it manually."),(0,r.kt)("h2",{id:"usage"},"Usage"),(0,r.kt)("p",null,(0,r.kt)("strong",{parentName:"p"},"IF")," you're confused with the type definitons, this is for you:\nYou may notice that some parameters are separated by a ",(0,r.kt)("inlineCode",{parentName:"p"},"|")," this is noting that you can use either of these types to fill the parameter. ",(0,r.kt)("br",null),"\nExamples:"),(0,r.kt)("b",null,"userId: number | string | Player"),(0,r.kt)("ul",null,(0,r.kt)("li",{parentName:"ul"},(0,r.kt)("inlineCode",{parentName:"li"},"1")),(0,r.kt)("li",{parentName:"ul"},(0,r.kt)("inlineCode",{parentName:"li"},'"ROBLOX"')),(0,r.kt)("li",{parentName:"ul"},(0,r.kt)("inlineCode",{parentName:"li"},"game.Players.ROBLOX"))),(0,r.kt)("b",null,"rank: number | string"),(0,r.kt)("ul",null,(0,r.kt)("li",{parentName:"ul"},(0,r.kt)("inlineCode",{parentName:"li"},"1")),(0,r.kt)("li",{parentName:"ul"},(0,r.kt)("inlineCode",{parentName:"li"},'"Worker"')),(0,r.kt)("li",{parentName:"ul"},(0,r.kt)("inlineCode",{parentName:"li"},"roleId"))),(0,r.kt)("p",null,(0,r.kt)("a",{parentName:"p",href:"/VibezAPI/docs/Features/Ranking#whats-this-whocalled-parameter"},(0,r.kt)("strong",{parentName:"a"},"whoCalled: (See Below)"))),(0,r.kt)("h3",{id:"promote"},(0,r.kt)("a",{parentName:"h3",href:"/VibezAPI/api/VibezAPI#Promote"},"Promote")),(0,r.kt)("p",null,"Increments a player's rank by 1."),(0,r.kt)("p",null,(0,r.kt)("inlineCode",{parentName:"p"},"userId: number | string | Player")," ",(0,r.kt)("br",null),"\n",(0,r.kt)("inlineCode",{parentName:"p"},"whoCalled: { userName: string, userId: number }?")),(0,r.kt)("p",null,"Returns: ",(0,r.kt)("a",{parentName:"p",href:"/VibezAPI/api/VibezAPI#rankResponse"},"rankResponse")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local userId = 1\nVibezApi:Promote(userId)\n")),(0,r.kt)("h3",{id:"demote"},(0,r.kt)("a",{parentName:"h3",href:"/VibezAPI/api/VibezAPI#Demote"},"Demote")),(0,r.kt)("p",null,"Decrements a player's rank by 1."),(0,r.kt)("p",null,(0,r.kt)("inlineCode",{parentName:"p"},"userId: number | string | Player")," ",(0,r.kt)("br",null),"\n",(0,r.kt)("inlineCode",{parentName:"p"},"whoCalled: { userName: string, userId: number }?")),(0,r.kt)("p",null,"Returns: ",(0,r.kt)("a",{parentName:"p",href:"/VibezAPI/api/VibezAPI#rankResponse"},"rankResponse")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local userId = 1\nVibezApi:Demote(userId)\n")),(0,r.kt)("h3",{id:"fire"},(0,r.kt)("a",{parentName:"h3",href:"/VibezAPI/api/VibezAPI#Fire"},"Fire")),(0,r.kt)("p",null,"Sets a player's rank to the lowest rank."),(0,r.kt)("p",null,(0,r.kt)("inlineCode",{parentName:"p"},"userId: number | string | Player")," ",(0,r.kt)("br",null),"\n",(0,r.kt)("inlineCode",{parentName:"p"},"whoCalled: { userName: string, userId: number }?")),(0,r.kt)("p",null,"Returns: ",(0,r.kt)("a",{parentName:"p",href:"/VibezAPI/api/VibezAPI#rankResponse"},"rankResponse")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local userId = 1\nlocal newRankId = 5\nVibezApi:Fire(userId, newRankId)\n")),(0,r.kt)("h3",{id:"setrank"},(0,r.kt)("a",{parentName:"h3",href:"/VibezAPI/api/VibezAPI#setRank"},"setRank")),(0,r.kt)("p",null,"Sets a player's rank to a specific rank."),(0,r.kt)("p",null,(0,r.kt)("inlineCode",{parentName:"p"},"userId: number | string | Player")," ",(0,r.kt)("br",null),"\n",(0,r.kt)("inlineCode",{parentName:"p"},"rank: number | string")," ",(0,r.kt)("br",null),"\n",(0,r.kt)("inlineCode",{parentName:"p"},"whoCalled: { userName: string, userId: number }?")),(0,r.kt)("p",null,"Returns: ",(0,r.kt)("a",{parentName:"p",href:"/VibezAPI/api/VibezAPI#rankResponse"},"rankResponse")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local userId = 1\nVibezApi:setRank(1, 2)\n")),(0,r.kt)("h2",{id:"whats-this-whocalled-parameter"},"What's this ",(0,r.kt)("inlineCode",{parentName:"h2"},"whoCalled")," parameter?"),(0,r.kt)("p",null,"Under the hood of the API, we use the ",(0,r.kt)("inlineCode",{parentName:"p"},"whoCalled")," parameter to generate logs within a Discord channel of the action, who did it, and who was affected. ",(0,r.kt)("strong",{parentName:"p"},"THIS PARAMETER IS OPTIONAL"),". This is useful for auditing purposes, and to see who's abusing the API. If you supply nothing, the wrapper will automatically supply ",(0,r.kt)("strong",{parentName:"p"},"SYSTEM")," for the username, and the log generated will look different than with a proper user. If you supply a user's ID and name, the log will look like this:"),(0,r.kt)("img",{src:"/VibezAPI/rankingExampleWithUser.png"}),(0,r.kt)("p",null,"If you supply nothing, the log will look like this:"),(0,r.kt)("img",{src:"/VibezAPI/rankingExampleAutomatic.png"}),(0,r.kt)("h3",{id:"how-would-i-use-this"},"How would I use this?"),(0,r.kt)("p",null,"When issuing a function with the wrapper that has this included, just create a new parameter with the ",(0,r.kt)("inlineCode",{parentName:"p"},"userName")," and ",(0,r.kt)("inlineCode",{parentName:"p"},"userId")," keys, and supply the values. Here's an example:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'VibezApi:Promote(1, { userName = "ltsRune", userId = 107392833 })\n')),(0,r.kt)("h2",{id:"why-isnt-it-working"},"Why isn't it working?"),(0,r.kt)("p",null,"There's many reasons why the ranking API may fail, maybe your discord bot is offline, or maybe the worker is already ranked to the rank you're trying to rank them to. If you're having issues with the ranking API, please join our discord below and ask for help in the support channel."),(0,r.kt)("iframe",{src:"https://discord.com/widget?id=528920896497516554&theme=dark",width:"350",height:"500",allowtransparency:"true",frameborder:"0",sandbox:"allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts"}),(0,r.kt)("h2",{id:"examples"},"Examples"),(0,r.kt)("details",null,(0,r.kt)("summary",null,"AutoRank Points"),(0,r.kt)("br",null),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua",metastring:'title="ServerScriptService/autoRankPoints.server.lua"',title:'"ServerScriptService/autoRankPoints.server.lua"'},'--// Configuration \\\\--\nlocal apiKey = "API KEY" -- Vibez\'s API Key\nlocal vibezApiLocation = 14946453963 --game:GetService("ServerScriptService").VibezAPI\nlocal pointRanks = {\n    { Rank = 2, pointsRequired = 10 }\n}\n\n-- IMPORTANT: Scroll down to line 23 to change the location\n-- of a player\'s points!\n\n--// Services \\\\--\nlocal Players = game:GetService("Players")\nlocal ReplicatedStorage = game:GetService("ReplicatedStorage")\nlocal DataStoreService = game:GetService("DataStoreService")\n\n--// Variables \\\\--\nlocal vibezApi = require(vibezApiLocation)(apiKey)\nlocal dataStoreToUse = DataStoreService:GetDataStore("pointRanks_" .. game.PlaceId)\nlocal userCache = {}\n\n--// Functions \\\\--\nlocal function onPlayerAdded(Player: Player)\n    -- Wherever you\'re keeping your player\'s points, this is what you\'d want to change it to.\n    local pointStats = Player:WaitForChild("leaderstats", 120):WaitForChild("Points", 120)\n\n    -- Don\'t touch below unless you know what you\'re doing.\n    local isOk, data, connections, formattedString\n    isOk, data = pcall(dataStoreToUse.GetAsync, dataStoreToUse, tostring(Player.UserId))\n\n    if not isOk then\n        return\n    end\n\n    data = data or {}\n    connections = {}\n\n    table.sort(pointRanks, function(a, b)\n        return a.pointsRequired < b.pointsRequired\n    end)\n\n    table.insert(connections, pointStats:GetPropertyChangedSignal("Value"):Connect(function()\n        local userGroupData = vibezApi:_getGroupFromUser(vibezApi.GroupId, Player.UserId)\n        local copiedData = userCache[Player.UserId][2] or {}\n        \n        if not userGroupData or userGroupData.Rank == 0 then\n            return\n        end\n\n        for i = 1, #pointRanks do\n            local data = pointRanks[i]\n\n            if\n                table.find(copiedData, data.Rank) ~= nil\n                or userGroupData.Rank >= data.Rank\n                or pointStats.Value < data.pointsRequired\n            then\n                continue\n            end\n            \n            if\n                userGroupData.Rank < data.Rank\n                and pointStats.Value >= data.pointsRequired\n            then\n                local response = vibezApi:setRank(Player, data.Rank)\n                \n                if response.success then\n                    table.insert(copiedData, data.Rank)\n                end\n                break\n            end\n        end\n        \n        userCache[Player.UserId][2] = copiedData\n    end))\n\n    userCache[Player.UserId] = {connections, data}\nend\n\nlocal function onPlayerLeft(Player: Player, retry: number?)\n    local exists = userCache[Player.UserId]\n    if not exists then\n        return\n    end\n\n    local isOk = pcall(dataStoreToUse.SetAsync, dataStoreToUse, tostring(Player.UserId), exists[2])\n    if not isOk then\n        retry = retry or 0\n        if retry > 3 then\n            error("Failed to save data for user " .. Player.Name)\n            return\n        end\n\n        task.wait(3)\n        return onPlayerLeft(Player, retry + 1)\n    end\n\n    for _, connection: RBXScriptConnection in pairs(exists[1]) do\n        connection:Disconnect()\n    end\n\n    userCache[Player.UserId] = nil\nend\n\n--// Events \\\\--\nfor _, v in ipairs(Players:GetPlayers()) do\n    coroutine.wrap(onPlayerAdded)(v)\nend\n\nPlayers.PlayerAdded:Connect(onPlayerAdded)\nPlayers.PlayerRemoving:Connect(onPlayerLeft)\n'))))}c.isMDXComponent=!0}}]);