"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[111],{8770:(e,n,t)=>{t.r(n),t.d(n,{assets:()=>l,contentTitle:()=>o,default:()=>h,frontMatter:()=>i,metadata:()=>r,toc:()=>d});const r=JSON.parse('{"id":"Features/Ranking","title":"Ranking","description":"Let\'s be honest, there\'s nothing worse than a potential future worker doing an application and not being automatically ranked by a system, days or even weeks of them spamming the group wall (or discord DMs) begging for their rank. This is why we have the ranking API. It allows you to rank workers in game without having to do it manually.","source":"@site/docs/Features/Ranking.md","sourceDirName":"Features","slug":"/Features/Ranking","permalink":"/VibezAPI/docs/Features/Ranking","draft":false,"unlisted":false,"editUrl":"https://github.com/ItsRune/VibezAPI/edit/master/docs/Features/Ranking.md","tags":[],"version":"current","sidebarPosition":1,"frontMatter":{"sidebar_position":1},"sidebar":"defaultSidebar","previous":{"title":"Chainable","permalink":"/VibezAPI/docs/Chainable"},"next":{"title":"Activity Tracking","permalink":"/VibezAPI/docs/Features/Activity Tracking"}}');var a=t(4848),s=t(8453);const i={sidebar_position:1},o=void 0,l={},d=[{value:"Usage",id:"usage",level:2},{value:"Promote",id:"promote",level:3},{value:"Demote",id:"demote",level:3},{value:"Fire",id:"fire",level:3},{value:"setRank",id:"setrank",level:3},{value:"What&#39;s this <code>whoCalled</code> parameter?",id:"whats-this-whocalled-parameter",level:2},{value:"How would I use this?",id:"how-would-i-use-this",level:3},{value:"Why isn&#39;t it working?",id:"why-isnt-it-working",level:2},{value:"Examples",id:"examples",level:2}];function c(e){const n={a:"a",code:"code",h2:"h2",h3:"h3",li:"li",p:"p",pre:"pre",strong:"strong",ul:"ul",...(0,s.R)(),...e.components},{Details:t}=n;return t||function(e,n){throw new Error("Expected "+(n?"component":"object")+" `"+e+"` to be defined: you likely forgot to import, pass, or provide it.")}("Details",!0),(0,a.jsxs)(a.Fragment,{children:[(0,a.jsx)(n.p,{children:"Let's be honest, there's nothing worse than a potential future worker doing an application and not being automatically ranked by a system, days or even weeks of them spamming the group wall (or discord DMs) begging for their rank. This is why we have the ranking API. It allows you to rank workers in game without having to do it manually."}),"\n",(0,a.jsx)(n.h2,{id:"usage",children:"Usage"}),"\n",(0,a.jsxs)(n.p,{children:[(0,a.jsx)(n.strong,{children:"IF"})," you're confused with the type definitons, this is for you:\nYou may notice that some parameters are separated by a ",(0,a.jsx)(n.code,{children:"|"})," this is noting that you can use either of these types to fill the parameter. ",(0,a.jsx)("br",{}),"\nExamples:"]}),"\n",(0,a.jsx)("b",{children:"userId: number | string | Player"}),"\n",(0,a.jsxs)(n.ul,{children:["\n",(0,a.jsx)(n.li,{children:(0,a.jsx)(n.code,{children:"1"})}),"\n",(0,a.jsx)(n.li,{children:(0,a.jsx)(n.code,{children:'"ROBLOX"'})}),"\n",(0,a.jsx)(n.li,{children:(0,a.jsx)(n.code,{children:"game.Players.ROBLOX"})}),"\n"]}),"\n",(0,a.jsx)("b",{children:"rank: number | string"}),"\n",(0,a.jsxs)(n.ul,{children:["\n",(0,a.jsx)(n.li,{children:(0,a.jsx)(n.code,{children:"1"})}),"\n",(0,a.jsx)(n.li,{children:(0,a.jsx)(n.code,{children:'"Worker"'})}),"\n",(0,a.jsx)(n.li,{children:(0,a.jsx)(n.code,{children:"roleId"})}),"\n"]}),"\n",(0,a.jsx)(n.p,{children:(0,a.jsx)(n.a,{href:"/VibezAPI/docs/Features/Ranking#whats-this-whocalled-parameter",children:(0,a.jsx)(n.strong,{children:"whoCalled: (See Below)"})})}),"\n",(0,a.jsx)(n.h3,{id:"promote",children:(0,a.jsx)(n.a,{href:"/VibezAPI/api/VibezAPI#Promote",children:"Promote"})}),"\n",(0,a.jsx)(n.p,{children:"Increments a player's rank by 1."}),"\n",(0,a.jsxs)(n.p,{children:[(0,a.jsx)(n.code,{children:"userId: number | string | Player"})," ",(0,a.jsx)("br",{}),"\n",(0,a.jsx)(n.code,{children:"whoCalled: { userName: string, userId: number }?"})]}),"\n",(0,a.jsxs)(n.p,{children:["Returns: ",(0,a.jsx)(n.a,{href:"/VibezAPI/api/VibezAPI#rankResponse",children:"rankResponse"})]}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-lua",children:"local userId = 1\nVibezApi:Promote(userId)\n"})}),"\n",(0,a.jsx)(n.h3,{id:"demote",children:(0,a.jsx)(n.a,{href:"/VibezAPI/api/VibezAPI#Demote",children:"Demote"})}),"\n",(0,a.jsx)(n.p,{children:"Decrements a player's rank by 1."}),"\n",(0,a.jsxs)(n.p,{children:[(0,a.jsx)(n.code,{children:"userId: number | string | Player"})," ",(0,a.jsx)("br",{}),"\n",(0,a.jsx)(n.code,{children:"whoCalled: { userName: string, userId: number }?"})]}),"\n",(0,a.jsxs)(n.p,{children:["Returns: ",(0,a.jsx)(n.a,{href:"/VibezAPI/api/VibezAPI#rankResponse",children:"rankResponse"})]}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-lua",children:"local userId = 1\nVibezApi:Demote(userId)\n"})}),"\n",(0,a.jsx)(n.h3,{id:"fire",children:(0,a.jsx)(n.a,{href:"/VibezAPI/api/VibezAPI#Fire",children:"Fire"})}),"\n",(0,a.jsx)(n.p,{children:"Sets a player's rank to the lowest rank."}),"\n",(0,a.jsxs)(n.p,{children:[(0,a.jsx)(n.code,{children:"userId: number | string | Player"})," ",(0,a.jsx)("br",{}),"\n",(0,a.jsx)(n.code,{children:"whoCalled: { userName: string, userId: number }?"})]}),"\n",(0,a.jsxs)(n.p,{children:["Returns: ",(0,a.jsx)(n.a,{href:"/VibezAPI/api/VibezAPI#rankResponse",children:"rankResponse"})]}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-lua",children:"local userId = 1\nlocal newRankId = 5\nVibezApi:Fire(userId, newRankId)\n"})}),"\n",(0,a.jsx)(n.h3,{id:"setrank",children:(0,a.jsx)(n.a,{href:"/VibezAPI/api/VibezAPI#setRank",children:"setRank"})}),"\n",(0,a.jsx)(n.p,{children:"Sets a player's rank to a specific rank."}),"\n",(0,a.jsxs)(n.p,{children:[(0,a.jsx)(n.code,{children:"userId: number | string | Player"})," ",(0,a.jsx)("br",{}),"\n",(0,a.jsx)(n.code,{children:"rank: number | string"})," ",(0,a.jsx)("br",{}),"\n",(0,a.jsx)(n.code,{children:"whoCalled: { userName: string, userId: number }?"})]}),"\n",(0,a.jsxs)(n.p,{children:["Returns: ",(0,a.jsx)(n.a,{href:"/VibezAPI/api/VibezAPI#rankResponse",children:"rankResponse"})]}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-lua",children:"local userId = 1\nVibezApi:setRank(1, 2)\n"})}),"\n",(0,a.jsxs)(n.h2,{id:"whats-this-whocalled-parameter",children:["What's this ",(0,a.jsx)(n.code,{children:"whoCalled"})," parameter?"]}),"\n",(0,a.jsxs)(n.p,{children:["Under the hood of the API, we use the ",(0,a.jsx)(n.code,{children:"whoCalled"})," parameter to generate logs within a Discord channel of the action, who did it, and who was affected. ",(0,a.jsx)(n.strong,{children:"THIS PARAMETER IS OPTIONAL"}),". This is useful for auditing purposes, and to see who's abusing the API. If you supply nothing, the wrapper will automatically supply ",(0,a.jsx)(n.strong,{children:"SYSTEM"})," for the username, and the log generated will look different than with a proper user. If you supply a user's ID and name, the log will look like this:"]}),"\n",(0,a.jsx)("img",{src:"/VibezAPI/rankingExampleWithUser.png"}),"\n",(0,a.jsx)(n.p,{children:"If you supply nothing, the log will look like this:"}),"\n",(0,a.jsx)("img",{src:"/VibezAPI/rankingExampleAutomatic.png"}),"\n",(0,a.jsx)(n.h3,{id:"how-would-i-use-this",children:"How would I use this?"}),"\n",(0,a.jsxs)(n.p,{children:["When issuing a function with the wrapper that has this included, just create a new parameter with the ",(0,a.jsx)(n.code,{children:"userName"})," and ",(0,a.jsx)(n.code,{children:"userId"})," keys, and supply the values. Here's an example:"]}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-lua",children:'VibezApi:Promote(1, { userName = "ltsRune", userId = 107392833 })\n'})}),"\n",(0,a.jsx)(n.h2,{id:"why-isnt-it-working",children:"Why isn't it working?"}),"\n",(0,a.jsx)(n.p,{children:"There's many reasons why the ranking API may fail, maybe your discord bot is offline, or maybe the worker is already ranked to the rank you're trying to rank them to. If you're having issues with the ranking API, please join our discord below and ask for help in the support channel."}),"\n",(0,a.jsx)("iframe",{src:"https://discord.com/widget?id=528920896497516554&theme=dark",width:"350",height:"500",allowtransparency:"true",frameborder:"0",sandbox:"allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts"}),"\n",(0,a.jsx)(n.h2,{id:"examples",children:"Examples"}),"\n",(0,a.jsxs)(t,{children:[(0,a.jsx)("summary",{children:"AutoRank Points"}),(0,a.jsx)("br",{}),(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-lua",metastring:'title="ServerScriptService/autoRankPoints.server.lua"',children:'--// Configuration \\\\--\nlocal apiKey = "API KEY" -- Vibez\'s API Key\nlocal pointRanks = {\n\t{ Rank = 2, pointsRequired = 10 }\n}\n\n-- IMPORTANT: Scroll down to line 23 to change the location\n-- of a player\'s points!\n\n--// Services \\\\--\nlocal Players = game:GetService("Players")\nlocal ReplicatedStorage = game:GetService("ReplicatedStorage")\nlocal DataStoreService = game:GetService("DataStoreService")\n\n--// Variables \\\\--\nlocal vibezApi = require(14946453963)(apiKey)\nlocal dataStoreToUse = DataStoreService:GetDataStore("pointRanks_" .. game.PlaceId)\nlocal userCache = {}\n\n--// Functions \\\\--\nlocal function onPlayerAdded(Player: Player)\n\t-- Wherever you\'re keeping your player\'s points, this is where you\'d want to change it.\n\tlocal pointStats = Player:WaitForChild("leaderstats", 120):WaitForChild("Points", 120)\n\n\t-- Don\'t touch below unless you know what you\'re doing.\n\tlocal isOk, data, connections, formattedString\n\tisOk, data = pcall(dataStoreToUse.GetAsync, dataStoreToUse, tostring(Player.UserId))\n\n\tif not isOk then\n\t\treturn\n\tend\n\n\tdata = data or {}\n\tconnections = {}\n\n\ttable.sort(pointRanks, function(a, b)\n\t\treturn a.pointsRequired < b.pointsRequired\n\tend)\n\n\ttable.insert(connections, pointStats:GetPropertyChangedSignal("Value"):Connect(function()\n\t\tlocal userGroupData = vibezApi:_getGroupFromUser(vibezApi.GroupId, Player.UserId)\n\t\tlocal copiedData = userCache[Player.UserId][2] or {}\n\n\t\tif not userGroupData or userGroupData.Rank == 0 then\n\t\t\treturn\n\t\tend\n\n\t\tfor i = 1, #pointRanks do\n\t\t\tlocal data = pointRanks[i]\n\n\t\t\tif\n                table.find(copiedData, data.Rank) ~= nil\n                or userGroupData.Rank >= data.Rank\n                or pointStats.Value < data.pointsRequired\n            then\n\t\t\t\tcontinue\n\t\t\tend\n\n\t\t\tif\n\t\t\t\tuserGroupData.Rank < data.Rank\n\t\t\t\tand pointStats.Value >= data.pointsRequired\n\t\t\tthen\n\t\t\t\tlocal response = vibezApi:setRank(Player, data.Rank)\n\n\t\t\t\tif response.success then\n\t\t\t\t\ttable.insert(copiedData, data.Rank)\n\t\t\t\tend\n\t\t\t\tbreak\n\t\t\tend\n\t\tend\n\n\t\tuserCache[Player.UserId][2] = copiedData\n\tend))\n\n\tuserCache[Player.UserId] = {connections, data}\nend\n\nlocal function onPlayerLeft(Player: Player, retry: number?)\n\tlocal exists = userCache[Player.UserId]\n\tif not exists then\n\t\treturn\n\tend\n\n\tlocal isOk = pcall(dataStoreToUse.SetAsync, dataStoreToUse, tostring(Player.UserId), exists[2])\n\tif not isOk then\n\t\tretry = retry or 0\n\t\tif retry > 3 then\n\t\t\terror("Failed to save data for user " .. Player.Name)\n\t\t\treturn\n\t\tend\n\n\t\ttask.wait(3)\n\t\treturn onPlayerLeft(Player, retry + 1)\n\tend\n\n\tfor _, connection: RBXScriptConnection in pairs(exists[1]) do\n\t\tconnection:Disconnect()\n\tend\n\n\tuserCache[Player.UserId] = nil\nend\n\n--// Events \\\\--\nfor _, v in ipairs(Players:GetPlayers()) do\n\tcoroutine.wrap(onPlayerAdded)(v)\nend\n\nPlayers.PlayerAdded:Connect(onPlayerAdded)\nPlayers.PlayerRemoving:Connect(onPlayerLeft)\n'})})]})]})}function h(e={}){const{wrapper:n}={...(0,s.R)(),...e.components};return n?(0,a.jsx)(n,{...e,children:(0,a.jsx)(c,{...e})}):c(e)}},8453:(e,n,t)=>{t.d(n,{R:()=>i,x:()=>o});var r=t(6540);const a={},s=r.createContext(a);function i(e){const n=r.useContext(s);return r.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function o(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(a):e.components||a:i(e.components),r.createElement(s.Provider,{value:n},e.children)}}}]);