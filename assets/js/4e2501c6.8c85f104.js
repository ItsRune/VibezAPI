"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[837],{3905:(e,n,o)=>{o.d(n,{Zo:()=>p,kt:()=>g});var t=o(67294);function r(e,n,o){return n in e?Object.defineProperty(e,n,{value:o,enumerable:!0,configurable:!0,writable:!0}):e[n]=o,e}function a(e,n){var o=Object.keys(e);if(Object.getOwnPropertySymbols){var t=Object.getOwnPropertySymbols(e);n&&(t=t.filter((function(n){return Object.getOwnPropertyDescriptor(e,n).enumerable}))),o.push.apply(o,t)}return o}function l(e){for(var n=1;n<arguments.length;n++){var o=null!=arguments[n]?arguments[n]:{};n%2?a(Object(o),!0).forEach((function(n){r(e,n,o[n])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(o)):a(Object(o)).forEach((function(n){Object.defineProperty(e,n,Object.getOwnPropertyDescriptor(o,n))}))}return e}function i(e,n){if(null==e)return{};var o,t,r=function(e,n){if(null==e)return{};var o,t,r={},a=Object.keys(e);for(t=0;t<a.length;t++)o=a[t],n.indexOf(o)>=0||(r[o]=e[o]);return r}(e,n);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);for(t=0;t<a.length;t++)o=a[t],n.indexOf(o)>=0||Object.prototype.propertyIsEnumerable.call(e,o)&&(r[o]=e[o])}return r}var s=t.createContext({}),c=function(e){var n=t.useContext(s),o=n;return e&&(o="function"==typeof e?e(n):l(l({},n),e)),o},p=function(e){var n=c(e.components);return t.createElement(s.Provider,{value:n},e.children)},d="mdxType",u={inlineCode:"code",wrapper:function(e){var n=e.children;return t.createElement(t.Fragment,{},n)}},m=t.forwardRef((function(e,n){var o=e.components,r=e.mdxType,a=e.originalType,s=e.parentName,p=i(e,["components","mdxType","originalType","parentName"]),d=c(o),m=r,g=d["".concat(s,".").concat(m)]||d[m]||u[m]||a;return o?t.createElement(g,l(l({ref:n},p),{},{components:o})):t.createElement(g,l({ref:n},p))}));function g(e,n){var o=arguments,r=n&&n.mdxType;if("string"==typeof e||r){var a=o.length,l=new Array(a);l[0]=m;var i={};for(var s in n)hasOwnProperty.call(n,s)&&(i[s]=n[s]);i.originalType=e,i[d]="string"==typeof e?e:r,l[1]=i;for(var c=2;c<a;c++)l[c]=o[c];return t.createElement.apply(null,l)}return t.createElement.apply(null,o)}m.displayName="MDXCreateElement"},76221:(e,n,o)=>{o.r(n),o.d(n,{assets:()=>s,contentTitle:()=>l,default:()=>u,frontMatter:()=>a,metadata:()=>i,toc:()=>c});var t=o(87462),r=(o(67294),o(3905));const a={"sidebar-position":10},l=void 0,i={unversionedId:"Examples/Webhooks",id:"Examples/Webhooks",title:"Webhooks",description:"Colors",source:"@site/docs/Examples/Webhooks.md",sourceDirName:"Examples",slug:"/Examples/Webhooks",permalink:"/VibezAPI/docs/Examples/Webhooks",draft:!1,editUrl:"https://github.com/ItsRune/VibezAPI/edit/master/docs/Examples/Webhooks.md",tags:[],version:"current",frontMatter:{"sidebar-position":10},sidebar:"defaultSidebar",previous:{title:"Ranking",permalink:"/VibezAPI/docs/Examples/Ranking"}},s={},c=[{value:"Colors",id:"colors",level:3},{value:"Logs",id:"logs",level:2},{value:"Join Logs",id:"join-logs",level:3},{value:"Leave Logs",id:"leave-logs",level:3},{value:"Message Logs",id:"message-logs",level:3}],p={toc:c},d="wrapper";function u(e){let{components:n,...o}=e;return(0,r.kt)(d,(0,t.Z)({},p,o,{components:n,mdxType:"MDXLayout"}),(0,r.kt)("h3",{id:"colors"},"Colors"),(0,r.kt)("p",null,"Typically you would use a hexidecimal color code for the color parameter, but you can also use a ",(0,r.kt)("inlineCode",{parentName:"p"},"Color3")," value. ",(0,r.kt)("strong",{parentName:"p"},"Only works for ",(0,r.kt)("inlineCode",{parentName:"strong"},"addEmbedWithBuilder"))),(0,r.kt)("h4",null,"Preview:"),(0,r.kt)("img",{src:"/VibezAPI/color3WebhookExample.png"}),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local Vibez = require(14946453963)("API Key", {\n    nameOfGameForLogging = "Colors Example"\n})\n\nlocal webhook = Vibez:getWebhookBuilder("https://discord.com/api/webhooks/")\nwebhook:addEmbedWithBuilder(function(embed)\n    return embed\n        :setColor(Color3.fromRGB(255, 125, 255)) -- Light pink\n        :setTitle("Color3 Example")\n        :setDescription("This is an example of using a Color3 value for the color parameter.")\nend):Send()\n')),(0,r.kt)("h2",{id:"logs"},"Logs"),(0,r.kt)("p",null,"For any kind of logs that require an on server start-up event, you should use ",(0,r.kt)("inlineCode",{parentName:"p"},":waitUntilLoaded()")," to ensure that the API is loaded before you try to use it. You also have to set ",(0,r.kt)("inlineCode",{parentName:"p"},"isAsync")," to ",(0,r.kt)("inlineCode",{parentName:"p"},"true")," in the API settings."),(0,r.kt)("h3",{id:"join-logs"},"Join Logs"),(0,r.kt)("h4",null,"Preview:"),(0,r.kt)("img",{src:"/VibezAPI/joinLogExample.png"}),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local Players = game:GetService("Players")\nlocal Vibez = require(14946453963)("API Key", {\n    isAsync = true\n})\n\nPlayers.PlayerAdded:Connect(function(Player)\n    local api = Vibez:waitUntilLoaded()\n    if api == nil then\n        error("API Failed to load!")\n    end\n\n    local webhook = api:getWebhookBuilder("https://discord.com/api/webhooks/")\n    webhook:setContent(\n        `[**{Player.Name}**](<https://roblox.com/users/{Player.UserId}/profile>) has joined the game!`\n    ):Send()\nend)\n')),(0,r.kt)("h3",{id:"leave-logs"},"Leave Logs"),(0,r.kt)("h4",null,"Preview:"),(0,r.kt)("img",{src:"/VibezAPI/leaveLogExample.png"}),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local Players = game:GetService("Players")\nlocal Vibez = require(14946453963)("API Key", {\n    isAsync = true\n})\n\nPlayers.PlayerRemoving:Connect(function(Player)\n    local api = Vibez:waitUntilLoaded()\n    if api == nil then\n        error("API Failed to load!")\n    end\n\n    local webhook = api:getWebhookBuilder("https://discord.com/api/webhooks/")\n    webhook:setContent(\n        `[**{Player.Name}**](<https://roblox.com/users/{Player.UserId}/profile>) has left the game!`\n    ):Send()\nend)\n')),(0,r.kt)("h3",{id:"message-logs"},"Message Logs"),(0,r.kt)("h4",null,"Preview:"),(0,r.kt)("img",{src:"/VibezAPI/messageLogExample.png"}),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local Players = game:GetService("Players")\nlocal Vibez = require(14946453963)("API Key", {\n    isAsync = true\n})\n\nPlayers.PlayerAdded:Connect(function(Player)\n    local api = Vibez:waitUntilLoaded()\n    if api == nil then\n        error("API Failed to load!")\n    end\n\n    Player.Chatted:Connect(function(Message: string)\n        local webhook = api:getWebhookBuilder("https://discord.com/api/webhooks/")\n        webhook:setContent(\n            `\\[[**{Player.Name}**](<https://roblox.com/users/{Player.UserId}/profile>)\\]: {Message}`\n        ):Send()\n    end)\nend)\n')))}u.isMDXComponent=!0}}]);