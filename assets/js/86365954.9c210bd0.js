"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[703],{8123:(e,n,t)=>{t.r(n),t.d(n,{assets:()=>d,contentTitle:()=>i,default:()=>h,frontMatter:()=>a,metadata:()=>r,toc:()=>l});const r=JSON.parse('{"id":"Features/Commands/Command Operation Codes","title":"Argument Prefixes","description":"Note: This is considered an advanced tutorial, if you don\'t understand lua/luau, I would not recommend attempting to create your own prefixes!","source":"@site/docs/Features/Commands/Command Operation Codes.md","sourceDirName":"Features/Commands","slug":"/Features/Commands/Command Operation Codes","permalink":"/VibezAPI/docs/Features/Commands/Command Operation Codes","draft":false,"unlisted":false,"editUrl":"https://github.com/ItsRune/VibezAPI/edit/master/docs/Features/Commands/Command Operation Codes.md","tags":[],"version":"current","sidebarPosition":3,"frontMatter":{"sidebar_position":3},"sidebar":"defaultSidebar","previous":{"title":"Adding Commands","permalink":"/VibezAPI/docs/Features/Commands/Adding Commands"},"next":{"title":"Application Center","permalink":"/VibezAPI/docs/Centers/Application Center"}}');var o=t(4848),s=t(8453);const a={sidebar_position:3},i="Argument Prefixes",d={},l=[{value:"What are argument prefixes?",id:"what-are-argument-prefixes",level:3},{value:"Default Codes",id:"default-codes",level:3},{value:"How do they work?",id:"how-do-they-work",level:3},{value:"How to use",id:"how-to-use",level:3},{value:"How to remove operation codes",id:"how-to-remove-operation-codes",level:3}];function c(e){const n={code:"code",h1:"h1",h3:"h3",header:"header",hr:"hr",p:"p",pre:"pre",strong:"strong",table:"table",tbody:"tbody",td:"td",th:"th",thead:"thead",tr:"tr",...(0,s.R)(),...e.components};return(0,o.jsxs)(o.Fragment,{children:[(0,o.jsx)(n.header,{children:(0,o.jsx)(n.h1,{id:"argument-prefixes",children:"Argument Prefixes"})}),"\n",(0,o.jsx)(n.p,{children:(0,o.jsx)(n.strong,{children:"Note: This is considered an advanced tutorial, if you don't understand lua/luau, I would not recommend attempting to create your own prefixes!"})}),"\n",(0,o.jsx)(n.h3,{id:"what-are-argument-prefixes",children:"What are argument prefixes?"}),"\n",(0,o.jsxs)(n.p,{children:["Argument prefixes are ",(0,o.jsx)(n.code,{children:"shorteners"})," that allow you to use less characters when using commands. For example, instead of saying ",(0,o.jsx)(n.code,{children:'game.Teams["myTeam"]'})," as a command argument, you can send ",(0,o.jsx)(n.code,{children:"#myTeam"}),". Operation codes can be anything you'd like, as long as they don't conflict with any other operation codes. We'd also recommend not using ",(0,o.jsx)(n.code,{children:"commas"})," as your operation code, as it will conflict with the existing argument separator."]}),"\n",(0,o.jsx)(n.hr,{}),"\n",(0,o.jsx)(n.h3,{id:"default-codes",children:"Default Codes"}),"\n",(0,o.jsxs)(n.table,{children:[(0,o.jsx)(n.thead,{children:(0,o.jsxs)(n.tr,{children:[(0,o.jsx)(n.th,{style:{textAlign:"center"},children:"Name"}),(0,o.jsx)(n.th,{style:{textAlign:"center"},children:"Prefix"}),(0,o.jsx)(n.th,{style:{textAlign:"center"},children:"Description"})]})}),(0,o.jsxs)(n.tbody,{children:[(0,o.jsxs)(n.tr,{children:[(0,o.jsx)(n.td,{style:{textAlign:"center"},children:"Team"}),(0,o.jsx)(n.td,{style:{textAlign:"center"},children:(0,o.jsx)(n.code,{children:"%"})}),(0,o.jsx)(n.td,{style:{textAlign:"center"},children:"Checks for a given team name"})]}),(0,o.jsxs)(n.tr,{children:[(0,o.jsx)(n.td,{style:{textAlign:"center"},children:"Rank"}),(0,o.jsx)(n.td,{style:{textAlign:"center"},children:(0,o.jsx)(n.code,{children:"r:"})}),(0,o.jsx)(n.td,{style:{textAlign:"center"},children:"Checks the player's rank with a tolerance"})]}),(0,o.jsxs)(n.tr,{children:[(0,o.jsx)(n.td,{style:{textAlign:"center"},children:"shortenedUsername"}),(0,o.jsx)(n.td,{style:{textAlign:"center"},children:"None"}),(0,o.jsx)(n.td,{style:{textAlign:"center"},children:"Checks for a portion of a player's username"})]}),(0,o.jsxs)(n.tr,{children:[(0,o.jsx)(n.td,{style:{textAlign:"center"},children:"External"}),(0,o.jsx)(n.td,{style:{textAlign:"center"},children:(0,o.jsx)(n.code,{children:"e:"})}),(0,o.jsx)(n.td,{style:{textAlign:"center"},children:"Gets a player that is not in the server"})]}),(0,o.jsxs)(n.tr,{children:[(0,o.jsx)(n.td,{style:{textAlign:"center"},children:"UserId"}),(0,o.jsx)(n.td,{style:{textAlign:"center"},children:(0,o.jsx)(n.code,{children:"id:"})}),(0,o.jsx)(n.td,{style:{textAlign:"center"},children:"Gets a player that is not in the server"})]})]})]}),"\n",(0,o.jsx)(n.hr,{}),"\n",(0,o.jsx)(n.h3,{id:"how-do-they-work",children:"How do they work?"}),"\n",(0,o.jsx)(n.p,{children:"Argument prefixes work by first splitting the sent command, then checking if the first argument is an existing prefix. If it is, it will run the prefix's function and return the result. If it isn't, it will return the command argument as is."}),"\n",(0,o.jsx)(n.hr,{}),"\n",(0,o.jsx)(n.h3,{id:"how-to-use",children:"How to use"}),"\n",(0,o.jsxs)(n.p,{children:["To create a new operation code, you'll use the ",(0,o.jsx)(n.code,{children:":addArgumentPrefix"})," method. This method takes ",(0,o.jsx)(n.strong,{children:"three arguments"}),": the operation name, the operation prefix, and the operation function. The operation function must return a ",(0,o.jsx)(n.code,{children:"boolean"})," value, if it does not the operation will not work."]}),"\n",(0,o.jsx)(n.pre,{children:(0,o.jsx)(n.code,{className:"language-lua",children:'local VibezAPI = require(14946453963)("myApiKey")\n\nVibezAPI:addArgumentPrefix("Rank", "r:", function(playerToCheck: Player, incomingArgument: string)\n    -- Operation code is automatically removed from the \'incomingArgument\'.\n    -- incomeArgument would look something like this: "3:<="\n    local rank, tolerance = table.unpack(string.split(incomingArgument, ":"))\n    \n    -- Make sure the rank is a number.\n    if not tonumber(rank) then\n        return false\n    end\n\n    -- Make sure the tolerance is a valid tolerance.\n    tolerance = tolerance or "<="\n\n    -- Convert \'rank\' to a number.\n    rank = tonumber(rank)\n\n    -- \'GetRankInGroup\' caches when it\'s first called, this will not update if their rank changes.\n    local isOk, currentPlayerRank = pcall(\n        playerToCheck.GetRankInGroup,\n        playerToCheck,\n        rank\n    )\n    \n    -- Make sure the player is in the group and their rank was fetched.\n    if not isOk or currentPlayerRank == 0 then\n        return false\n    end\n\n    -- Check the tolerances\n    if tolerance == "<=" then\n        return currentPlayerRank <= rank\n    elseif tolerance == ">=" then\n        return currentPlayerRank >= rank\n    elseif tolerance == "<" then\n        return currentPlayerRank < rank\n    elseif tolerance == ">" then\n        return currentPlayerRank > rank\n    elseif tolerance == "==" then\n        return currentPlayerRank == rank\n    end\n\n    -- If the tolerance is invalid, return false.\n    return false\nend)\n'})}),"\n",(0,o.jsxs)(n.p,{children:["Now, you can use the operation code in your commands: ",(0,o.jsx)(n.code,{children:"!promote r:3:<="})]}),"\n",(0,o.jsx)(n.hr,{}),"\n",(0,o.jsx)(n.h3,{id:"how-to-remove-operation-codes",children:"How to remove operation codes"}),"\n",(0,o.jsxs)(n.p,{children:["To remove an operation code, you'll use the ",(0,o.jsx)(n.code,{children:":removeArgumentPrefix"})," method. This method takes ",(0,o.jsx)(n.strong,{children:"one argument"}),": the operation name. If you don't like how one operation code performs that was made by us, you can simply remove it."]}),"\n",(0,o.jsx)(n.pre,{children:(0,o.jsx)(n.code,{className:"language-lua",children:'VibezAPI:removeArgumentPrefix("Rank") -- Removes the default rank operation code.\n'})})]})}function h(e={}){const{wrapper:n}={...(0,s.R)(),...e.components};return n?(0,o.jsx)(n,{...e,children:(0,o.jsx)(c,{...e})}):c(e)}},8453:(e,n,t)=>{t.d(n,{R:()=>a,x:()=>i});var r=t(6540);const o={},s=r.createContext(o);function a(e){const n=r.useContext(s);return r.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function i(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(o):e.components||o:a(e.components),r.createElement(s.Provider,{value:n},e.children)}}}]);